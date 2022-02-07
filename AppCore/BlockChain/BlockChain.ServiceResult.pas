unit BlockChain.ServiceResult;

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
  Crypto.RSA;

const
  LastVersionServiceResult = 0;
  ResultSize = 100;

type
  TSRData = array [0 .. ResultSize - 1] of byte;

  TServiceResultInfoV0 = packed record
    ID: UINT64;
    Data: TSRData;
    UnixTime: int64;
    class operator Implicit(Buf: TServiceResultInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TServiceResultInfoV0;
    class operator Add(buf1: TBytes; buf2: TServiceResultInfoV0): TBytes;
    class operator Add(buf2: TServiceResultInfoV0; buf1: TBytes): TBytes;
    function GetSize: integer;
  end;

  TServiceResultV0 = packed record
    ServiceResultInfo: TServiceResultInfoV0;
    OwnerSign: TSignedHash;
    function GetSize: integer;
    class operator Implicit(Buf: TServiceResultV0): TBytes;
    class operator Implicit(Buf: TBytes): TServiceResultV0;
    class operator Add(buf1: TBytes; buf2: TServiceResultV0): TBytes;
    class operator Add(buf2: TServiceResultV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
    function CheckTrx(APublicKey: TBytes): boolean;
  end;

  TServiceResultBlockV0 = class(TBaseBlock)
  protected
    ServiceResultInfo: TServiceResultV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetString: string;
    function GetSizeBlock: UINT64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AServiceResultInfo: TServiceResultV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TBlockSRData = TArray<TServiceResultV0>;

  TServiceResultChain = class(TBaseChain)
  private
    //
  public
    function GetBlock(Ind: UINT64): TBaseBlock; override;
    function GetLastBlockID: UINT64;
    procedure AddToFastIndex(AData: TBytes); override;
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain); override;
    destructor Destroy; override;
  end;

implementation

class operator TServiceResultInfoV0.Add(buf1: TBytes; buf2: TServiceResultInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceResultInfoV0));
  Move(buf2, LData[0], SizeOf(TServiceResultInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TServiceResultInfoV0.Add(buf2: TServiceResultInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceResultInfoV0));
  Move(buf2, LData[0], SizeOf(TServiceResultInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TServiceResultInfoV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TServiceResultInfoV0.Implicit(Buf: TServiceResultInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TServiceResultInfoV0));
  Move(Buf, Result[0], SizeOf(TServiceResultInfoV0));
end;

class operator TServiceResultInfoV0.Implicit(Buf: TBytes): TServiceResultInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TServiceResultInfoV0));
end;

constructor TServiceResultBlockV0.Create;
begin
  //
end;

function TServiceResultBlockV0.GetString: string;
begin
  Result := 'ServiceResult. Header.' + #13#10 + string(header) + #13#10 + 'ServiceResult. Data.' + #13#10 + 'ID: ' +
    IntToStr(ServiceResultInfo.ServiceResultInfo.ID) + #13#10 + 'UnixTime: ' +
    DateTimeToStr(UnixToDateTime(ServiceResultInfo.ServiceResultInfo.UnixTime));
end;

constructor TServiceResultBlockV0.Create(AServiceResultInfo: TServiceResultV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin
  header.VersionData := 0;
  header.TypeBlock := byte(ServiceResult);
  header.UnixTime := DateTimeToUnix(now, False);
  ServiceResultInfo := AServiceResultInfo;
end;

class function TServiceResultBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalServiceResult: TServiceResultV0;
  LocalIDSigned: integer;
  LocalSign: TSignedHash;
  counter: integer;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := byte(TTypesChain.ServiceResult);
  LocalServiceResult := Default (TServiceResultV0);
  FIllChar(LocalServiceResult, SizeOf(LocalServiceResult), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;
  Result := LocalHeader + LocalServiceResult;
end;

function TServiceResultBlockV0.GetData: TBytes;
begin
  Result := header + ServiceResultInfo;
end;

function TServiceResultBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := ServiceResultInfo;
end;

function TServiceResultBlockV0.GetSizeBlock: UINT64;
begin
  Result := header.GetSize + ServiceResultInfo.GetSize;
end;

function TServiceResultBlockV0.GetTrxData: TBytes;
begin
  Result := ServiceResultInfo;
end;

procedure TServiceResultBlockV0.SetData(const AData: TBytes);
var
  counter: integer;
begin
  counter := 0;

  Move(AData[counter], header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  ServiceResultInfo := Copy(AData, counter, ServiceResultInfo.GetSize);
end;

procedure TServiceResultChain.AddToFastIndex(AData: TBytes);
begin
  inherited;
end;

function TServiceResultChain.ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
var
  i: integer;
  Inf: THelpInfoMainChain;
  header: THeader;
begin
  Result := [];
  if Cache.Count = 0 then
    exit
  else
  begin
    for i := 0 to Cache.Count - 1 do
    begin
      header := Copy(Cache[i], 0, SizeOf(THeader));
      case header.VersionData of
        0:
          begin
            var
              Block: TServiceResultBlockV0;
            Block := TServiceResultBlockV0.Create;
            Block.SetData(Cache[i]);
            var
              trx: TServiceResultV0 := Block.GetDataWithoutHeader;
            Block.SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);
            begin
              if ChainFile.TryWrite(Block.GetData, Block.GetHeader) then
              begin
                AddToFastIndex(Block.GetData);
                Inf.ID := ChainFile.GetLastBlockNumber;
                Inf.Hash := GetLastBlockHash;
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

constructor TServiceResultChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  inherited Create(AName, Data, AtypeChain);
end;

destructor TServiceResultChain.Destroy;
begin
  inherited;
end;

function TServiceResultChain.GetBlock(Ind: UINT64): TBaseBlock;
var
  header: THeader;
  Data: TBytes;
  ServiceResultBlockV0: TServiceResultBlockV0;
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], header, SizeOf(THeader));
  case header.VersionData of
    0:
      begin
        ServiceResultBlockV0 := TServiceResultBlockV0.Create;
        ServiceResultBlockV0.SetData(Data);
        Result := ServiceResultBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TServiceResultChain.GetLastBlockID: UINT64;
begin
  Result := ChainFile.GetLastBlockNumber;
end;

class operator TServiceResultV0.Add(buf1: TBytes; buf2: TServiceResultV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceResultV0));
  Move(buf2, LData[0], SizeOf(TServiceResultV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TServiceResultV0.Add(buf2: TServiceResultV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceResultV0));
  Move(buf2, LData[0], SizeOf(TServiceResultV0));
  RData := LData + RData;
  Result := RData;
end;

function TServiceResultV0.CheckTrx(APublicKey: TBytes): boolean;
var
  Buf: TMemoryStream;
  Bytes: TBytes;
  signedHash, curHash: THash;
begin
  try
    Buf := TMemoryStream.Create;          
    Buf.Write(ServiceResultInfo, ServiceResultInfo.GetSize);
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

function TServiceResultV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TServiceResultV0.Implicit(Buf: TServiceResultV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TServiceResultV0.Implicit(Buf: TBytes): TServiceResultV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TServiceResultV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(ServiceResultInfo, ServiceResultInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

end.
