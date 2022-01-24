unit WebServer.HTTPConnectedClient;

interface

uses
  System.Types,
  System.Net.Socket,
  System.SysUtils,
  Net.ConnectedClient;

type
  THTTPConnectedClient = class(TConnectedClient)
    procedure CallBack(const ASyncResult: IAsyncResult);
  private
    FHandle: TProc<THTTPConnectedClient, TBytes>;
    procedure StartReceive; override;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
  public
    function SendMessage(const AData: TBytes): integer; override;
    property Handle: TProc<THTTPConnectedClient, TBytes> read FHandle write FHandle;
    destructor Destroy; override;
  end;

implementation

{ THTTPConnectedClient }

procedure THTTPConnectedClient.CallBack(const ASyncResult: IAsyncResult);
var
  Bytes: TBytes;
begin
  Log.DoStartProcedure(ClassName + '.' + 'CallBack');
  try
    Bytes := Socket.EndReceiveBytes(ASyncResult);
  except
    SetLength(Bytes, 0);
  end;

  if Length(Bytes) > 0 then
  begin
    Handle(Self, Bytes);
    Log.DoEndProcedure(ClassName + '.' + 'CallBack');
    StartReceive
  end;
end;

destructor THTTPConnectedClient.Destroy;
begin
  Log.DoStartProcedure(ClassName + '.' + 'Destroy');
  Log.DoEndProcedure(ClassName + '.' + 'Destroy');
  inherited;
end;

function THTTPConnectedClient.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  //
end;

procedure THTTPConnectedClient.StartReceive;
begin
  Log.DoStartProcedure(ClassName + '.' + 'StartReceive');
  if (TSocketState.Connected in Socket.State) then
  begin
    Socket.BeginReceive(CallBack);
    Log.DoEndProcedure(ClassName + '.' + 'StartReceive');
  end
  else
  begin
    Log.DoEndProcedure(ClassName + '.' + 'StartReceive');
    Free;
  end;

end;

function THTTPConnectedClient._AddRef: integer;
begin
  //
end;

function THTTPConnectedClient._Release: integer;
begin
  //
end;

function THTTPConnectedClient.SendMessage(const AData: TBytes): integer;
begin
  Log.DoStartProcedure(ClassName + '.' + 'SendMessage');
  Result := Socket.Send(AData);
  Log.DoEndProcedure(ClassName + '.' + 'SendMessage');
end;

end.
