unit BlockChain.FastIndex.RegistredService;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.IOUtils,
  App.Types,
  BlockChain.Types,
  BlockChain.FileHandler;

type
  TRegistredServiceIndex = record
    RegistredServiceOwnerID: UInt64;
    RegistredServiceName: TName;
    RegistredServiceSymbol: TSymbol;
    class operator Implicit(Buf: TRegistredServiceIndex): TBytes;
    class operator Implicit(Buf: TBytes): TRegistredServiceIndex;
  end;

  TFastIndexRegistredService = class
  private
    FPath: string;
    FName: string;
    ChainFile: TChainFile;
    RegistredServices: TArray<TRegistredServiceIndex>;
  public
    procedure SetData(AOwnerID: UInt64; AName: TName; ASymbol: TSymbol);
    constructor Create(AName: string);
    destructor Destroy; override;
  end;

implementation

{ TFastIndexRegistredService }

constructor TFastIndexRegistredService.Create(AName: string);
var
  count: integer;
begin
  FName := AName;
  FPath := TPath.Combine(Paths.GetPathFastIndex, FName);
  var Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 0;
  var AI := Header + Default (TRegistredServiceIndex);
  ChainFile := TChainFile.Create(FPath, AI);
  count := ChainFile.GetLastBlockNumber;
  if count = 0 then
  begin
    RegistredServices := RegistredServices + [Default (TRegistredServiceIndex)];
    exit;
  end;

  for var i := 1 to ChainFile.GetLastBlockNumber do
  begin
    var Buf: TBytes;
    ChainFile.TryRead(i, Buf);
    Buf := Copy(Buf, SizeOf(THeader), Length(Buf) - SizeOf(THeader));
    AI := Buf;
    RegistredServices := RegistredServices + [AI];
  end;
end;

destructor TFastIndexRegistredService.Destroy;
begin
  ChainFile.Free;
end;

procedure TFastIndexRegistredService.SetData(AOwnerID: UInt64; AName: TName; ASymbol: TSymbol);
begin
  var RSI: TRegistredServiceIndex;
  RSI.RegistredServiceOwnerID := AOwnerID;
  RSI.RegistredServiceName := AName;
  RSI.RegistredServiceSymbol := ASymbol;
  var Header: THeader := Default (THeader);
  Header.TypeBlock := ord(TTypesChain.FastIndex);
  Header.VersionData := 0;
  var Buf: TBytes := RSI;
  if ChainFile.TryWrite(Header + Buf, Header) then
    RegistredServices := RegistredServices + [RSI];
end;

{ TRegistredServiceIndex }

class operator TRegistredServiceIndex.Implicit(Buf: TBytes): TRegistredServiceIndex;
begin
  Move(Buf[0], Result, SizeOf(TRegistredServiceIndex));
end;

class operator TRegistredServiceIndex.Implicit(Buf: TRegistredServiceIndex): TBytes;
begin
  SetLength(Result, SizeOf(TRegistredServiceIndex));
  Move(Buf, Result[0], SizeOf(TRegistredServiceIndex));
end;

end.
