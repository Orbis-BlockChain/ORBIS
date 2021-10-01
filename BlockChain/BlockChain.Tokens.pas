unit BlockChain.Tokens;

interface

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.Hash,
  System.DateUtils,
  System.Generics.Collections,
  App.Types,
  Wallet.Types,
  BlockChain.BaseBlock,
  BlockChain.BaseChain,
  BlockChain.Types,
  BlockChain.FileHandler,
  BlockChain.FastIndex.Token,
  Crypto.RSA;

const
  LastVersionTokens = 0;

type
  TTokensInfoV0 = packed record // 128
    Owner: UINT64;
    Name: TName;
    Symbol: TSymbol;
    Decimals: UINT64;
    Volume: int64;
    TokenType: TToken;
    UnixTime: int64;
    class operator Implicit(Buf: TTokensInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TTokensInfoV0;
    class operator Add(buf1: TBytes; buf2: TTokensInfoV0): TBytes;
    class operator Add(buf2: TTokensInfoV0; buf1: TBytes): TBytes;
    function GetSize: integer;
  end;

  TTokensTrxV0 = packed record // 192
    TokensInfo: TTokensInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: integer;
    class operator Implicit(Buf: TTokensTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TTokensTrxV0;
    class operator Add(buf1: TBytes; buf2: TTokensTrxV0): TBytes;
    class operator Add(buf2: TTokensTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
  end;

  TTokensBlockV0 = class(TBaseBlock)
  protected
    TokensInfo: TTokensTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: UINT64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(ATokensInfo: TTokensTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TTokensChain = class(TBaseChain)
  private
    FastIndex: TFastIndexTokens;
  public
    function GetBlock(Ind: UINT64): TBaseBlock; override;
    function GetLastBlockID: UINT64;
    function GetIDToken(ASymbol: string): UINT64;
    function GetTokenName(AID: UINT64): TSymbol;
    function GetTokenDecimals(AID: UINT64): UINT64;
    procedure AddToFastIndex(AData: TBytes); override;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain); override;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TTokensInfoV0'}


class operator TTokensInfoV0.Add(buf1: TBytes; buf2: TTokensInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTokensInfoV0));
  Move(buf2, LData[0], SizeOf(TTokensInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TTokensInfoV0.Add(buf2: TTokensInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTokensInfoV0));
  Move(buf2, LData[0], SizeOf(TTokensInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TTokensInfoV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TTokensInfoV0.Implicit(Buf: TTokensInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TTokensInfoV0));
  Move(Buf, Result[0], SizeOf(TTokensInfoV0));
end;

class operator TTokensInfoV0.Implicit(Buf: TBytes): TTokensInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TTokensInfoV0));
end;
{$ENDREGION}
{$REGION 'TTokensBlockV0'}


constructor TTokensBlockV0.Create;
begin
  //
end;

constructor TTokensBlockV0.Create(ATokensInfo: TTokensTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin
  Header.VersionData := 0;
  Header.TypeBlock := Byte(Tokens);
  Header.UnixTime := DateTimeToUnix(now, False);
  TokensInfo := ATokensInfo;
end;

class function TTokensBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalTokens: TTokensTrxV0;
  LocalIDSigned: integer;
  LocalSign: TSignedHash;
  counter: integer;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(TTypesChain.Tokens);
  LocalTokens := Default (TTokensTrxV0);
  case NetState of
    MAINNET:
      FIllChar(LocalTokens, SizeOf(LocalTokens), 0);
    TESTNET:
      FIllChar(LocalTokens, SizeOf(LocalTokens), 1);
    LABNET:
      FIllChar(LocalTokens, SizeOf(LocalTokens), 2);
  end;
  Result := LocalHeader + LocalTokens;
end;

function TTokensBlockV0.GetData: TBytes;
begin
  Result := Header + TokensInfo;
end;

function TTokensBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := TokensInfo;
end;

function TTokensBlockV0.GetSizeBlock: UINT64;
begin
  Result := Header.GetSize + TokensInfo.GetSize;
end;

function TTokensBlockV0.GetTrxData: TBytes;
begin
  Result := TokensInfo;
end;

procedure TTokensBlockV0.SetData(const AData: TBytes);
var
  counter: integer;
begin
  counter := 0;

  Move(AData[counter], Header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  TokensInfo := Copy(AData, counter, TokensInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TTokensChain'}


procedure TTokensChain.AddToFastIndex(AData: TBytes);
begin
  var
    Buf: TTokensInfoV0 := Copy(AData, SizeOf(THeader), SizeOf(TTokensInfoV0));
  FastIndex.SetData(GetLastBlockID, Buf.Symbol);
end;

constructor TTokensChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  inherited Create(AName, Data, AtypeChain);
  FastIndex := TFastIndexTokens.Create(AName);
end;

destructor TTokensChain.Destroy;
begin
  FastIndex.Free;
  inherited;
end;

function TTokensChain.GetBlock(Ind: UINT64): TBaseBlock;
var
  Header: THeader;
  Data: TBytes;
  TokensBlockV0: TTokensBlockV0;
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], Header, SizeOf(THeader));
  case Header.VersionData of
    0:
      begin
        TokensBlockV0 := TTokensBlockV0.Create;
        TokensBlockV0.SetData(Data);
        Result := TokensBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TTokensChain.GetIDToken(ASymbol: string): UINT64;
begin
  Result := FastIndex.GetID(ASymbol);
end;

function TTokensChain.GetLastBlockID: UINT64;
begin
  Result := ChainFile.GetLastBlockNumber;
end;

function TTokensChain.GetTokenDecimals(AID: UINT64): UINT64;
var
  BaseBlock: TBaseBlock;
begin
  BaseBlock := GetBlock(AID);
  case BaseBlock.GetHeader.VersionData of
    0:
      begin
        var
          Trx: TTokensTrxV0;
        Trx := Copy(BaseBlock.GetData, SizeOf(THeader), Trx.GetSize);
        Result := Trx.TokensInfo.Decimals;
      end;
  end;
end;

function TTokensChain.GetTokenName(AID: UINT64): TSymbol;
begin
  Result := FastIndex.GetName(AID);
end;

{$ENDREGION}
{$REGION 'TTokensTrxV0'}


class operator TTokensTrxV0.Add(buf1: TBytes; buf2: TTokensTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTokensTrxV0));
  Move(buf2, LData[0], SizeOf(TTokensTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TTokensTrxV0.Add(buf2: TTokensTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTokensTrxV0));
  Move(buf2, LData[0], SizeOf(TTokensTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TTokensTrxV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TTokensTrxV0.Implicit(Buf: TTokensTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TTokensTrxV0.Implicit(Buf: TBytes): TTokensTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TTokensTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(TokensInfo, TokensInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.
