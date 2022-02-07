unit WebServer.HTTPCore;

interface

uses
  BlockChain.Core,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Threading,
  System.Net.Socket,
  System.Generics.Collections,
  System.SyncObjs,
  App.Log,
  App.Types,
  WebServer.HTTPConnectedClient,
  App.IHandlerCore,
  Net.ConnectedClient,
  WebServer.HTTPServer;
//  WebServer.DataControl;

type

  TWebServer = class
  private
    Log: TLogs;
    Server: THTTPServer;
    FHandler: IBaseHandler;
    Request: String;
    NeedDestroySelf: Boolean;
    procedure Handle(From: THTTPConnectedClient; AData: TBytes);
    procedure NewConHandle(SocketIP: String);
    procedure DiscClientHandle(SocketIP: String);
    procedure DeleteConnectedClient(AID: integer; State: integer);
    function GetServerStatus: Boolean;
    function GetFreeArraySell: integer;
  public
    ConnectedClients: TArray<THTTPConnectedClient>;
    constructor Create(const AHandler: IBaseHandler);
    property ServerStarted: Boolean read GetServerStatus;
    property Handler: IBaseHandler read FHandler write FHandler;
    property DestroyNetCore: Boolean write NeedDestroySelf;
    // function DoApiRequest(Request: TRequest; Response: TResponse): Boolean;
    procedure Start(APort: word);
    procedure Stop;
    function IsActive: Boolean;
    destructor Destroy; override;
  end;

implementation

{ TWebServer }

constructor TWebServer.Create(const AHandler: IBaseHandler);
var
  id: integer;
begin
  Log := TLogs.Create('WebServer', Paths.GetPathLog);
  Log.DoStartProcedure(ClassName + '.' + 'Create');
  Request := '';
  NeedDestroySelf := False;
  SetLength(ConnectedClients, 0);
  Server := THTTPServer.Create;
  FHandler := AHandler;
  Server.AcceptHandle := (
    procedure(ConnectedCli: THTTPConnectedClient)
    begin
      ConnectedCli.Handle := Handle;
      id := GetFreeArraySell;
      ConnectedCli.IdInArray := id;
      ConnectedCli.AfterDisconnect := DeleteConnectedClient;
      ConnectedClients[id] := ConnectedCli;
    end);
  Server.NewConnectHandle := NewConHandle;
  Log.DoEndProcedure(ClassName + '.' + 'Create');
end;

procedure TWebServer.DeleteConnectedClient(AID: integer; State: integer);
begin
  Log.DoStartProcedure(ClassName + '.' + 'DeleteConnectedClient');
  DiscClientHandle(ConnectedClients[AID].GetSocketIP);
  ConnectedClients[AID] := nil;
  Log.DoEndProcedure(ClassName + '.' + 'DeleteConnectedClient');
end;

destructor TWebServer.Destroy;
begin
  Log.DoStartProcedure(ClassName + '.' + 'Destroy');
  Server.Free;
  SetLength(ConnectedClients, 0);
  Log.DoEndProcedure(ClassName + '.' + 'Destroy');
  Log.Free;
end;

procedure TWebServer.DiscClientHandle(SocketIP: String);
begin
  Log.DoStartProcedure(ClassName + '.' + 'DiscClientHandle');
  FHandler.HandleDisconnectClient(SocketIP);
  Log.DoEndProcedure(ClassName + '.' + 'DiscClientHandle');
end;

function TWebServer.GetFreeArraySell: integer;
var
  i, len: integer;
begin
  Log.DoStartProcedure(ClassName + '.' + 'GetFreeArraySell');
  len := Length(ConnectedClients);
  Result := len;
  for i := 0 to len - 1 do
    if (ConnectedClients[i] = nil) then
    begin
      Result := i;
      exit;
    end;
  SetLength(ConnectedClients, len + 1);
  Log.DoEndProcedure(ClassName + '.' + 'GetFreeArraySell');
end;

function TWebServer.GetServerStatus: Boolean;
begin
  GetServerStatus := Server.IsActive;
end;

procedure TWebServer.Handle(From: THTTPConnectedClient; AData: TBytes);
begin
  FHandler.HandleReceiveHTTPData(From, AData);
end;

function TWebServer.IsActive: Boolean;
begin
  Log.DoStartProcedure(ClassName + '.' + 'IsActive');
  Result := Server.IsActive;
  Log.DoEndProcedure(ClassName + '.' + 'IsActive');
end;

procedure TWebServer.NewConHandle(SocketIP: String);
begin
  Log.DoStartProcedure(ClassName + '.' + 'NewConHandle');
  FHandler.HandleConnectClient(SocketIP);
  Log.DoEndProcedure(ClassName + '.' + 'NewConHandle');
end;

procedure TWebServer.Start(APort: word);
begin
  Log.DoStartProcedure(ClassName + '.' + 'Start');
  Server.Start('0.0.0.0', APort);
  Log.DoEndProcedure(ClassName + '.' + 'Start');
end;

procedure TWebServer.Stop;
var
  i: integer;
begin
  Log.DoStartProcedure(ClassName + '.' + 'Stop');
  for i := 0 to Length(ConnectedClients) - 1 do
    if (ConnectedClients[i] <> nil) then
      ConnectedClients[i].Disconnect;

  Server.Stop;

  Log.DoEndProcedure(ClassName + '.' + 'Stop');
  if NeedDestroySelf then
end;

end.

