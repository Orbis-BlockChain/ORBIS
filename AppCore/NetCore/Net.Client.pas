unit Net.Client;

interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  System.SyncObjs,
  System.Threading,
  System.Net.Socket,
  System.Generics.Collections,
  System.DateUtils,
  Net.IClient,
  Net.Types,
  App.IHandlerCore,
  App.Log,
  App.Types,
  App.Packet;
{$RTTI EXPLICIT METHODS([vcPrivate])}

type
  TClient = class;
  TEventConnect = procedure(AClient: TClient) of Object;
  TEventDisconnect = procedure(AClient: TClient) of Object;

  TReconnectThread = class(TThread)
  private
    Client: TClient;
  protected
    procedure SetClient(AClient: TClient);
    procedure Execute; override;
    destructor Destroy; override;
  end;

  TClient = class(TInterfacedObject, IClient)
  private
    FCS: TCriticalSection;
    FIDNode: UInt64;
    FIPv4: string;
    FPort: Word;
    FHandler: IBaseHandler;
    FSocket: TSocket;
    FData: TBytes;
    DataSize: integer;
    ConIP: String;
    ConPort: Word;
    FAfterDisconnect: TProc<Boolean>;
    FAfterDisconnect2: TProc<TClient>;
    FEventConnect: TEventConnect;
    FEventDisconnect: TEventDisconnect;
    DestroyAfterDisc: Boolean;
    AutoReconnect: TReconnectThread;
    procedure Init;
    procedure Handle(const AData: TBytes);
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
    function GetID: UInt64;
    procedure SetID(AID: UInt64);
    procedure DoOnConnect(AClient: TClient);
    procedure DoOnDisconnect(AClient: TClient);
  public
    onDisconnect: TProc;
    onConnect: TProc;
    procedure Disconnect;
    procedure DoLog(AProc, AMsg: string);
    procedure CheckConnect;
    function TryConnect(const AIP: string; APort: Word; FirstConnect: Boolean = False): Boolean;
    function TryDisconnect: Boolean;
    function Connected: Boolean;
    function SendMessage(const AData: TBytes): integer;
    function GetIP: string;
    procedure CallBack(const ASyncResult: IAsyncResult);
    procedure StartReceive;
    property BeforeDestroy: TProc<Boolean> read FAfterDisconnect write FAfterDisconnect;
    property BeforeDestroy2: TProc<TClient> read FAfterDisconnect2 write FAfterDisconnect2;
    property IP: String read ConIP write ConIP;
    property NeedDestroy: Boolean write DestroyAfterDisc;
    property IDNode: UInt64 read GetID write SetID;
    property IPv4: string read FIPv4 write FIPv4;
    property Port: Word read FPort write FPort;
    property Socket: TSocket read FSocket write FSocket;
    constructor Create(AHandler: IBaseHandler; AID: UInt64 = 0);
    destructor Destroy; override;

    { Events }
    property OnConnectE: TEventConnect read FEventConnect write FEventConnect;
    property OnDisconnectE: TEventDisconnect read FEventDisconnect write FEventDisconnect;
  end;

implementation

procedure TClient.SetID(AID: UInt64);
begin
  FIDNode := AID;
end;

function TClient.GetID: UInt64;
begin
  Result := FIDNode;
end;

function TClient.GetIP: string;
begin
  try
    Result := '';
    if Assigned(Socket) and (TSocketState.Connected in Socket.State) then
      Result := Socket.Endpoint.Address.Address;
  except
    Result := '';
  end;
end;

procedure TClient.CheckConnect;
var
  Packet: TPacket;
begin
  Packet.CreatePacket(CMD_REQUEST_HEART_BEAT, HEART_BEAT_PACKET);
  SendMessage(Packet);
end;

function TClient.Connected: Boolean;
begin
  try
    if Assigned(Self) and Assigned(Socket) then
      Result := TSocketState.Connected in Socket.State
    else
      Result := False;
  except
    Result := False;
  end;
end;

constructor TClient.Create(AHandler: IBaseHandler; AID: UInt64 = 0);
begin
  FCS := TCriticalSection.Create;
  FHandler := AHandler;
  FIDNode := AID;
  NeedDestroy := False;
  Init;
end;

function TClient.TryDisconnect: Boolean;
begin
  if Self.Connected then
    Disconnect;
  Result := not Connected;
end;

function TClient._AddRef: integer;
begin
  Result := -1;
end;

function TClient._Release: integer;
begin
  Result := -1;
end;

destructor TClient.Destroy;
begin
  DoOnDisconnect(Self);
  try
    if Assigned(Self) then
      setLength(FData, 0);
    if Assigned(Self) then
      DataSize := 0;
    if Assigned(Self) then
      if TSocketState.Connected in Socket.State then
        Socket.Close;
    if Assigned(Self) then
      Socket.Free;
    if Assigned(AutoReconnect) then
      AutoReconnect.Free;
  except
    if Assigned(Self) then
      setLength(FData, 0);
    if Assigned(Self) then
      DataSize := 0;
    if Assigned(Self) then
      if TSocketState.Connected in Socket.State then
        Socket.Close;
    if Assigned(Self) then
      Socket.Free;

  end;
  FCS.Free;
end;

procedure TClient.Disconnect;
begin
  DoOnDisconnect(Self);
  Socket.Close;
  if Assigned(onDisconnect) then
    onDisconnect;
end;

procedure TClient.DoLog(AProc, AMsg: string);
begin
  MyClientsLog.DoAlert(AProc, AMsg);
end;

