unit WebServer.WebAppCore;

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
  Wallet.Core;

type
  TWebAppCore = class(TInterfacedObject, IAppCore)
  private
    BlockChain: TBlockChainCore;
    Net: TNetCore;
    WebServer: TWebServer;
    HandlerCore: THandlerCore;
    WalletCore: TWalletCore;
    Config: TConfig;
    Log: TLogs;
  public
    function GetHandler: IBaseHandler;
    procedure DoRun;
    procedure ShowForm(AType: Byte; AArgs: TArray<string>);
    constructor Create;
    destructor Destroy; override;
    property WS: TWebServer read WebServer write WebServer;
    property WC: TWalletCore read WalletCore;
//    property NC: TNetCore read Net write Net;
  end;

implementation

{ TWebAppCore }

constructor TWebAppCore.Create;
begin
  Config := TConfig.Create;
  if not Config.DoConfigurate then
  begin
    Config.Destroy;
    Readln;
    exit;
  end;
  AutoConnect := True;
  Notifyer := TNotifyer.Create;
  AppLog := TLogs.Create('app', Paths.GetPathLog);
  NetLog := TLogs.Create('net', Paths.GetPathLog);
  BlockChainLog := TLogs.Create('bc', Paths.GetPathLog);

  BlockChain := TBlockChainCore.Create;
  HandlerCore := THandlerCore.Create;
  Net := TNetCore.Create(HandlerCore, Config.ConnectTo,Config.ApprovedConnections);
  WebServer := TWebServer.Create(HandlerCore);
  WalletCore := TWalletCore.Create;
{$IFDEF GUII}
  NodeState := FullNode;
{$ELSE}
  NodeState := Config.NodeState;
  var flag: boolean := WalletCore.OpenWallet(Config.WalletName, Config.WalletPassword);
  if not BlockChain.Inquiries.CheckAddress(Config.WalletName) then
    flag := False
  else
    WalletID := BlockChain.Inquiries.TryGetAccountID(Config.WalletName);

  if not flag then
    NodeState := FullNode;

{$ENDIF}

  HandlerCore.BlockChain := BlockChain;
  HandlerCore.Net := Net;
  HandlerCore.WalletCore := WalletCore;
  HandlerCore.WebServer := WebServer;
  HandlerCore.Config := Config;

  FWallet := WalletCore;
  Handler := HandlerCore;
end;

destructor TWebAppCore.Destroy;
begin
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

procedure TWebAppCore.DoRun;
begin

end;

function TWebAppCore.GetHandler: IBaseHandler;
begin
  Result := HandlerCore;
end;

procedure TWebAppCore.ShowForm(AType: Byte; AArgs: TArray<string>);
begin

end;

end.
