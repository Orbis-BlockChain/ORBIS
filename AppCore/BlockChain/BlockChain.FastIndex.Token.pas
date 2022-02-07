unit BlockChain.FastIndex.Token;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.IOUtils,
  App.Types,
  BlockChain.Types,
  BlockChain.FileHandler;

type
  TTokensIndex = record
    TokenID: UInt64;
    TokenSymbol: TSymbol;
    class operator Implicit(Buf: TTokensIndex): TBytes;
    class operator Implicit(Buf: TBytes): TTokensIndex;
  end;

  TFastIndexTokens = class
  private
    FPath: string;
    FName: string;
    ChainFile: TChainFile;
    Tokens: TArray<TTokensIndex>;
  public
    function GetID(ASymbol: TSymbol): UInt64;
    function GetName(AID: UInt64): TSymbol;
    procedure SetData(AID: UInt64; ASymbol: TSymbol);
    constructor Create(AName: string);
    destructor Destroy; override;
  end;

implementation

{ TFastIndexAccount }

constructor TFastIndexTokens.Create(AName: string);
begin
  FName := AName;
  FPath := TPath.Combine(Paths.GetPathFastIndex, FName);
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 1;
  var
  TI := Header + Default (TTokensIndex);
  ChainFile := TChainFile.Create(FPath, TI);
  for var i := 1 to ChainFile.GetLastBlockNumber do
  begin
    var
      Buf: TBytes;
    ChainFile.TryRead(i, Buf);
    Buf := Copy(Buf, SizeOf(THeader), Length(Buf) - SizeOf(THeader));
    TI := Buf;
    Tokens := Tokens + [TI];
  end;

end;

destructor TFastIndexTokens.Destroy;
begin
  ChainFile.Free;
end;

function TFastIndexTokens.GetID(ASymbol: TSymbol): UInt64;
begin
  Result := 0;
  for var item in Tokens do
  begin
    if item.TokenSymbol = ASymbol then
    begin
      Result := item.TokenID;
      break;
    end;
  end;
end;

function TFastIndexTokens.GetName(AID: UInt64): TSymbol;
begin
  Result := Default (TSymbol);
  if AID - 1 <= Length(Tokens) then
    Result := Tokens[AID - 1].TokenSymbol;
end;

procedure TFastIndexTokens.SetData(AID: UInt64; ASymbol: TSymbol);
begin
  var
    TI: TTokensIndex;
  TI.TokenID := AID;
  TI.TokenSymbol := ASymbol;
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 1;
  var
    Buf: TBytes := TI;
  if ChainFile.TryWrite(Header + Buf, Header) then
    Tokens := Tokens + [TI];
end;

{ TAccountIndex }

class operator TTokensIndex.Implicit(Buf: TBytes): TTokensIndex;
begin
  Move(Buf[0], Result, SizeOf(TTokensIndex));
end;

class operator TTokensIndex.Implicit(Buf: TTokensIndex): TBytes;
begin
  SetLength(Result, SizeOf(TTokensIndex));
  Move(Buf, Result[0], SizeOf(TTokensIndex));
end;

end.
