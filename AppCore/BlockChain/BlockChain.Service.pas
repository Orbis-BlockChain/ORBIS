unit BlockChain.Service;

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
  BlockChain.FastIndex.Service,
  Crypto.RSA;

const
  LastVersionService = 0;

type
  TServiceInfoV0 = packed record
    Owner: UInt64;
    Name: TName;
    UnixTime: int64;
    class operator Implicit(Buf: TServiceInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TServiceInfoV0;
    class operator Add(buf1: TBytes; buf2: TServiceInfoV0): TBytes;
    class operator Add(buf2: TServiceInfoV0; buf1: TBytes): TBytes;
    function GetSize: integer;
  end;

  TServiceV0 = packed record
    ServiceInfo: TServiceInfoV0;
    OwnerSign: TSignedHash;
    function GetSize: integer;
    class operator Implicit(Buf: TServiceV0): TBytes;
    class operator Implicit(Buf: TBytes): TServiceV0;
    class operator Add(buf1: TBytes; buf2: TServiceV0): TBytes;
    class operator Add(buf2: TServiceV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
    function CheckTrx(APublicKey: TBytes): boolean;
  end;

  TServiceBlockV0 = class(TBaseBlock)
  protected
    ServiceInfo: TServiceV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetString: string;
    function GetSizeBlock: UInt64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AServiceInfo: TServiceV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TServiceChain = class(TBaseChain)
  private
    FastIndex: TFastIndexService;
  public
    function GetBlock(Ind: UInt64): TBaseBlock; override;
    function GetLastBlockID: UInt64;
    function GetIDService(AName: string): UInt64;
    function GetServiceName(AID: UInt64): TName;
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
    procedure AddToFastIndex(AData: TBytes); override;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain); override;
    destructor Destroy; override;
  end;

implementation

class operator TServiceInfoV0.Add(buf1: TBytes; buf2: TServiceInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceInfoV0));
  Move(buf2, LData[0], SizeOf(TServiceInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TServiceInfoV0.Add(buf2: TServiceInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceInfoV0));
  Move(buf2, LData[0], SizeOf(TServiceInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TServiceInfoV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TServiceInfoV0.Implicit(Buf: TServiceInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TServiceInfoV0));
  Move(Buf, Result[0], SizeOf(TServiceInfoV0));
end;

class operator TServiceInfoV0.Implicit(Buf: TBytes): TServiceInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TServiceInfoV0));
end;

constructor TServiceBlockV0.Create;
begin
  //
end;

function TServiceBlockV0.GetString: string;
begin
  Result := 'Service. Header.' + #13#10 + string(header) + #13#10 + 'Service. Data.' + #13#10 + 'Owner: ' + IntToStr(ServiceInfo.ServiceInfo.Owner) +
    #13#10 + 'Name: ' + string(ServiceInfo.ServiceInfo.Name) + #13#10 + 'UnixTime: ' +
    DateTimeToStr(UnixToDateTime(ServiceInfo.ServiceInfo.UnixTime));
end;

constructor TServiceBlockV0.Create(AServiceInfo: TServiceV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin
  header.VersionData := 0;
  header.TypeBlock := Byte(Service);
  header.UnixTime := DateTimeToUnix(now, False);
  ServiceInfo := AServiceInfo;
end;

class function TServiceBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalService: TServiceV0;
  LocalIDSigned: integer;
  LocalSign: TSignedHash;
  counter: integer;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(TTypesChain.Service);
  LocalService := Default (TServiceV0);
  FIllChar(LocalService, SizeOf(LocalService), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;
  Result := LocalHeader + LocalService;
end;

function TServiceBlockV0.GetData: TBytes;
begin
  Result := header + ServiceInfo;
end;

function TServiceBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := ServiceInfo;
end;

function TServiceBlockV0.GetSizeBlock: UInt64;
begin
  Result := header.GetSize + ServiceInfo.GetSize;
end;

function TServiceBlockV0.GetTrxData: TBytes;
begin
  Result := ServiceInfo;
end;

procedure TServiceBlockV0.SetData(const AData: TBytes);
var
  counter: integer;
begin
  counter := 0;

  Move(AData[counter], header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  ServiceInfo := Copy(AData, counter, ServiceInfo.GetSize);
end;

procedure TServiceChain.AddToFastIndex(AData: TBytes);
begin
  var
    Buf: TServiceInfoV0 := Copy(AData, SizeOf(THeader), SizeOf(TServiceInfoV0));
  FastIndex.SetData(GetLastBlockID, Buf.Name);
end;

function TServiceChain.ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
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
              Block: TServiceBlockV0;
            Block := TServiceBlockV0.Create;
            Block.SetData(Cache[i]);
            var
              trx: TServiceV0 := Block.GetDataWithoutHeader;
            Block.SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);
            if GetIDService(trx.ServiceInfo.Name) = 0 then
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

constructor TServiceChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  inherited Create(AName, Data, AtypeChain);
  FastIndex := TFastIndexService.Create(AName);
end;

destructor TServiceChain.Destroy;
begin
  FastIndex.Free;
  inherited;
end;

function TServiceChain.GetBlock(Ind: UInt64): TBaseBlock;
var
  header: THeader;
  Data: TBytes;
  ServiceBlockV0: TServiceBlockV0;
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], header, SizeOf(THeader));
  case header.VersionData of
    0:
      begin
        ServiceBlockV0 := TServiceBlockV0.Create;
        ServiceBlockV0.SetData(Data);
        Result := ServiceBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TServiceChain.GetIDService(AName: string): UInt64;
begin
  Result := FastIndex.GetID(AName);
end;

function TServiceChain.GetLastBlockID: UInt64;
begin
  Result := ChainFile.GetLastBlockNumber;
end;

function TServiceChain.GetServiceName(AID: UInt64): TName;
begin
  Result := FastIndex.GetName(AID);
end;

class operator TServiceV0.Add(buf1: TBytes; buf2: TServiceV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceV0));
  Move(buf2, LData[0], SizeOf(TServiceV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TServiceV0.Add(buf2: TServiceV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TServiceV0));
  Move(buf2, LData[0], SizeOf(TServiceV0));
  RData := LData + RData;
  Result := RData;
end;

function TServiceV0.CheckTrx(APublicKey: TBytes): boolean;
var
  Buf: TMemoryStream;
  Bytes: TBytes;
  signedHash, curHash: THash;
begin
  try
    Buf := TMemoryStream.Create;
    Buf.Write(ServiceInfo, ServiceInfo.GetSize);
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

function TServiceV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TServiceV0.Implicit(Buf: TServiceV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TServiceV0.Implicit(Buf: TBytes): TServiceV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TServiceV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(ServiceInfo, ServiceInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

end.
