unit BlockChain.Transfer;

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
  BlockChain.FastIndex.Transfer,
  Crypto.RSA;

const
  LastVersionTransfer = 0;

type
  TTransferInfoV0 = packed record // 128
    DirectFrom: UINT64;
    DirectTo: UINT64;
    Amount: UINT64;
    TokenID: UINT64;
    class operator Implicit(Buf: TTransferInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TTransferInfoV0;
    class operator Add(buf1: TBytes; buf2: TTransferInfoV0): TBytes;
    class operator Add(buf2: TTransferInfoV0; buf1: TBytes): TBytes;
    function GetSize: integer;
  end;

  TTransferTrxV0 = packed record // 192
    TransferInfo: TTransferInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: integer;
    class operator Implicit(Buf: TTransferTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TTransferTrxV0;
    class operator Add(buf1: TBytes; buf2: TTransferTrxV0): TBytes;
    class operator Add(buf2: TTransferTrxV0; buf1: TBytes): TBytes;
    procedure SignTrx(Wallet: TWallet);
  end;

  TTransferBlockV0 = class(TBaseBlock)
  protected
    TransferInfo: TTransferTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: UINT64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    function GetDataHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(ATransferInfo: TTransferTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TTransferChain = class(TBaseChain)
  private
    FastIndex: TFastIndexBalances;
  public
    function GetTransactioHistory(AID, ATID: UINT64): TArray<TTransferHistoryData>;
    function GetBalances(AAID: UINT64): TBytes;
    function GetBalance(AAID, ATID: UINT64): UINT64;
    function GetBalanceWide(AAID, ATID: UINT64; var AAIDB, ATIDB: boolean): UINT64;
    function GetBlock(Ind: UINT64): TBaseBlock; override;
    procedure AddToFastIndex(AData: TBytes); override;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain); override;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TTransferInfoV0'}

class operator TTransferInfoV0.Add(buf1: TBytes; buf2: TTransferInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTransferInfoV0));
  Move(buf2, LData[0], SizeOf(TTransferInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TTransferInfoV0.Add(buf2: TTransferInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTransferInfoV0));
  Move(buf2, LData[0], SizeOf(TTransferInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TTransferInfoV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TTransferInfoV0.Implicit(Buf: TTransferInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TTransferInfoV0));
  Move(Buf, Result[0], SizeOf(TTransferInfoV0));
end;

class operator TTransferInfoV0.Implicit(Buf: TBytes): TTransferInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TTransferInfoV0));
end;
{$ENDREGION}
{$REGION 'TTransferBlockV0'}

constructor TTransferBlockV0.Create;
begin
  //
end;

constructor TTransferBlockV0.Create(ATransferInfo: TTransferTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  Data: TBytes;
begin
  Header.VersionData := 0;
  Header.TypeBlock := Byte(Transfers);
  Header.UnixTime := DateTimeToUnix(now, False);
  TransferInfo := ATransferInfo;
end;

class function TTransferBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalTransfer: TTransferTrxV0;
  LocalIDSigned: integer;
  LocalSign: TSignedHash;
  counter: integer;
begin
  LocalHeader := Default (THeader);
  LocalHeader.TypeBlock := Byte(TTypesChain.Transfers);

  LocalTransfer := Default (TTransferTrxV0);
    case NetState of
    MAINNET:
      FIllChar(LocalTransfer, SizeOf(LocalTransfer), 0);
    TESTNET:
      FIllChar(LocalTransfer, SizeOf(LocalTransfer), 1);
    LABNET:
      FIllChar(LocalTransfer, SizeOf(LocalTransfer), 2);
  end;

  Result := LocalHeader + LocalTransfer;
end;

function TTransferBlockV0.GetData: TBytes;
begin
  Result := Header + TransferInfo;
end;

function TTransferBlockV0.GetDataHeader: TBytes;
begin
  Result := Header;
end;

function TTransferBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := TransferInfo;
end;


function TTransferBlockV0.GetSizeBlock: UINT64;
begin
  Result := Header.GetSize + TransferInfo.GetSize;
end;

function TTransferBlockV0.GetTrxData: TBytes;
begin
  Result := TransferInfo;
end;

procedure TTransferBlockV0.SetData(const AData: TBytes);
var
  counter: integer;
begin
  counter := 0;

  Move(AData[counter], Header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  TransferInfo := Copy(AData, counter, TransferInfo.GetSize);
end;

{$ENDREGION}
{$REGION 'TTransferChain'}

procedure TTransferChain.AddToFastIndex(AData: TBytes);
begin
  var
    Buf: TTransferInfoV0 := Copy(AData, SizeOf(THeader), SizeOf(TTransferInfoV0));
  FastIndex.SetData(Buf.DirectFrom, Buf.TokenID, Buf.Amount, False);
  FastIndex.SetData(Buf.DirectTo, Buf.TokenID, Buf.Amount, True);
  Notifyer.DoEvent(nOnAcceptTransfers);
end;

constructor TTransferChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  inherited Create(AName, Data, AtypeChain);
  FastIndex := TFastIndexBalances.Create(AName);
end;

destructor TTransferChain.Destroy;
begin
  FastIndex.Free;
  inherited;
end;

function TTransferChain.GetBalance(AAID, ATID: UINT64): UINT64;
begin
  Result := FastIndex.GetBalance(AAID, ATID);
end;

function TTransferChain.GetBalances(AAID: UINT64): TBytes;
begin
  Result := FastIndex.GetAllBalances(AAID);
end;

function TTransferChain.GetBalanceWide(AAID, ATID: UINT64; var AAIDB, ATIDB: boolean): UINT64;
begin
  Result := FastIndex.GetBalanceWide(AAID, ATID, AAIDB, ATIDB);
end;

function TTransferChain.GetBlock(Ind: UINT64): TBaseBlock;
var
  Header: THeader;
  Data: TBytes;
var
  TransferBlockV0: TTransferBlockV0; // �� ������������� ��������� ����
begin
  ChainFile.TryRead(Ind, Data);
  Move(Data[0], Header, SizeOf(THeader));
  case Header.VersionData of
    0:
      begin
        TransferBlockV0 := TTransferBlockV0.Create;
        TransferBlockV0.SetData(Data);
        Result := TransferBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TTransferChain.GetTransactioHistory(AID, ATID: UINT64): TArray<TTransferHistoryData>;
var
  Block: TBaseBlock;
  Data: TTransferHistoryData;
begin
  Result := [];
  for var I := 1 to GetLastBlockID do
  begin
    try
      Block := GetBlock(I);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              Trx: TTransferTrxV0 := Block.GetDataWithoutHeader;
            var
              Info: TTransferInfoV0 := Trx.TransferInfo;
            if ((Info.DirectFrom = AID) or (Info.DirectTo = AID)) and (Info.TokenID = ATID) then
            begin
              Data.DirectFrom := Info.DirectFrom;
              Data.DirectTo := Info.DirectTo;
              Data.Plus := AID = Data.DirectTo;
              Data.Amount := Info.Amount;
              Data.TokenID := Info.TokenID;
              Data.UnixTime := Header.UnixTime;
              Data.BlockHash := Header.CurrentHash;
              Result := Result + [Data];
            end;
          end;
      end;
    finally
      Block.Free;
    end;
  end;

end;

{$ENDREGION}
{$REGION 'TTransferTrxV0'}

class operator TTransferTrxV0.Add(buf1: TBytes; buf2: TTransferTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTransferTrxV0));
  Move(buf2, LData[0], SizeOf(TTransferTrxV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TTransferTrxV0.Add(buf2: TTransferTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTransferTrxV0));
  Move(buf2, LData[0], SizeOf(TTransferTrxV0));
  RData := LData + RData;
  Result := RData;
end;

function TTransferTrxV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TTransferTrxV0.Implicit(Buf: TTransferTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;

class operator TTransferTrxV0.Implicit(Buf: TBytes): TTransferTrxV0;
begin
  Move(Buf[0], Result, SizeOf(Result));
end;

procedure TTransferTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(TransferInfo, TransferInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}

end.