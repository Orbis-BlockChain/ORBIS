unit BlockChain.Mined;

interface

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.Hash,
  System.DateUtils,
  System.Generics.Collections,
  App.Types,
  App.Log,
  App.Notifyer,
  Wallet.Types,
  BlockChain.BaseBlock,
  BlockChain.BaseChain,
  BlockChain.Types,
  BlockChain.FileHandler,
  BlockChain.FastIndex.Account,
  Crypto.RSA;

const
  LastVersionMined = 0;

type
  TMinedInfoV0 = packed record
    IDWitness: UInt64;
    FromBlock: UInt64;
    DateTime: int64;
    class operator Implicit(Buf: TMinedInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TMinedInfoV0;
    class operator Add(buf1: TBytes; buf2: TMinedInfoV0): TBytes;
    class operator Add(buf2: TMinedInfoV0; buf1: TBytes): TBytes;
    function GetSize: UInt64;
  end;

  TMinedTrxV0 = packed record
    MinedInfo: TMinedInfoV0;
    OwnerSign: TSignedHash;
    function GetSize: UInt64;
    class operator Implicit(Buf: TMinedTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TMinedTrxV0;
    class operator Add(buf1: TBytes; buf2: TMinedTrxV0): TBytes;
    class operator Add(buf2: TMinedTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
    function CheckTrx(APublicKey: TBytes): boolean;
  end;

  TMinedBlockV0 = class(TBaseBlock)
  protected
    MinedInfo: TMinedTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetString: string;
    function GetSizeBlock: UInt64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AMinedInfo: TMinedTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TMinedChain = class(TBaseChain)
  public
    function GetBlock(Ind: UInt64): TBaseBlock; override;
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
    procedure AddToFastIndex(AData: TBytes); override;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
    destructor Destroy; override;
  end;

implementation

{$REGION 'TMinedInfoV0'}

class operator TMinedInfoV0.Add(buf1: TBytes; buf2: TMinedInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMinedInfoV0));
  Move(buf2, LData[0], SizeOf(TMinedInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TMinedInfoV0.Add(buf2: TMinedInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMinedInfoV0));
  Move(buf2, LData[0], SizeOf(TMinedInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TMinedInfoV0.GetSize: UInt64;
begin
  Result := SizeOf(self);
end;

class operator TMinedInfoV0.Implicit(Buf: TMinedInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TMinedInfoV0));
  Move(Buf, Result[0], SizeOf(TMinedInfoV0));
end;

class operator TMinedInfoV0.Implicit(Buf: TBytes): TMinedInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TMinedInfoV0));
end;
{$ENDREGION}
{$REGION 'TMinedBlockV0'}

constructor TMinedBlockV0.Create;
begin
  //
end;

function TMinedBlockV0.GetString: string;
begin
  Result := 'Mined. Header.' + #13#10 + string(header) + #13#10 + 'Mined. Data.' + #13#10 + 'IDWitness: ' + IntToStr(MinedInfo.MinedInfo.IDWitness) +
    #13#10 + 'FromBlock: ' + IntToStr(MinedInfo.MinedInfo.FromBlock) + #13#10 + 'DateTime: ' +
    DateTimeToStr(UnixToDateTime(MinedInfo.MinedInfo.DateTime));
end;

constructor TMinedBlockV0.Create(AMinedInfo: TMinedTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin
  header.VersionData := 0;
  header.TypeBlock := Byte(Mined);
  header.UnixTime := DateTimeToUnix(now, False);
  MinedInfo := AMinedInfo;
end;

class function TMinedBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalMined: TMinedTrxV0;
  LocalIDSigned: UInt64;
  LocalSign: TSignedHash;
  counter: UInt64;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(Mined);
  LocalMined := Default (TMinedTrxV0);
  FIllChar(LocalMined, SizeOf(LocalMined), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;
  Result := LocalHeader + LocalMined;
end;

function TMinedBlockV0.GetData: TBytes;
begin
  Result := header + MinedInfo;
end;

function TMinedBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := MinedInfo;
end;

function TMinedBlockV0.GetSizeBlock: UInt64;
begin
  Result := header.GetSize + MinedInfo.GetSize;
end;

function TMinedBlockV0.GetTrxData: TBytes;
begin
  Result := MinedInfo;
end;

procedure TMinedBlockV0.SetData(const AData: TBytes);
var
  counter: UInt64;
begin
  counter := 0;

  Move(AData[counter], header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  MinedInfo := Copy(AData, counter, MinedInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TMinedChain'}

function TMinedChain.ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
var
  i: integer;
  Inf: THelpInfoMainChain;
  header: THeader;
begin
  cs.Enter;
  Result := [];
  if Cache.Count = 0 then
  begin
    cs.Leave;
    exit;
  end
  else
  begin
    for i := 0 to Cache.Count - 1 do
    begin
      header := Copy(Cache[i], 0, SizeOf(THeader));
      case header.VersionData of
        0:
          begin
            var
              Block: TMinedBlockV0;
            Block := TMinedBlockV0.Create;
            Block.SetData(Cache[i]);
            var
              trx: TMinedTrxV0 := Block.GetDataWithoutHeader;
            Block.SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);
            if ChainFile.TryWrite(Block.GetData, Block.GetHeader) then
            begin
              AddToFastIndex(Block.GetData);
              Inf.ID := ChainFile.GetLastBlockNumber;
              Inf.Hash := GetLastBlockHash;

              BlockChainLogs.DoAlert('ApproveBlocks', 'IDWitness: ' + Block.MinedInfo.MinedInfo.IDWitness.AsString + 'FromBlock: ' +
                Block.MinedInfo.MinedInfo.FromBlock.AsString + 'DateTime: ' + Block.MinedInfo.MinedInfo.DateTime.ToString + 'Header: ' +
                Stringof(Block.GetHeader));

              Result := Result + [Inf];
            end;
            Block.Free;
          end;
      end;
    end;
  end;
  Cache.Clear;
  cs.Leave;
end;

procedure TMinedChain.AddToFastIndex(AData: TBytes);
begin
  var
    Buf: TMinedInfoV0 := Copy(AData, SizeOf(THeader), SizeOf(TMinedInfoV0));
end;

constructor TMinedChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  inherited Create(AName, Data, AtypeChain);
end;

destructor TMinedChain.Destroy;
begin
  inherited;
end;

function TMinedChain.GetBlock(Ind: UInt64): TBaseBlock;
var
  header: THeader;
  Data: TBytes;
var
  MinedBlockV0: TMinedBlockV0;
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], header, SizeOf(THeader));
  case header.VersionData of
    0:
      begin
        MinedBlockV0 := TMinedBlockV0.Create;
        MinedBlockV0.SetData(Data);
        Result := MinedBlockV0;
      end;
  else
    Result := nil;
  end;
end;

{$ENDREGION}
{$REGION 'TMinedTrxV0'}

class operator TMinedTrxV0.Add(buf1: TBytes; buf2: TMinedTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMinedTrxV0));
  Move(buf2, LData[0], SizeOf(TMinedTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TMinedTrxV0.Add(buf2: TMinedTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMinedTrxV0));
  Move(buf2, LData[0], SizeOf(TMinedTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TMinedTrxV0.CheckTrx(APublicKey: TBytes): boolean;
var
  Buf: TMemoryStream;
  Bytes: TBytes;
  signedHash, curHash: THash;
begin
  try
    Buf := TMemoryStream.Create;
    Buf.Write(MinedInfo, MinedInfo.GetSize);
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

function TMinedTrxV0.GetSize: UInt64;
begin
  Result := SizeOf(self);
end;

class operator TMinedTrxV0.Implicit(Buf: TMinedTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TMinedTrxV0.Implicit(Buf: TBytes): TMinedTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TMinedTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(MinedInfo, MinedInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.
