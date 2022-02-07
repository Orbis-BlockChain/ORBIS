unit Net.Core;

interface

uses
  App.IHandlerCore,
  App.Types,
  App.Packet,
  App.Log,
  App.Notifyer,
  Net.Server,
  Net.ConnectedClient,
  Net.Client,
  Net.Types,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.SyncObjs,
  System.Threading,
  System.Net.Socket,
  System.Generics.Collections;
{$RTTI EXPLICIT METHODS([vcPrivate])}

type
  TClient1 = TClient;
  TClient2 = class(TConnectedClient);

  TNetCore = class
  private
    FCS: TCriticalSection;
    NodesHosts: TArray<string>;
    ApprovedConnections: TArray<string>;
    Server: TServer;
    FMainClient: TClient;
    FHandler: IBaseHandler;
    NeedDestroySelf: Boolean;
    BanList: TThreadList<string>;
    NetLog: TLogs;

    FEventConnect: TEventConnect;
    FEventDisconnect: TEventDisconnect;
    FEventDisconnect2: TEventDisconnect2;

    function GetServerStatus: Boolean;
    function GetFreeArraySell: uint64;
    function Checks(AIP: string): Boolean;
    procedure Handle(From: TConnectedClient; AData: TBytes);
    procedure NewConHandle(SocketIP: String);
    procedure DeleteConnectedClient(AID: integer; state: integer);
    procedure NilConClient(arg: Boolean);
    procedure onConnectedMainCli;
    procedure onDisconnectedMainCli;
    procedure NilClient(AClient: TClient);

    procedure DoOnConnect(AClient: TClient);
    procedure DoOnDisconnect(AClient: TClient);
    procedure DoOnDisconnect2(AClient: TConnectedClient);

    procedure SetMainClient(AClient: TClient);
    function GetMainClient(): TClient;
  public
    ConnectedClients: TArray<TConnectedClient>;
    Clients: TArray<TClient>;
    property ServerStarted: Boolean read GetServerStatus;
    property Handler: IBaseHandler read FHandler write FHandler;
    property MainClient: TClient read GetMainClient write SetMainClient;
    property DestroyNetCore: Boolean write NeedDestroySelf;
    function Start(AID: Int64; AServerPort, AClientPort: Word): Boolean;
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

    procedure DoDisconnect(AClient: TClient);
    procedure DoDisconnect2(AClient: TConnectedClient);
    { Events }
    property OnConnect: TEventConnect read FEventConnect write FEventConnect;
    property OnDisconnectE: TEventDisconnect read FEventDisconnect write FEventDisconnect;
    property OnDisconnectE2: TEventDisconnect2 read FEventDisconnect2 write FEventDisconnect2;
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
    MainClient := Client; //
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
      if (Clients[i].IDNode = AID) or ((Clients[i].IDNode = 0) and (Clients[i].IPv4 = ARemoteAddress) and (Clients[i].Port = ARemotePort)) then
      begin
        if (Clients[i].IDNode = 0) then
          Clients[i].IDNode := AID;

        Result := Clients[i];
        Client := Clients[i];
        if not Client.Connected then
        begin
          if Client.TryConnect(ARemoteAddress, ARemotePort) then
          begin
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
  Client.BeforeDestroy2 := NilClient;
  Client.OnConnectE := DoOnConnect;
  Client.OnDisconnectE := DoDisconnect;
  if Client.TryConnect(ARemoteAddress, ARemotePort) then
  begin
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
  FCS := TCriticalSection.Create;;
  NetLog := TLogs.Create('net_core.log', Paths.GetPathLog);
  NetLog.DoStartProcedure('TNetCore.Create');
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
      ConnectedCli.OnDisconnectE := DoDisconnect2;
      ConnectedCli.AfterDisconnect := DeleteConnectedClient;
      ConnectedClients[id] := ConnectedCli;
    end);
  Server.NewConnectHandle := NewConHandle;
  NetLog.DoEndProcedure('TNetCore.Create');
end;

procedure TNetCore.DeleteConnectedClient(AID: integer; state: integer);
begin
  if Length(ConnectedClients) > 0 then
  begin
    try
      if state = -1 then
        BanList.Add(ConnectedClients[AID].GetSocketIP);

    finally
      ConnectedClients[AID] := nil;
    end;
  end;
end;

destructor TNetCore.Destroy;
begin
  self.Stop;
  BanList.Destroy;

  Server.Free;

  NetLog.Free;
  FCS.Free;
end;

procedure TNetCore.DoDisconnect(AClient: TClient);
begin
  DoOnDisconnect(AClient);
