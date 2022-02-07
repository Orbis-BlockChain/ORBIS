unit App.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  App.FileLocker,
  App.Types,
  App.Notifyer,
  App.Abstractions,
  App.HandlerCore,
  App.Config,
  App.Paths,
  App.Log,
  App.Meta,
  App.IHandlerCore,
  App.Globals,
  BlockChain.Core,
  Net.Core,
  WebServer.HTTPCore,
  UI.Abstractions,
  UI.CommandLineParser,
  UI.ConsoleUI,
{$IFDEF GUII}
  UI.GUI,
{$ENDIF}
  Wallet.Core,
  Updater.Core,
  Consensus2.Core;

type
  TAppCore = class(TInterfacedObject, IAppCore)
  private
    fileLocsker: TFileLocker;
    isTerminate: boolean;
    isCanDoRun: boolean;
    UI: TBaseUI;
    BlockChain: TBlockChainCore;
    Net: TNetCore;
    WebServer: TWebServer;
    HandlerCore: THandlerCore;
    WalletCore: TWalletCore;
    ConsensusCore: TConsensusCore2;
    Config: TConfig;
    Log: TLogs;
    Updater: TUpdaterCore;
    { Procedures }
    procedure AppException(Sender: TObject);

    procedure DoConnect(AClient: TClient1);
    procedure DoDisconnect(AClient: TClient1);
  public
    procedure Terminate;
    procedure DoRun;
    procedure ShowMessage(AMessage: string);
    procedure ShowForm(AType: Byte; AArgs: TArray<string>);
    function GetHandler: IBaseHandler;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TAppCore }

constructor TAppCore.Create;
var
  ErrorCode: integer;
  ErrorMessage: string;
begin
  isCanDoRun := True;
  Notifyer := TNotifyer.Create;
{$IFDEF GUII}
  UI := TGUI.Create;
{$ELSE}
  UI := TConsoleUI.Create;
{$ENDIF}
  Config := TConfig.Create;
  CurrentLanguage := Config.Language;
  if not Config.DoConfigurate then
  begin
    Config.Destroy;
    UI.Free;
    ShowMessage('System: Error, badconfig');
    ShowMessage('System: Press any key...');
    Readln;
    exit;
  end;
{$IFDEF GUII}
  Updater := TUpdaterCore.Create(GetVersion);
  if Updater.needTreminte(ErrorCode, ErrorMessage) then
  begin
    if ErrorCode = -1 then
    begin
      HandlerCore := THandlerCore.Create;
      HandlerCore.UpdaterCore := Updater;
      HandlerCore.UI := UI;

      UI.DoUpdate;

    end
    else
    begin
      isCanDoRun := False;
      UI.ShowMessage(ErrorMessage);
    end;
    exit;
  end;
  Updater.StartAutoUpdate;
{$ENDIF}
  fileLocsker := TFileLocker.Create(Config.ConfigDirectory);
  if not fileLocsker.TryTakeDescriptor then
  begin
    isCanDoRun := False;
    exit;
  end;

  ShowMessage(GetEnumName(TypeInfo(TNET), ord(Config.TypeNet)));
  ShowMessage(Config.ServerPort.ToString);
  ShowMessage(Config.ClientPort.ToString);
  ShowMessage(Config.WebServerPort.ToString);
  ShowMessage(Config.StaticIP);

  MyClientsLog := TLogs.Create('MyClientsLog.log', Paths.GetPathLog);
  ConnectedClientsLog := TLogs.Create('ConnectedClients.log', Paths.GetPathLog);
  BlockChainLogs := TLogs.Create('BlockChainLogs.log', Paths.GetPathLog);
  HTTPLog := TLogs.Create('HTTPLog.log', Paths.GetPathLog);
  WebServerLog := TLogs.Create('WebServer.log', Paths.GetPathLog);
  ConsensusLog := TLogs.Create('Consensus.log', Paths.GetPathLog);
  WalletCoreLog := TLogs.Create('WalletCore.log', Paths.GetPathLog);

  NodeState := Invalid;
  NetState := Config.TypeNet;
  ApplicationHandleException := AppException;

  ShowMessage(GetTextGreeting(English));
  ShowMessage(Carriage);

  AutoConnect := True;
  BlockChain := TBlockChainCore.Create;
  HandlerCore := THandlerCore.Create;
  Net := TNetCore.Create(HandlerCore, Config.ConnectTo, Config.ApprovedConnections);
  Net.OnConnect := DoConnect;
  Net.OnDisconnectE := DoDisconnect;
  WebServer := TWebServer.Create(HandlerCore);
  WalletCore := TWalletCore.Create;
  NetState := Config.TypeNet;
  NodeState := Invalid;
  ConsensusCore := TConsensusCore2.Create(Net, BlockChain, WalletCore, UI, Config, HandlerCore);
  HandlerCore.BlockChain := BlockChain;
  HandlerCore.UI := UI;
  HandlerCore.Net := Net;
  HandlerCore.WalletCore := WalletCore;
  HandlerCore.WebServer := WebServer;
  HandlerCore.Config := Config;
  HandlerCore.ConsensusCore := ConsensusCore;
  Handler := HandlerCore;
  UI.ShowMessage := ShowMessage;
  UI.Handler := HandlerCore;
