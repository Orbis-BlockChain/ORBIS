unit BlockChain.Mining;

interface

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.Hash,
  System.DateUtils,
  App.Types,
  App.Log,
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
    function GetString: string;
    function GetSizeBlock: UInt64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AMiningInfo: TMiningTrxV0;
      LastBlockHash: THash); overload;
    constructor Create; overload;
    destructor Destroy; override;
  end;

  TMiningChain = class(TBaseChain)
  public
    function CheckOwner(const AUID: UInt64): boolean;
    function GetOMs: TArray<UInt64>;
    function GetBlock(Ind: UInt64): TBaseBlock; override;
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
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

function TMiningBlockV0.GetString: string;
begin
Result:= 'Mining. Header.'+#13#10+string(header)+ #13#10+
         'Mining. Data.'+#13#10+
                 'OwnerID: '+IntToStr(MiningInfo.MiningInfo.OwnerID);
end;

destructor TMiningBlockV0.Destroy;
begin

  inherited;
end;

constructor TMiningBlockV0.Create(AMiningInfo: TMiningTrxV0;
  LastBlockHash: THash);
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
  FIllChar(LocalMining, SizeOf(LocalMining), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
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

function TMiningChain.ApproveBlocks(Awallet: TWallet)
  : TArray<THelpInfoMainChain>;
var
  i: integer;
  Inf: THelpInfoMainChain;
  Header: THeader;
begin
  Result := [];
  if Cache.Count = 0 then
    exit
  else
  begin
    for i := 0 to Cache.Count - 1 do
    begin
      Header := Copy(Cache[i], 0, SizeOf(THeader));
      case Header.VersionData of
        0:
          begin
            var
              Block: TMiningBlockV0;
            Block := TMiningBlockV0.Create;
            Block.SetData(Cache[i]);
            var
              trx: TMiningTrxV0 := Block.GetTrxData;

            Block.SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);
            if not CheckOwner(trx.MiningInfo.OwnerID) then
            begin
              if ChainFile.TryWrite(Block.GetData, Block.GetHeader) then
              begin
                AddToFastIndex(Block.GetData);
                Inf.ID := ChainFile.GetLastBlockNumber;
                Inf.Hash := GetLastBlockHash;

                BlockChainLogs.DoAlert('ApproveBlocks',
                  'OwnerID: ' + Block.MiningInfo.MiningInfo.OwnerID.AsString +
                  'Header: ' + Stringof(Block.GetHeader));

                Result := Result + [Inf];
              end;
            end;
            Block.Free;
          end;
      end;
    end;
  end;

  Cache.Clear;
end;

function TMiningChain.CheckOwner(const AUID: UInt64): boolean;
var
  Owners: TArray<UInt64>;
begin
  Result := False;
  Owners := GetOMs;
  for var item in Owners do
    if item = AUID then
      exit(True);

end;

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
    var
      BaseBlock: TBaseBlock;
    BaseBlock := GetBlock(i);
    var
      Header: THeader;
    Header := BaseBlock.GetHeader;

    case Header.VersionData of
      0:
        begin
          var
            trx: TMiningTrxV0;
          trx := BaseBlock.GetDataWithoutHeader;
          var
            Info: TMiningInfoV0;
          Info := trx.MiningInfo;
          Return := Info.OwnerID;
        end;
    end;
    Result := Result + [Return];

    BaseBlock.Free;
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
