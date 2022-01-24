unit BlockChain.VoteRequest;

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
  LastVersionVoteRequest = 0;

type
  TVoteRequestInfoV0 = packed record
    OwnerRequest: uint64;
    CommTransOrigCoin: uint64;
    CommRecService: uint64;
    CommTransTokenInside: uint64;
    CommCreateToken: uint64;
    CommCreateService: uint64;
    class operator Implicit(Buf: TVoteRequestInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TVoteRequestInfoV0;
    class operator Add(buf1: TBytes; buf2: TVoteRequestInfoV0): TBytes;
    class operator Add(buf2: TVoteRequestInfoV0; buf1: TBytes): TBytes;
    function GetSize: uint64;
  end;

  TVoteRequestTrxV0 = packed record // 192
    VoteRequestInfo: TVoteRequestInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: uint64;
    class operator Implicit(Buf: TVoteRequestTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TVoteRequestTrxV0;
    class operator Add(buf1: TBytes; buf2: TVoteRequestTrxV0): TBytes;
    class operator Add(buf2: TVoteRequestTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
  end;

  TVoteRequestBlockV0 = class(TBaseBlock)
  protected
    VoteRequestInfo: TVoteRequestTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: uint64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AVoteRequestInfo: TVoteRequestTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TVoteRequestChain = class(TBaseChain)
  public
    function GetBlock(Ind: uint64): TBaseBlock; override;
    procedure AddToFastIndex(AData: TBytes); override;
  end;

implementation

{$REGION 'TVoteRequestInfoV0'}


class operator TVoteRequestInfoV0.Add(buf1: TBytes; buf2: TVoteRequestInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVoteRequestInfoV0));
  Move(buf2, LData[0], SizeOf(TVoteRequestInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TVoteRequestInfoV0.Add(buf2: TVoteRequestInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVoteRequestInfoV0));
  Move(buf2, LData[0], SizeOf(TVoteRequestInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TVoteRequestInfoV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TVoteRequestInfoV0.Implicit(Buf: TVoteRequestInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TVoteRequestInfoV0));
  Move(Buf, Result[0], SizeOf(TVoteRequestInfoV0));
end;

class operator TVoteRequestInfoV0.Implicit(Buf: TBytes): TVoteRequestInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TVoteRequestInfoV0));
end;
{$ENDREGION}
{$REGION 'TVoteRequestBlockV0'}


constructor TVoteRequestBlockV0.Create;
begin
  //
end;

constructor TVoteRequestBlockV0.Create(AVoteRequestInfo: TVoteRequestTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  data: TBytes;
begin
  Header.VersionData := 0;
  Header.TypeBlock := Byte(VoteRequest);
  Header.UnixTime := DateTimeToUnix(now, False);
  VoteRequestInfo := AVoteRequestInfo;
end;

class function TVoteRequestBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  Local—ommission: TVoteRequestTrxV0;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(VoteRequest);
  Local—ommission := Default (TVoteRequestTrxV0);
  FIllChar(Local—ommission, SizeOf(Local—ommission), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;
  Result := LocalHeader + Local—ommission;
end;

function TVoteRequestBlockV0.GetData: TBytes;
begin
  Result := Header + VoteRequestInfo;
end;

function TVoteRequestBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := VoteRequestInfo;
end;

function TVoteRequestBlockV0.GetSizeBlock: uint64;
begin
  Result := Header.GetSize + VoteRequestInfo.GetSize;
end;

function TVoteRequestBlockV0.GetTrxData: TBytes;
begin
  Result := VoteRequestInfo;
end;

procedure TVoteRequestBlockV0.SetData(const AData: TBytes);
var
  counter: uint64;
begin
  counter := 0;
  Move(AData[counter], Header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));
  VoteRequestInfo := Copy(AData, counter, VoteRequestInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TVoteRequestChain'}


procedure TVoteRequestChain.AddToFastIndex(AData: TBytes);
begin
  inherited;

end;

function TVoteRequestChain.GetBlock(Ind: uint64): TBaseBlock;
var
  Header: THeader;
  data: TBytes;
var
  —ommissionBlockV0: TVoteRequestBlockV0;
begin
  ChainFile.TryRead(Ind, data);
  Move(data[0], Header, SizeOf(THeader));
  case Header.VersionData of
    0:
      begin
        —ommissionBlockV0 := TVoteRequestBlockV0.Create;
        —ommissionBlockV0.SetData(data);
        Result := —ommissionBlockV0;
      end;
  else
    Result := nil;
  end;
end;

{$ENDREGION}
{$REGION 'TVoteRequestTrxV0'}


class operator TVoteRequestTrxV0.Add(buf1: TBytes; buf2: TVoteRequestTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVoteRequestTrxV0));
  Move(buf2, LData[0], SizeOf(TVoteRequestTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TVoteRequestTrxV0.Add(buf2: TVoteRequestTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVoteRequestTrxV0));
  Move(buf2, LData[0], SizeOf(TVoteRequestTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TVoteRequestTrxV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TVoteRequestTrxV0.Implicit(Buf: TVoteRequestTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TVoteRequestTrxV0.Implicit(Buf: TBytes): TVoteRequestTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TVoteRequestTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(VoteRequestInfo, VoteRequestInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;
  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.
