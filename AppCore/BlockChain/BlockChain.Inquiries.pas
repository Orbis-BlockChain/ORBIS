unit BlockChain.Inquiries;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Hash,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,
  System.TypInfo,
  System.Rtti,
  System.DateUtils,
  System.IOUtils,
  System.SyncObjs,
  App.Types,
  App.Meta,
  App.Log,
  BlockChain.BaseBlock,
  BlockChain.MainChain,
  BlockChain.Account,
  BlockChain.MultiSign,
  BlockChain.VotingResults,
  BlockChain.Commission,
  BlockChain.Transfer,
  BlockChain.Tokens,
  BlockChain.Mining,
  BlockChain.Types,
  BlockChain.Service,
  BlockChain.ServiceResult,
  BlockChain.Mined,
  Crypto.RSA,
  Wallet.Core,
  Wallet.Types;

type
  TBlockChainInquiries = class
  private
    MainChain: TMainChain;
    AccountsChain: TAccountChain;
    MultiSignChain: TMultiSignChain;
    VotingResultChain: TVotingResultChain;
    CommissionChain: TCommissionChain;
    TransferChain: TTransferChain;
    TokensChain: TTokensChain;
    MiningChain: TMiningChain;
    ServiceChain: TServiceChain;
    ServiceResultChain: TServiceResultChain;
    MinedChain: TMinedChain;
    function ReadBlock(AIndBlock: integer; AType: TTypesChain): TBytes;
    function GetBlockOwner(IDChain, IDBlock: UInt64): UInt64;
    function CheckBlock(ABlock: TBaseBlock; PublicKey: TPublicKey; ACountBlockInChain: UInt64): boolean;
    procedure WriteBlock(const AData: TBytes; AType: TTypesChain; ABlockVersion: integer = -1);
    procedure SetTrxInMainChain(TypeChain: TTypesChain; lastBlock: UInt64; Hash: THash; AWallet: TWallet);
    procedure CoruptedBlockChain;
    procedure CreateTransfersForNewToken(const AID: UInt64; AWallet: TWallet);
    procedure CheckAccountsCache;
    procedure CheckTokensCache;
    procedure CheckTransfersCache;
    procedure CheckMiningssCache;
    function GetDataAsString(mainblockid: UInt64): string;
  public
    function GetAllCacheTrx: TBytes;
    function CountCacheBlock: UInt64;
    function GetOMs: TArray<UInt64>;
    function GetTransactionHistory(AID, ATID: UInt64): TArray<string>;
    function GetBalances(AAccountID: UInt64): TBytes;
    function TryGetBalance(AHash: THash; ASymbol: string): double;
    function TryGetBalanceString(AHash: THash; ASymbol: string): String;
    function CheckAddress(AHash: THash): boolean;
    function CheckAddressB(AHash: THash): boolean;
    function TryGetAccountID(AHash: THash): UInt64;
    function TryGetPublicKey(AID: UInt64): TPublicKey;
    function TryGetTokenID(ASymbol: TSymbol): UInt64;
    function TryCheckIfTokenExists(Symbol: TSymbol): boolean;
    function TryGetTokenDecimals(AID: UInt64): UInt64;
    function TryGetTokenSymbol(AID: UInt64): TSymbol;
    function TryGetTokenInfo(ASymbol: String): TTokensInfoV0;
    function TryGetTokenInfoAll(Sort: String = 'datetime'): TArray<TTokensInfoV0>;
    function TryGetAccountAddress(AccID: UInt64): THash;
    function TryGetTransCount(AccID, TokenID: UInt64): UInt64;
    function TryGetTokenTransCount(Symbol: TSymbol): UInt64;
    function TryGetTransInfo(AHash: THash): TTransHistoryItem;
    function TryGetTransBetweenTime(AccID: UInt64; UnixFrom, UnixTo: Int64): TArray<TTransferInfoV0>;
    function TryGetTransactionHistoryItems(AccID: UInt64; UnixFrom, UnixTo: Int64): TArray<TTransHistoryItem>;
    function TryGetAllTransactionsBySymbol(Symbol: TSymbol): TArray<TTransHistoryItem>;
    function TryGetALLTransactions(Sort: String = 'blocknum'): TArray<TTransHistoryItem>;
    function TryGetMinedInfo(Sort:String = 'datetime'): TArray<TMinedInfo>;
    function TryGetLastMined: Int64;
    function TryGetCountOM: UInt64;
    function TryGetSentAmountAllTime(AID, TID: UInt64): double;
    function TryGetReceivedAmountAllTime(AID, TID: UInt64): double;
    function GetVolumeFromAmount(Amount: UInt64; Decimals: UInt64): double; overload;
    function GetVolumeFromAmount(Amount: UInt64; Decimals: UInt64; IsForce: Boolean): String; overload;
    function GetVolumeFromAmountToken(Amount: UInt64; TokenID: UInt64): double;
    function GetAmountFromVolume(Volume: Double; Decimals: UInt64): UInt64;
    function TryGetTransAmount(Trans: TTransferInfoV0): double;
    function TryGetCommissionsInfoAll: TArray<string>;
    function TryGetAccTransactions(AccID: UInt64): TArray<TTransferInfoV0>;
    function TryGetAccountInfo(Address: THash): TAccountInfoV0;
    function TryGetALLServices(Sort: String = 'datetime'): TArray<TServiceInfoV0>;
    function TryGetServiceInfo(ID: UInt64): TServiceInfoV0;
    function TryGetServiceDataByID(ID: UInt64): TArray<TServiceResultV0>;
    function TryGetAccRegDate(Address: THash): Int64;
    function TryGetAllAccounts(Sort: String = 'datetime'): TArray<TAccountInfoV0>;

    function TryGetTokenOwners(Symbol: TSymbol): TArray<TAccountInfoV0>;
    function TryGetFunctionAboutOwningOM(UID: UInt64): boolean;
    function CreateTrxNewToken(ASymbol, AName, ADecimals, AVolume: string; AToken: TToken; AWallet: TWallet): TBytes;
    function CreateTrxNewTransfer(var OwnerSign: string; ASymbol: string; AIDTo, AAmount: UInt64; AWallet: TWallet; isForce: boolean = False): TBytes;
    function TryGetTransInfoByOwnerSign(AOwnerSign: string): TArray<string>;
    function TryGetAccTokensCountCreate(Address: String): UInt64;
    function TryGetServiceID(AName: string): UInt64;
    function CreateNewService(AName: string; AWallet: TWallet): TBytes;
    function SetServiceData(ID: UInt64; Data: TSRData; AWallet: TWallet): TServiceResultV0;
    function GetServiceData(ID: UInt64): TBlockSRData;
    function TryGetAccTokensCount(Address: String): UInt64;
    function TryGetTransInfoByID(TID: UInt64): TTransHistoryItem;
    function CreateTrxNewWallet(Wallet: TWallet): TBytes;
    function GetBlocksFrom(const AID: UInt64): TBytes;
    function GetChains: TArray<string>;
    function GetDataFromChain(i: integer): TArray<TArray<TPair<string, string>>>;
    function GetDataFromChainToMonitor(i: integer): integer;
    function MainChainCount: UInt64;
    function SetTrxCacheChain(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet; out ACountBlocks: UInt64): boolean;
    function CreateTokenWithCommisson(ABytes: TBytes; AWallet: TWallet): boolean;
    function SearchMiningOwnerID(OwnerID: UInt64): boolean;
    function DoEasyBuyOm(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet; out ACountBlocks: UInt64): boolean;
    function TestDeSerializtion(const buf: TBytes): boolean;
    function ApproveAllCachedBlocks(AWallet: TWallet; out ACountBlocks: UInt64): TBytes;
    function CheckHashByInfo(const Buffer; Count: integer; Pkey: TPublicKey; buf: TBytes): boolean;
    function CheckAnyID(AType: TTypesChain; AID: UInt64): boolean;
    function CheckBlocks(AFromID, AToID: UInt64): boolean;
    function GetMainLastblocHash: THash;
    function GetMainLastblocHashFromID(AID: UInt64): THash;
    function TryCheckAccIDByMining(AID: UInt64): boolean;
    function GetDateTimeLastMining: Int64;
    function CreateTrxNewMinedData(AWallet: TWallet; AFromBlock: UInt64): TBytes;
    function NeedCalcMine: boolean;
    procedure DoMining(AWallet: TWallet; var ACountBlocks: integer);
    procedure SetAllCacheTrx(AData: TBytes);
    procedure CreateOM(const AID: UInt64);
    function SetNewBlocks(buf: TBytes; var AError: string): boolean;
    procedure DoCorruptedBC;
    constructor Create(AMainChain: TMainChain; AAccountsChain: TAccountChain; ATokensChain: TTokensChain; ATransferChain: TTransferChain;
      AMultiSignChain: TMultiSignChain; AVotingResultChain: TVotingResultChain; AÑommissionChain: TCommissionChain; AMiningChain: TMiningChain;
      AServiceChain: TServiceChain; AServiceResultChain: TServiceResultChain; AMinedChain: TMinedChain);
    destructor Destroy; override;
  end;

implementation

{ TBlockChainInquiries }
function TBlockChainInquiries.CreateTokenWithCommisson(ABytes: TBytes; AWallet: TWallet): boolean;
var
  lastBlock: UInt64;
  Hash, HashBuf: THash;
  WorkData: TBytes;
  counter: integer;
  trx: TTransferTrxV0;
  trxt: TTokensTrxV0;
  BaseBlockTrx: TTransferBlockV0;
begin
  Result := True;
  counter := 0;
  try
    case LastVersionTransfer of
      0:
        begin
          trx := Copy(ABytes, counter, SizeOf(TTransferTrxV0));
          counter := SizeOf(TTransferTrxV0);
          if TransferChain.GetBalance(trx.TransferInfo.DirectFrom, trx.TransferInfo.TokenID) < GetVolumeFromAmount(trx.TransferInfo.Amount,
            TokensChain.GetTokenDecimals(trx.TransferInfo.TokenID)) then
            raise Exception.Create('Not enough funds');
          BaseBlockTrx := TTransferBlockV0.Create(trx, TransferChain.GetLastBlockHash);
          TransferChain.SetBlock(BaseBlockTrx.GetData);
          BaseBlockTrx.Free;
        end;
    else
      Result := False;
    end;
    if Result then
      case LastVersionTokens of
        0:
          begin
            trxt := Copy(ABytes, counter, SizeOf(TTokensTrxV0));
            if TryGetTokenID(trxt.TokensInfo.Symbol) > 0 then
            begin
              Result := False;
              exit;
            end;
            var
              BaseBlock: TTokensBlockV0;
            BaseBlock := TTokensBlockV0.Create(trxt, TokensChain.GetLastBlockHash);
            TokensChain.SetBlock(BaseBlock.GetData);
            BaseBlock.Free;
          end;
      else
        Result := False;
      end;
  except
    Result := False;
  end;
end;

function TBlockChainInquiries.GetDataFromChainToMonitor(i: integer): integer;
var
  Nt: integer;
begin
  Nt := 0;
  case TTypesChain(i) of
    Main:
      begin
        Nt := MainChain.GetLastBlockID;
      end;

    Accounts:
      begin
        Nt := AccountsChain.GetLastBlockID;
      end;

    Tokens:
      begin
        Nt := TokensChain.GetLastBlockID
      end;

    Transfers:
      begin
        Nt := TransferChain.GetLastBlockID;
      end;

  end;
  Result := Nt;

end;

procedure TBlockChainInquiries.CreateTransfersForNewToken(const AID: UInt64; AWallet: TWallet);
var
  RAW: TBaseBlock;
  Header: THeader;
  Owner, Amount: UInt64;
begin
  for var i := AID + 1 to TokensChain.GetLastBlockID do
  begin
    RAW := TokensChain.GetBlock(i);
    Header := RAW.GetHeader;
    case Header.VersionData of
      0:
        begin
          var
            trx: TTokensTrxV0 := RAW.GetDataWithoutHeader;
          Owner := trx.TokensInfo.Owner;
          Amount := trx.TokensInfo.Volume;
        end;
    end;
    RAW.Free;
    var
      TrxTransfer: TTransferTrxV0;
    TrxTransfer.TransferInfo.DirectFrom := 0;
    TrxTransfer.TransferInfo.DirectTo := Owner;
    TrxTransfer.TransferInfo.Amount := Amount;
    TrxTransfer.TransferInfo.TokenID := i;
    TrxTransfer.SignTrx(AWallet);
    var
      BaseBlockTrx: TTransferBlockV0;
    BaseBlockTrx := TTransferBlockV0.Create(TrxTransfer, TransferChain.GetLastBlockHash);
    TransferChain.SetBlock(BaseBlockTrx.GetData);
    BaseBlockTrx.Free;
  end;
end;

function TBlockChainInquiries.ApproveAllCachedBlocks(AWallet: TWallet; out ACountBlocks: UInt64): TBytes;
var
  lastBlock, idFromToken: UInt64;
  Hash, HashBuf: THash;
  bufA, bufB: TBytes;
  helpInfo: TArray<THelpInfoMainChain>;
