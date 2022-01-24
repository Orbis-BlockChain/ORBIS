unit Net.Server;

interface

uses
  Net.ConnectedClient,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Threading,
  System.Net.Socket,
  System.Generics.Collections,
  System.SyncObjs;
{$RTTI EXPLICIT METHODS([vcProtected])}

type
  TServer = class
  protected
    FAcceptHandle: TProc<TConnectedClient>;
    FNewConnectHandle: TProc<String>;
    FDisClientHandle: TProc<String>;
    FCheckHandle: TFunc<string, boolean>;
    HideActiveStatus: boolean;
    Socket: TSocket;
    ServerStoped: TEvent;
    procedure AcceptCallback(const ASyncResult: IAsyncResult);
    procedure DoWaitStopServer;
  public
    property isActive: boolean read HideActiveStatus;
    property AcceptHandle: TProc<TConnectedClient> read FAcceptHandle write FAcceptHandle;
    property NewConnectHandle: TProc<String> read FNewConnectHandle write FNewConnectHandle;
    property Checks: TFunc<string, boolean> read FCheckHandle write FCheckHandle;
{$IFDEF TESTNET}
    procedure Start(const AIP: string = '127.0.0.1'; APort: Word = 30000); virtual;
{$ELSE}
    procedure Start(const AIP: string = '0.0.0.0'; APort: Word = 30000); virtual;
{$ENDIF}
    procedure Stop;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TServer'}

constructor TServer.Create;
begin
  Socket := TSocket.Create(TSocketType.TCP);
  ServerStoped := TEvent.Create;
end;

destructor TServer.Destroy;
begin
  try
    Stop;
  finally
    ServerStoped.Free;
    Socket.Free;
  end;
end;

procedure TServer.DoWaitStopServer;
begin
  HideActiveStatus := False;
  if not(ServerStoped.WaitFor(1000) = TWaitResult.wrSignaled) then
    ServerStoped.SetEvent;
end;

{$IFDEF TESTNET}

procedure TServer.Start(const AIP: string = '127.0.0.1'; APort: Word = 30000);
begin
  ServerStoped.ResetEvent;
  HideActiveStatus := True;
  Socket.Listen(AIP, '', APort);
  Socket.BeginAccept(AcceptCallback, 100);
end;
{$ELSE}

procedure TServer.Start(const AIP: string = '0.0.0.0'; APort: Word = 30000);
begin
  ServerStoped.ResetEvent;
  HideActiveStatus := True;

  Socket.Listen(AIP, '', APort);
  Socket.BeginAccept(AcceptCallback, 100);
end;
{$ENDIF}

procedure TServer.Stop;
begin
  if isActive then
  begin
    DoWaitStopServer;
    Socket.Close(True)
  end;
end;

procedure TServer.AcceptCallback(const ASyncResult: IAsyncResult);
var
  AcceptedSocket: TSocket;
  ConnectedClient: TConnectedClient;
begin
  if not HideActiveStatus then
  begin
    ServerStoped.SetEvent;
    Exit;
  end;

  AcceptedSocket := nil;
  AcceptedSocket := Socket.EndAccept(ASyncResult);
  if (AcceptedSocket <> nil) and (Checks(Socket.Endpoint.Address.Address)) then
  begin
    ConnectedClient := TConnectedClient.Create(AcceptedSocket);
    FAcceptHandle(ConnectedClient);
    FNewConnectHandle(ConnectedClient.GetSocketIP);
    ConnectedClient.StartReceive;
  end;
  if Assigned(Self)  then
    Socket.BeginAccept(AcceptCallback, 100);
end;
{$ENDREGION}

end.
