unit BlockChain.Commission;

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
  LastVersion—ommission = 0;

type
  TCommissionInfoV0 = packed record
    ownerId: uint64;
    CommTransOrigCoin: uint64;
    CommRecService: uint64;
    CommTransTokenInside: uint64;
    CommCreateToken: uint64;
    CommCreateService: uint64;
    class operator Implicit(Buf: TCommissionInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TCommissionInfoV0;
    class operator Add(buf1: TBytes; buf2: TCommissionInfoV0): TBytes;
    class operator Add(buf2: TCommissionInfoV0; buf1: TBytes): TBytes;
    function GetSize: uint64;
  end;

  TCommissionTrxV0 = packed record // 192
    CommissionInfo: TCommissionInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: uint64;
    class operator Implicit(Buf: TCommissionTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TCommissionTrxV0;
    class operator Add(buf1: TBytes; buf2: TCommissionTrxV0): TBytes;
    class operator Add(buf2: TCommissionTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
  end;

  TCommissionBlockV0 = class(TBaseBlock)
  protected
    CommissionInfo: TCommissionTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetString: string;
    function GetSizeBlock: uint64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(A—ommissionInfo: TCommissionTrxV0;
      LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TCommissionChain = class(TBaseChain)
  public
    function GetCommissions: TArray<uint64>;
    function GetBlock(Ind: uint64): TBaseBlock; override;
    procedure AddToFastIndex(AData: TBytes); override;
  end;

implementation

{$REGION 'T—ommissionInfoV0'}

class operator TCommissionInfoV0.Add(buf1: TBytes;
  buf2: TCommissionInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TCommissionInfoV0));
  Move(buf2, LData[0], SizeOf(TCommissionInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TCommissionInfoV0.Add(buf2: TCommissionInfoV0;
  buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TCommissionInfoV0));
  Move(buf2, LData[0], SizeOf(TCommissionInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TCommissionInfoV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TCommissionInfoV0.Implicit(Buf: TCommissionInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TCommissionInfoV0));
  Move(Buf, Result[0], SizeOf(TCommissionInfoV0));
end;

class operator TCommissionInfoV0.Implicit(Buf: TBytes): TCommissionInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TCommissionInfoV0));
end;
{$ENDREGION}
{$REGION 'T—ommissionBlockV0'}

constructor TCommissionBlockV0.Create;
begin
  //
end;

function TCommissionBlockV0.GetString: string;
begin
  Result := 'Commission. Header.' + #13#10 + string(header) + #13#10 +
            'Commission. Data.' + #13#10 +
            'ownerId: ' + IntToStr(CommissionInfo.CommissionInfo.ownerId) + #13#10 +
            'CommTransOrigCoin: ' + IntToStr(CommissionInfo.CommissionInfo.CommTransOrigCoin) + #13#10 +
            'CommRecService: ' + IntToStr(CommissionInfo.CommissionInfo.CommRecService) + #13#10 +
            'CommTransTokenInside: ' + IntToStr(CommissionInfo.CommissionInfo.CommTransTokenInside) + #13#10  +
            'CommCreateToken: ' + IntToStr(CommissionInfo.CommissionInfo.CommCreateToken) + #13#10 +
            'CommCreateService: ' + IntToStr(CommissionInfo.CommissionInfo.CommCreateService) + #13#10;
end;

constructor TCommissionBlockV0.Create(A—ommissionInfo: TCommissionTrxV0;
  LastBlockHash: THash);
var
  Buf: TMemoryStream;
  data: TBytes;
begin
  header.VersionData := 0;
  header.TypeBlock := Byte(Commissions);
  header.UnixTime := DateTimeToUnix(now, False);
  CommissionInfo := A—ommissionInfo;
end;

class function TCommissionBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  Local—ommission: TCommissionTrxV0;
  LocalIDSigned: uint64;
  LocalSign: TSignedHash;
  counter: uint64;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(TTypesChain.Commissions);
  Local—ommission := Default (TCommissionTrxV0);
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

function TCommissionBlockV0.GetData: TBytes;
begin
  Result := header + CommissionInfo;
end;

function TCommissionBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := CommissionInfo;
end;

function TCommissionBlockV0.GetSizeBlock: uint64;
begin
  Result := header.GetSize + CommissionInfo.GetSize;
end;

function TCommissionBlockV0.GetTrxData: TBytes;
begin
  Result := CommissionInfo;
end;

procedure TCommissionBlockV0.SetData(const AData: TBytes);
var
  counter: uint64;
begin
  counter := 0;
  Move(AData[counter], header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));
  CommissionInfo := Copy(AData, counter, CommissionInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'T—ommissionChain'}

procedure TCommissionChain.AddToFastIndex(AData: TBytes);
begin
  inherited;

end;

function TCommissionChain.GetBlock(Ind: uint64): TBaseBlock;
var
  header: THeader;
  data: TBytes;
var
  commissionBlockV0: TCommissionBlockV0;
begin
  ChainFile.TryRead(Ind, data);
  Move(data[0], header, SizeOf(THeader));
  case header.VersionData of
    0:
      begin
        commissionBlockV0 := TCommissionBlockV0.Create;
        commissionBlockV0.SetData(data);
        Result := commissionBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TCommissionChain.GetCommissions: TArray<uint64>;
begin
  Result := [];
  var
  BaseBlock := GetBlock(GetLastBlockID);
  case BaseBlock.GetHeader.VersionData of
    0:
      begin
        try
          var
            Trx: TCommissionTrxV0 := BaseBlock.GetDataWithoutHeader;
          var
            Info: TCommissionInfoV0 := Trx.CommissionInfo;
          Result := [Info.CommTransOrigCoin] + [Info.CommRecService] +
            [Info.CommTransTokenInside] + [Info.CommCreateToken] +
            [Info.CommCreateService];
        except
          BaseBlock.Free;
          Result := [];
        end;
      end;
  end;
  BaseBlock.Free;
end;

{$ENDREGION}
{$REGION 'TcommissionTrxV0'}

class operator TCommissionTrxV0.Add(buf1: TBytes;
  buf2: TCommissionTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TCommissionTrxV0));
  Move(buf2, LData[0], SizeOf(TCommissionTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TCommissionTrxV0.Add(buf2: TCommissionTrxV0;
  buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TCommissionTrxV0));
  Move(buf2, LData[0], SizeOf(TCommissionTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TCommissionTrxV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TCommissionTrxV0.Implicit(Buf: TCommissionTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TCommissionTrxV0.Implicit(Buf: TBytes): TCommissionTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TCommissionTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(CommissionInfo, CommissionInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;
  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.