begin
  try
    ACountBlocks := 0;
    helpInfo := AccountsChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
      begin
        SetTrxInMainChain(Accounts, item.ID, item.Hash, AWallet);
        BlockChainLogs.DoAlert('ApproveAllCachedBlocks', 'Accounts, item.ID:' + item.ID.AsString + ', item.Hash:' + item.Hash);
      end;
    end;
    idFromToken := TokensChain.GetLastBlockID;
    helpInfo := TokensChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
      begin
        SetTrxInMainChain(Tokens, item.ID, item.Hash, AWallet);
        BlockChainLogs.DoAlert('ApproveAllCachedBlocks', 'Tokens, item.ID:' + item.ID.AsString + ', item.Hash:' + item.Hash);
      end;
    end;
    CreateTransfersForNewToken(idFromToken, AWallet);
    helpInfo := TransferChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
      begin
        SetTrxInMainChain(Transfers, item.ID, item.Hash, AWallet);
        BlockChainLogs.DoAlert('ApproveAllCachedBlocks', 'Transfers, item.ID:' + item.ID.AsString + ', item.Hash:' + item.Hash);
      end;
    end;
    helpInfo := MiningChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
      begin
        SetTrxInMainChain(Mining, item.ID, item.Hash, AWallet);
        BlockChainLogs.DoAlert('ApproveAllCachedBlocks', 'Mining, item.ID:' + item.ID.AsString + ', item.Hash:' + item.Hash);
      end;
    end;

    helpInfo := ServiceChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
      begin
        SetTrxInMainChain(Service, item.ID, item.Hash, AWallet);
        BlockChainLogs.DoAlert('ApproveAllCachedBlocks', 'Service, item.ID:' + item.ID.AsString + ', item.Hash:' + item.Hash);
      end;
    end;

    helpInfo := ServiceResultChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
      begin
        SetTrxInMainChain(ServiceResult, item.ID, item.Hash, AWallet);
        BlockChainLogs.DoAlert('ApproveAllCachedBlocks', 'ServiceResult, item.ID:' + item.ID.AsString + ', item.Hash:' + item.Hash);
      end;
    end;

    helpInfo := MinedChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
      begin
        SetTrxInMainChain(Mined, item.ID, item.Hash, AWallet);
        BlockChainLogs.DoAlert('ApproveAllCachedBlocks', 'Mined, item.ID:' + item.ID.AsString + ', item.Hash:' + item.Hash);
      end;
    end;

    if ACountBlocks > 0 then
      Result := GetBlocksFrom(MainChainCount - ACountBlocks);
  except
    Result := [];
  end;
end;

procedure TBlockChainInquiries.CheckAccountsCache;
var
  Header: THeader;
  ItemsOnDelete: TArray<TBytes>;
begin
  ItemsOnDelete := [];
  for var item in AccountsChain.Cache do
  begin
    Header := Copy(item, 0, SizeOf(Header));
    case Header.VersionData of
      0:
        begin
          var
            Block: TAccountBlockV0;
          Block := TAccountBlockV0.Create;
          Block.SetData(item);
          var
            trx: TAccountTrxV0 := Block.GetTrxData;
          if AccountsChain.GetID(trx.AccountInfo.Address) <> NaN then
            ItemsOnDelete := ItemsOnDelete + [item];
          Block.Free;
        end;
    end;
  end;
  for var item in ItemsOnDelete do
    AccountsChain.Cache.Remove(item);
end;

function TBlockChainInquiries.CheckAddress(AHash: THash): boolean;
var
  ID: UInt64;
begin
  ID := AccountsChain.GetID(AHash);
  Result := ID < NaN;
end;

function TBlockChainInquiries.CheckAddressB(AHash: THash): boolean;
var
  ID: UInt64;
begin
  Result := AccountsChain.GetIDB(ID, AHash);
end;

function TBlockChainInquiries.TryGetTransInfoByID(TID: UInt64): TTransHistoryItem;
var
  Block: TBaseBlock;
  Data: TTransHistoryItem;
begin
  Result := Default (TTransHistoryItem);
  try
    Block := TransferChain.GetBlock(TID);
    var
    Header := Block.GetHeader;
    case Header.VersionData of
      0:
        begin
          var
            trx: TTransferTrxV0 := Block.GetDataWithoutHeader;
          var
            info: TTransferInfoV0 := trx.TransferInfo;
          Data.datetime := Header.UnixTime;
          Data.block_number := TID;
          Data.Afrom := TryGetAccountAddress(info.DirectFrom);
          Data.Ato := TryGetAccountAddress(info.DirectTo);
          Data.Hash := Header.CurrentHash;
          Data.token := TryGetTokenSymbol(info.TokenID);
          Data.sent := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID));
          Data.sentstr := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID), False);
          Data.received := 0;
          Data.receivedstr := '0';
          Data.fee := 0;
          Result := Data;
        end;
    end;
  finally
    Block.Free;
  end;
end;

function TBlockChainInquiries.TryGetTransInfoByOwnerSign(AOwnerSign: string): TArray<string>;
var
  Block: TBaseBlock;
  Data: TBytes;
begin
  Result := [];
  for var j := 1 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(j);
      Data := Block.GetDataWithoutHeader;
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              info: TSignedHash := TTransferTrxV0(Data).OwnerSign;
            if info = AOwnerSign then
            begin
              Result := [TTransferTrxV0(Data).OwnerSign, 'DateTimeUnix', TTransferTrxV0(Data).TransferInfo.DateTimeUnix.ToString, 'DirectFrom',
                TTransferTrxV0(Data).TransferInfo.DirectFrom.AsString, 'DirectTo', TTransferTrxV0(Data).TransferInfo.DirectTo.AsString, 'Amount',
                TTransferTrxV0(Data).TransferInfo.Amount.AsString, 'TokenID', TTransferTrxV0(Data).TransferInfo.TokenID.AsString];
              break;
            end;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.TryGetLastMined: Int64;
var
  Data: TBytes;
  Block: TBaseBlock;
begin
  Result := 0;
  try
    Block := MinedChain.GetBlock(MinedChain.GetLastBlockID);
    var
    Header := Block.GetHeader;
    case Header.VersionData of
      0:
        begin
          Data := Block.GetDataWithoutHeader;
          Result := TMinedTrxV0(Data).MinedInfo.datetime;
        end;
    end;
  finally
    Block.Free;
  end;
end;

function TBlockChainInquiries.TryGetMinedInfo(Sort:String = 'datetime'): TArray<TMinedInfo>;
var
  Data: TBytes;
  Block: TBaseBlock;
  AMined: TMinedInfo;
begin
  Result := [];
  for var j := 1 to MinedChain.GetLastBlockID do
  begin
    try
      Block := MinedChain.GetBlock(j);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            Data := MinedChain.GetBlock(j).GetDataWithoutHeader;
            var
              info: TMinedInfoV0 := TMinedTrxV0(Data).MinedInfo;

            AMined.ValidAddress := TryGetAccountAddress(info.IDWitness);
            AMined.BlockNumber := info.FromBlock;
            AMined.DateTime := info.DateTime;

            Result := Result + [AMined];
          end;
      end;
    finally
      Block.Free;
    end;
  end;

  TArray.Sort<TMinedInfo>(Result, TComparer<TMinedInfo>.Construct(
    function(const Left, Right: TMinedInfo): integer
    begin
      if Sort = 'datetime' then
        Result := CompareValue(Left.DateTime, Right.DateTime)
      else
        Result := CompareValue(Left.BlockNumber, Right.BlockNumber)
    end));
end;

function TBlockChainInquiries.TryGetAccTokensCount(Address: String): UInt64;
begin
  Result := 0;
  for var j := 0 to TokensChain.GetLastBlockID do
  begin
    if TransferChain.GetBalance(TryGetAccountID(Address), j) > 0 then
      inc(Result);
  end;
end;

function TBlockChainInquiries.TryGetAccTokensCountCreate(Address: String): UInt64;
var
  Data: TBytes;
  Block: TBaseBlock;
begin
  Result := 0;
  for var j := 0 to TokensChain.GetLastBlockID do
  begin
    try
      Block := TokensChain.GetBlock(j);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            Data := TokensChain.GetBlock(j).GetDataWithoutHeader;
            var
              info: TTokensInfoV0 := TTokensTrxV0(Data).TokensInfo;
            if ((TryGetAccountID(Address) = info.Owner) and (info.Volume > 0)) then
              inc(Result);
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.CheckAnyID(AType: TTypesChain; AID: UInt64): boolean;
begin
  Result := True;
  case AType of
    Main:
      begin
        Result := MainChain.CheckID(AID);
      end;
    Accounts:
      begin
        Result := AccountsChain.CheckID(AID);
      end;
    Tokens:
      begin
        Result := TokensChain.CheckID(AID);
      end;
    Transfers:
      begin
        Result := TransferChain.CheckID(AID);
      end;
    MultiSigns:
      begin
        Result := MultiSignChain.CheckID(AID);
      end;
    VotingResults:
      begin
        Result := VotingResultChain.CheckID(AID);
      end;
    Commissions:
      begin
        Result := CommissionChain.CheckID(AID);
      end;
    Mining:
      begin
        Result := MiningChain.CheckID(AID);
      end;
    Service:
      begin
        Result := ServiceChain.CheckID(AID)
      end;
    ServiceResult:
      begin
        Result := ServiceResultChain.CheckID(AID)
      end;
    Mined:
      begin
        Result := MinedChain.CheckID(AID)
      end;
  end;
end;

constructor TBlockChainInquiries.Create(AMainChain: TMainChain; AAccountsChain: TAccountChain; ATokensChain: TTokensChain;
  ATransferChain: TTransferChain; AMultiSignChain: TMultiSignChain; AVotingResultChain: TVotingResultChain; AÑommissionChain: TCommissionChain;
  AMiningChain: TMiningChain; AServiceChain: TServiceChain; AServiceResultChain: TServiceResultChain; AMinedChain: TMinedChain);
begin
  MainChain := AMainChain;
  AccountsChain := AAccountsChain;
  MultiSignChain := AMultiSignChain;
  VotingResultChain := AVotingResultChain;
  CommissionChain := AÑommissionChain;
  TransferChain := ATransferChain;
  TokensChain := ATokensChain;
  MiningChain := AMiningChain;
  ServiceChain := AServiceChain;
  ServiceResultChain := AServiceResultChain;
  MinedChain := AMinedChain;
end;

function TBlockChainInquiries.CreateNewService(AName: string; AWallet: TWallet): TBytes;
var
  Base: TServiceInfoV0;
  S: TServiceV0;
begin
  if ((ServiceChain.GetIDService(AName) = 0) and (AName <> '')) then
  begin
    Base.Owner := WalletID;
    Base.Name := AName;
    Base.UnixTime := DateTimeToUnix(now, False);
    S.ServiceInfo := Base;
    S.SignTrx(AWallet);
    Result := S;
  end;
end;

function TBlockChainInquiries.CreateTrxNewWallet(Wallet: TWallet): TBytes;
var
  Base: TAccountInfoV0;
  trx: TAccountTrxV0;
begin
  Base.PublicKey := Wallet.PubKey;
  Base.Address := Wallet.GetAddress;
  trx.AccountInfo := Base;
  trx.SignTrx(Wallet);
  Result := trx;
end;

function TBlockChainInquiries.CreateTrxNewToken(ASymbol, AName, ADecimals, AVolume: string; AToken: TToken; AWallet: TWallet): TBytes;
var
  Base: TTokensInfoV0;
  trx: TTokensTrxV0;
  semiValue: string;
  decimal, resValue, counter: UInt64;
begin
  counter := 0;
  decimal := StrToUInt64(ADecimals);
  semiValue := AVolume;
  while counter < decimal do
  begin
    semiValue := semiValue + '0';
    inc(counter);
  end;
  resValue := StrToUInt64(semiValue);
  if ((TokensChain.GetIDToken(ASymbol) = 0) and (ASymbol <> '') and (AName <> '') and (decimal < 9)) then
  begin
    Base.Owner := WalletID;
    Base.Name := AName;
    Base.Symbol := ASymbol;
    Base.Decimals := decimal;
    Base.Volume := resValue;
    Base.TokenType := AToken;
    Base.UnixTime := DateTimeToUnix(now, False);
    trx.TokensInfo := Base;
    trx.SignTrx(AWallet);
    Result := trx;
  end;
end;

function TBlockChainInquiries.CreateTrxNewTransfer(var OwnerSign: string; ASymbol: string; AIDTo, AAmount: UInt64; AWallet: TWallet;
  isForce: boolean = False): TBytes;
var
  Base: TTransferInfoV0;
  trx: TTransferTrxV0;
begin
  Result := [];
  if isForce or ((AAmount > 0) and (AIDTo <> NaN)) then
  begin
    Base.DateTimeUnix := DateTimeToUnix(now, False);
    Base.DirectFrom := AccountsChain.GetID(AWallet.GetAddress);
    Base.DirectTo := AIDTo;
    Base.Amount := AAmount;
    Base.TokenID := TryGetTokenID(ASymbol);
    trx.TransferInfo := Base;
    trx.SignTrx(AWallet);
    OwnerSign := trx.OwnerSign;
    Result := trx;
  end;
end;

destructor TBlockChainInquiries.Destroy;
begin
  inherited;
end;

procedure TBlockChainInquiries.DoCorruptedBC;
begin
{$IFDEF DEBUG}
{$ELSE}
  TDirectory.Delete(Paths.GetPathBlockChain, True);
  TDirectory.Delete(Paths.GetPathFastIndex, True);
{$ENDIF}
end;

function TBlockChainInquiries.DoEasyBuyOm(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet; out ACountBlocks: UInt64): boolean;
var
  ID: UInt64;
begin
  ID := WalletID;
  WalletID := 0;
  Result := False;
  case LastVersionMining of
    0:
      begin
        var
          trx: TTransferTrxV0;
        trx := ABytes;
        var
          TrxOM: TMiningTrxV0;
        TrxOM.MiningInfo.OwnerID := trx.TransferInfo.DirectFrom;
        if SearchMiningOwnerID(TrxOM.MiningInfo.OwnerID) = False then
        begin
          var
            BaseBlockOM: TMiningBlockV0;
          BaseBlockOM := TMiningBlockV0.Create(TrxOM, MiningChain.GetLastBlockHash);
          MiningChain.SetBlock(BaseBlockOM.GetData);
          BaseBlockOM.Free;
          Result := True;
        end;
      end;
  else
    Result := False;
  end;
  if Result and (NodeState = Speaker) and (ParamStr(1) = 'init') then
  begin
    MiningChain.ApproveBlocks(AWallet);
    var
    Hash := MiningChain.GetLastBlockHash;
    var
    lastBlock := MiningChain.GetLastBlockID;
    ACountBlocks := 1;
    SetTrxInMainChain(Mining, lastBlock, Hash, AWallet);
  end;
  WalletID := ID;
end;

procedure TBlockChainInquiries.DoMining(AWallet: TWallet; var ACountBlocks: integer);
var
  AID: UInt64;
  ValueActive, ValuePassive: UInt64;
  lasblock, fromblock, uniqueBlocks: UInt64;
  IDActives, IDPassives: TArray<UInt64>;
  endCalc: TEvent;
  RAW: TBaseBlock;
  function isRepeat(AValue: UInt64; Arr: TArray<UInt64>): boolean;
  begin
    Result := False;
    for var k := 0 to Length(Arr) - 1 do
      if Arr[k] = AValue then
        exit(True);
  end;

