unit Net.Core;

interface

uses
  App.IHandlerCore,
  App.Types,
  App.Packet,
  Net.Server,
  Net.ConnectedClient,
  Net.Client,
  Net.Types,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Threading,
  System.Net.Socket,
  System.Generics.Collections;
{$RTTI EXPLICIT METHODS([vcPrivate])}


type
  TNetCore = class
  private
    NodesHosts: TArray<string>;
    ApprovedConnections: TArray<string>;
    Server: TServer;
    FMainClient: TClient;
    FHandler: IBaseHandler;
    NeedDestroySelf: Boolean;
    BanList: TThreadList<string>;
    procedure Handle(From: TConnectedClient; AData: TBytes);
    procedure NewConHandle(SocketIP: String);
    procedure DeleteConnectedClient(AID: integer; state: integer);
    function GetServerStatus: Boolean;
    function GetFreeArraySell: uint64;
    function Checks(AIP: string): Boolean;
    procedure NilConClient(arg: Boolean);
  public
    ConnectedClients: TArray<TConnectedClient>;
    Clients: TArray<TClient>;
    property ServerStarted: Boolean read GetServerStatus;
    property Handler: IBaseHandler read FHandler write FHandler;
    property MainClient: TClient read FMainClient write FMainClient;
    property DestroyNetCore: Boolean write NeedDestroySelf;
    procedure Start(AID: Int64; AServerPort, AClientPort: Word);
    procedure Stop;
    function NewValidatorClient(AIP: string; APort: Word; AID: uint64): TClient;
    function SendPacket(const Buf: TBytes): integer;
    function ConnectToValidator(AID: uint64; ARemoteAddress: string; ARemotePort: Word): TClient;
    function ChangeMainClient(AID: uint64; RemoteAddress: string; ARemotePort: Word): Boolean;
    procedure SendAll(const Buf: TBytes);
    procedure SendAllMy(const Buf: TBytes);
    procedure SendAll2(const Buf: TBytes);
    constructor Create(AHandler: IBaseHandler; ANodesHosts, ApprovedConnectedIPs: TArray<string>);
    destructor Destroy; override;
  end;

implementation

{$REGION 'TNetCore'}


function TNetCore.ChangeMainClient(AID: uint64; RemoteAddress: string; ARemotePort: Word): Boolean;
var
  Client: TClient;
begin
  MainClient.Disconnect;
  Client := TClient.Create(Handler, AID);
  Result := Client.TryConnect(RemoteAddress, ARemotePort);
  if Result then
  begin
    Clients := Clients + [Client];
    MainClient :=  Client;
  end;

end;

function TNetCore.Checks(AIP: string): Boolean;
var
  ip: string;
begin
  Result := False;

  if Length(ApprovedConnections) > 0 then
  begin
    for ip in ApprovedConnections do
    begin
      if AIP = ip then
      begin
        Result := True;
        break;
      end;
    end
  end
  else
    Result := True;

  if Result then
    try
      if (BanList.LockList.IndexOf(AIP) = -1) then
        Result := True
      else
        Result := False;
    finally

      BanList.UnlockList;
    end;
end;

function TNetCore.ConnectToValidator(AID: uint64; ARemoteAddress: string; ARemotePort: Word): TClient;
var
  i: integer;
  Client: TClient;
begin
  Result := nil;

  for i := 0 to Length(Clients) - 1 do
  begin
    if Assigned(Clients[i]) then
      if (Clients[i].IDNode = AID)
      or ((Clients[i].IDNode = 0) and (Clients[i].IPv4 = ARemoteAddress) and (Clients[i].Port = ARemotePort))
      then
      begin
        if (Clients[i].IDNode = 0) then
          Clients[i].IDNode := AID;

        Result := Clients[i];
        Client := Clients[i];
        if not Client.Connected then
        begin
          if Client.TryConnect(ARemoteAddress, ARemotePort) then
          begin
            Client.SendMessage([0, 0, 0, 0, 0, 0, 0, 0, 0]);
            Result := Client;
          end
          else
            Client.Destroy;
        end;
        Exit;
      end;
  end;

  Client := TClient.Create(FHandler, AID);
  Client.BeforeDestroy := NilConClient;
  if Client.TryConnect(ARemoteAddress, ARemotePort) then
  begin
    Client.SendMessage([0, 0, 0, 0, 0, 0, 0, 0, 0]);
    Clients := Clients + [Client];
    Result := Client;
  end
  else
    Client.Destroy;
end;

constructor TNetCore.Create(AHandler: IBaseHandler; ANodesHosts, ApprovedConnectedIPs: TArray<string>);
var
  id: uint64;
