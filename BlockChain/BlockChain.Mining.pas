unit BlockChain.Mining;

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
  LastVersionMining = 0;

type
  TMiningInfoV0 = packed record
    OwnerID: UInt64;
    class operator Implicit(Buf: TMiningInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TMiningInfoV0;
    class operator Add(buf1: TBytes; buf2: TMiningInfoV0): TBytes;
    class operator Add(buf2: TMiningInfoV0; buf1: TBytes): TBytes;
    function GetSize: UInt64;
  end;

  TMiningTrxV0 = packed record
    MiningInfo: TMiningInfoV0;
    OwnerSign: TSignedHash;
    function GetSize: UInt64;
    class operator Implicit(Buf: TMiningTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TMiningTrxV0;
    class operator Add(buf1: TBytes; buf2: TMiningTrxV0): TBytes;
    class operator Add(buf2: TMiningTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
  end;

  TMiningBlockV0 = class(TBaseBlock)
  protected
    MiningInfo: TMiningTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: UInt64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AMiningInfo: TMiningTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TMiningChain = class(TBaseChain)
  public
    function GetOMs: TArray<UInt64>;
    function GetBlock(Ind: UInt64): TBaseBlock; override;
    procedure AddToFastIndex(AData: TBytes); override;
  end;

implementation

{$REGION 'TMiningInfoV0'}


class operator TMiningInfoV0.Add(buf1: TBytes; buf2: TMiningInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMiningInfoV0));
  Move(buf2, LData[0], SizeOf(TMiningInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TMiningInfoV0.Add(buf2: TMiningInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMiningInfoV0));
  Move(buf2, LData[0], SizeOf(TMiningInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TMiningInfoV0.GetSize: UInt64;
begin
  Result := SizeOf(self);
end;

class operator TMiningInfoV0.Implicit(Buf: TMiningInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TMiningInfoV0));
  Move(Buf, Result[0], SizeOf(TMiningInfoV0));
end;

class operator TMiningInfoV0.Implicit(Buf: TBytes): TMiningInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TMiningInfoV0));
end;
{$ENDREGION}
{$REGION 'TMiningBlockV0'}


constructor TMiningBlockV0.Create;
begin
  //
end;

constructor TMiningBlockV0.Create(AMiningInfo: TMiningTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  data: TBytes;
begin
  Header.VersionData := LastVersionMining;
  Header.TypeBlock := Byte(Mining);
  Header.UnixTime := DateTimeToUnix(now, False);
  MiningInfo := AMiningInfo;
end;

class function TMiningBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalMining: TMiningTrxV0;
  LocalIDSigned: UInt64;
  LocalSign: TSignedHash;
  counter: UInt64;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(TTypesChain.Mining);
  LocalMining := Default (TMiningTrxV0);
  case NetState of
    MAINNET:
      FIllChar(LocalMining, SizeOf(LocalMining), 0);
    TESTNET:
      FIllChar(LocalMining, SizeOf(LocalMining), 1);
    LABNET:
      FIllChar(LocalMining, SizeOf(LocalMining), 2);
  end;
  Result := LocalHeader + LocalMining;
end;

function TMiningBlockV0.GetData: TBytes;
begin
  Result := Header + MiningInfo;
end;

function TMiningBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := MiningInfo;
end;

function TMiningBlockV0.GetSizeBlock: UInt64;
begin
  Result := Header.GetSize + MiningInfo.GetSize;
end;

function TMiningBlockV0.GetTrxData: TBytes;
begin
  Result := MiningInfo;
end;

procedure TMiningBlockV0.SetData(const AData: TBytes);
var
  counter: UInt64;
begin
  counter := 0;

  Move(AData[counter], Header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  MiningInfo := Copy(AData, counter, MiningInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TMiningChain'}


procedure TMiningChain.AddToFastIndex(AData: TBytes);
begin
  inherited;

end;

function TMiningChain.GetBlock(Ind: UInt64): TBaseBlock;
var
  Header: THeader;
  data: TBytes;
var
  MiningBlockV0: TMiningBlockV0;
begin
  ChainFile.TryRead(Ind, data);
  Move(data[0], Header, SizeOf(THeader));
  case Header.VersionData of
    0:
      begin
        MiningBlockV0 := TMiningBlockV0.Create;
        MiningBlockV0.SetData(data);
        Result := MiningBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TMiningChain.GetOMs: TArray<UInt64>;
var
  Return: UInt64;
begin
  Result := [];
  for var i := 1 to GetLastBlockID do
  begin
    var BaseBlock: TBaseBlock;
    BaseBlock := GetBlock(i);
    var Header: THeader;
    Header := BaseBlock.GetHeader;

    case Header.VersionData of
      0:
        begin
          var Trx: TMiningTrxV0;
          Trx := BaseBlock.GetDataWithoutHeader;
          var Info: TMiningInfoV0;
          Info := Trx.MiningInfo;
          Return := Info.OwnerID;
        end;
    end;
    Result := Result + [Return];
  end;

end;

{$ENDREGION}
{$REGION 'TMiningTrxV0'}


class operator TMiningTrxV0.Add(buf1: TBytes; buf2: TMiningTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMiningTrxV0));
  Move(buf2, LData[0], SizeOf(TMiningTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TMiningTrxV0.Add(buf2: TMiningTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMiningTrxV0));
  Move(buf2, LData[0], SizeOf(TMiningTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TMiningTrxV0.GetSize: UInt64;
begin
  Result := SizeOf(self);
end;

class operator TMiningTrxV0.Implicit(Buf: TMiningTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TMiningTrxV0.Implicit(Buf: TBytes): TMiningTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TMiningTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(MiningInfo, MiningInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.