begin
  endCalc := TEvent.Create;
  lasblock := MiningChain.GetLastBlockID;
  if lasblock < 1 then
    exit;
  setLength(IDActives, 0);
  setLength(IDPassives, 0);
  for var i := 1 to lasblock do
  begin
    RAW := MiningChain.GetBlock(i);
    var
      Header: THeader := RAW.GetHeader;
    case Header.VersionData of
      0:
        begin
          var
            trx: TMiningTrxV0;
          var
          buf := MiningChain.GetBlock(i);
          trx := buf.GetDataWithoutHeader;
          AID := trx.MiningInfo.OwnerID;
        end;
    end;
    if not isRepeat(AID, IDActives) then
      IDActives := IDActives + [AID];
    RAW.Free;
  end;

  lasblock := MainChain.GetLastBlockID;
  try
    fromblock := 0;
    RAW := MinedChain.GetBlock(MinedChain.GetLastBlockID);
    case RAW.GetHeader.VersionData of
      0:
        begin
          var
            trx: TMinedTrxV0 := RAW.GetDataWithoutHeader;
          fromblock := trx.MinedInfo.fromblock;
        end;
    end;
  finally
    RAW.Free;
  end;

  for var i := fromblock to lasblock do
  begin
    RAW := MainChain.GetBlock(i);
    var
      Header: THeader := RAW.GetHeader;
    if not isRepeat(Header.WitnessID, IDPassives) and (Header.WitnessID <> 0) then
      IDPassives := IDPassives + [Header.WitnessID];
    RAW.Free;
  end;

  ACountBlocks := 0;
  ValueActive := Round((TransferChain.GetBalance(0, TokensChain.GetIDToken(MainCoin)) * Percent * ActivePercent) / Length(IDActives));
  if Length(IDPassives) > 0 then
    ValuePassive := Round((TransferChain.GetBalance(0, TokensChain.GetIDToken(MainCoin)) * Percent * PassivePercent) / Length(IDPassives));

  System.Classes.TThread.Queue(nil,
    procedure
    var
      dt: Int64;
      token: UInt64;
    begin
      dt := DateTimeToUnix(now, False);
      token := TokensChain.GetIDToken(MainCoin);

      if ValueActive > 100000 then

        for var i := 0 to Length(IDActives) - 1 do
        begin
          case LastVersionTransfer of
            0:
              begin
                var
                  TrxTransfer: TTransferTrxV0;
                TrxTransfer.TransferInfo.DateTimeUnix := dt;
                TrxTransfer.TransferInfo.DirectFrom := 0;
                TrxTransfer.TransferInfo.DirectTo := IDActives[i];
                TrxTransfer.TransferInfo.Amount := ValueActive;
                TrxTransfer.TransferInfo.TokenID := token;
                TrxTransfer.SignTrx(AWallet);
                var
                  BaseBlockTrx: TTransferBlockV0;
                BaseBlockTrx := TTransferBlockV0.Create(TrxTransfer, TransferChain.GetLastBlockHash);
                TransferChain.SetBlock(BaseBlockTrx.GetData);
                BaseBlockTrx.Free;
                if (NodeState = Speaker) and (ParamStr(1) = 'init') then
                begin
                  TransferChain.ApproveBlocks(AWallet);
                  var
                  Hash := TransferChain.GetLastBlockHash;
                  var
                  lastBlock := TransferChain.GetLastBlockID;
                  SetTrxInMainChain(Transfers, lastBlock, Hash, AWallet);
                end;

              end;
          end;
        end;
      if ValuePassive > 100000 then
        for var i := 0 to Length(IDPassives) - 1 do
        begin
          case LastVersionTransfer of
            0:
              begin
                var
                  TrxTransfer: TTransferTrxV0;
                TrxTransfer.TransferInfo.DateTimeUnix := dt;
                TrxTransfer.TransferInfo.DirectFrom := 0;
                TrxTransfer.TransferInfo.DirectTo := IDPassives[i];
                TrxTransfer.TransferInfo.Amount := ValuePassive;
                TrxTransfer.TransferInfo.TokenID := token;
                TrxTransfer.SignTrx(AWallet);
                var
                  BaseBlockTrx: TTransferBlockV0;
                BaseBlockTrx := TTransferBlockV0.Create(TrxTransfer, TransferChain.GetLastBlockHash);
                TransferChain.SetBlock(BaseBlockTrx.GetData);
                BaseBlockTrx.Free;
                if (NodeState = Speaker) and (ParamStr(1) = 'init') then
                begin
                  TransferChain.ApproveBlocks(AWallet);
                  var
                  Hash := TransferChain.GetLastBlockHash;
                  var
                  lastBlock := TransferChain.GetLastBlockID;
                  SetTrxInMainChain(Transfers, lastBlock, Hash, AWallet);
                end;
              end;
          end;
        end;

      var
        trxMined: TMinedTrxV0;
      trxMined.MinedInfo.IDWitness := WalletID;
      trxMined.MinedInfo.fromblock := MainChain.GetLastBlockID;
      trxMined.MinedInfo.datetime := dt;
      trxMined.SignTrx(AWallet);
      var
        BaseBlockTrx: TMinedBlockV0;
      BaseBlockTrx := TMinedBlockV0.Create(trxMined, MinedChain.GetLastBlockHash);
      MinedChain.SetBlock(BaseBlockTrx.GetData);
      BaseBlockTrx.Free;
      if (NodeState = Speaker) and (ParamStr(1) = 'init') then
      begin
        MinedChain.ApproveBlocks(AWallet);
        var
        Hash := MinedChain.GetLastBlockHash;
        var
        lastBlock := MinedChain.GetLastBlockID;
        SetTrxInMainChain(Mined, lastBlock, Hash, AWallet);
      end;

      endCalc.SetEvent;
    end);
  endCalc.WaitFor;
  endCalc.Free;
end;

function TBlockChainInquiries.SearchMiningOwnerID(OwnerID: UInt64): boolean;
var
  info: TMiningInfoV0;
  Data: TBytes;
begin
  Result := False;
  for var j := 1 to MiningChain.GetLastBlockID do
  begin
    Data := MiningChain.GetBlock(j).GetDataWithoutHeader;
    info := TMiningTrxV0(Data).MiningInfo;
    if info.OwnerID = OwnerID then
    begin
      Result := True;
      break;
    end
  end;
end;

function TBlockChainInquiries.SetNewBlocks(buf: TBytes; var AError: string): boolean;
var
  Data: TBytes;
  i, counter, fromid, toid: integer;
  blocksSize, j, Count, size, controlSize: UInt64;
  Header: THeader;
  version, TypeChain: Byte;
begin
  AError := '';
  Data := Copy(buf, 1, Length(buf) - 1);
  Move(Data[0], controlSize, SizeOf(controlSize));
  Data := Copy(Data, SizeOf(controlSize), Length(Data) - SizeOf(controlSize));
  Move(Data[0], Count, SizeOf(Count));
  Data := Copy(Data, SizeOf(Count), Length(Data) - SizeOf(Count));
  fromid := MainChain.GetLastBlockID + 1;
  toid := controlSize;
  if controlSize <= MainChain.GetLastBlockID then
    exit;
  for i := 0 to Count - 1 do
  begin
    Move(Data[0], size, SizeOf(size));
    Data := Copy(Data, SizeOf(size), Length(Data) - SizeOf(size));
    Move(Data[0], Header, SizeOf(Header));
    case Header.VersionData of
      0:
        begin
          var
            MainBlock: TMainBlockV0;
          var
            trx: TMainTrxV0;
          MainBlock := TMainBlockV0.Create;
          MainBlock.SetData(Copy(Data, 0, size));
          if MainBlock.GetHeader.IDBlock <= MainChain.GetLastBlockID then
          begin
            AError := 'Input blocks id:' + MainBlock.GetHeader.IDBlock.AsString + '<= count blocks' + MainChain.GetLastBlockID.AsString;
            exit;
          end;

          MainChain.WriteApprovedBlock(MainBlock);
          MainBlock.Free;
        end;
    end;
    Data := Copy(Data, size, Length(Data) - size);
  end;
  counter := 0;
  while counter < Count do
  begin
    Move(Data[0], TypeChain, SizeOf(Byte));
    Move(Data[1], j, SizeOf(j));
    Data := Copy(Data, SizeOf(j) + SizeOf(TypeChain), Length(Data) - SizeOf(j) - SizeOf(TypeChain));
    case TTypesChain(TypeChain) of
      Accounts:
        begin
          blocksSize := AccountsChain.WriteApprovedBlocks(j, Data);
        end;
      Tokens:
        begin
          blocksSize := TokensChain.WriteApprovedBlocks(j, Data);
        end;
      Transfers:
        begin
          blocksSize := TransferChain.WriteApprovedBlocks(j, Data);
        end;
      MultiSigns:
        begin
          blocksSize := MultiSignChain.WriteApprovedBlocks(j, Data);
        end;
      VotingResults:
        begin
          blocksSize := VotingResultChain.WriteApprovedBlocks(j, Data);
        end;
      Commissions:
        begin
        end;
      Mining:
        begin
          blocksSize := MiningChain.WriteApprovedBlocks(j, Data);
        end;
      Service:
        begin
          blocksSize := ServiceChain.WriteApprovedBlocks(j, Data);
        end;
      ServiceResult:
        begin
          blocksSize := ServiceResultChain.WriteApprovedBlocks(j, Data);
        end;
      Mined:
        begin
          blocksSize := MinedChain.WriteApprovedBlocks(j, Data);
        end;
    end;
    inc(counter, j);
    Data := Copy(Data, blocksSize, Length(Data) - blocksSize);
  end;
end;

function TBlockChainInquiries.SetServiceData(ID: UInt64; Data: TSRData; AWallet: TWallet): TServiceResultV0;
var
  AName: TName;
  Base: TServiceResultInfoV0;
  S: TServiceResultV0;
begin
  AName := ServiceChain.GetServiceName(ID);
  if (AName <> '') then
  begin
    Base.ID := ID;
    Base.Data := Data;
    Base.UnixTime := DateTimeToUnix(now, False);
    S.ServiceResultInfo := Base;
    S.SignTrx(AWallet);
    Result := S;
  end;
end;

function TBlockChainInquiries.TryCheckIfTokenExists(Symbol: TSymbol): boolean;
begin
  if TokensChain.GetIDToken(Symbol) = 0 then
    Result := False
  else
    Result := True;
end;

function TBlockChainInquiries.TryGetAccountAddress(AccID: UInt64): THash;
begin
  Result := AccountsChain.GetName(AccID);
end;

function TBlockChainInquiries.GetAllCacheTrx: TBytes;
var
  counter: UInt64;
begin
  Result := [];
  counter := AccountsChain.GetCacheCount + MultiSignChain.GetCacheCount + VotingResultChain.GetCacheCount + CommissionChain.GetCacheCount +
    TransferChain.GetCacheCount + TokensChain.GetCacheCount + MiningChain.GetCacheCount + ServiceChain.GetCacheCount +
    ServiceResultChain.GetCacheCount;
  if counter > 0 then
  begin
    Result := counter.AsBytes;
    if AccountsChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(Accounts)] + AccountsChain.GetCacheCount.AsBytes + AccountsChain.GetCachedTrxs;
      AccountsChain.DoClearCache;
    end;
    if MultiSignChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(MultiSigns)] + MultiSignChain.GetCacheCount.AsBytes + MultiSignChain.GetCachedTrxs;
      MultiSignChain.DoClearCache;
    end;
    if VotingResultChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(VotingResults)] + VotingResultChain.GetCacheCount.AsBytes + VotingResultChain.GetCachedTrxs;
      VotingResultChain.DoClearCache;
    end;
    if CommissionChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(Commissions)] + CommissionChain.GetCacheCount.AsBytes + CommissionChain.GetCachedTrxs;
      CommissionChain.DoClearCache;
    end;
    if TransferChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(Transfers)] + TransferChain.GetCacheCount.AsBytes + TransferChain.GetCachedTrxs;
      TransferChain.DoClearCache;
    end;
    if TokensChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(Tokens)] + TokensChain.GetCacheCount.AsBytes + TokensChain.GetCachedTrxs;
      TokensChain.DoClearCache;
    end;
    if MiningChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(Mining)] + MiningChain.GetCacheCount.AsBytes + MiningChain.GetCachedTrxs;
      MiningChain.DoClearCache;
    end;
    if ServiceChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(Service)] + ServiceChain.GetCacheCount.AsBytes + ServiceChain.GetCachedTrxs;
      ServiceChain.DoClearCache;
    end;
    if ServiceResultChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(ServiceResult)] + ServiceResultChain.GetCacheCount.AsBytes + ServiceResultChain.GetCachedTrxs;
      ServiceResultChain.DoClearCache;
    end;

    if MinedChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(Mined)] + MinedChain.GetCacheCount.AsBytes + MinedChain.GetCachedTrxs;
      MinedChain.DoClearCache;
    end;

  end;
end;

function TBlockChainInquiries.GetAmountFromVolume(Volume: Double;
  Decimals: UInt64): UInt64;
begin
  if Decimals = 0 then
    Result := Round(Volume)
  else
    Result := Round(Volume * (Power(10, Decimals)));
end;

procedure TBlockChainInquiries.SetAllCacheTrx(AData: TBytes);
var
  counter, CountTrxs, blocksSize, j: UInt64;
  ChainCounter, LocalChainCounter, SizePackage, totalamount: UInt64;
  ByteCounter: UInt64;
  TypeChain: Byte;