end;

procedure TNetCore.DoOnConnect(AClient: TClient);
begin
  if Assigned(OnConnect) then
    OnConnect(AClient);
end;

procedure TNetCore.DoOnDisconnect(AClient: TClient);
begin
  if Assigned(OnDisconnectE) then
    OnDisconnectE(AClient);
end;

procedure TNetCore.DoDisconnect2(AClient: TConnectedClient);
begin
  DoOnDisconnect2(AClient);
end;

procedure TNetCore.DoOnDisconnect2(AClient: TConnectedClient);
begin
  if Assigned(OnDisconnectE2) then
    OnDisconnectE2(AClient);
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

  var
    Packet: TPacket;
  Packet.CreatePacket(CMD_REQUEST_AUTH, []);
  Client.SendMessage(Packet);

  Clients := Clients + [Client];
  Result := Client;
end;

procedure TNetCore.NilConClient(arg: Boolean);
begin
  FCS.Enter;
  FCS.Leave;
end;

procedure TNetCore.NilClient(AClient: TClient);
begin
  AClient := nil;
end;

procedure TNetCore.onConnectedMainCli;
begin
  ChangeConnected(True);
end;

procedure TNetCore.onDisconnectedMainCli;
begin
  ChangeConnected(False);
end;

procedure TNetCore.SendAll(const Buf: TBytes);
var
  Cli: TConnectedClient;
  ip: string;
begin
  for var i := 0 to Length(ConnectedClients) - 1 do
  begin
    try
      if (ConnectedClients[i] <> nil) and Assigned(ConnectedClients[i]) then
        ConnectedClients[i].SendMessage(Buf);
    except
    end;
  end;
end;

procedure TNetCore.SendAll2(const Buf: TBytes);
begin

end;

procedure TNetCore.SendAllMy(const Buf: TBytes);
var
  Cli: TClient;
begin
  for Cli in Clients do
    try
      if (Cli.GetIP <> '') then
        Cli.SendMessage(Buf);

    except
      NetLog.DoError('TNetCore.SendAll', 'ERROR: Cant send message to CLI');
    end;
end;

function TNetCore.SendPacket(const Buf: TBytes): integer;
begin
  FCS.Enter;
  Result := -1;
  Result := MainClient.SendMessage(Buf);
  FCS.Leave;
end;

function TNetCore.GetMainClient: TClient;
begin
  FCS.Enter;
  Result := FMainClient;
  FCS.Leave;
end;

procedure TNetCore.SetMainClient(AClient: TClient);
begin
  FCS.Enter;
  FMainClient := AClient;
  FCS.Leave;
end;

function TNetCore.Start(AID: Int64; AServerPort, AClientPort: Word): Boolean;
var
  i: integer;
  Client: TClient;
begin
  NetLog.DoStartProcedure('TNetCore.Start');
  try
    Server.Start('0.0.0.0', AServerPort);
    NetLog.DoRequest('TNetCore.Start', 'Server start');
  except
    on e: Exception do
    begin
      NetLog.DoError('TNetCore.Start', 'Error: ' + e.Message);
      NetLog.DoEndProcedure('TNetCore.Start');
    end;
  end;

  MainClient := nil;
  for i := 0 to Length(NodesHosts) - 1 do
  begin
    Client := TClient.Create(FHandler, AID);
    MainClient := Client;
    Client.OnConnectE := DoOnConnect;
    Client.OnDisconnectE := DoOnDisconnect;
    Client.IPv4 := NodesHosts[i];
    Client.Port := AClientPort;
    if Client.TryConnect(NodesHosts[i], AClientPort, True) then
    begin
      Clients := Clients + [Client];
      MainClient.onDisconnect := onDisconnectedMainCli;
      MainClient.OnConnect := onConnectedMainCli;
      ChangeConnected(True);
      Notifyer.DoEvent(TEvents.nOnMainConnect);
    end
    else
      Client.Destroy;
  end;

  Result := Assigned(MainClient);

  NetLog.DoStartProcedure('TNetCore.Start');
end;

procedure TNetCore.Stop;
begin
  for var i := 0 to Length(Clients) - 1 do
  begin
    Clients[i].NeedDestroy := True;
    Clients[i].Disconnect;
    Sleep(10);
  end;

  for var i := 0 to Length(ConnectedClients) - 1 do
    if (ConnectedClients[i] <> nil) then
      ConnectedClients[i].Disconnect;

  Server.Stop;
  if NeedDestroySelf then
    Free;
end;

{$ENDREGION}

end.
