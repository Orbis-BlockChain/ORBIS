unit BlockChain.VotingResults;

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
  LastVersionVotingResult = 0;

type
  TVotingResultInfoV0 = packed record // 128
    VotingID: uint64;
    VotingTime: int64; // UnixTime
    VotingRequest: uint64;
    VotingOwnerID: uint64;
    VotingOwnerResult: boolean;
    class operator Implicit(Buf: TVotingResultInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TVotingResultInfoV0;
    class operator Add(buf1: TBytes; buf2: TVotingResultInfoV0): TBytes;
    class operator Add(buf2: TVotingResultInfoV0; buf1: TBytes): TBytes;
    function GetSize: uint64;
  end;

  TVotingResultTrxV0 = packed record // 192
    VotingResultInfo: TVotingResultInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: uint64;
    class operator Implicit(Buf: TVotingResultTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TVotingResultTrxV0;
    class operator Add(buf1: TBytes; buf2: TVotingResultTrxV0): TBytes;
    class operator Add(buf2: TVotingResultTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
    function CheckTrx(APublicKey: TBytes): boolean;
  end;

  TVotingResultBlockV0 = class(TBaseBlock)
  protected
    VotingResultInfo: TVotingResultTrxV0;
  public
    function GetString: string;
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: uint64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AVotingResultInfo: TVotingResultTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TVotingResultChain = class(TBaseChain)
  public
    function GetBlock(Ind: uint64): TBaseBlock; override;
    procedure AddToFastIndex(AData: TBytes); override;
  end;

implementation

{$REGION 'TVotingResultInfoV0'}

class operator TVotingResultInfoV0.Add(buf1: TBytes; buf2: TVotingResultInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVotingResultInfoV0));
  Move(buf2, LData[0], SizeOf(TVotingResultInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TVotingResultInfoV0.Add(buf2: TVotingResultInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVotingResultInfoV0));
  Move(buf2, LData[0], SizeOf(TVotingResultInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TVotingResultInfoV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TVotingResultInfoV0.Implicit(Buf: TVotingResultInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TVotingResultInfoV0));
  Move(Buf, Result[0], SizeOf(TVotingResultInfoV0));
end;

class operator TVotingResultInfoV0.Implicit(Buf: TBytes): TVotingResultInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TVotingResultInfoV0));
end;
{$ENDREGION}
{$REGION 'TVotingResultBlockV0'}

constructor TVotingResultBlockV0.Create;
begin
  //
end;

function TVotingResultBlockV0.GetString: string;
begin
  Result := 'VotingResult. Header.' + #13#10 + string(header) + #13#10 + 'VotingResult. Data.' + #13#10 + 'VotingID: ' +
    IntToStr(VotingResultInfo.VotingResultInfo.VotingID) + #13#10 + 'VotingTime: ' +
    DateTimeToStr(UnixToDateTime(VotingResultInfo.VotingResultInfo.VotingTime)) + #13#10 + 'VotingRequest: ' +
    IntToStr(VotingResultInfo.VotingResultInfo.VotingRequest) + #13#10 + 'VotingOwnerID: ' + IntToStr(VotingResultInfo.VotingResultInfo.VotingOwnerID)
    + #13#10 + 'VotingOwnerResult: ' + BoolToStr(VotingResultInfo.VotingResultInfo.VotingOwnerResult);
end;

constructor TVotingResultBlockV0.Create(AVotingResultInfo: TVotingResultTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  data: TBytes;
begin
  header.VersionData := 0;
  header.TypeBlock := Byte(VotingResults);
  VotingResultInfo := AVotingResultInfo;
end;

class function TVotingResultBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalVotingResult: TVotingResultTrxV0;
  LocalIDSigned: uint64;
  LocalSign: TSignedHash;
  counter: uint64;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(TTypesChain.VotingResults);
  LocalVotingResult := Default (TVotingResultTrxV0);
  FIllChar(LocalVotingResult, SizeOf(LocalVotingResult), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;

  Result := LocalHeader + LocalVotingResult;
end;

function TVotingResultBlockV0.GetData: TBytes;
begin
  Result := header + VotingResultInfo;
end;

function TVotingResultBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := VotingResultInfo;
end;

function TVotingResultBlockV0.GetSizeBlock: uint64;
begin
  Result := header.GetSize + VotingResultInfo.GetSize;
end;

function TVotingResultBlockV0.GetTrxData: TBytes;
begin
  Result := VotingResultInfo;
end;

procedure TVotingResultBlockV0.SetData(const AData: TBytes);
var
  counter: uint64;
begin
  counter := 0;

  Move(AData[counter], header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  VotingResultInfo := Copy(AData, counter, VotingResultInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TVotingResultChain'}

procedure TVotingResultChain.AddToFastIndex(AData: TBytes);
begin
  inherited;

end;

function TVotingResultChain.GetBlock(Ind: uint64): TBaseBlock;
var
  header: THeader;
  data: TBytes;
var
  VotingResultBlockV0: TVotingResultBlockV0;
begin
  ChainFile.TryRead(Ind, data);
  Move(data[0], header, SizeOf(THeader));
  case header.VersionData of
    0:
      begin
        VotingResultBlockV0 := TVotingResultBlockV0.Create;
        VotingResultBlockV0.SetData(data);
        Result := VotingResultBlockV0;
      end;
  else
    Result := nil;
  end;
end;
{$ENDREGION}
{$REGION 'TVotingResultTrxV0'}

class operator TVotingResultTrxV0.Add(buf1: TBytes; buf2: TVotingResultTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVotingResultTrxV0));
  Move(buf2, LData[0], SizeOf(TVotingResultTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TVotingResultTrxV0.Add(buf2: TVotingResultTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TVotingResultTrxV0));
  Move(buf2, LData[0], SizeOf(TVotingResultTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TVotingResultTrxV0.CheckTrx(APublicKey: TBytes): boolean;
var
  Buf: TMemoryStream;
  Bytes: TBytes;
  signedHash, curHash: THash;
begin
  try
    Buf := TMemoryStream.Create;
    Buf.Write(VotingResultInfo, VotingResultInfo.GetSize);
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

function TVotingResultTrxV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TVotingResultTrxV0.Implicit(Buf: TVotingResultTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TVotingResultTrxV0.Implicit(Buf: TBytes): TVotingResultTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TVotingResultTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(VotingResultInfo, VotingResultInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.
