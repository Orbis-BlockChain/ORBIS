unit BlockChain.Account;

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
  App.Log,
  Wallet.Types,
  BlockChain.BaseBlock,
  BlockChain.BaseChain,
  BlockChain.Types,
  BlockChain.FileHandler,
  BlockChain.FastIndex.Account,
  Crypto.RSA;

const
  LastVersionAccount = 0;

type
  TAccountInfoV0 = packed record // 128
    PublicKey: TPublicKey; // 96
    Address: THash; // 32
    class operator Implicit(Buf: TAccountInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TAccountInfoV0;
    class operator Add(buf1: TBytes; buf2: TAccountInfoV0): TBytes;
    class operator Add(buf2: TAccountInfoV0; buf1: TBytes): TBytes;
    function GetSize: uint64;
  end;

  TAccountTrxV0 = packed record // 192
    AccountInfo: TAccountInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: uint64;
    class operator Implicit(Buf: TAccountTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TAccountTrxV0;
    class operator Add(buf1: TBytes; buf2: TAccountTrxV0): TBytes;
    class operator Add(buf2: TAccountTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
    function CheckTrx(APublicKey: TBytes): boolean;
  end;

  TAccountBlockV0 = class(TBaseBlock)
  protected
    AccountInfo: TAccountTrxV0;
  public
    function GetString: string;
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: uint64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AAccountInfo: TAccountTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TAccountChain = class(TBaseChain)
  private
    FastIndex: TFastIndexAccount;
  public
    function GetBlock(Ind: uint64): TBaseBlock; override;
    function GetID(AHash: THash): uint64;
    function GetIDB(var ID: uint64; AName: THash): boolean;
    function GetName(AID: uint64): THash;
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
    procedure AddToFastIndex(AData: TBytes); override;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
    destructor Destroy; override;
  end;

implementation

{$REGION 'TAccountInfoV0'}

class operator TAccountInfoV0.Add(buf1: TBytes; buf2: TAccountInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TAccountInfoV0));
  Move(buf2, LData[0], SizeOf(TAccountInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TAccountInfoV0.Add(buf2: TAccountInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TAccountInfoV0));
  Move(buf2, LData[0], SizeOf(TAccountInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TAccountInfoV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TAccountInfoV0.Implicit(Buf: TAccountInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TAccountInfoV0));
  Move(Buf, Result[0], SizeOf(TAccountInfoV0));
end;

class operator TAccountInfoV0.Implicit(Buf: TBytes): TAccountInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TAccountInfoV0));
end;
{$ENDREGION}
{$REGION 'TAccountBlockV0'}

constructor TAccountBlockV0.Create;
begin

end;

constructor TAccountBlockV0.Create(AAccountInfo: TAccountTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin
  Header.VersionData := 0;
  Header.TypeBlock := Byte(Accounts);
  Header.UnixTime := DateTimeToUnix(now, False);
  AccountInfo := AAccountInfo;
end;

class function TAccountBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalAccount: TAccountTrxV0;
  LocalIDSigned: uint64;
  LocalSign: TSignedHash;
  counter: uint64;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(TTypesChain.Accounts);
  LocalAccount := Default (TAccountTrxV0);
  FIllChar(LocalAccount, SizeOf(LocalAccount), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;
  Result := LocalHeader + LocalAccount;
end;

function TAccountBlockV0.GetData: TBytes;
begin
  Result := Header + AccountInfo;
end;

function TAccountChain.GetIDB(var ID: uint64; AName: THash): boolean;
var
  IDt: uint64;
begin
  Result := FastIndex.GetIDB(ID, AName);
end;

function TAccountBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := AccountInfo;
end;


function TAccountBlockV0.GetSizeBlock: uint64;
begin
  Result := Header.GetSize + AccountInfo.GetSize;
end;

function TAccountBlockV0.GetString: string;
begin
  Result := 'Account. Header.' + #13#10 + string(Header) + #13#10 + 'Account. Data.' + #13#10 + 'PublicKey: ' +
    string(AccountInfo.AccountInfo.PublicKey) + #13#10 + 'Address:' + String(AccountInfo.AccountInfo.Address);
end;

function TAccountBlockV0.GetTrxData: TBytes;
begin
  Result := AccountInfo;
end;

procedure TAccountBlockV0.SetData(const AData: TBytes);
var
  counter: uint64;
begin
  counter := 0;

  Move(AData[counter], Header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  AccountInfo := Copy(AData, counter, AccountInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TAccountChain'}

function TAccountChain.ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
var
  i: integer;
  Inf: THelpInfoMainChain;
  Header: THeader;
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
      Header := Copy(Cache[i], 0, SizeOf(THeader));
      case Header.VersionData of
        0:
          begin
            var
              Block: TAccountBlockV0;
            Block := TAccountBlockV0.Create;
            Block.SetData(Cache[i]);
            var
              trx: TAccountTrxV0 := Block.GetDataWithoutHeader;
            Block.SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);
            if GetID(trx.AccountInfo.Address) = NaN then
            begin
              if ChainFile.TryWrite(Block.GetData, Block.GetHeader) then
              begin
                AddToFastIndex(Block.GetData);
                Inf.ID := ChainFile.GetLastBlockNumber;
                Inf.Hash := GetLastBlockHash;
                BlockChainLogs.DoAlert('ApproveBlocks', 'Address: ' + trx.AccountInfo.Address + 'Header: ' + Block.GetHeader);

                Result := Result + [Inf];
              end;
            end;
            Block.Free;
          end;
      end;
    end;
  end;
  Cache.Clear;
  cs.Leave;
end;

procedure TAccountChain.AddToFastIndex(AData: TBytes);
begin
  var
    Buf: TAccountInfoV0 := Copy(AData, SizeOf(THeader), SizeOf(TAccountInfoV0));
  FastIndex.SetData(GetLastBlockID, Buf.Address);
  Notifyer.DoEvent(nOnAcceptCC);
end;

constructor TAccountChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  inherited Create(AName, Data, AtypeChain);
  FastIndex := TFastIndexAccount.Create(AName);
end;

destructor TAccountChain.Destroy;
begin
  FastIndex.Free;
  inherited;
end;

function TAccountChain.GetBlock(Ind: uint64): TBaseBlock;
var
  Header: THeader;
  Data: TBytes;
var
  AccountBlockV0: TAccountBlockV0;
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], Header, SizeOf(THeader));
  case Header.VersionData of
    0:
      begin
        AccountBlockV0 := TAccountBlockV0.Create;
        AccountBlockV0.SetData(Data);
        Result := AccountBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TAccountChain.GetID(AHash: THash): uint64;
begin
  Result := FastIndex.GetID(AHash);
end;

function TAccountChain.GetName(AID: uint64): THash;
begin
  Result := FastIndex.GetName(AID);
end;
{$ENDREGION}
{$REGION 'TAccountTrxV0'}

class operator TAccountTrxV0.Add(buf1: TBytes; buf2: TAccountTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TAccountTrxV0));
  Move(buf2, LData[0], SizeOf(TAccountTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TAccountTrxV0.Add(buf2: TAccountTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TAccountTrxV0));
  Move(buf2, LData[0], SizeOf(TAccountTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TAccountTrxV0.CheckTrx(APublicKey: TBytes): boolean;
var
  Buf: TMemoryStream;
  Bytes: TBytes;
  signedHash, curHash: Thash;
begin
  try
    Buf := TMemoryStream.Create;
    Buf.Write(AccountInfo, AccountInfo.GetSize);
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

function TAccountTrxV0.GetSize: uint64;
begin
  Result := SizeOf(self);
end;

class operator TAccountTrxV0.Implicit(Buf: TAccountTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TAccountTrxV0.Implicit(Buf: TBytes): TAccountTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TAccountTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(AccountInfo, AccountInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.
