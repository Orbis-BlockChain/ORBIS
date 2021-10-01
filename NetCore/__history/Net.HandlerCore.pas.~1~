unit Net.HandlerCore;

interface
uses
  System.SysUtils,
  Net.IHandlerCore,
  BlockChain.Core;

type
  TNetHandlerCore = class(TInterfacedObject,IBaseHandler)
  private
    FBlockChain: TBlockChainCore;
  public
    procedure HandleReceiveData(const ABytes: TBytes);
    procedure HandleConnectClient(ClientName: String);
    procedure HandleDisconnectClient(ClientName: String);
    constructor Create(ABlockChain:TBlockChainCore);
    destructor Destroy; override;
  end;
implementation

{ TNetHandlerCore }

constructor TNetHandlerCore.Create(ABlockChain: TBlockChainCore);
begin
  FBlockChain := ABlockChain;
end;

destructor TNetHandlerCore.Destroy;
begin
  FBlockChain := nil;
//  FNetCore := nil;
  inherited;
end;

procedure TNetHandlerCore.HandleConnectClient(ClientName: String);
begin
//
end;

procedure TNetHandlerCore.HandleDisconnectClient(ClientName: String);
begin
//
end;

procedure TNetHandlerCore.HandleReceiveData(const ABytes: TBytes);
var
  typeData: byte;
begin
  case typeData of
    0:begin

      end;
  end;

end;

end.
