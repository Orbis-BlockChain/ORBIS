unit Net.Client;

interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Threading,
  System.Net.Socket,
  System.Generics.Collections,
  Net.IClient,
  App.IHandlerCore;
{$RTTI EXPLICIT METHODS([vcPrivate])}


type
  TClient = class(TInterfacedObject, IClient)
  private
    FIDNode: UInt64;
    FIPv4: string;
    FPort: Word;
    FHandler: IBaseHandler;
    Data: TBytes;
    DataSize: integer;
    ConIP: String;
    ConPort: Word;
    FAfterDisconnect: TProc<Boolean>;
    DestroyAfterDisc: Boolean;
    FSocket: TSocket;
    procedure Init;
    procedure Handle(AData: TBytes);
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
    function GetID: UInt64;
    procedure SetID(AID: UInt64);
  public
    constructor Create(AHandler: IBaseHandler; AID: UInt64 = 0);
    function TryConnect(const AIP: string; APort: Word): Boolean;
    procedure Disconnect;
    function TryDisconnect: Boolean;
    property BeforeDestroy: TProc<Boolean> read FAfterDisconnect write FAfterDisconnect;
    function Connected: Boolean;
    procedure CallBack(const ASyncResult: IAsyncResult);
    procedure StartReceive;
    function SendMessage(const AData: TBytes): integer;
    function GetIP: string;
    destructor Destroy; override;
    property IP: String read ConIP write ConIP;
    property NeedDestroy: Boolean write DestroyAfterDisc;
    property IDNode: UInt64 read GetID write SetID;
    property IPv4: string read FIPv4 write FIPv4;
    property Port: Word read FPort write FPort;
    property Socket: TSocket read FSocket write FSocket;
  end;

  TReconnectThread = class(TThread)
  private
    Client: TClient;
  protected
    procedure SetClient(AClient: TClient);
    procedure Execute; override;
    destructor Destroy; override;
  end;

var
  AutoReconnect: TReconnectThread;

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

function TClient.Connected: Boolean;
begin
  try
    if Assigned(Socket) then
      Result := TSocketState.Connected in Socket.State
    else
      Result := False;
  except
    Result := False;
  end;
end;

constructor TClient.Create(AHandler: IBaseHandler; AID: UInt64 = 0);
begin
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
  if Assigned(Self) then
  begin
    if Assigned(AutoReconnect) then
      AutoReconnect.Terminate;

    setLength(Data, 0);
    DataSize := 0;
    if TSocketState.Connected in Socket.State then
      Socket.Close;
    Socket.Free;
  end;
end;

procedure TClient.Disconnect;
begin
  Socket.Close;
end;

procedure TClient.Handle(AData: TBytes);
begin
  FHandler.HandleReceiveTCPData(Self, AData);
end;

procedure TClient.Init;
begin
  if not Assigned(Socket) then
  begin
    Socket := TSocket.Create(TSocketType.TCP, TEncoding.UTF8);
    DataSize := 0;
    setLength(Data, DataSize);
  end;
  AutoReconnect := TReconnectThread.Create(True);
  AutoReconnect.FreeOnTerminate := True;
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
begin
  try
    Bytes := Socket.EndReceiveBytes(ASyncResult);
  except
    setLength(Bytes, 0);
  end;

  if Length(Bytes) > 0 then
  begin
    Data := Data + Bytes;
    while True do
    begin
      if DataSize > 0 then
      begin
        if Length(Data) >= DataSize then
        begin
          Handle(Copy(Data, 0, DataSize));
          Data := Copy(Data, DataSize, Length(Data) - DataSize);
          DataSize := 0;
        end
        else
          break;
      end
      else
      begin
        if Length(Data) >= SizeOf(integer) then
        begin
          DataSize := Pinteger(Data)^;
          Data := Copy(Data, SizeOf(DataSize), Length(Data) - SizeOf(DataSize));
        end
        else
          break;
      end;
    end;
    StartReceive;
  end
  else if Assigned(Self) then
    if DestroyAfterDisc then
      Self.Free
    else
      Self.Disconnect;
end;

function TClient.SendMessage(const AData: TBytes): integer;
var
  Len: integer;
  buf: TBytes;
begin
  Len := Length(AData);
  setLength(buf, SizeOf(integer));
  Move(Len, buf[0], SizeOf(integer));
  buf := buf + AData;
  Result := Socket.Send(buf);
end;

procedure TClient.StartReceive;
begin
  Socket.BeginReceive(CallBack);
end;

function TClient.TryConnect(const AIP: string; APort: Word): Boolean;
begin
  Result := True;
  try
    Socket.Connect('', AIP, '', APort);
    StartReceive;
    if not AutoReconnect.Started then
    begin
      Self.IP := AIP;
      Self.Port := APort;
      AutoReconnect.SetClient(Self);
      AutoReconnect.Resume;
    end;
  except
    Result := False;
  end;
end;

{ TReconnectThread }

destructor TReconnectThread.Destroy;
begin
  Client := nil;
  inherited;
end;

procedure TReconnectThread.Execute;
begin
  inherited;
  while not Self.Terminated do
  begin
    if Self.Client.DestroyAfterDisc then
    begin
      Self.Terminate;
      exit;
    end;

    if Assigned(Self.Client) and (not Client.Connected) then
      Client.TryConnect(Client.IP, Client.Port);
    Sleep(1000);
  end;
end;

procedure TReconnectThread.SetClient(AClient: TClient);
begin
  if Assigned(AClient) then
    Self.Client := AClient;
end;

end.