begin
  BanList := TThreadList<string>.Create;
  NodesHosts := ANodesHosts;
  ApprovedConnections := ApprovedConnectedIPs;
  NeedDestroySelf := False;
  SetLength(ConnectedClients, 0);
  Server := TServer.Create;
  FHandler := AHandler;
  Server.Checks := Checks;
  Server.AcceptHandle := (
    procedure(ConnectedCli: TConnectedClient)
    begin
      ConnectedCli.Handle := Handle;
      id := GetFreeArraySell;
      ConnectedCli.IdInArray := id;
      ConnectedCli.AfterDisconnect := DeleteConnectedClient;
      ConnectedClients[id] := ConnectedCli;
    end);
  Server.NewConnectHandle := NewConHandle;
end;

procedure TNetCore.DeleteConnectedClient(AID: integer; state: integer);
begin
  try
    if state = -1 then
      BanList.Add(ConnectedClients[AID].GetSocketIP);

  finally
    ConnectedClients[AID] := nil;
  end;
end;

destructor TNetCore.Destroy;
begin
  BanList.Destroy;

  Server.Free;
  if Assigned(MainClient) then
    MainClient.Disconnect;
  SetLength(ConnectedClients, 0);
  SetLength(Clients, 0);
end;

function TNetCore.GetFreeArraySell: uint64;
var
  i, len: integer;
begin
  len := Length(ConnectedClients);
  Result := len;
  for i := 0 to len - 1 do
    if (ConnectedClients[i] = nil) then
    begin
      Result := i;
      Exit;
    end;
  SetLength(ConnectedClients, len + 1);
end;

function TNetCore.GetServerStatus: Boolean;
begin
  GetServerStatus := Server.IsActive;
end;

procedure TNetCore.Handle(From: TConnectedClient; AData: TBytes);
begin
  FHandler.HandleReceiveTCPData(From, AData);
end;

procedure TNetCore.NewConHandle(SocketIP: String);
begin
  FHandler.HandleConnectClient(SocketIP);
end;

function TNetCore.NewValidatorClient(AIP: string; APort: Word; AID: uint64): TClient;
var
  Client: TClient;
begin
  Client := TClient.Create(Handler, AID);
  Client.NeedDestroy := True;
  Client.TryConnect(AIP, APort);

  var Packet: TPacket;
  Packet.CreatePacket(CMD_REQUEST_AUTH, []);
  Client.SendMessage(Packet);

  Clients := Clients + [Client];
  Result := Client;
end;

procedure TNetCore.NilConClient(arg: Boolean);
begin
  MainClient := nil;
end;

procedure TNetCore.SendAll(const Buf: TBytes);
var
  Cli: TConnectedClient;
begin
  for Cli in ConnectedClients do
    try
      if (Cli.SocketIP <> '127.0.0.1') and (Cli.SocketIP <> '') then
        Cli.SendMessage(Buf);

    except
      NetLog.DoError('TNetCore.SendAll', 'ERROR: Cant send message to CLI');
    end;
end;

procedure TNetCore.SendAll2(const Buf: TBytes);
begin

end;

procedure TNetCore.SendAllMy(const Buf: TBytes);
var
  Cli: TClient;
begin
  for Cli in CLients do
    try
      if (Cli.GetIP <> '127.0.0.1') and (Cli.GetIP <> '') then
        Cli.SendMessage(Buf);

    except
      NetLog.DoError('TNetCore.SendAll', 'ERROR: Cant send message to CLI');
    end;
end;

function TNetCore.SendPacket(const Buf: TBytes): integer;
begin
  Result := MainClient.SendMessage(Buf);
end;

procedure TNetCore.Start(AID: Int64; AServerPort, AClientPort: Word);
var
  i: integer;
  Client: TClient;
begin
  Server.Start('0.0.0.0', AServerPort);
  MainClient := nil;
  for i := 0 to Length(NodesHosts) - 1 do
  begin
    Client := TClient.Create(FHandler, AID);
    if Client.TryConnect(NodesHosts[i], AClientPort) then
      Clients := Clients + [Client]
    else
      Client.Destroy;
  end;
  if Length(Clients) <> 0 then
    MainClient := Clients[0];
end;

procedure TNetCore.Stop;
begin
  for var i := 0 to Length(Clients) - 1 do
    Clients[i].NeedDestroy := True;

  for var i := 0 to Length(ConnectedClients) - 1 do
    if (ConnectedClients[i] <> nil) then
      ConnectedClients[i].Disconnect;

  Server.Stop;
  if NeedDestroySelf then
    Free;
end;

{$ENDREGION}

end.
