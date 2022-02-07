unit WebServer.HTTPConnectedClient;

interface

uses
  System.Types,
  System.Net.Socket,
  System.SysUtils,
  System.Classes,
  Net.ConnectedClient,
  App.Log;

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
    property Handle: TProc<THTTPConnectedClient, TBytes> read FHandle
      write FHandle;
    destructor Destroy; override;
  end;

implementation

{ THTTPConnectedClient }

procedure THTTPConnectedClient.CallBack(const ASyncResult: IAsyncResult);
var
  Bytes: TBytes;
begin
  HTTPLog.DoStartProcedure(ClassName + '.' + 'CallBack');
  try
    Bytes := Socket.EndReceiveBytes(ASyncResult);
  except
    SetLength(Bytes, 0);
  end;

  if Length(Bytes) > 0 then
  begin
    TThread.Queue(nil,
      procedure
      begin
        Handle(Self, Bytes)
      end);
    HTTPLog.DoEndProcedure(ClassName + '.' + 'CallBack');
    StartReceive
  end;
end;

destructor THTTPConnectedClient.Destroy;
begin
  HTTPLog.DoStartProcedure(ClassName + '.' + 'Destroy');
  HTTPLog.DoEndProcedure(ClassName + '.' + 'Destroy');
  inherited;
end;

function THTTPConnectedClient.QueryInterface(const IID: TGUID; out Obj)
  : HResult;
begin
  //
end;

procedure THTTPConnectedClient.StartReceive;
begin
  HTTPLog.DoStartProcedure(ClassName + '.' + 'StartReceive');
  if (TSocketState.Connected in Socket.State) then
  begin
    Socket.BeginReceive(CallBack);
    HTTPLog.DoEndProcedure(ClassName + '.' + 'StartReceive');
  end
  else
  begin
    HTTPLog.DoEndProcedure(ClassName + '.' + 'StartReceive');
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
  HTTPLog.DoStartProcedure(ClassName + '.' + 'SendMessage');
  Result := Socket.Send(AData);
  HTTPLog.DoEndProcedure(ClassName + '.' + 'SendMessage');
end;

end.
