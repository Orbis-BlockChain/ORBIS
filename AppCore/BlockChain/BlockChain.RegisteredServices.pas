unit BlockChain.RegisteredServices;

interface

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.Hash,
  System.DateUtils,
  System.Generics.Collections,
  App.Types,
  App.Notifyer,
  Wallet.Types,
  BlockChain.BaseBlock,
  BlockChain.BaseChain,
  BlockChain.Types,
  BlockChain.FileHandler,
  BlockChain.FastIndex.RegistredService,
  Crypto.RSA;

const
  LastVersionRegistredService = 0;

type
  TRegistredServiceInfoV0 = packed record // 128
    IDOwner: UInt64;
    SeviceName: TName;
    Symbol: TSymbol;
    class operator Implicit(Buf: TRegistredServiceInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TRegistredServiceInfoV0;
    class operator Add(buf1: TBytes; buf2: TRegistredServiceInfoV0): TBytes;
    class operator Add(buf2: TRegistredServiceInfoV0; buf1: TBytes): TBytes;
    function GetSize: UInt64;
  end;

  TRegistredServiceTrxV0 = packed record // 192
    RegistredServiceInfo: TRegistredServiceInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: UInt64;
    class operator Implicit(Buf: TRegistredServiceTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TRegistredServiceTrxV0;
    class operator Add(buf1: TBytes; buf2: TRegistredServiceTrxV0): TBytes;
    class operator Add(buf2: TRegistredServiceTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
  end;

  TRegistredServiceBlockV0 = class(TBaseBlock)
  protected
    RegistredServiceInfo: TRegistredServiceTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: UInt64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(ARegistredServiceInfo: TRegistredServiceTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TRegistredServiceChain = class(TBaseChain)
  private
    FastIndex: TFastIndexRegistredService;
  public
    function GetBlock(Ind: UInt64): TBaseBlock; override;
    procedure AddToFastIndex(AData: TBytes); override;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
    destructor Destroy; override;
  end;

implementation

{$REGION 'TRegistredServiceInfoV0'}

class operator TRegistredServiceInfoV0.Add(buf1: TBytes; buf2: TRegistredServiceInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TRegistredServiceInfoV0));
  Move(buf2, LData[0], SizeOf(TRegistredServiceInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TRegistredServiceInfoV0.Add(buf2: TRegistredServiceInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TRegistredServiceInfoV0));
  Move(buf2, LData[0], SizeOf(TRegistredServiceInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TRegistredServiceInfoV0.GetSize: UInt64;
begin
  Result := SizeOf(self);
end;

class operator TRegistredServiceInfoV0.Implicit(Buf: TRegistredServiceInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TRegistredServiceInfoV0));
  Move(Buf, Result[0], SizeOf(TRegistredServiceInfoV0));
end;

class operator TRegistredServiceInfoV0.Implicit(Buf: TBytes): TRegistredServiceInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TRegistredServiceInfoV0));
end;
{$ENDREGION}
{$REGION 'TRegistredServiceBlockV0'}

constructor TRegistredServiceBlockV0.Create;
begin
  //
end;

constructor TRegistredServiceBlockV0.Create(ARegistredServiceInfo: TRegistredServiceTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin
  // Header.VersionData := 0;
  // Header.TypeBlock := Byte(RegistredServices);
  // Header.UnixTime := DateTimeToUnix(now, False);
  // RegistredServiceInfo := ARegistredServiceInfo;
end;

class function TRegistredServiceBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalRegistredService: TRegistredServiceTrxV0;
  LocalIDSigned: UInt64;
  LocalSign: TSignedHash;
  counter: UInt64;
begin
  // LocalHeader := Default (THeader);
  // LocalHeader.TypeBlock := Byte(TTypesChain.RegistredServices);
  // LocalRegistredService := Default (TRegistredServiceTrxV0);
  // case NetState of
  // MAINNET:
  // FIllChar(LocalRegistredService, SizeOf(LocalRegistredService), 0);
  // TESTNET:
  // FIllChar(LocalRegistredService, SizeOf(LocalRegistredService), 1);
  // LABNET:
  // FIllChar(LocalRegistredService, SizeOf(LocalRegistredService), 2);
  // end;
  // Result := LocalHeader + LocalRegistredService;
end;

function TRegistredServiceBlockV0.GetData: TBytes;
begin
  Result := Header + RegistredServiceInfo;
end;

function TRegistredServiceBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := RegistredServiceInfo;
end;

function TRegistredServiceBlockV0.GetSizeBlock: UInt64;
begin
  Result := Header.GetSize + RegistredServiceInfo.GetSize;
end;

function TRegistredServiceBlockV0.GetTrxData: TBytes;
begin
  Result := RegistredServiceInfo;
end;

procedure TRegistredServiceBlockV0.SetData(const AData: TBytes);
var
  counter: UInt64;
begin
  counter := 0;

  Move(AData[counter], Header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  RegistredServiceInfo := Copy(AData, counter, RegistredServiceInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TRegistredServiceChain'}

procedure TRegistredServiceChain.AddToFastIndex(AData: TBytes);
begin
  var
    Buf: TRegistredServiceInfoV0 := Copy(AData, SizeOf(THeader), SizeOf(TRegistredServiceInfoV0));
  FastIndex.SetData(Buf.IDOwner, Buf.SeviceName, Buf.Symbol);
  Notifyer.DoEvent(nOnAcceptCC);
end;

constructor TRegistredServiceChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  inherited Create(AName, Data, AtypeChain);
  FastIndex := TFastIndexRegistredService.Create(AName);
end;

destructor TRegistredServiceChain.Destroy;
begin
  FastIndex.Free;
  inherited;
end;

function TRegistredServiceChain.GetBlock(Ind: UInt64): TBaseBlock;
var
  Header: THeader;
  Data: TBytes;
var
  RegistredServiceBlockV0: TRegistredServiceBlockV0;
  // По необходимости добовлять типы
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], Header, SizeOf(THeader));
  case Header.VersionData of
    0:
      begin
        RegistredServiceBlockV0 := TRegistredServiceBlockV0.Create;
        RegistredServiceBlockV0.SetData(Data);
        Result := RegistredServiceBlockV0;
      end;
  else
    Result := nil;
  end;
end;

{$ENDREGION}
{$REGION 'TRegistredServiceTrxV0'}

class operator TRegistredServiceTrxV0.Add(buf1: TBytes; buf2: TRegistredServiceTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TRegistredServiceTrxV0));
  Move(buf2, LData[0], SizeOf(TRegistredServiceTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TRegistredServiceTrxV0.Add(buf2: TRegistredServiceTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TRegistredServiceTrxV0));
  Move(buf2, LData[0], SizeOf(TRegistredServiceTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TRegistredServiceTrxV0.GetSize: UInt64;
begin
  Result := SizeOf(self);
end;

class operator TRegistredServiceTrxV0.Implicit(Buf: TRegistredServiceTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TRegistredServiceTrxV0.Implicit(Buf: TBytes): TRegistredServiceTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TRegistredServiceTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(RegistredServiceInfo, RegistredServiceInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.