procedure TClient.DoOnConnect(AClient: TClient);
begin
  try
    if (Assigned(OnConnectE)) then
      OnConnectE(AClient);
  except
    on e: exception do
      DoLog('TClient.DoOnConnect', 'Can''t onConnect event');
  end;
end;

procedure TClient.DoOnDisconnect(AClient: TClient);
begin
  try
    if Assigned(OnDisconnectE) then
      OnDisconnectE(AClient);
  except
    on e: exception do
      DoLog('TClient.DoOnConnect', 'Can''t onConnect event');
  end;
end;

procedure TClient.Handle(const AData: TBytes);
begin
  FHandler.HandleReceiveTCPData(Self, AData);
end;

procedure TClient.Init;
begin
  if not Assigned(Socket) then
  begin
    Socket := TSocket.Create(TSocketType.TCP, TEncoding.UTF8);
    DataSize := 0;
    setLength(FData, DataSize);

  end;
  AutoReconnect := TReconnectThread.Create(True);
//  AutoReconnect.FreeOnTerminate := True;
end;

function TClient.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TClient.CallBack(const ASyncResult: IAsyncResult);
var
  Bytes: TBytes;
  Event: TEvent;
begin
  FCS.Enter;
  try
    Bytes := Socket.EndReceiveBytes(ASyncResult);
  except
    setLength(Bytes, 0);
  end;

  if Length(Bytes) > 0 then
  begin
    FData := FData + Bytes;
    MyClientsLog.DoAlert('CllBack', 'RECEIVE: ARRAY BYTE = ' + Length(FData).ToString);
    while True do
    begin
      if DataSize > 0 then
      begin
        if Length(FData) >= DataSize then
        begin
          Event := TEvent.Create;
          TThread.Queue(nil,
            procedure
            begin
              MyClientsLog.DoAlert('CllBack', 'RECEIVE: START HANDLE');
              Handle(Copy(FData, 0, DataSize));
              Event.SetEvent;
              MyClientsLog.DoAlert('CllBack', 'RECEIVE: END HANDLE');
            end);
          Event.WaitFor;
          Event.Free;

          FData := Copy(FData, DataSize, Length(FData) - DataSize);
          DataSize := 0;
        end
        else
          break;
      end
      else
      begin
        if Length(FData) >= SizeOf(integer) then
        begin
          Move(FData[0], DataSize, SizeOf(integer));
          FData := Copy(FData, SizeOf(DataSize), Length(FData) - SizeOf(DataSize));
          MyClientsLog.DoAlert('Callback', 'RECEIVE: DATASIZE = ' + DataSize.ToString);
        end
        else
          break;
      end;
    end;
    StartReceive;
  end
  else if Assigned(Self) then
  begin
    MyClientsLog.DoAlert('CllBack', 'RECEIVE: ARRAY BYTE = 0');
    DoOnDisconnect(Self);
    if DestroyAfterDisc then
    begin
      Self.Free;
      if Assigned(onDisconnect) then
      begin
        onDisconnect;
      end;
    end
    else
    begin
      Self.Disconnect;
    end;
  end;
  FCS.Leave;
end;

function TClient.SendMessage(const AData: TBytes): integer;
var
  Len: integer;
  buf: TBytes;
begin
  Result := -1;
  try
    if (Self <> nil) and (Socket <> nil) and (Assigned(Socket)) and (Connected) then
    begin
      Len := Length(AData);
      setLength(buf, SizeOf(integer));
      Move(Len, buf[0], SizeOf(integer));
      buf := buf + AData;
      Result := Socket.Send(buf);
    end
    else
    begin
      try
        if (Self <> nil) and (Socket <> nil) then
        begin
          Socket.Connect('', FIPv4, '', FPort);
          StartReceive;
          DoOnConnect(Self);
        end;
      except
        on e: exception do
          MyClientsLog.DoAlert('SendMessage', e.Message);
      end;
    end;
  except
    on e: exception do
    begin
      MyClientsLog.DoAlert('SendMessage', e.Message);
      Result := -1;
    end;
  end;
end;

procedure TClient.StartReceive;
var
  Flags: TSocketFlags;
begin
  try
    Socket.BeginReceive(CallBack);
  except
    on e: exception do
      MyClientsLog.DoAlert('StartReceive', e.Message);
  end;

end;

function TClient.TryConnect(const AIP: string; APort: Word; FirstConnect: Boolean = False): Boolean;
begin
  Result := True;
  try
    Socket.Connect('', AIP, '', APort);
    if Assigned(onConnect) then
      onConnect;
    StartReceive;
    DoOnConnect(Self);
    if not AutoReconnect.Started then
    begin
      Self.IP := AIP;
      Self.Port := APort;
      Self.FIPv4 := AIP;
      Self.FPort := APort;
      AutoReconnect.SetClient(Self);
      AutoReconnect.Resume;
    end;
    // if Assigned(OnConnectE) and (FirstConnect) then
    // OnConnectE(Self);
  except
    Result := False;
  end;
end;

{ TReconnectThread }

destructor TReconnectThread.Destroy;
begin
end;

procedure TReconnectThread.Execute;
begin
  inherited;
  while (not Self.Terminated) do
  begin
    Sleep(1000);
    if (Assigned(Self.Client)) and (Self.Client.DestroyAfterDisc) then
    begin
      Self.Terminate;
      exit;
    end;

    if Assigned(Self.Client) and (not Client.Connected) then
      Client.TryConnect(Client.IP, Client.Port, True)
    else
      Client.CheckConnect;
  end;
end;

procedure TReconnectThread.SetClient(AClient: TClient);
begin
  if Assigned(AClient) then
    Self.Client := AClient;
end;

end.
