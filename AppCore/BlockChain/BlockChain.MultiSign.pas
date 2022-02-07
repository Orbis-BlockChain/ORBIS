unit BlockChain.MultiSign;

interface

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.Hash,
  System.DateUtils,
  App.Types,
  Wallet.Types,
  BlockChain.BaseBlock,
  BlockChain.BaseChain,
  BlockChain.Types,
  BlockChain.FileHandler,
  Crypto.RSA;

const
  LastVersionMultiSign = 0;
  Xsign = 31;
  CountSign = 8; // ?

type

  Tsign = record
    Data: array [0 .. Xsign] of byte;
  end;

  TValSign = record
    ValID: int64;
    ValSign: Tsign;
  end;

  TSetValSign = record
    SetSign: array [0 .. CountSign - 1] of TValSign;
  end;

  TMultiSignInfoV0 = packed record
    ValID: int64;
    BeginBlock: int64;
    EndBlock: int64;
    SignLastBlock: Tsign;
    SetValSign: TSetValSign;
    class operator Implicit(Buf: TMultiSignInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TMultiSignInfoV0;
    class operator Add(buf1: TBytes; buf2: TMultiSignInfoV0): TBytes;
    class operator Add(buf2: TMultiSignInfoV0; buf1: TBytes): TBytes;
    function GetSize: uint64;
  end;

  TMultiSignTrxV0 = packed record // 192
    MultiSignInfo: TMultiSignInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: uint64;
    class operator Implicit(Buf: TMultiSignTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TMultiSignTrxV0;
    class operator Add(buf1: TBytes; buf2: TMultiSignTrxV0): TBytes;
    class operator Add(buf2: TMultiSignTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
    function CheckTrx(APublicKey: TBytes): boolean;
  end;

  TMultiSignBlockV0 = class(TBaseBlock)
  protected
    MultiSignInfo: TMultiSignTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetString: string;
    function GetSizeBlock: uint64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AMultiSignInfo: TMultiSignTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TMultiSignChain = class(TBaseChain)
  public
    function GetBlock(Ind: uint64): TBaseBlock; override;
    function GetLastBlockID: uint64;
    procedure AddToFastIndex(AData: TBytes); override;
  end;

implementation

{$REGION 'TMultiSignInfoV0'}

class operator TMultiSignInfoV0.Add(buf1: TBytes; buf2: TMultiSignInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMultiSignInfoV0));
  Move(buf2, LData[0], SizeOf(TMultiSignInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TMultiSignInfoV0.Add(buf2: TMultiSignInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMultiSignInfoV0));
  Move(buf2, LData[0], SizeOf(TMultiSignInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TMultiSignInfoV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TMultiSignInfoV0.Implicit(Buf: TMultiSignInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TMultiSignInfoV0));
  Move(Buf, Result[0], SizeOf(TMultiSignInfoV0));
end;

class operator TMultiSignInfoV0.Implicit(Buf: TBytes): TMultiSignInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TMultiSignInfoV0));
end;
{$ENDREGION}
{$REGION 'TMultiSignBlockV0'}

constructor TMultiSignBlockV0.Create;
begin
  //
end;

function TMultiSignBlockV0.GetString: string;
begin
  Result := 'MultiSign. Header.' + #13#10 + string(header) + #13#10 + 'MultiSign. Data.' + #13#10 + 'ValID: ' +
    IntToStr(MultiSignInfo.MultiSignInfo.ValID) + #13#10 + 'BeginBlock: ' + IntToStr(MultiSignInfo.MultiSignInfo.BeginBlock) + #13#10 + 'EndBlock: ' +
    IntToStr(MultiSignInfo.MultiSignInfo.EndBlock) + #13#10;
end;

constructor TMultiSignBlockV0.Create(AMultiSignInfo: TMultiSignTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin

  header.VersionData := 0;
  header.TypeBlock := byte(MultiSigns);
  header.UnixTime := DateTimeToUnix(now, False);
  MultiSignInfo := AMultiSignInfo;
end;

class function TMultiSignBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalMultiSign: TMultiSignTrxV0;
  LocalIDSigned: uint64;
  LocalSign: TSignedHash;
  counter: uint64;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := byte(TTypesChain.MultiSigns);
  LocalMultiSign := Default (TMultiSignTrxV0);
  FIllChar(LocalMultiSign, SizeOf(LocalMultiSign), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;
  Result := LocalHeader + LocalMultiSign;
end;

function TMultiSignBlockV0.GetData: TBytes;
begin
  Result := header + MultiSignInfo;
end;

function TMultiSignBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := MultiSignInfo;
end;

function TMultiSignBlockV0.GetSizeBlock: uint64;
begin
  Result := header.GetSize + MultiSignInfo.GetSize;
end;

function TMultiSignBlockV0.GetTrxData: TBytes;
begin
  Result := MultiSignInfo;
end;

procedure TMultiSignBlockV0.SetData(const AData: TBytes);
var
  counter: uint64;
begin
  counter := 0;
  Move(AData[counter], header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));
  MultiSignInfo := Copy(AData, counter, MultiSignInfo.GetSize);
end;
{$ENDREGION}
{$REGION 'TMultiSignChain'}

procedure TMultiSignChain.AddToFastIndex(AData: TBytes);
begin
  inherited;

end;

function TMultiSignChain.GetBlock(Ind: uint64): TBaseBlock;
var
  header: THeader;
  Data: TBytes;
var
  MultiSignBlockV0: TMultiSignBlockV0;
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], header, SizeOf(THeader));
  case header.VersionData of
    0:
      begin
        MultiSignBlockV0 := TMultiSignBlockV0.Create;
        MultiSignBlockV0.SetData(Data);
        Result := MultiSignBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TMultiSignChain.GetLastBlockID: uint64;
begin
  Result := ChainFile.GetLastBlockNumber;
end;

{$ENDREGION}
{$REGION 'TMultiSignTrxV0'}

class operator TMultiSignTrxV0.Add(buf1: TBytes; buf2: TMultiSignTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMultiSignTrxV0));
  Move(buf2, LData[0], SizeOf(TMultiSignTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TMultiSignTrxV0.Add(buf2: TMultiSignTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMultiSignTrxV0));
  Move(buf2, LData[0], SizeOf(TMultiSignTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TMultiSignTrxV0.CheckTrx(APublicKey: TBytes): boolean;
var
  Buf: TMemoryStream;
  Bytes: TBytes;
  signedHash, curHash: Thash;
begin
  try
    Buf := TMemoryStream.Create;
    Buf.Write(MultiSignInfo, MultiSignInfo.GetSize);
    SetLength(Bytes, SizeOf(THash));
    Buf.Position := 0;
    Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
    Buf.Destroy;

    curHash := Bytes;

    signedHash := RSADecrypt(APublicKey, OwnerSign);
    Result := curHash = signedHash;
  except
    Result := False;
  end;
end;

function TMultiSignTrxV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TMultiSignTrxV0.Implicit(Buf: TMultiSignTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TMultiSignTrxV0.Implicit(Buf: TBytes): TMultiSignTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TMultiSignTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(MultiSignInfo, MultiSignInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;
  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;
{$ENDREGION}

end.