begin
  counter := 0;
  ChainCounter := 0;
  ByteCounter := 0;
  Move(AData[ByteCounter], totalamount, SizeOf(CountTrxs));
  inc(ByteCounter, SizeOf(totalamount)); // +8
  if totalamount > 0 then
  begin
    while counter < totalamount do
    begin
      Move(AData[ByteCounter], TypeChain, SizeOf(TypeChain));
      inc(ByteCounter, SizeOf(TypeChain)); // +1
      Move(AData[ByteCounter], ChainCounter, SizeOf(ChainCounter));
      inc(ByteCounter, SizeOf(ChainCounter)); // +8
      LocalChainCounter := 0;
      case TTypesChain(TypeChain) of
        Accounts:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));
              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TAccountBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TAccountTrxV0)));
                    AccountsChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TAccountTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        Tokens:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));
              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TTokensBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TTokensTrxV0)));
                    TokensChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TTokensTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        Transfers:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));
              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TTransferBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TTransferTrxV0)));
                    TransferChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TTransferTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        MultiSigns:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));
              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TMultiSignBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TMultiSignTrxV0)));
                    MultiSignChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TMultiSignTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        Commissions:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));
              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TCommissionBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TCommissionTrxV0)));
                    CommissionChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TCommissionTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        Mining:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));
              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TMiningBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TMiningTrxV0)));
                    MiningChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TMiningTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        Service:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TServiceBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TServiceV0)));
                    ServiceChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TServiceV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        ServiceResult:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TServiceResultBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TServiceResultV0)));
                    ServiceResultChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TServiceResultV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        Mined:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var
                Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TMinedBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TMinedTrxV0)));
                    MinedChain.SetBlock(Block.GetData);
                    Block.Free;
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TMinedTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
      end;
      inc(counter, LocalChainCounter);
    end;
  end;
end;

function TBlockChainInquiries.GetBalances(AAccountID: UInt64): TBytes;
begin
  Result := TransferChain.GetBalances(AAccountID);
end;

function TBlockChainInquiries.GetBlockOwner(IDChain, IDBlock: UInt64): UInt64;
var
  RAWMainBlock: TBaseBlock;
begin
  case TTypesChain(IDChain) of
    Main:
      begin
        RAWMainBlock := MainChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    Accounts:
      begin
        Result := IDBlock;
      end;
    Tokens:
      begin
        RAWMainBlock := TokensChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        case Header.VersionData of
          0:
            begin
              var
                trx: TTokensTrxV0 := TTokensBlockV0(RAWMainBlock).GetDataWithoutHeader;
              Result := trx.TokensInfo.Owner;
            end;
        end;
        RAWMainBlock.Free;
      end;
    Transfers:
      begin
        RAWMainBlock := TransferChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        case Header.VersionData of
          0:
            begin
              var
                trx: TTokensTrxV0 := TTokensBlockV0(RAWMainBlock).GetDataWithoutHeader;
              Result := trx.TokensInfo.Owner;
            end;
        end;
        RAWMainBlock.Free;
      end;
    MultiSigns:
      begin
        RAWMainBlock := MultiSignChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    VotingResults:
      begin
        RAWMainBlock := VotingResultChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    Commissions:
      begin
        RAWMainBlock := CommissionChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    Mining:
      begin
        RAWMainBlock := MiningChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    Service:
      begin
        RAWMainBlock := ServiceChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    ServiceResult:
      begin
        RAWMainBlock := ServiceResultChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    Mined:
      begin
        RAWMainBlock := MinedChain.GetBlock(IDBlock);
        var
          Header: THeader := RAWMainBlock.GetHeader;
        case Header.VersionData of
          0:
            begin
              var
                trx: TMinedTrxV0 := TMinedBlockV0(RAWMainBlock).GetDataWithoutHeader;
              Result := trx.MinedInfo.IDWitness;
            end;
        end;
        RAWMainBlock.Free;
      end;
  end;
end;

function TBlockChainInquiries.GetBlocksFrom(const AID: UInt64): TBytes;
var
  Chains: TDictionary<Byte, UInt64>;
  RAWMainBlock: TBaseBlock;
  buf: TBytes;
  Count: UInt64;
