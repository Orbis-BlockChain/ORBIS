unit App.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
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
  UI.GUI,
  Wallet.Core,
  Consesus.Core.TonyEdition;

type
  TAppCore = class(TInterfacedObject, IAppCore)
  private
    isTerminate: boolean;
    UI: TBaseUI;
    BlockChain: TBlockChainCore;
    Net: TNetCore;
    WebServer: TWebServer;
    HandlerCore: THandlerCore;
    WalletCore: TWalletCore;
    ConsensusCore: TConsensusCore;
    Config: TConfig;
    Log: TLogs;
    { Procedures }
    procedure AppException(Sender: TObject);
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
begin
{$IFDEF GUII}
  UI := TGUI.Create;
{$ELSE}
  UI := TConsoleUI.Create;
{$ENDIF}
  NodeState := Invalid;
  ApplicationHandleException := AppException;
  Config := TConfig.Create;
  ShowMessage(GetTextGreeting(English));
  ShowMessage(Carriage);
  if not Config.DoConfigurate then
  begin
    Config.Destroy;
    UI.Free;
    ShowMessage('System: Error, badconfig');
    ShowMessage('System: Press any key...');
    Readln;
    exit;
  end;
  AutoConnect := True;
  Notifyer := TNotifyer.Create;
  ShowMessage(#13#10);
  AppLog := TLogs.Create('app', Paths.GetPathLog);
  NetLog := TLogs.Create('net', Paths.GetPathLog);
  BlockChainLog := TLogs.Create('bc', Paths.GetPathLog);

  BlockChain := TBlockChainCore.Create;
  HandlerCore := THandlerCore.Create;
  Net := TNetCore.Create(HandlerCore, Config.ConnectTo, Config.ApprovedConnections);
  WebServer := TWebServer.Create(HandlerCore);
  WalletCore := TWalletCore.Create;
  ConsensusCore := TConsensusCore.Create(Net,BlockChain,WalletCore,UI,Config,HandlerCore);
  NetState := Config.TypeNet;
  NodeState := Invalid;
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
      Readln;
    end;
  end
  else
    System.SysUtils.ShowException(O, ExceptAddr);
end;

destructor TAppCore.Destroy;
begin

{$IFDEF GUII}
  TGUI(UI).Destroy;
{$ENDIF}
{$IFDEF CONSOLEI}
  TConsoleUI(UI).Destroy;
{$ENDIF}
  ConsensusCore.Free;
  BlockChain.Free;
  Net.Stop;
  Net.Free;
  WebServer.Free;
  HandlerCore := nil;
  WalletCore.Free;
  Config.Free;
  AppLog.Free;
  NetLog.Free;
  BlockChainLog.Free;
  Paths := nil;
  Notifyer.Free;
  inherited;
end;

procedure TAppCore.DoRun;
begin
{$IFDEF GUII}
  TGUI(UI).DoRun;
{$ENDIF}
{$IFDEF CONSOLEI}
  TConsoleUI(UI).DoRun;
{$ENDIF}
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
  TThread.Synchronize(nil,
    procedure
    begin
      try
          Writeln(FormatDateTime('[hh:nn:ss.zzz] ', Now()) + AMessage);
      except

      end;
    end);
{$ENDIF}
end;

procedure TAppCore.Terminate;
begin
  isTerminate := True;
end;

end.
