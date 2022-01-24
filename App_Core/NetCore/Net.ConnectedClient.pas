unit Net.ConnectedClient;

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
  App.Types,
  App.Log,
  App.Packet;
{$RTTI EXPLICIT METHODS([vcProtected])}

type
  TConnectedClient = class;
  TEventDisconnect2 = procedure(AClient: TConnectedClient) of Object;

  TConnectedClient = class(TInterfacedObject, IClient)
  protected
    FCS: TCriticalSection;
    FIDNode: UInt64;
    Socket: TSocket;
    Approved: boolean;
    FHandle: TProc<TConnectedClient, TBytes>;
    Data: TBytes;
    DataSize: integer;
    Id: integer;
    FEventDisconnect: TEventDisconnect2;
    FAfterDisconnect: TProc<integer, integer>;
    function isActive: boolean;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
    procedure SetID(AID: UInt64);
    function GetID: UInt64;
    procedure DoOnDisconnect(AClient: TConnectedClient);
  public
    property IDNode: UInt64 read GetID write SetID;
    procedure DoApprove;
    procedure DoNotApprove;
    procedure Disconnect;
    procedure CallBack(const ASyncResult: IAsyncResult);
    procedure StartReceive; virtual;
    procedure DoLog(AProc, AMsg: string);
    function Connected: boolean;
    function GetSocketIP: String;
    function SendMessage(const AData: TBytes): integer; virtual;
    function GetIP: string;
    property AfterDisconnect: TProc<integer, integer> read FAfterDisconnect write FAfterDisconnect;
    property IdInArray: integer read Id write Id;
    property Handle: TProc<TConnectedClient, TBytes> read FHandle write FHandle;
    property SocketIP: String read GetSocketIP;
    constructor Create(ASocket: TSocket);
    destructor Destroy; override;

    { Events }
    property OnDisconnectE: TEventDisconnect2 read FEventDisconnect write FEventDisconnect;
  end;

implementation

{$REGION 'TConnectedClient'}

procedure TConnectedClient.CallBack(const ASyncResult: IAsyncResult);
const
  ApprovedBuf: TBytes = [0, 0, 0, 0, 0, 0, 0, 0, 0];
var
  Bytes: TBytes;
  Event: TEvent;
begin
  FCS.Enter;
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'CallBack');
  try
    Bytes := Socket.EndReceiveBytes(ASyncResult);
  except
    SetLength(Bytes, 0);
  end;

  if (Length(Bytes) > 0) then
  begin
    Data := Data + Bytes;
    while True do
    begin
      if DataSize > 0 then
      begin
        if (Length(Data) >= DataSize) then
        begin
          Event := TEvent.Create;
          TThread.Queue(nil,
            procedure
            begin
              Handle(Self, Copy(Data, 0, DataSize));
              Event.SetEvent;
            end);
          Event.WaitFor;
          Event.Free;
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
          // DataSize := Pinteger(Data)^;
          Move(Data[0], DataSize, SizeOf(integer));
          Data := Copy(Data, SizeOf(DataSize), Length(Data) - SizeOf(DataSize));
        end
        else
          break;
      end;
    end;
    StartReceive;
  end
  else
  begin
    ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'CallBack');
    Self.Free;
  end;
  FCS.Leave;
end;

function TConnectedClient.Connected: boolean;
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

constructor TConnectedClient.Create(ASocket: TSocket);
begin
  FCS := TCriticalSection.Create;

  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'Create');
  Socket := ASocket;
  Approved := False;
  DataSize := 0;
  FIDNode := 0;
  SetLength(Data, DataSize);
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'Create');
end;

destructor TConnectedClient.Destroy;
begin
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'Destroy');
  FHandle := nil;
  SetLength(Data, 0);
  DataSize := 0;
  if Approved then
    AfterDisconnect(Id, 0)
  else
    AfterDisconnect(Id, -1);
  Socket.Free;
  Socket := nil;
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'Destroy');
  FCS.Free;
end;

procedure TConnectedClient.Disconnect;
begin

  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'Disconnect');
  if Assigned(Socket) and isActive then
    Socket.Close
  else
    raise Exception.Create('TConnectedClient unable to disconnect ');
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'Disconnect');
end;

function TConnectedClient.GetID: UInt64;
begin
  Result := FIDNode;
end;

function TConnectedClient.GetIP: string;
begin
  Result := GetSocketIP;
end;

function TConnectedClient.GetSocketIP: String;
begin
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'GetSocketIP');
  try
    Result := '';
    if Assigned(Socket) and (TSocketState.Connected in Socket.State) then
      Result := Socket.Endpoint.Address.Address;
  except
    Result := '';
  end;
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'GetSocketIP');
end;

function TConnectedClient.isActive: boolean;
begin
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'isActive');
  try
    if Assigned(Socket) then
      Result := TSocketState.Connected in Socket.State;
  except
    Result := False;
  end;
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'isActive');
end;

function TConnectedClient.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TConnectedClient.DoApprove;
begin
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'DoApprove');
  Approved := True;
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'DoApprove');
end;

procedure TConnectedClient.DoLog(AProc, AMsg: string);
begin
  ConnectedClientsLog.DoAlert(AProc, AMsg);
end;

procedure TConnectedClient.DoNotApprove;
begin
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'DoNotApprove');
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'DoNotApprove');
  Destroy;
end;

procedure TConnectedClient.DoOnDisconnect(AClient: TConnectedClient);
begin
  if Assigned(OnDisconnectE) then
    OnDisconnectE(AClient);
end;

function TConnectedClient.SendMessage(const AData: TBytes): integer;
var
  Len: integer;
  buf: TBytes;
begin
  Result := -1;
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'SendMessage');
  try
    if Connected then
    begin
      Len := Length(AData);
      SetLength(buf, SizeOf(integer));
      Move(Len, buf[0], SizeOf(integer));
      buf := buf + AData;
      Result := Socket.Send(buf);
      ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'SendMessage');
    end;
  except
    on e: Exception do
    begin
      ConnectedClientsLog.DoEndProcedure(' *** ERROR TConnectedClient' + '.' + 'SendMessage: ' + e.Message);
    end;
  end;
end;

procedure TConnectedClient.SetID(AID: UInt64);
begin
  FIDNode := AID;
end;

procedure TConnectedClient.StartReceive;
begin
  ConnectedClientsLog.DoStartProcedure('TConnectedClient' + '.' + 'StartReceive');
  Socket.BeginReceive(CallBack);
  ConnectedClientsLog.DoEndProcedure('TConnectedClient' + '.' + 'StartReceive');
end;

function TConnectedClient._AddRef: integer;
begin
  Result := -1;
end;

function TConnectedClient._Release: integer;
begin
  Result := -1;
end;

{$ENDREGION}

end.