begin
  Result := [];
  if MainChain.GetLastBlockID < AID then
    exit;
  Result := [0];
  Result := Result + MainChain.GetLastBlockID.AsBytes;
  Count := MainChain.GetLastBlockID - AID;
  Result := Result + Count.AsBytes;
  Chains := TDictionary<Byte, UInt64>.Create;
  for var i := AID + 1 to MainChain.GetLastBlockID do
  begin
    RAWMainBlock := MainChain.GetBlock(i);
    case RAWMainBlock.GetHeader.VersionData of
      0:
        begin
          var
            MainBlock: TMainBlockV0;
          var
            MainTrxV0: TMainTrxV0;
          var
            MainInfoV0: TMainInfoV0;
          MainBlock := TMainBlockV0.Create;
          MainBlock.SetData(RAWMainBlock.GetData);
          MainTrxV0 := MainBlock.GetTrxData;
          MainInfoV0 := MainTrxV0.MainInfo;
          Chains.TryAdd(MainInfoV0.IDChain, MainInfoV0.IDBlock);
          MainBlock.Destroy;
        end;
    end;
    Result := Result + RAWMainBlock.GetSizeBlock.AsBytes + RAWMainBlock.GetData;
    RAWMainBlock.Free;
  end;
  var
    ChainPair: TPair<Byte, UInt64>;
  for ChainPair in Chains.ToArray do
  begin
    case TTypesChain(ChainPair.Key) of
      Accounts:
        Result := Result + [ChainPair.Key] + UInt64(AccountsChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          AccountsChain.GetBlocksFrom(ChainPair.Value);
      Tokens:
        Result := Result + [ChainPair.Key] + UInt64(TokensChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          TokensChain.GetBlocksFrom(ChainPair.Value);
      Transfers:
        Result := Result + [ChainPair.Key] + UInt64(TransferChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          TransferChain.GetBlocksFrom(ChainPair.Value);
      MultiSigns:
        Result := Result + [ChainPair.Key] + UInt64(MultiSignChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          MultiSignChain.GetBlocksFrom(ChainPair.Value);
      VotingResults:
        Result := Result + [ChainPair.Key] + UInt64(VotingResultChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          VotingResultChain.GetBlocksFrom(ChainPair.Value);
      Commissions:
        Result := Result + [ChainPair.Key] + UInt64(CommissionChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          CommissionChain.GetBlocksFrom(ChainPair.Value);
      Mining:
        Result := Result + [ChainPair.Key] + UInt64(MiningChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          MiningChain.GetBlocksFrom(ChainPair.Value);
      Service:
        Result := Result + [ChainPair.Key] + UInt64(ServiceChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          ServiceChain.GetBlocksFrom(ChainPair.Value);
      ServiceResult:
        Result := Result + [ChainPair.Key] + UInt64(ServiceResultChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          ServiceResultChain.GetBlocksFrom(ChainPair.Value);
      Mined:
        Result := Result + [ChainPair.Key] + UInt64(MinedChain.GetLastBlockID - ChainPair.Value + 1).AsBytes +
          MinedChain.GetBlocksFrom(ChainPair.Value);
    end;
  end;
  Chains.Free;
end;

function TBlockChainInquiries.GetChains: TArray<string>;
begin
  Result := [];
  for var i := Low(TTypesChain) to High(TTypesChain) do
    Result := Result + [GetEnumName(TypeInfo(TTypesChain), ord(i))];
end;

function TBlockChainInquiries.GetDataFromChain(i: integer): TArray<TArray<TPair<string, string>>>;
var
  rttiContext: TRttiContext;
  flds: TArray<TRttiField>;
  fld: TRttiField;
  Pair: TPair<string, string>;
  buf: TBytes;
  Header: THeader;
  LocalBaseBlock: TBaseBlock;
  j: integer;
  subRes: TArray<TPair<string, string>>;
begin
  Result := [];
  LocalBaseBlock := TBaseBlock.Create;
  case TTypesChain(i) of
    Main:
      begin
        for j := 0 to MainChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := MainChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TMainTrxV0;
                var
                  inf: TMainInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.MainInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', DateTimeToStr(UnixToDateTime(Header.UnixTime)));
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('IDChain', inf.IDChain.ToString);
                subRes := subRes + [Pair];
                Pair.Create('IDBlock', inf.IDBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('HashBlock', inf.HashBlock);
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    Accounts:
      begin
        for j := 0 to AccountsChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := AccountsChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TAccountTrxV0;
                var
                  inf: TAccountInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.AccountInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', DateTimeToStr(UnixToDateTime(Header.UnixTime)));
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('PublicKey', inf.PublicKey);
                subRes := subRes + [Pair];
                Pair.Create('Address', inf.Address);
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    Tokens:
      begin
        for j := 0 to TokensChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := TokensChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TTokensTrxV0;
                var
                  inf: TTokensInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.TokensInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', DateTimeToStr(UnixToDateTime(Header.UnixTime)));
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('Owner', inf.Owner.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Name', inf.Name);
                subRes := subRes + [Pair];
                Pair.Create('Symbol', inf.Symbol);
                subRes := subRes + [Pair];
                Pair.Create('Decimals', inf.Decimals.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Volume', (GetVolumeFromAmount(inf.Volume, inf.Decimals)).ToString);
                subRes := subRes + [Pair];
                Pair.Create('TokenType', ord(inf.TokenType).ToString);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', DateTimeToStr(UnixToDateTime(inf.UnixTime)));
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    Transfers:
      begin
        for j := 0 to TransferChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := TransferChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TTransferTrxV0;
                var
                  inf: TTransferInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.TransferInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', DateTimeToStr(UnixToDateTime(Header.UnixTime)));
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                try
                  Pair.Create('DateTimeUnix', DateTimeToStr(UnixToDateTime(inf.DateTimeUnix)));
                  subRes := subRes + [Pair];
                except
                  sleep(1);
                end;
                Pair.Create('DirectFrom', inf.DirectFrom.AsString);
                subRes := subRes + [Pair];
                Pair.Create('DirectTo', inf.DirectTo.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Amount', GetVolumeFromAmount(inf.Amount, TokensChain.GetTokenDecimals(inf.TokenID)).ToString);
                subRes := subRes + [Pair];
                Pair.Create('TokenType', inf.TokenID.AsString);
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    VotingResults:
      begin
        for j := 0 to VotingResultChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := VotingResultChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TVotingResultTrxV0;
                var
                  inf: TVotingResultInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.VotingResultInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', DateTimeToStr(UnixToDateTime(Header.UnixTime)));
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('VotingID', inf.VotingID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('VotingTime', inf.VotingTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VotingOwnerID', inf.VotingOwnerID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('VotingOwnerResult', inf.VotingOwnerResult.ToString);
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    Commissions:
      begin
        for j := 0 to CommissionChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := CommissionChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TCommissionTrxV0;
                var
                  inf: TCommissionInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.CommissionInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('CommTransOrigCoin', inf.CommTransOrigCoin.AsString);
                subRes := subRes + [Pair];
                Pair.Create('CommRecService', inf.CommRecService.AsString);
                subRes := subRes + [Pair];
                Pair.Create('CommTransTokenInside', inf.CommTransTokenInside.AsString);
                subRes := subRes + [Pair];
                Pair.Create('CommCreateToken', inf.CommCreateToken.AsString);
                subRes := subRes + [Pair];
                Pair.Create('CommCreateService', inf.CommCreateService.AsString);
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    MultiSigns:
      begin
        for j := 0 to MultiSignChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := MultiSignChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TMultiSignTrxV0;
                var
                  inf: TMultiSignInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.MultiSignInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('ValID', inf.ValID.ToString);
                subRes := subRes + [Pair];
                Pair.Create('BeginBlock', inf.BeginBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('EndBlock', inf.EndBlock.ToString);
                subRes := subRes + [Pair];
                for var n := 0 to CountSign - 1 do
                begin
                  Pair.Create('SetValSignValID ' + IntToStr(n), inf.SetValSign.SetSign[n].ValID.ToString);
                  subRes := subRes + [Pair];
                  for var k := 0 to Xsign do
                  begin
                    Pair.Create('SetValSignValSign ' + IntToStr(n) + ' ' + IntToStr(k), inf.SetValSign.SetSign[n].ValSign.Data[k].ToString);
                    subRes := subRes + [Pair];
                  end;
                end;
                for var S := 0 to Xsign do
                begin
                  Pair.Create('SignLastBlock ' + IntToStr(S), inf.SignLastBlock.Data[S].ToString);
                  subRes := subRes + [Pair];
                end;
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    Mining:
      begin
        for j := 0 to MiningChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := MiningChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TMiningTrxV0;
                var
                  inf: TMiningInfoV0;
                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.MiningInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerID', inf.OwnerID.AsString);
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    Service:
      begin
        for j := 0 to ServiceChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := ServiceChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx: TServiceV0;
                var
                  inf: TServiceInfoV0;

                trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf := trx.ServiceInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];

                Pair.Create('OwnerSign', trx.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('Owner', inf.Owner.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Name', string(inf.Name));
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    ServiceResult:
      begin
        for j := 0 to ServiceResultChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := ServiceResultChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx1: TServiceResultV0;
                var
                  inf1: TServiceResultInfoV0;

                trx1 := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf1 := trx1.ServiceResultInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];

                Pair.Create('OwnerSign', trx1.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('Service', inf1.ID.AsString);
                subRes := subRes + [Pair];
                var
                S := '';
                for var kk := 0 to High(inf1.Data) do
                begin
                  var
                  t := '';
                  if inf1.Data[kk] < 100 then
                    t := '0';
                  if inf1.Data[kk] < 10 then
                    t := '00';
                  S := S + t + inf1.Data[kk].ToString;
                end;

                Pair.Create('Data', S);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    Mined:
      begin
        for j := 0 to MinedChain.GetLastBlockID do
        begin
          subRes := [];
          LocalBaseBlock := MinedChain.GetBlock(j);
          buf := LocalBaseBlock.GetData;
          Header := Copy(buf, 0, SizeOf(THeader));
          case Header.VersionData of
            0:
              begin
                var
                  trx1: TMinedTrxV0;
                var
                  inf1: TMinedInfoV0;

                trx1 := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
                inf1 := trx1.MinedInfo;
                Pair.Create('ID', Header.IDBlock.AsString);
                subRes := subRes + [Pair];
                Pair.Create('TypeBlock', Header.TypeBlock.ToString);
                subRes := subRes + [Pair];
                Pair.Create('VersionData', Header.VersionData.ToString);
                subRes := subRes + [Pair];
                Pair.Create('CurrentHash', Header.CurrentHash);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('WitnessID', Header.WitnessID.AsString);
                subRes := subRes + [Pair];
                Pair.Create('Sign', Header.Sign);
                subRes := subRes + [Pair];
                Pair.Create('OwnerSign', trx1.OwnerSign);
                subRes := subRes + [Pair];
                Pair.Create('UnixTime', Header.UnixTime.ToString);
                subRes := subRes + [Pair];
                Pair.Create('IDWitness', inf1.IDWitness.AsString);
                subRes := subRes + [Pair];
                Pair.Create('DateTime', DateTimeToStr(UnixToDateTime(inf1.datetime)));
                subRes := subRes + [Pair];
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
  end;
end;

function TBlockChainInquiries.GetDateTimeLastMining: Int64;
var
  return: Int64;
  RawBlock: TBaseBlock;
begin
  try
    return := 0;
    RawBlock := MinedChain.GetBlock(MinedChain.GetLastBlockID);
    case RawBlock.GetHeader.VersionData of
      0:
        begin
          var
            trx: TMinedTrxV0 := RawBlock.GetDataWithoutHeader;
          return := trx.MinedInfo.IDWitness;
        end;
    end;

  finally
    Result := return;
    RawBlock.Free;
  end;
end;

function TBlockChainInquiries.CreateTrxNewMinedData(AWallet: TWallet; AFromBlock: UInt64): TBytes;
var
  Base: TMinedInfoV0;
  trx: TMinedTrxV0;
begin
  Base.IDWitness := WalletID;
  Base.datetime := DateTimeToUnix(now, False);
  Base.fromblock := AFromBlock;
  trx.MinedInfo := Base;
  trx.SignTrx(AWallet);
  Result := trx;
end;

function TBlockChainInquiries.GetMainLastblocHash: THash;
begin
  Result := MainChain.GetLastBlockHash;
end;

function TBlockChainInquiries.GetMainLastblocHashFromID(AID: UInt64): THash;
var
  Hash: THash;
begin
  Result := Default (THash);
  if AID > MainChain.GetLastBlockID then
    exit;
  var
    BaseBlock: TBaseBlock := MainChain.GetBlock(AID);
  Result := BaseBlock.GetHeader.CurrentHash;
  BaseBlock.Free;
end;

function TBlockChainInquiries.GetOMs: TArray<UInt64>;
begin
  Result := MiningChain.GetOMs;
end;

function TBlockChainInquiries.GetServiceData(ID: UInt64): TBlockSRData;
var
  R: TServiceResultV0;
begin
  Result := [];
  for var i := 1 to ServiceResultChain.GetLastBlockID do
  begin
    R := ServiceResultChain.GetBlock(i).GetData;
    if R.ServiceResultInfo.ID = ID then
      Result := Result + [R];
  end;
end;

function TBlockChainInquiries.GetTransactionHistory(AID, ATID: UInt64): TArray<string>;
var
  buf: TArray<TTransferHistoryData>;
  DirectFrom, DirectTo, Amount, TokenID, UnixTime, Hash, sd: string;
begin
  buf := TransferChain.GetTransactioHistory(AID, ATID);
  Result := [];
  if Length(buf) = 0 then
    exit
  else
    for var item in buf do
    begin
      DirectFrom := AccountsChain.GetName(item.DirectFrom);
      DirectTo := AccountsChain.GetName(item.DirectTo);
      sd := GetVolumeFromAmount(item.Amount, TokensChain.GetTokenDecimals(item.TokenID), False);
      if item.Plus then
        Amount := sd
      else
        Amount := '-' + sd;

      TokenID := TryGetTokenSymbol(item.TokenID);
      UnixTime := DateTimeToStr(UnixToDateTime(item.UnixTime));
      Hash := item.BlockHash;
      Result := Result + [DirectFrom] + [DirectTo] + [Amount] + [TokenID] + [UnixTime] + [Hash];
    end;
end;

function TBlockChainInquiries.MainChainCount: UInt64;
begin
  Result := MainChain.GetLastBlockID;
end;

function TBlockChainInquiries.NeedCalcMine: boolean;
var
  lastDateTimeMining: Int64;
begin
  Result := False;
{$IFDEF MAINNET}
  if DateTimeToUnix(now, False) > 1644667200 then
  begin

    var
    RAW := MinedChain.GetBlock(MinedChain.GetLastBlockID);
    lastDateTimeMining := RAW.GetHeader.UnixTime;
    RAW.Free;
    Result := HoursBetween(TTimeZone.Local.ToUniversalTime(now), UnixToDateTime(lastDateTimeMining)) >= 168;
  end;
{$ELSE}
  var
  RAW := MinedChain.GetBlock(MinedChain.GetLastBlockID);
  lastDateTimeMining := RAW.GetHeader.UnixTime;
  RAW.Free;
//  if (DateTimeToUnix(now, False) > 1643403601)
//    and (lastDateTimeMining < 1643403601)
//  then
//  begin
//    Result:= True;
//  end
//  else
//  begin
//    Result:= HoursBetween(TTimeZone.Local.ToUniversalTime(now), UnixToDateTime(lastDateTimeMining)) > 168;
//  end;
  Result:= HoursBetween(TTimeZone.Local.ToUniversalTime(now), UnixToDateTime(lastDateTimeMining)) >= 168;
{$ENDIF}
end;

procedure TBlockChainInquiries.WriteBlock(const AData: TBytes; AType: TTypesChain; ABlockVersion: integer = -1);
var
  BlockVersion: integer;
begin
  case AType of
    Tokens:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionTokens
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                TkBlock: TTokensBlockV0;
              var
                TkTrx: TTokensTrxV0;
              TkTrx := AData;
              TkBlock := TTokensBlockV0.Create(TkTrx, TokensChain.GetLastBlockHash);
              TokensChain.SetBlock(TkBlock.GetData);
              TkBlock.Free;
            end;
        else
        end;
      end;
    Transfers:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionTransfer
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                TrBlock: TTransferBlockV0;
              var
                TrTrx: TTransferTrxV0;
              TrTrx := AData;
              TrBlock := TTransferBlockV0.Create(TrTrx, TransferChain.GetLastBlockHash);
              TransferChain.SetBlock(TrBlock.GetData);
              TrBlock.Free;
            end;
        else
        end;
      end;
    Main:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionMain
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                MnBlock: TMainBlockV0;
              var
                MnTrx: TMainTrxV0;
              MnTrx := AData;
              MnBlock := TMainBlockV0.Create(MnTrx, MainChain.GetLastBlockHash);
              MainChain.SetBlock(MnBlock.GetData);
              MnBlock.Free;
            end;
        else
        end;
      end;
    Accounts:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionAccount
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                AccBlock: TAccountBlockV0;
              var
                accTrx: TAccountTrxV0;
              accTrx := AData;
              AccBlock := TAccountBlockV0.Create(accTrx, AccountsChain.GetLastBlockHash);
              AccountsChain.SetBlock(AccBlock.GetData);
              AccBlock.Free;
            end;
        else
        end;
      end;
    Service:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionService
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                SrvBlock: TServiceBlockV0;
              var
                srvD: TServiceV0;
              srvD := AData;
              SrvBlock := TServiceBlockV0.Create(srvD, ServiceChain.GetLastBlockHash);
              ServiceChain.SetBlock(SrvBlock.GetData);
            end;
        else
        end;
      end;
    ServiceResult:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionServiceResult
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                SrvBlock: TServiceResultBlockV0;
              var
                srvD: TServiceResultV0;
              srvD := AData;
              SrvBlock := TServiceResultBlockV0.Create(srvD, ServiceResultChain.GetLastBlockHash);
              ServiceResultChain.SetBlock(SrvBlock.GetData);
            end;
        else
        end;
      end;
    Mined:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionMined
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                MinedBlock: TMinedBlockV0;
              var
                MinedTrx: TMinedTrxV0;
              MinedTrx := AData;
              MinedBlock := TMinedBlockV0.Create(MinedTrx, MinedChain.GetLastBlockHash);
              MinedChain.SetBlock(MinedBlock.GetData);
            end;
        else
        end;
      end;
  else
  end;
end;

function TBlockChainInquiries.ReadBlock(AIndBlock: integer; AType: TTypesChain): TBytes;
var
  Block: TBaseBlock;
begin
  case AType of
    Main:
      begin
        Block := MainChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    Accounts:
      begin
        Block := AccountsChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    MultiSigns:
      begin
        Block := MultiSignChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    VotingResults:
      begin
        Block := VotingResultChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    Commissions:
      begin
        Block := CommissionChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    Transfers:
      begin
        Block := TransferChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    Tokens:
      begin
        Block := TokensChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    Service:
      begin
        Block := ServiceChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    ServiceResult:
      begin
        Block := ServiceResultChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
    Mined:
      begin
        Block := MinedChain.GetBlock(AIndBlock);
        Result := Block.GetData;
      end;
  else
  end;
end;

procedure TBlockChainInquiries.SetTrxInMainChain(TypeChain: TTypesChain; lastBlock: UInt64; Hash: THash; AWallet: TWallet);
begin
  var
    mainInf: TMainInfoV0;
  mainInf.IDChain := ord(TypeChain);
  mainInf.IDBlock := lastBlock;
  mainInf.HashBlock := Hash;
  var
    mainTrx: TMainTrxV0;
  mainTrx.MainInfo := mainInf;
  mainTrx.SignTrx(AWallet);
  var
    mainbaseBlock: TMainBlockV0;
  mainbaseBlock := TMainBlockV0.Create(mainTrx, MainChain.GetLastBlockHash);
  MainChain.SetBlock(mainbaseBlock.GetData);
  mainbaseBlock.Free;
  MainChain.ApproveBlocks(AWallet);
end;

function TBlockChainInquiries.CheckBlock(ABlock: TBaseBlock; PublicKey: TPublicKey; ACountBlockInChain: UInt64): boolean;
var
  Header: THeader;
  EncryptedHash: THash;
  buf: TMemoryStream;
  PreviosBlock: TBaseBlock;
  PreviosHash: THash;
  SemiHash: THash;
  mainTrx: TMainTrxV0;
  accTrx: TAccountTrxV0;
  TokenTrx: TTokensTrxV0;
  TransferTrx: TTransferTrxV0;
  MiningTrx: TMiningTrxV0;
  ServiceTrx: TServiceV0;
  ServiceRTrx: TServiceResultV0;
  MinedTrx: TMinedTrxV0;
begin
  try
    Header := ABlock.GetHeader;
    EncryptedHash := RSADecrypt(PublicKey, Header.Sign);
    buf := TMemoryStream.Create;
    case TTypesChain(Header.TypeBlock) of
      Main:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := MainChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                mainTrx := TMainBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(mainTrx), SizeOf(THash) + Length(TBytes(mainTrx)));
                PreviosBlock.Free;
              end;
          end;
        end;
      Accounts:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := AccountsChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                accTrx := TAccountBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(accTrx), SizeOf(THash) + Length(TBytes(accTrx)));
                PreviosBlock.Free;
              end;
          end;
        end;
      Tokens:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := TokensChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                TokenTrx := TTokensBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(TokenTrx), SizeOf(THash) + Length(TBytes(TokenTrx)));
                PreviosBlock.Free;
              end;
          end;
        end;
      Transfers:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := TransferChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                TransferTrx := TTransferBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(TransferTrx), SizeOf(THash) + Length(TBytes(TransferTrx)));
                PreviosBlock.Free;
              end;
          end;
        end;
      Mining:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := MiningChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                MiningTrx := TMiningBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(MiningTrx), SizeOf(THash) + Length(TBytes(MiningTrx)));
                PreviosBlock.Destroy;
              end;
          end;
        end;
      Service:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := ServiceChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                ServiceTrx := TServiceBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(ServiceTrx), SizeOf(THash) + Length(TBytes(ServiceTrx)));
                PreviosBlock.Free;
              end;
          end;
        end;
      ServiceResult:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := ServiceResultChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                ServiceRTrx := TServiceResultBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(ServiceRTrx), SizeOf(THash) + Length(TBytes(ServiceRTrx)));
                PreviosBlock.Free;
              end;
          end;
        end;
      Mined:
        begin
          case Header.VersionData of
            0:
              begin
                PreviosBlock := MinedChain.GetBlock(ACountBlockInChain - 1);
                PreviosHash := PreviosBlock.GetHeader.CurrentHash;
                MinedTrx := TMinedBlockV0(ABlock).GetDataWithoutHeader;
                buf.WriteData(PreviosHash + TBytes(MinedTrx), SizeOf(THash) + Length(TBytes(MinedTrx)));
                PreviosBlock.Free;
              end;
          end;
        end;
    end;
    buf.Position := 0;
    SemiHash := THashSHA2.GetHashBytes(buf);
    if EncryptedHash = SemiHash then
      Result := True
    else
      Result := False;
    buf.Free;
  except
    Result := False;
  end;
end;

function TBlockChainInquiries.GetDataAsString(mainblockid: UInt64): string;
var
  Block: TBaseBlock;
  AnyChainID: Byte;
  AnyBlockID: integer;
begin
  try
    Block := MainChain.GetBlock(mainblockid);
    var
    Header := Block.GetHeader;
    Result := string(Header) + #13#10;
    case Header.VersionData of
      0:
        begin
          var
            trx: TMainTrxV0 := Block.GetDataWithoutHeader;
          var
            info: TMainInfoV0 := trx.MainInfo;
          AnyChainID := info.IDChain;
          AnyBlockID := info.IDBlock;
          Result := Result + 'Chain: ' + GetEnumName(TypeInfo(TTypesChain), ord(info.IDChain)) + ' idblock: ' + IntToStr(info.IDBlock) + ' hash:' +
            info.HashBlock;
        end;
    end;

    case TTypesChain(AnyChainID) of
      Accounts:
        begin
          Block := AccountsChain.GetBlock(AnyBlockID);
          Result := Result + TAccountBlockV0(Block).GetString;
        end;
      Tokens:
        begin
          Block := TokensChain.GetBlock(AnyBlockID);
          Result := Result + TTokensBlockV0(Block).GetString;
        end;
      Transfers:
        begin
          Block := TransferChain.GetBlock(AnyBlockID);
          Result := Result + TTransferBlockV0(Block).GetString;
        end;
      MultiSigns:
        begin
          Block := MultiSignChain.GetBlock(AnyBlockID);
          Result := Result + TMultiSignBlockV0(Block).GetString;
        end;
      VotingResults:
        begin
          Block := VotingResultChain.GetBlock(AnyBlockID);
          Result := Result + TVotingResultBlockV0(Block).GetString;
        end;
      Commissions:
        begin
          Block := CommissionChain.GetBlock(AnyBlockID);
          Result := Result + TCommissionBlockV0(Block).GetString;
        end;
      VoteRequest:
        begin
          Result := Result + 'VoteRequest';
        end;
      Mining:
        begin
          Block := MiningChain.GetBlock(AnyBlockID);
          Result := Result + TMiningBlockV0(Block).GetString;
        end;
      Service:
        begin
          Block := ServiceChain.GetBlock(AnyBlockID);
          Result := Result + TServiceBlockV0(Block).GetString;
        end;
      ServiceResult:
        begin
          Block := ServiceResultChain.GetBlock(AnyBlockID);
          Result := Result + TServiceResultBlockV0(Block).GetString;
        end;
      Mined:
        begin
          Block := MinedChain.GetBlock(AnyBlockID);
          Result := Result + TMinedBlockV0(Block).GetString;
        end;
    end;
  finally
    Block.Free;
  end;
end;

function TBlockChainInquiries.CheckBlocks(AFromID, AToID: UInt64): boolean;
var
  AnyChainID: Byte;
  AnyBlockID, previosval: integer;
  RawBlock, Block: TBaseBlock;
  Header: THeader;
begin
  Result := True;
  for var i := AFromID to AToID do
  begin
    RawBlock := MainChain.GetBlock(i);
    Header := RawBlock.GetHeader;
    if Header.WitnessID = 0 then
    begin
      RawBlock.Free;
      Continue;
    end;

    if CheckBlock(RawBlock, TryGetPublicKey(Header.WitnessID), i) then
    begin
      try
        case Header.VersionData of
          0:
            begin
              var
                trx: TMainTrxV0 := TMainBlockV0(RawBlock).GetDataWithoutHeader;
              AnyChainID := trx.MainInfo.IDChain;
              AnyBlockID := trx.MainInfo.IDBlock;
            end;
        end;
        case TTypesChain(AnyChainID) of
          Accounts:
            begin
              Block := AccountsChain.GetBlock(AnyBlockID);
            end;
          Tokens:
            begin
              Block := TokensChain.GetBlock(AnyBlockID);
            end;
          Transfers:
            begin
              Block := TransferChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.MultiSigns:
            begin
              Block := MultiSignChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.VotingResults:
            begin
              Block := VotingResultChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.Commissions:
            begin
              Block := CommissionChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.VoteRequest:
            begin
              Block := CommissionChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.Mining:
            begin
              Block := MiningChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.Service:
            begin
              Block := ServiceChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.ServiceResult:
            begin
              Block := ServiceResultChain.GetBlock(AnyBlockID);
            end;
          TTypesChain.Mined:
            begin
              Block := MinedChain.GetBlock(AnyBlockID);
            end;
        end;
      except
        Block := nil;
      end;

      if (Block = nil) or (not CheckBlock(Block, TryGetPublicKey(Block.GetHeader.WitnessID), Block.GetHeader.IDBlock)) then
      begin
        Result := False;
        BlockChainLogs.DoAlert('CheckBlocks: AFromID ' + AFromID.AsString + ', AToId ' + AToID.AsString, GetDataAsString(i));
        RawBlock.Free;
        Block.Free;
        break;
      end;
    end
    else
    begin
      Result := False;

      BlockChainLogs.DoAlert('CheckBlocks: AFromID ' + AFromID.AsString + ', AToId ' + AToID.AsString, GetDataAsString(i));

      RawBlock.Free;
      break;
    end;
    Block.Free;
    RawBlock.Free;
  end;
end;

function TBlockChainInquiries.CheckHashByInfo(const Buffer; Count: integer; Pkey: TPublicKey; buf: TBytes): boolean;
var
  bufA, bufB: TBytes;
  BufStream: TMemoryStream;
begin
  Result := False;
  BufStream := TMemoryStream.Create;
  BufStream.Write(Buffer, Count);
  BufStream.Position := 0;
  bufA := THashSHA2.GetHashBytes(BufStream);
  BufStream.Destroy;
  try
    bufB := RSADecrypt(Pkey, buf);
  except
    exit;
  end;
  if bufA = bufB then
    Result := True;
end;

procedure TBlockChainInquiries.CheckMiningssCache;
var
  Header: THeader;
  ItemsOnDelete: TArray<TBytes>;
begin
  ItemsOnDelete := [];
  for var item in MiningChain.Cache do
  begin
    Header := Copy(item, 0, SizeOf(Header));
    case Header.VersionData of
      0:
        begin
          var
            Block: TMiningBlockV0;
          Block := TMiningBlockV0.Create;
          Block.SetData(item);
          var
            trx: TMiningTrxV0 := Block.GetTrxData;
          if MiningChain.CheckOwner(trx.MiningInfo.OwnerID) then
            ItemsOnDelete := ItemsOnDelete + [item];
          Block.Free;
        end;
    end;
  end;
  for var item in ItemsOnDelete do
    MiningChain.Cache.Remove(item);
end;

procedure TBlockChainInquiries.CheckTokensCache;
var
  Header: THeader;
  ItemsOnDelete: TArray<TBytes>;
begin
  ItemsOnDelete := [];
  for var item in TokensChain.Cache do
  begin
    Header := Copy(item, 0, SizeOf(Header));
    case Header.VersionData of
      0:
        begin
          var
            Block: TTokensBlockV0;
          Block := TTokensBlockV0.Create;
          Block.SetData(item);
          var
            trx: TTokensTrxV0 := Block.GetTrxData;
          if TokensChain.GetIDToken(trx.TokensInfo.Symbol) <> 0 then
            ItemsOnDelete := ItemsOnDelete + [item];
          Block.Free;
        end;
    end;
  end;
  for var item in ItemsOnDelete do
    TokensChain.Cache.Remove(item);
end;

procedure TBlockChainInquiries.CheckTransfersCache;
var
  Header: THeader;
  ItemsOnDelete: TArray<TBytes>;
begin
  ItemsOnDelete := [];
  for var item in TransferChain.Cache do
  begin
    Header := Copy(item, 0, SizeOf(Header));
    case Header.VersionData of
      0:
        begin
          var
            Block: TTransferBlockV0;
          Block := TTransferBlockV0.Create;
          Block.SetData(item);
          var
            trx: TTransferTrxV0 := Block.GetTrxData;
          ItemsOnDelete := ItemsOnDelete + [item];
          Block.Free;
        end;
    end;
  end;
  for var item in ItemsOnDelete do
    TransferChain.Cache.Remove(item);
end;

procedure TBlockChainInquiries.CoruptedBlockChain;
begin
end;

function TBlockChainInquiries.CountCacheBlock: UInt64;
begin
  Result := AccountsChain.GetCacheCount + MultiSignChain.GetCacheCount + VotingResultChain.GetCacheCount + CommissionChain.GetCacheCount +
    TransferChain.GetCacheCount + TokensChain.GetCacheCount + MiningChain.GetCacheCount + ServiceChain.GetCacheCount +
    ServiceResultChain.GetCacheCount + MinedChain.GetCacheCount;
end;

function TBlockChainInquiries.SetTrxCacheChain(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet; out ACountBlocks: UInt64): boolean;
var
  lastBlock: UInt64;
  Hash, HashBuf: THash;
  bufA, bufB: TBytes;
  flag: boolean;
  cnt: integer;
  Commission: TTransferBlockV0;

begin
  bufA := Copy(ABytes, Length(ABytes) - 64, 64);
  Result := True;
  flag := False;
  try
    case TypeChain of
      Accounts:
        begin
          case LastVersionAccount of
            0:
              begin
                var
                  trx: TAccountTrxV0;
                trx := ABytes;
                if trx.CheckTrx(trx.AccountInfo.PublicKey) then
                begin
                  flag := Result;
                  var
                    BaseBlock: TAccountBlockV0;
                  BaseBlock := TAccountBlockV0.Create(trx, AccountsChain.GetLastBlockHash);
                  AccountsChain.SetBlock(BaseBlock.GetData);
                  BaseBlock.Free;
                end;
              end;
          else
            Result := False;
          end;
          if (NodeState = Speaker) and (ParamStr(1) = 'init') and flag then
          begin
            AccountsChain.ApproveBlocks(AWallet);
            Hash := AccountsChain.GetLastBlockHash;
            lastBlock := AccountsChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TypeChain, lastBlock, Hash, AWallet);
          end;
        end;
      Tokens:
        begin
          case LastVersionTokens of
            0:
              begin
                var
                  trx: TTokensTrxV0;
                trx := ABytes;

                flag := trx.CheckTrx(TryGetPublicKey(trx.TokensInfo.Owner));

                if flag and (TryGetTokenID(trx.TokensInfo.Symbol) > 0) then
                begin
                  Result := False;
                  exit;
                end;
                var
                  BaseBlock: TTokensBlockV0;
                BaseBlock := TTokensBlockV0.Create(trx, TokensChain.GetLastBlockHash);
                TokensChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
                if (NodeState = Speaker) and (ParamStr(1) = 'init') then
                begin
                  TokensChain.ApproveBlocks(AWallet);
                  SetTrxInMainChain(TypeChain, TokensChain.GetLastBlockID, TokensChain.GetLastBlockHash, AWallet);
                  var
                    TrxTransfer: TTransferTrxV0;
                  TrxTransfer.TransferInfo.DirectFrom := 0;
                  TrxTransfer.TransferInfo.DirectTo := trx.TokensInfo.Owner;
                  TrxTransfer.TransferInfo.Amount := trx.TokensInfo.Volume;
                  TrxTransfer.TransferInfo.TokenID := TokensChain.GetIDToken(trx.TokensInfo.Symbol);
                  TrxTransfer.SignTrx(AWallet);
                  var
                    BaseBlockTrx: TTransferBlockV0;
                  BaseBlockTrx := TTransferBlockV0.Create(TrxTransfer, TransferChain.GetLastBlockHash);
                  TransferChain.SetBlock(BaseBlockTrx.GetData);
                  BaseBlockTrx.Free;
                end;
              end;
          else
            Result := False;
          end;
          if flag and (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            TransferChain.ApproveBlocks(AWallet);
            Hash := TransferChain.GetLastBlockHash;
            lastBlock := TransferChain.GetLastBlockID;
            ACountBlocks := 2;
            SetTrxInMainChain(Transfers, lastBlock, Hash, AWallet);
          end;
        end;
      Transfers:
        begin
          case LastVersionTransfer of
            0:
              begin
                var
                  trx: TTransferTrxV0;
                trx := ABytes;
                flag := trx.CheckTrx(TryGetPublicKey(trx.TransferInfo.DirectFrom));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                if TransferChain.GetBalance(trx.TransferInfo.DirectFrom, trx.TransferInfo.TokenID) < GetVolumeFromAmount(trx.TransferInfo.Amount,
                  TokensChain.GetTokenDecimals(trx.TransferInfo.TokenID)) then
                  raise Exception.Create('Not enough funds');
                var
                  BaseBlock: TTransferBlockV0;
                BaseBlock := TTransferBlockV0.Create(trx, TransferChain.GetLastBlockHash);
                BlockChainLogs.DoAlert('SetTrxCacheChain', 'UnixTime:' + trx.TransferInfo.DateTimeUnix.ToString + ';' + 'DirectFrom:' +
                  trx.TransferInfo.DirectFrom.AsString + ';' + 'DirectTo:' + trx.TransferInfo.DirectTo.AsString + ';' + 'Amount:' +
                  trx.TransferInfo.Amount.AsString + ';' + 'TokenID:' + trx.TransferInfo.TokenID.AsString + ';');
                TransferChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
              end;
          else
            Result := False;
          end;
          if flag and (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            TransferChain.ApproveBlocks(AWallet);
            Hash := TransferChain.GetLastBlockHash;
            lastBlock := TransferChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(Transfers, lastBlock, Hash, AWallet);
          end;
        end;
      MultiSigns:
        begin
          case LastVersionMultiSign of
            0:
              begin
                var
                  trx: TMultiSignTrxV0;
                trx := ABytes;
                flag := trx.CheckTrx(TryGetPublicKey(trx.MultiSignInfo.ValID));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                var
                  BaseBlock: TMultiSignBlockV0;
                BaseBlock := TMultiSignBlockV0.Create(trx, MultiSignChain.GetLastBlockHash);
                MultiSignChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
              end;
          else
            Result := False;
          end;
          if flag and (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            MultiSignChain.ApproveBlocks(AWallet);
            Hash := MultiSignChain.GetLastBlockHash;
            lastBlock := MultiSignChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TypeChain, lastBlock, Hash, AWallet);
          end;
        end;
      VotingResults:
        begin
          case LastVersionVotingResult of
            0:
              begin
                var
                  trx: TVotingResultTrxV0;
                trx := ABytes;
                flag := trx.CheckTrx(TryGetPublicKey(trx.VotingResultInfo.VotingOwnerID));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                var
                  BaseBlock: TVotingResultBlockV0;
                BaseBlock := TVotingResultBlockV0.Create(trx, VotingResultChain.GetLastBlockHash);
                VotingResultChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
              end;
          else
            Result := False;
          end;
        end;
      Commissions:
        begin
          case LastVersionÑommission of
            0:
              begin
                var
                  trx: TCommissionTrxV0;
                trx := ABytes;
                var
                  BaseBlock: TCommissionBlockV0;
                BaseBlock := TCommissionBlockV0.Create(trx, CommissionChain.GetLastBlockHash);
                CommissionChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
              end;
          else
            Result := False;
          end;
          if (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            CommissionChain.ApproveBlocks(AWallet);
            Hash := CommissionChain.GetLastBlockHash;
            lastBlock := CommissionChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TypeChain, lastBlock, Hash, AWallet);
          end;
        end;
      Mining:
        begin
          case LastVersionMining of
            0:
              begin
                var
                  trx: TTransferTrxV0;
                trx := ABytes;
                flag := trx.CheckTrx(TryGetPublicKey(trx.TransferInfo.DirectFrom));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                if TransferChain.GetBalance(trx.TransferInfo.DirectFrom, trx.TransferInfo.TokenID) < GetVolumeFromAmount(trx.TransferInfo.Amount,
                  TokensChain.GetTokenDecimals(trx.TransferInfo.TokenID)) then
                  raise Exception.Create('Not enough funds');
                var
                  BaseBlock: TTransferBlockV0;
                BaseBlock := TTransferBlockV0.Create(trx, TransferChain.GetLastBlockHash);
                TransferChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
                var
                  TrxOM: TMiningTrxV0;
                TrxOM.MiningInfo.OwnerID := trx.TransferInfo.DirectFrom;
                var
                  BaseBlockOM: TMiningBlockV0;
                BaseBlockOM := TMiningBlockV0.Create(TrxOM, MiningChain.GetLastBlockHash);
                MiningChain.SetBlock(BaseBlockOM.GetData);
                BaseBlockOM.Free;
              end;
          else
            Result := False;
          end;
          if flag and (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            TransferChain.ApproveBlocks(AWallet);
            MiningChain.ApproveBlocks(AWallet);
            SetTrxInMainChain(Transfers, TransferChain.GetLastBlockID, TransferChain.GetLastBlockHash, AWallet);
            Hash := MiningChain.GetLastBlockHash;
            lastBlock := MiningChain.GetLastBlockID;
            ACountBlocks := 2;
            SetTrxInMainChain(Mining, lastBlock, Hash, AWallet);
          end;
        end;
      Service:
        begin
          case LastVersionService of
            0:
              begin
                // add commission
                var
                  trx: TTransferTrxV0;

                trx := Copy(ABytes, cnt, SizeOf(TTransferTrxV0));
                flag := trx.CheckTrx(TryGetPublicKey(trx.TransferInfo.DirectFrom));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                cnt := SizeOf(TTransferTrxV0);
                if TransferChain.GetBalance(trx.TransferInfo.DirectFrom, trx.TransferInfo.TokenID) < GetVolumeFromAmount(trx.TransferInfo.Amount,
                  TokensChain.GetTokenDecimals(trx.TransferInfo.TokenID)) then
                  raise Exception.Create('Not enough funds');
                Commission := TTransferBlockV0.Create(trx, TransferChain.GetLastBlockHash);
                TransferChain.SetBlock(Commission.GetData);
                Commission.Free;
                // ---add commission---//

                var
                  trxS: TServiceV0;
                flag := trxS.CheckTrx(TryGetPublicKey(trxS.ServiceInfo.Owner));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                trxS := ABytes;
                trxS := Copy(ABytes, cnt, SizeOf(TServiceV0));

                var
                  BaseBlockBB: TServiceBlockV0;
                BaseBlockBB := TServiceBlockV0.Create(trxS, ServiceChain.GetLastBlockHash);
                ServiceChain.SetBlock(BaseBlockBB.GetData);
                BaseBlockBB.Free;

              end;
          else
            Result := False;
          end;

          if flag and (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            ServiceChain.ApproveBlocks(AWallet);
            Hash := ServiceChain.GetLastBlockHash;
            lastBlock := ServiceChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TypeChain, lastBlock, Hash, AWallet);
          end;
        end;
      ServiceResult:
        begin
          case LastVersionServiceResult of
            0:
              begin
                var
                  trx: TServiceResultV0;
                trx := ABytes;
                flag := trx.CheckTrx(TryGetPublicKey(TryGetServiceInfo(trx.ServiceResultInfo.ID).Owner));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                var
                  BaseBlock: TServiceResultBlockV0;
                BaseBlock := TServiceResultBlockV0.Create(trx, ServiceResultChain.GetLastBlockHash);
                ServiceResultChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
              end;
          else
            Result := False;
          end;

          if flag and (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            ServiceResultChain.ApproveBlocks(AWallet);
            Hash := ServiceResultChain.GetLastBlockHash;
            lastBlock := ServiceResultChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TypeChain, lastBlock, Hash, AWallet);
          end;
        end;
      Mined:
        begin
          case LastVersionMined of
            0:
              begin
                var
                  trx: TMinedTrxV0 := ABytes;
                flag := trx.CheckTrx(TryGetPublicKey(trx.MinedInfo.IDWitness));
                if not flag then
                begin
                  Result := False;
                  exit;
                end;
                var
                  BaseBlock: TMinedBlockV0 := TMinedBlockV0.Create(trx, MinedChain.GetLastBlockHash);
                MinedChain.SetBlock(BaseBlock.GetData);
                BaseBlock.Free;
              end;
          else
            Result := False;
          end;
          if flag and (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            MinedChain.ApproveBlocks(AWallet);
            Hash := MinedChain.GetLastBlockHash;
            lastBlock := MinedChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(Mined, lastBlock, Hash, AWallet);
          end;
        end;
    end;
  except
    Result := False;
  end;
end;

function TBlockChainInquiries.TestDeSerializtion(const buf: TBytes): boolean;
var
  Data: TBytes;
  i, counter: integer;
  blocksSize, j, Count, size, controlSize: UInt64;
  Header: THeader;
  version, TypeChain: Byte;
begin
  Data := Copy(buf, 1, Length(buf) - 2);
  Move(Data[0], controlSize, SizeOf(controlSize));
  Data := Copy(Data, SizeOf(controlSize), Length(Data) - SizeOf(controlSize));
  Move(Data[0], Count, SizeOf(Count));
  Data := Copy(Data, SizeOf(Count), Length(Data) - SizeOf(Count));
  if controlSize <= MainChain.GetLastBlockID then
    exit;
  for i := 0 to Count do
  begin
    Move(Data[0], size, SizeOf(size));
    Data := Copy(Data, SizeOf(size), Length(Data) - SizeOf(size));
    Move(Data[0], Header, SizeOf(Header));
    case Header.VersionData of
      0:
        begin
          var
            MainBlock: TMainBlockV0;
          MainBlock := TMainBlockV0.Create;
          MainBlock.SetData(Copy(Data, 0, size));
          if CheckBlock(MainBlock, TryGetPublicKey(MainBlock.GetHeader.WitnessID), MainBlock.GetHeader.IDBlock) then
            MainChain.WriteApprovedBlock(MainBlock)
          else
            CoruptedBlockChain;
          MainBlock.Free;
        end;
    end;
    Data := Copy(Data, size, Length(Data) - size);
  end;
  counter := 0;
  while counter < Count do
  begin
    Move(Data[0], TypeChain, SizeOf(Byte));
    Move(Data[1], j, SizeOf(j));
    Data := Copy(Data, SizeOf(j) + SizeOf(TypeChain), Length(Data) - SizeOf(j) - SizeOf(TypeChain));
    case TypeChain of
      1:
        begin
          blocksSize := AccountsChain.WriteApprovedBlocks(j, Data);
        end;
      2:
        begin
          blocksSize := TokensChain.WriteApprovedBlocks(j, Data);
        end;
      3:
        begin
          blocksSize := TransferChain.WriteApprovedBlocks(j, Data);
        end;
      4:
        begin
          blocksSize := MultiSignChain.WriteApprovedBlocks(j, Data);
        end;
      5:
        begin
          blocksSize := VotingResultChain.WriteApprovedBlocks(j, Data);
        end;
      6:
        begin
          blocksSize := CommissionChain.WriteApprovedBlocks(j, Data);
        end;
    end;
    inc(counter, j);
    Data := Copy(Data, blocksSize, Length(Data) - blocksSize);
  end;
end;

function TBlockChainInquiries.TryGetAccountID(AHash: THash): UInt64;
begin
  Result := AccountsChain.GetID(AHash);
end;

function TBlockChainInquiries.TryGetTokenDecimals(AID: UInt64): UInt64;
begin
  Result := TokensChain.GetTokenDecimals(AID);
end;

function TBlockChainInquiries.TryGetTokenID(ASymbol: TSymbol): UInt64;
begin
  Result := TokensChain.GetIDToken(ASymbol);
end;

function TBlockChainInquiries.TryGetTokenInfo(ASymbol: String): TTokensInfoV0;
begin
  var
  Data := TokensChain.GetBlock(TokensChain.GetIDToken(ASymbol)).GetDataWithoutHeader;
  Result := TTokensTrxV0(Data).TokensInfo;
end;

function TBlockChainInquiries.TryCheckAccIDByMining(AID: UInt64): boolean;
var
  Data: TBytes;
  Block: TBaseBlock;
begin
  Result := False;
  for var j := 1 to MiningChain.GetLastBlockID do
  begin
    try
      Block := MiningChain.GetBlock(j);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            Data := MiningChain.GetBlock(j).GetDataWithoutHeader;
            var
              info: UInt64 := TMiningInfoV0(Data).OwnerID;
            if info = AID then
            begin
              Result := True;
              break;
            end;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.TryGetTokenInfoAll(Sort: String = 'datetime'): TArray<TTokensInfoV0>;
var
  Data: TBytes;
  Block: TBaseBlock;
begin
  Result := [];
  for var j := 0 to TokensChain.GetLastBlockID do
  begin
    try
      Block := TokensChain.GetBlock(j);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            Data := TokensChain.GetBlock(j).GetDataWithoutHeader;
            var
              info: TTokensInfoV0 := TTokensTrxV0(Data).TokensInfo;
            Result := Result + [info];
          end;
      end;
    finally
      Block.Free;
    end;
  end;

  if Sort > '' then
  begin
    TArray.Sort<TTokensInfoV0>(Result, TComparer<TTokensInfoV0>.Construct(
      function(const Left, Right: TTokensInfoV0): integer
      begin
        if Sort = 'ownerid' then
          Result := CompareValue(Left.Owner, Right.Owner)
        else if Sort = 'datetime' then
          Result := CompareValue(Left.UnixTime, Right.UnixTime)
        else if Sort = 'name' then
          Result := -CompareText(Trim(Left.Name), Trim(Right.Name))
        else if Sort = 'symbol' then
          Result := -CompareText(Trim(Left.Symbol), Trim(Right.Symbol))
        else if Sort = 'decimals' then
          Result := CompareValue(Left.Decimals, Right.Decimals)
        else if Sort = 'volume' then
          Result := CompareValue(Left.Volume, Right.Volume)
        else
          Result := CompareValue(Left.UnixTime, Right.UnixTime);
      end));
  end;
end;

function TBlockChainInquiries.TryGetTokenOwners(Symbol: TSymbol): TArray<TAccountInfoV0>;
var
  Block: TBaseBlock;
  Data: TBytes;
begin
  Result := [];
  for var j := 1 to AccountsChain.GetLastBlockID do
  begin
    if TransferChain.GetBalance(j, TryGetTokenID(Symbol)) > 0 then
    begin
      try
        Block := AccountsChain.GetBlock(j);
        Data := Block.GetDataWithoutHeader;
        var
        Header := Block.GetHeader;
        case Header.VersionData of
          0:
            begin
              var
                info: TAccountInfoV0 := TAccountTrxV0(Data).AccountInfo;
              Result := Result + [info];
            end;
        end;
      finally
        Block.Free;
      end;
    end;
  end;
end;

function TBlockChainInquiries.TryGetCommissionsInfoAll: TArray<string>;
var
  Block: TBaseBlock;
  Data: TBytes;
begin
  try
    Block := CommissionChain.GetBlock(CommissionChain.GetLastBlockID);
    Data := Block.GetDataWithoutHeader;
    var
    Header := Block.GetHeader;
    case Header.VersionData of
      0:
        begin
          var
            info: TCommissionInfoV0 := TCommissionTrxV0(Data).CommissionInfo;
          Result := ['CommTransOrigCoin ' + UInttostr(info.CommTransOrigCoin)] + ['CommRecService ' + UInttostr(info.CommRecService)] +
            ['CommTransTokenInside ' + UInttostr(info.CommTransTokenInside)] + ['CommCreateToken ' + UInttostr(info.CommCreateToken)] +
            ['CommCreateService ' + UInttostr(info.CommCreateService)];
        end;
    end;
  finally
    Block.Free;
  end;
end;

function TBlockChainInquiries.TryGetCountOM: UInt64;
begin
  Result := MiningChain.GetLastBlockID;
end;

function TBlockChainInquiries.TryGetFunctionAboutOwningOM(UID: UInt64): boolean;
var
  OMOwners: TArray<UInt64>;
begin
  Result := False;
  OMOwners := MiningChain.GetOMs;
  for var item in OMOwners do
    if item = UID then
    begin
      Result := True;
      break;
    end;
end;

function TBlockChainInquiries.TryGetPublicKey(AID: UInt64): TPublicKey;
var
  Block: TBaseBlock;
begin
  if not CheckAnyID(Accounts, AID) then
    exit;
  Result := Default (TPublicKey);
  try
    Block := AccountsChain.GetBlock(AID);
    case Block.GetHeader.VersionData of
      0:
        begin
          var
            re: TAccountTrxV0 := TAccountBlockV0(Block).GetDataWithoutHeader;
          Result := re.AccountInfo.PublicKey;
        end;
    end;
  finally
    Block.Free;
  end;
end;

function TBlockChainInquiries.TryGetReceivedAmountAllTime(AID, TID: UInt64): double;
var
  Block: TBaseBlock;
  Data: TBytes;
  Amount: UInt64;
begin
  if not CheckAnyID(Accounts, AID) then
    exit;
  Amount := 0;
  for var j := 1 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(j);
      Data := Block.GetDataWithoutHeader;
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              info: TTransferInfoV0 := TTransferTrxV0(Data).TransferInfo;
            if ((info.DirectTo = AID) and (info.TokenID = TID)) then
              Amount := Amount + info.Amount;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
  Result := GetVolumeFromAmountToken(Amount, TID);
end;

function TBlockChainInquiries.TryGetSentAmountAllTime(AID, TID: UInt64): double;
var
  Block: TBaseBlock;
  Data: TBytes;
  Amount: UInt64;
begin
  if not CheckAnyID(Accounts, AID) then
    exit;
  Amount := 0;
  for var j := 1 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(j);
      Data := Block.GetDataWithoutHeader;
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              info: TTransferInfoV0 := TTransferTrxV0(Data).TransferInfo;
            if ((info.DirectFrom = AID) and (info.TokenID = TID)) then
              Amount := Amount + info.Amount;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
  Result := GetVolumeFromAmountToken(Amount, TID);
end;

function TBlockChainInquiries.TryGetServiceDataByID(ID: UInt64): TArray<TServiceResultV0>;
var
  Block: TBaseBlock;
  Data: TBytes;
begin
  Result := [];
  for var j := 1 to ServiceResultChain.GetLastBlockID do
  begin
    try
      Block := ServiceResultChain.GetBlock(j);
      Data := Block.GetDataWithoutHeader;
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              info: TServiceResultV0 := TServiceResultV0(Data);
            if info.ServiceResultInfo.ID = ID then
              Result := Result + [info];
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.TryGetServiceID(AName: string): UInt64;
begin
  Result := ServiceChain.GetIDService(AName);
end;

function TBlockChainInquiries.TryGetServiceInfo(ID: UInt64): TServiceInfoV0;
begin
  var
  ServiceData := ServiceChain.GetBlock(ID).GetDataWithoutHeader;
  Result := TServiceV0(ServiceData).ServiceInfo;
end;

function TBlockChainInquiries.TryGetAccountInfo(Address: THash): TAccountInfoV0;
begin
  var
  AccData := AccountsChain.GetBlock(AccountsChain.GetID(Address)).GetDataWithoutHeader;
  Result := TAccountTrxV0(AccData).AccountInfo;
end;

function TBlockChainInquiries.TryGetAccRegDate(Address: THash): Int64;
begin
  var
  AccHeader := AccountsChain.GetBlock(AccountsChain.GetID(Address)).GetHeader;
  Result := THeader(AccHeader).UnixTime;
end;

function TBlockChainInquiries.TryGetTokenSymbol(AID: UInt64): TSymbol;
begin
  Result := TokensChain.GetTokenName(AID);
end;

function TBlockChainInquiries.TryGetTokenTransCount(Symbol: TSymbol): UInt64;
var
  Block: TBaseBlock;
begin
  Result := 0;
  for var i := 1 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(i);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              trx: TTransferTrxV0 := Block.GetDataWithoutHeader;
            var
              info: TTransferInfoV0 := trx.TransferInfo;
            if TryGetTokenSymbol(info.TokenID) = Symbol then
              Result := Result + 1;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.TryGetTransAmount(Trans: TTransferInfoV0): double;
begin
  var
  TokenID := Trans.TokenID;
  var
  Amount := Trans.Amount;
  var
  Decimals := TryGetTokenDecimals(TokenID);
  Result := GetVolumeFromAmount(Amount, Decimals);
end;

function TBlockChainInquiries.TryGetTransBetweenTime(AccID: UInt64; UnixFrom, UnixTo: Int64): TArray<TTransferInfoV0>;
var
  info: TTransferInfoV0;
  head: THeader;
  Data, DataH: TBytes;
begin
  Result := [];
  for var j := 1 to TransferChain.GetLastBlockID do
  begin
    Data := TransferChain.GetBlock(j).GetDataWithoutHeader;
    info := TTransferTrxV0(Data).TransferInfo;
    DataH := TransferChain.GetBlock(j).GetDataHeader;
    head := THeader(DataH);
    if (((info.DirectFrom = AccID) or (info.DirectTo = AccID)) and ((UnixFrom <= head.UnixTime) and (head.UnixTime <= UnixTo))) then
      Result := Result + [info];
  end;
end;

function TBlockChainInquiries.TryGetTransactionHistoryItems(AccID: UInt64; UnixFrom, UnixTo: Int64): TArray<TTransHistoryItem>;
var
  Block: TBaseBlock;
  Data: TTransHistoryItem;
begin
  Result := [];
  for var i := 1 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(i);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              trx: TTransferTrxV0 := Block.GetDataWithoutHeader;
            var
              info: TTransferInfoV0 := trx.TransferInfo;
            if (((info.DirectFrom = AccID) or (info.DirectTo = AccID)) and ((UnixFrom <= Header.UnixTime) and (Header.UnixTime <= UnixTo))) then
            begin
              Data.datetime := Header.UnixTime;
              Data.block_number := i;
              Data.Afrom := TryGetAccountAddress(info.DirectFrom);
              Data.Ato := TryGetAccountAddress(info.DirectTo);
              Data.Hash := Header.CurrentHash;
              Data.token := TryGetTokenSymbol(info.TokenID);
              Data.sent := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID));
              Data.sentstr := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID), False);
              Data.received := Data.sent;
              Data.receivedstr := Data.sentstr;
              Data.fee := 0;
              Result := Result + [Data];
            end;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.TryGetTransCount(AccID, TokenID: UInt64): UInt64;
begin
  Result := Trunc(Length(GetTransactionHistory(AccID, TokenID)) / 6);
end;

function TBlockChainInquiries.TryGetTransInfo(AHash: THash): TTransHistoryItem;
var
  Block: TBaseBlock;
  Data: TTransHistoryItem;
begin
  Result := Default (TTransHistoryItem);
  Result.datetime := 0;
  for var i := 1 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(i);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              trx: TTransferTrxV0 := Block.GetDataWithoutHeader;
            var
              info: TTransferInfoV0 := trx.TransferInfo;
            if Header.CurrentHash = AHash then
            begin
              Data.datetime := Header.UnixTime;
              Data.block_number := i;
              Data.Afrom := TryGetAccountAddress(info.DirectFrom);
              Data.Ato := TryGetAccountAddress(info.DirectTo);
              Data.Hash := Header.CurrentHash;
              Data.token := TryGetTokenSymbol(info.TokenID);
              Data.sent := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID));
              Data.sentstr := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID),False);
              Data.received := 0;
              Data.receivedstr := '0';
              Data.fee := 0;
              Result := Data;
            end;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.GetVolumeFromAmount(Amount: UInt64; Decimals: UInt64): double;
begin
  if Decimals = 0 then
    Result := Amount
  else
    Result := Amount / (Power(10, Decimals));
end;

function TBlockChainInquiries.GetVolumeFromAmount(Amount, Decimals: UInt64;
  IsForce: Boolean): String;
begin
  Result := Amount.AsString;

  if Decimals > 0 then
  begin
    while Length(Result) < Decimals do
      Result := '0' + Result;

    Result := Result.Insert(Length(Result) - Decimals, DecimalSeparator);
    if Result.StartsWith(DecimalSeparator) then
      Result := '0' + Result;

    while Result.EndsWith('0') do
    begin
      Result := Copy(Result, 1, Length(Result) - 1);
      if Result.EndsWith(DecimalSeparator) then
      begin
        Result := Copy(Result, 1, Length(Result) - 1);
        break;
      end;
    end;
  end;
end;

function TBlockChainInquiries.GetVolumeFromAmountToken(Amount, TokenID: UInt64): double;
begin
  var
  decimal := TryGetTokenDecimals(TokenID);
  if decimal = 0 then
    Result := Amount
  else
    Result := Amount / (Power(10, TryGetTokenDecimals(TokenID)));
end;

function TBlockChainInquiries.TryGetAccTransactions(AccID: UInt64): TArray<TTransferInfoV0>;
var
  Block: TBaseBlock;
  Data: TBytes;
begin
  Result := [];
  for var j := 0 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(j);
      Data := Block.GetDataWithoutHeader;
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              info: TTransferInfoV0 := TTransferTrxV0(Data).TransferInfo;
            if ((info.DirectFrom = AccID) or (info.DirectTo = AccID)) then
              Result := Result + [info];
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.TryGetAllAccounts(Sort: String = 'datetime'): TArray<TAccountInfoV0>;
var
  Block: TBaseBlock;
  Data: TBytes;
begin
  Result := [];
  for var j := 1 to AccountsChain.GetLastBlockID do
  begin
    try
      Block := AccountsChain.GetBlock(j);
      Data := Block.GetDataWithoutHeader;
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              info: TAccountInfoV0 := TAccountTrxV0(Data).AccountInfo;
            Result := Result + [info];
          end;
      end;
    finally
      Block.Free;
    end;
  end;
  if Sort = 'datetime' then
  begin
    TArray.Sort<TAccountInfoV0>(Result, TComparer<TAccountInfoV0>.Construct(
      function(const Left, Right: TAccountInfoV0): integer
      begin
        Result := CompareValue(TryGetAccRegDate(Left.Address), TryGetAccRegDate(Right.Address));
      end));
  end;
end;

function TBlockChainInquiries.TryGetALLServices(Sort: String = 'datetime'): TArray<TServiceInfoV0>;
var
  Block: TBaseBlock;
  Data: TBytes;
begin
  Result := [];
  for var j := 1 to ServiceChain.GetLastBlockID do
  begin
    try
      Block := ServiceChain.GetBlock(j);
      Data := Block.GetDataWithoutHeader;
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              info: TServiceInfoV0 := TServiceV0(Data).ServiceInfo;
            Result := Result + [info];
          end;
      end;
    finally
      Block.Free;
    end;
  end;

  if Sort > '' then
  begin
    TArray.Sort<TServiceInfoV0>(Result, TComparer<TServiceInfoV0>.Construct(
      function(const Left, Right: TServiceInfoV0): integer
      begin
        if Sort = 'ownerid' then
          Result := CompareValue(Left.Owner, Right.Owner)
        else if Sort = 'datetime' then
          Result := CompareValue(Left.UnixTime, Right.UnixTime)
        else if Sort = 'name' then
          Result := -CompareText(Trim(Left.Name), Trim(Right.Name))
        else
          Result := CompareValue(Left.UnixTime, Right.UnixTime);
      end));
  end;
end;

function TBlockChainInquiries.TryGetALLTransactions(Sort: String = 'blocknum'): TArray<TTransHistoryItem>;
var
  Block: TBaseBlock;
  Data: TTransHistoryItem;
  j: integer;
begin
  Result := [];
  j := TransferChain.GetLastBlockID;
  for var i := 1 to j do
  begin
    try
      Block := TransferChain.GetBlock(i);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              trx: TTransferTrxV0 := Block.GetDataWithoutHeader;
            var
              info: TTransferInfoV0 := trx.TransferInfo;
            Data.datetime := Header.UnixTime;
            Data.block_number := i;
            Data.Afrom := TryGetAccountAddress(info.DirectFrom);
            Data.Ato := TryGetAccountAddress(info.DirectTo);
            Data.Hash := Header.CurrentHash;
            Data.token := TryGetTokenSymbol(info.TokenID);
            Data.sent := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID));
            Data.sentstr := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID),False);
            Data.received := 0;
            Data.receivedstr := '0';
            Data.fee := 0;
            Result := Result + [Data];
          end;
      end;
    finally
      Block.Free;
    end;
  end;

  if Sort > '' then
  begin
    TArray.Sort<TTransHistoryItem>(Result, TComparer<TTransHistoryItem>.Construct(
      function(const Left, Right: TTransHistoryItem): integer
      begin
        if Sort = 'datetime' then
          Result := CompareValue(Left.datetime, Right.datetime)
        else if Sort = 'blocknum' then
          Result := CompareValue(Left.block_number, Right.block_number)
        else if Sort = 'token' then
          Result := -CompareText(Trim(Left.token), Trim(Right.token))
        else if Sort = 'sent' then
          Result := CompareValue(Left.sent, Right.sent)
        else
          Result := CompareValue(Left.block_number, Right.block_number);
      end));
  end;
end;

function TBlockChainInquiries.TryGetAllTransactionsBySymbol(Symbol: TSymbol): TArray<TTransHistoryItem>;
var
  Block: TBaseBlock;
  Data: TTransHistoryItem;
begin
  Result := [];
  for var i := 1 to TransferChain.GetLastBlockID do
  begin
    try
      Block := TransferChain.GetBlock(i);
      var
      Header := Block.GetHeader;
      case Header.VersionData of
        0:
          begin
            var
              trx: TTransferTrxV0 := Block.GetDataWithoutHeader;
            var
              info: TTransferInfoV0 := trx.TransferInfo;
            if info.TokenID = TryGetTokenID(Symbol) then
            begin
              Data.datetime := Header.UnixTime;
              Data.block_number := i;
              Data.Afrom := TryGetAccountAddress(info.DirectFrom);
              Data.Ato := TryGetAccountAddress(info.DirectTo);
              Data.Hash := Header.CurrentHash;
              Data.token := TryGetTokenSymbol(info.TokenID);
              Data.sent := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID));
              Data.sentstr := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID),False);
              Data.received := 0;
              Data.receivedstr := '0';
              Data.fee := 0;
              Result := Result + [Data];
            end;
          end;
      end;
    finally
      Block.Free;
    end;
  end;