end;

procedure TAppCore.AppException(Sender: TObject);
var
  O: TObject;
begin
  O := ExceptObject;
  if O is Exception then
  begin
    if not(O is EAbort) then
    begin
      ShowMessage(Exception(O).Message);
    end;
  end
  else
    System.SysUtils.ShowException(O, ExceptAddr);
end;

destructor TAppCore.Destroy;
begin
  fileLocsker.FreeDescriptor;
  fileLocsker.Free;
{$IFDEF GUII}
  TGUI(UI).Free;
{$ENDIF}
{$IFDEF CONSOLEI}
  TConsoleUI(UI).Free;
{$ENDIF}
  ConsensusCore.Free;
  BlockChain.Free;
  Net.Free;
  WebServer.Free;
  HandlerCore := nil;
  WalletCore.Free;
  Config.Free;
  Paths := nil;
  Notifyer.Free;
{$IFDEF GUII}
  Updater.Free;
{$ENDIF}
  MyClientsLog.Free;
  ConnectedClientsLog.Free;
  BlockChainLogs.Free;
  HTTPLog.Free;
  WebServerLog.Free;
  ConsensusLog.Free;
  WalletCoreLog.Free;
end;

procedure TAppCore.DoConnect(AClient: TClient1);
begin
  ShowMessage('TAppCore.DoConnect: ' + AClient.IPv4 + ':' + AClient.Port.ToString + ' IDNode: ' + AClient.IDNode.AsString);
  if Assigned(ConsensusCore) then
  begin
    ShowMessage('TAppCore.DoConnect: Assigned(ConsensusCore)');
    ConsensusCore.EventConnect(AClient);
    HandlerCore.DoSendStartPacket;

  end
  else
  begin
    ShowMessage('TAppCore.DoConnect: not Assigned(ConsensusCore)');
  end;
end;

procedure TAppCore.DoDisconnect(AClient: TClient1);
begin
  ShowMessage('TAppCore.DoDisconnect: ' + AClient.IPv4 + ':' + AClient.Port.ToString);
  if Assigned(ConsensusCore) then
    ConsensusCore.EventDisconnect(AClient);
end;

procedure TAppCore.DoRun;
begin
  if isCanDoRun then
  begin
{$IFDEF GUII}
    TGUI(UI).DoRun;
{$ENDIF}
{$IFDEF CONSOLEI}
    TConsoleUI(UI).DoRun;
{$ENDIF}
  end;
end;

function TAppCore.GetHandler: IBaseHandler;
begin
  Result := HandlerCore;
end;

procedure TAppCore.ShowForm(AType: Byte; AArgs: TArray<string>);
begin
{$IFDEF GUII}
  UI.ShowForm(AType, AArgs);
{$ENDIF}
end;

procedure TAppCore.ShowMessage(AMessage: string);
begin
{$IFDEF CONSOLEI}
  TThread.Queue(nil,
    procedure()
    begin
      if AMessage.Length > 0 then
      begin
        if AMessage.Chars[0] = '=' then
          Writeln(AMessage)
        else
          Writeln(FormatDateTime('[hh:nn:ss.zzz] ', Now) + AMessage);
      end;
    end);
{$ENDIF}
end;

procedure TAppCore.Terminate;
begin
  isTerminate := True;
end;

end.
