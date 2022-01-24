unit Net.ConnectedClient;

interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Threading,
  System.Net.Socket,
  System.Generics.Collections,
  Net.IClient,
  App.Types,
  App.Log;
{$RTTI EXPLICIT METHODS([vcProtected])}

type
  TConnectedClient = class(TInterfacedObject, IClient)
  protected
    FIDNode: UInt64;
    Log: TLogs;
    Socket: TSocket;
    Approved: boolean;
    FHandle: TProc<TConnectedClient, TBytes>;
    Data: TBytes;
    DataSize: integer;
    Id: integer;
    FAfterDisconnect: TProc<integer, integer>;
    function isActive: boolean;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
    procedure SetID(AID: UInt64);
    function GetID: UInt64;
  public
    procedure DoApprove;
    procedure DoNotApprove;
    procedure Disconnect;
    constructor Create(ASocket: TSocket);
    property AfterDisconnect: TProc<integer, integer> read FAfterDisconnect write FAfterDisconnect;
    property IdInArray: integer read Id write Id;
    property Handle: TProc<TConnectedClient, TBytes> read FHandle write FHandle;
    function GetSocketIP: String;
    property SocketIP: String read GetSocketIP;
    procedure CallBack(const ASyncResult: IAsyncResult);
    procedure StartReceive; virtual;
    function SendMessage(const AData: TBytes): integer; virtual;
    function GetIP: string;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TConnectedClient'}

procedure TConnectedClient.CallBack(const ASyncResult: IAsyncResult);
const
  ApprovedBuf: TBytes = [0, 0, 0, 0, 0, 0, 0, 0, 0];
var
  Bytes: TBytes;
begin
  Log.DoStartProcedure('TConnectedClient' + '.' + 'CallBack');
  try
    Bytes := Socket.EndReceiveBytes(ASyncResult);
  except
    SetLength(Bytes, 0);
  end;

  if (Length(Bytes) > 0) and (not Approved) then
  begin
    Data := Data + Bytes;
    DataSize := Pinteger(Data)^;
    Data := Copy(Data, SizeOf(DataSize), Length(Data) - SizeOf(DataSize));

    if CompareMem(Data, ApprovedBuf, Length(ApprovedBuf)) then
    begin
      Approved := True;
      Data := Copy(Data, DataSize, Length(Data) - DataSize);
      DataSize := 0;
      Handle(Self, [0, 0, 0, 0, 0, 0, 0, 0, 0]);
      if Length(Data) > 0 then
      begin
        Bytes := Data;
        Data := [];
      end
      else
      begin
        StartReceive;
        exit;
      end;
    end
    else
    begin
      Data := [];
      DataSize := 0;
      Handle(Self, [0, 1, 0, 0, 0, 0, 0, 0, 0]);
      Destroy;
      exit;
    end;
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
          Handle(Self, Copy(Data, 0, DataSize));
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
  else
  begin
    Log.DoEndProcedure('TConnectedClient' + '.' + 'CallBack');
    Self.Free;
  end;
end;

constructor TConnectedClient.Create(ASocket: TSocket);
begin
  Log := TLogs.Create('TConnectedClient', Paths.GetPathLog);
  Log.DoStartProcedure('TConnectedClient' + '.' + 'Create');
  Socket := ASocket;
  Approved := False;
  DataSize := 0;
  FIDNode := 0;
  SetLength(Data, DataSize);
  Log.DoEndProcedure('TConnectedClient' + '.' + 'Create');
end;

destructor TConnectedClient.Destroy;
begin
  Log.DoStartProcedure('TConnectedClient' + '.' + 'Destroy');
  FHandle := nil;
  SetLength(Data, 0);
  DataSize := 0;
  if Approved then
    AfterDisconnect(Id, 0)
  else
    AfterDisconnect(Id, -1);
  Socket.Free;
  Socket := nil;
  Log.DoEndProcedure('TConnectedClient' + '.' + 'Destroy');
  Log.Free;
end;

procedure TConnectedClient.Disconnect;
begin
  Log.DoStartProcedure('TConnectedClient' + '.' + 'Disconnect');
  if Assigned(Socket) and isActive then
    Socket.Close
  else
    raise Exception.Create('TConnectedClient unable to disconnect ');
  Log.DoEndProcedure('TConnectedClient' + '.' + 'Disconnect');
end;

function TConnectedClient.GetID: UInt64;
begin
  Result:= FIDNode;
end;

function TConnectedClient.GetIP: string;
begin
  Result := GetSocketIP;
end;

function TConnectedClient.GetSocketIP: String;
begin
  Log.DoStartProcedure('TConnectedClient' + '.' + 'GetSocketIP');
  try
    Result := '';
    if Assigned(Socket) and (TSocketState.Connected in Socket.State) then
      Result := Socket.Endpoint.Address.Address;
  except
    Result := '';
  end;
  Log.DoEndProcedure('TConnectedClient' + '.' + 'GetSocketIP');
end;

function TConnectedClient.isActive: boolean;
begin
  Log.DoStartProcedure('TConnectedClient' + '.' + 'isActive');
  try
    if Assigned(Socket) then
      Result := TSocketState.Connected in Socket.State;
  except
    Result := False;
  end;
  Log.DoEndProcedure('TConnectedClient' + '.' + 'isActive');
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
  Log.DoStartProcedure('TConnectedClient' + '.' + 'DoApprove');
  Approved := True;
  Log.DoEndProcedure('TConnectedClient' + '.' + 'DoApprove');
end;

procedure TConnectedClient.DoNotApprove;
begin
  Log.DoStartProcedure('TConnectedClient' + '.' + 'DoNotApprove');
  Log.DoEndProcedure('TConnectedClient' + '.' + 'DoNotApprove');
  Destroy;
end;

function TConnectedClient.SendMessage(const AData: TBytes): integer;
var
  Len: integer;
  buf: TBytes;
begin
  Result := -1;
  Log.DoStartProcedure('TConnectedClient' + '.' + 'SendMessage');
  try
    Len := Length(AData);
    SetLength(buf, SizeOf(integer));
    Move(Len, buf[0], SizeOf(integer));
    buf := buf + AData;
    Result := Socket.Send(buf);
  finally
    Log.DoEndProcedure('TConnectedClient' + '.' + 'SendMessage');
  end;
end;

procedure TConnectedClient.SetID(AID: UInt64);
begin
  FIDNode:= AID;
end;

procedure TConnectedClient.StartReceive;
begin
  Log.DoStartProcedure('TConnectedClient' + '.' + 'StartReceive');
  Socket.BeginReceive(CallBack);
  Log.DoEndProcedure('TConnectedClient' + '.' + 'StartReceive');
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