end;

function TBlockChainInquiries.TryGetBalance(AHash: THash; ASymbol: string): double;
begin
  Result := -1;
  if not CheckAddress(AHash) then
    exit;
  var
  AID := TryGetAccountID(AHash);
  var
  TID := TryGetTokenID(ASymbol);
  if TID = 0 then
    exit;
  var
  decimal := TryGetTokenDecimals(TID);
  var
  firstBalance := TransferChain.GetBalance(AID, TID);
  if firstBalance = 0 then
    Result := 0
  else
    Result := GetVolumeFromAmount(firstBalance, decimal);
end;

function TBlockChainInquiries.TryGetBalanceString(AHash: THash;
  ASymbol: string): String;
var
  balance: string;
begin
  Result := '';
  if not CheckAddress(AHash) then
    exit;
  var
  AID := TryGetAccountID(AHash);
  var
  TID := TryGetTokenID(ASymbol);
  if TID = 0 then
    exit;
  var
  decimal := TryGetTokenDecimals(TID);

  Result := TransferChain.GetBalance(AID, TID).AsString;

  if decimal > 0 then
  begin
    while Length(Result) < decimal do
      Result := '0' + Result;

    Result := Result.Insert(Length(Result) - decimal, DecimalSeparator);
    if Result.StartsWith(DecimalSeparator) then
      Result := '0' + Result;

    while Result.EndsWith('0') do
    begin
      Result := Copy(Result, 1, Length(Result) - 1);
      if Result.EndsWith(DecimalSeparator) then
      begin
        Result := Copy(Result, 1, Length(Result) - 1);
        break;
      end;
    end;
  end;
end;

procedure TBlockChainInquiries.CreateOM(const AID: UInt64);
begin

end;

end.
