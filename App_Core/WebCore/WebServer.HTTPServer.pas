unit WebServer.HTTPServer;

interface

uses
  System.Net.Socket,
  System.Types,
  System.SysUtils,
  WebServer.HTTPConnectedClient,
  Net.Server;

type
  THTTPServer = class(TServer)
  private
    FAcceptHandle: TProc<THTTPConnectedClient>;
    procedure AcceptCallback(const ASyncResult: IAsyncResult);
  public
    procedure Start(const AIP: string = '0.0.0.0'; APort: Word = 20000); override;
    property AcceptHandle: TProc<THTTPConnectedClient> read FAcceptHandle write FAcceptHandle;
    destructor Destroy; override;
  end;

implementation

procedure THTTPServer.AcceptCallback(const ASyncResult: IAsyncResult);
var
  AcceptedSocket: TSocket;
  ConnectedClient: THTTPConnectedClient;
begin
  if not HideActiveStatus then
  begin
    ServerStoped.SetEvent;
    Exit;
  end;

  AcceptedSocket := nil;
  AcceptedSocket := Socket.EndAccept(ASyncResult);
  if AcceptedSocket <> nil then
  begin
    ConnectedClient := THTTPConnectedClient.Create(AcceptedSocket);
    FAcceptHandle(ConnectedClient);
    FNewConnectHandle(ConnectedClient.GetSocketIP);
    ConnectedClient.StartReceive;
  end;
  if Assigned(Self) then
    Socket.BeginAccept(AcceptCallback, 1000);
end;

destructor THTTPServer.Destroy;
begin

  inherited;
end;

procedure THTTPServer.Start(const AIP: string = '0.0.0.0'; APort: Word = 20000);
begin
  ServerStoped.ResetEvent;
  HideActiveStatus := True;

  Socket.Listen(AIP, '', APort);
  Socket.BeginAccept(AcceptCallback, 100);
end;

end.
