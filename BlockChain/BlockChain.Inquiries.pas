unit BlockChain.Inquiries;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Hash,
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,
  System.DateUtils,
  System.Math,
  App.Types,
  App.Meta,
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
    function ReadBlock(AIndBlock: integer; AType: TTypesChain): TBytes;
    procedure WriteBlock(const AData: TBytes; AType: TTypesChain; ABlockVersion: integer = -1);
    procedure SetTrxInMainChain(TypeChain: TTypesChain; lastBlock: UInt64; Hash: THash; AWallet: TWallet);
    procedure CoruptedBlockChain;
    function GetBlockOwner(IDChain, IDBlock: UInt64): UInt64;
    function CheckBlock(ABlock: TBaseBlock; PublicKey: TPublicKey): boolean;
    function CheckBlocks(AFromID, AToID: UInt64): boolean;
  public
    function GetAllCacheTrx: TBytes;
    function CountCacheBlock: UInt64;
    function GetOMs: TArray<UInt64>;
    function GetTransactionHistory(AID, ATID: UInt64): TArray<string>;
    function GetBalances(AAccountID: UInt64): TBytes;
    function TryGetBalance(AHash: THash; ASymbol: string): double;
    function CheckAddress(AHash: THash): boolean;
    function TryGetAccountID(AHash: THash): UInt64;
    function TryGetPublicKey(AID: UInt64): TPublicKey;
    function TryGetTokenID(ASymbol: string): UInt64;
    function TryGetTokenDecimals(AID: UInt64): UInt64;
    function TryGetTokenSymbol(AID: UInt64): TSymbol;
    function TryGetTokenInfo(ASymbol: String): TTokensInfoV0;
    function TryGetTokenInfoAll: TArray<TTokensInfoV0>;
    function TryGetAccountAddress(AccID: UInt64): THash;
    function TryGetTransCount(AccID, TokenID: UInt64): UInt64;
    function TryGetTransBetweenTime(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransferInfoV0>;
    function TryGetTransactionHistoryItems(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransHistoryItem>;
    function TryGetSentAmountAllTime(AccID, TokenID: UInt64): double;
    function TryGetReceivedAmountAllTime(AID, TID: UInt64): double;
    function GetVolumeFromAmount(Amount: UInt64; Decimals: UInt64): double;
    function GetVolumeFromAmountToken(Amount: UInt64; TokenID: UInt64): double;
    function TryGetTransAmount(Trans: TTransferInfoV0): double;
    function TryGetCommissionsInfoAll: TArray<string>;
    function TryGetAccTransactions(AccID: UInt64): TArray<TTransferInfoV0>;
    function TryGetAccountInfo(AAddress: THash): TAccountInfoV0;
    function CreateTrxNewToken(ASymbol, AName: string; ADecimals, AVolume: integer; AToken: TToken;
    AWallet: TWallet): TBytes;
    function CreateTrxNewTransfer(ASymbol: string; AIDTo, AAmount: UInt64; AWallet: TWallet): TBytes;
    function CreateTrxNewWallet(Wallet: TWallet): TBytes;
    function GetBlocksFrom(const AID: UInt64): TBytes;
    function GetChains: TArray<string>;
    function GetDataFromChain(i: integer): TArray<TArray<TPair<string, string>>>;
    function MainChainCount: UInt64;
    function SetTrxCacheChain(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet; out ACountBlocks: UInt64): boolean;
    function SearchMiningOwnerID(OwnerID: UInt64): boolean;
    function DoEasyBuyOm(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet; out ACountBlocks: UInt64): boolean;
    function TestDeSerializtion(const buf: TBytes): boolean;
    function ApproveAllCachedBlocks(AWallet: TWallet; out ACountBlocks: UInt64): TBytes;
    procedure SetAllCacheTrx(AData: TBytes);
    procedure DoMining(AWallet: TWallet; var ACountBlocks: integer);
    procedure CreateOM(const AID: UInt64);
    procedure SetNewBlocks(buf: TBytes);
    function CheckHashByInfo(const Buffer; Count: integer; Pkey: TPublicKey; buf: TBytes): boolean;
    function CheckAnyID(AType: TTypesChain; AID: UInt64): boolean;
    constructor Create(AMainChain: TMainChain; AAccountsChain: TAccountChain; ATokensChain: TTokensChain;
    ATransferChain: TTransferChain; AMultiSignChain: TMultiSignChain; AVotingResultChain: TVotingResultChain;
    A�ommissionChain: TCommissionChain; AMiningChain: TMiningChain);
    destructor Destroy; override;
  end;

implementation

{ TBlockChainInquiries }

function TBlockChainInquiries.ApproveAllCachedBlocks(AWallet: TWallet; out ACountBlocks: UInt64): TBytes;
var
  lastBlock: UInt64;
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
        SetTrxInMainChain(TTypesChain.Accounts, item.ID, item.Hash, AWallet);
    end;

    helpInfo := MultiSignChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
        SetTrxInMainChain(TTypesChain.MultiSigns, item.ID, item.Hash, AWallet);
    end;

    helpInfo := VotingResultChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
        SetTrxInMainChain(TTypesChain.VotingResults, item.ID, item.Hash, AWallet);
    end;

    helpInfo := CommissionChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
        SetTrxInMainChain(TTypesChain.Commissions, item.ID, item.Hash, AWallet);
    end;

    helpInfo := TransferChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
        SetTrxInMainChain(TTypesChain.Transfers, item.ID, item.Hash, AWallet);
    end;

    helpInfo := TokensChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
        SetTrxInMainChain(TTypesChain.Tokens, item.ID, item.Hash, AWallet);
    end;

    helpInfo := MiningChain.ApproveBlocks(AWallet);
    if Length(helpInfo) > 0 then
    begin
      inc(ACountBlocks, Length(helpInfo));
      for var item in helpInfo do
        SetTrxInMainChain(TTypesChain.Mining, item.ID, item.Hash, AWallet);
    end;

    if ACountBlocks > 0 then
      Result := GetBlocksFrom(MainChainCount - ACountBlocks);
  except
    Result := [];
  end;
end;

function TBlockChainInquiries.CheckAddress(AHash: THash): boolean;
begin
  Result := False;
  if AccountsChain.GetID(AHash) > 0 then
    Result := True;
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
  end;

end;

constructor TBlockChainInquiries.Create(AMainChain: TMainChain; AAccountsChain: TAccountChain; ATokensChain: TTokensChain;
ATransferChain: TTransferChain; AMultiSignChain: TMultiSignChain; AVotingResultChain: TVotingResultChain;
A�ommissionChain: TCommissionChain; AMiningChain: TMiningChain);
begin
  MainChain := AMainChain;
  AccountsChain := AAccountsChain;
  MultiSignChain := AMultiSignChain;
  VotingResultChain := AVotingResultChain;
  CommissionChain := A�ommissionChain;
  TransferChain := ATransferChain;
  TokensChain := ATokensChain;
  MiningChain := AMiningChain;
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

function TBlockChainInquiries.CreateTrxNewToken(ASymbol: string; AName: string; ADecimals, AVolume: integer; AToken: TToken;
AWallet: TWallet): TBytes;
var
  Base: TTokensInfoV0;
  trx: TTokensTrxV0;
begin
  if ((TokensChain.GetIDToken(ASymbol) = 0) and (ASymbol <> '') and (AName <> '')) then
  begin
    Base.Owner := WalletID;
    Base.Name := AName;
    Base.Symbol := ASymbol;
    Base.Decimals := ADecimals;
    Base.Volume := Round(AVolume * Power(10, ADecimals));
    Base.TokenType := AToken;
    Base.UnixTime := DateTimeToUnix(now, False);
    trx.TokensInfo := Base;
    trx.SignTrx(AWallet);
    Result := trx;
  end;
end;

function TBlockChainInquiries.CreateTrxNewTransfer(ASymbol: string; AIDTo, AAmount: UInt64; AWallet: TWallet): TBytes;
var
  Base: TTransferInfoV0;
  trx: TTransferTrxV0;
begin
  Result := [];
  if ((AAmount > 0) and not(AccountsChain.GetName(AIDTo) = Default (THash))) then
  begin
    Base.DirectFrom := AccountsChain.GetID(AWallet.GetAddress);
    Base.DirectTo := AIDTo;
    Base.Amount := AAmount;
    Base.TokenID := TryGetTokenID(ASymbol);
    trx.TransferInfo := Base;
    trx.SignTrx(AWallet);
    Result := trx;
  end;
end;

destructor TBlockChainInquiries.Destroy;
begin

  inherited;
end;

function TBlockChainInquiries.DoEasyBuyOm(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet;
out ACountBlocks: UInt64): boolean;
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
          MiningChain.SetBlock(BaseBlockOM);
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
    SetTrxInMainChain(TTypesChain.Mining, lastBlock, Hash, AWallet);
  end;
  WalletID := ID;
end;

procedure TBlockChainInquiries.DoMining(AWallet: TWallet; var ACountBlocks: integer);
var
  AID: UInt64;
  Value: UInt64;
begin
  if MiningChain.GetLastBlockID = 0 then
    exit;
  ACountBlocks := 0;
  Value := Round((TransferChain.GetBalance(0, TokensChain.GetIDToken(MainCoin)) * Percent) / MiningChain.GetLastBlockID);

  for var i := 1 to MiningChain.GetLastBlockID do
  begin
    case MiningChain.GetBlock(i).GetHeader.VersionData of
      0:
        begin
          var trx: TMiningTrxV0;
          var
          buf := MiningChain.GetBlock(i).GetData;
          trx := Copy(buf, SizeOf(THeader), Length(buf) - SizeOf(THeader));
          AID := trx.MiningInfo.OwnerID;
        end;
    end;

    case LastVersionTransfer of
      0:
        begin
          var TrxTransfer: TTransferTrxV0;
          TrxTransfer.TransferInfo.DirectFrom := 0;
          TrxTransfer.TransferInfo.DirectTo := AID;
          TrxTransfer.TransferInfo.Amount := Value;
          TrxTransfer.TransferInfo.TokenID := TokensChain.GetIDToken(MainCoin);
          TrxTransfer.SignTrx(AWallet);

          var BaseBlockTrx: TTransferBlockV0;
          BaseBlockTrx := TTransferBlockV0.Create(TrxTransfer, TransferChain.GetLastBlockHash);

          TransferChain.SetBlock(BaseBlockTrx);
        end;
    end;

    if (NodeState = Speaker) and (ParamStr(1) = 'init') then
    begin
      TransferChain.ApproveBlocks(AWallet);
      var
      Hash := TransferChain.GetLastBlockHash;
      var
      lastBlock := TransferChain.GetLastBlockID;
      SetTrxInMainChain(TTypesChain.Transfers, lastBlock, Hash, AWallet);
      inc(ACountBlocks, 1);
    end;
  end;
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
      Break;
    end
  end;
end;

procedure TBlockChainInquiries.SetNewBlocks(buf: TBytes);
var
  Data: TBytes;
  i, Counter, fromid, toid: integer;
  blocksSize, j, Count, size, controlSize: UInt64;
  Header: THeader;
  version, TypeChain: Byte;
begin
  Data := Copy(buf, 1, Length(buf) - 2);
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
          var MainBlock: TMainBlockV0;
          MainBlock := TMainBlockV0.Create;
          MainBlock.SetData(Copy(Data, 0, size));
          MainChain.WriteApprovedBlock(MainBlock);
          MainBlock.Free;
        end;
    end;
    Data := Copy(Data, size, Length(Data) - size);
  end;
  Counter := 0;
  while Counter < Count do
  begin
    Move(Data[0], TypeChain, SizeOf(Byte));
    Move(Data[1], j, SizeOf(j));
    Data := Copy(Data, SizeOf(j) + SizeOf(TypeChain), Length(Data) - SizeOf(j) - SizeOf(TypeChain));

    case TTypesChain(TypeChain) of
      TTypesChain.Accounts:
        begin
          blocksSize := AccountsChain.WriteApprovedBlocks(j, Data)
        end;
      TTypesChain.Tokens:
        begin
          blocksSize := TokensChain.WriteApprovedBlocks(j, Data);
        end;
      TTypesChain.Transfers:
        begin
          blocksSize := TransferChain.WriteApprovedBlocks(j, Data);
        end;
      TTypesChain.MultiSigns:
        begin
          blocksSize := MultiSignChain.WriteApprovedBlocks(j, Data);
        end;
      TTypesChain.VotingResults:
        begin
          blocksSize := VotingResultChain.WriteApprovedBlocks(j, Data);
        end;
      TTypesChain.Commissions:
        begin
        end;
      TTypesChain.Mining:
        begin
          blocksSize := MiningChain.WriteApprovedBlocks(j, Data);
        end;
    end;

    inc(Counter, j);
    Data := Copy(Data, blocksSize, Length(Data) - blocksSize);
  end;

  if not CheckBlocks(fromid, toid) then
    CoruptedBlockChain;
end;

function TBlockChainInquiries.TryGetAccountAddress(AccID: UInt64): THash;
begin
  Result := AccountsChain.GetName(AccID);
end;

function TBlockChainInquiries.GetAllCacheTrx: TBytes;
var
  Counter: UInt64;
begin
  Result := [];
  Counter :=
  AccountsChain.GetCacheCount +
  MultiSignChain.GetCacheCount +
  VotingResultChain.GetCacheCount +
  CommissionChain.GetCacheCount +
  TransferChain.GetCacheCount +
  TokensChain.GetCacheCount +
  MiningChain.GetCacheCount;

  if Counter > 0 then
  begin
    Result := Counter.AsBytes;
    if AccountsChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(TTypesChain.Accounts)] + AccountsChain.GetCacheCount.AsBytes + AccountsChain.GetCachedTrxs;
      AccountsChain.DoClearCache;
    end;
    if MultiSignChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(TTypesChain.MultiSigns)] + MultiSignChain.GetCacheCount.AsBytes + MultiSignChain.GetCachedTrxs;
      MultiSignChain.DoClearCache;
    end;
    if VotingResultChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(TTypesChain.VotingResults)] + VotingResultChain.GetCacheCount.AsBytes +
      VotingResultChain.GetCachedTrxs;
      VotingResultChain.DoClearCache;
    end;
    if CommissionChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(TTypesChain.Commissions)] + CommissionChain.GetCacheCount.AsBytes +
      CommissionChain.GetCachedTrxs;
      CommissionChain.DoClearCache;
    end;
    if TransferChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(TTypesChain.Transfers)] + TransferChain.GetCacheCount.AsBytes + TransferChain.GetCachedTrxs;
      TransferChain.DoClearCache;
    end;
    if TokensChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(TTypesChain.Tokens)] + TokensChain.GetCacheCount.AsBytes + TokensChain.GetCachedTrxs;
      TokensChain.DoClearCache;
    end;
    if MiningChain.GetCacheCount > 0 then
    begin
      Result := Result + [ord(TTypesChain.Mining)] + MiningChain.GetCacheCount.AsBytes + MiningChain.GetCachedTrxs;
      MiningChain.DoClearCache;
    end;
  end;
end;

procedure TBlockChainInquiries.SetAllCacheTrx(AData: TBytes);
var
  Counter, CountTrxs, blocksSize, j: UInt64;
  ChainCounter, LocalChainCounter, SizePackage, totalamount: UInt64;
  ByteCounter: UInt64;
  TypeChain: Byte;
begin
  Counter := 0;
  ChainCounter := 0;
  ByteCounter := 0;

  Move(AData[ByteCounter], totalamount, SizeOf(CountTrxs));
  inc(ByteCounter, SizeOf(totalamount)); // +8

  if totalamount > 0 then
  begin
    while Counter < totalamount do
    begin
      Move(AData[ByteCounter], TypeChain, SizeOf(TypeChain));
      inc(ByteCounter, SizeOf(TypeChain)); // +1

      Move(AData[ByteCounter], ChainCounter, SizeOf(ChainCounter));
      inc(ByteCounter, SizeOf(ChainCounter)); // +8

      LocalChainCounter := 0;

      case TTypesChain(TypeChain) of
        TTypesChain.Accounts:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TAccountBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TAccountTrxV0)));
                    AccountsChain.SetBlock(Block);
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TAccountTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        TTypesChain.Tokens:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TTokensBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TTokensTrxV0)));
                    TokensChain.SetBlock(Block);
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TTokensTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        TTypesChain.Transfers:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TTransferBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TTransferTrxV0)));
                    TransferChain.SetBlock(Block);
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TTransferTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        TTypesChain.MultiSigns:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TMultiSignBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TMultiSignTrxV0)));
                    MultiSignChain.SetBlock(Block);
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TMultiSignTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        TTypesChain.VotingResults:
          begin

          end;
        TTypesChain.Commissions:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TCommissionBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TCommissionTrxV0)));
                    CommissionChain.SetBlock(Block);
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TCommissionTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
        TTypesChain.Mining:
          begin
            while LocalChainCounter < ChainCounter do
            begin
              Move(AData[ByteCounter], SizePackage, SizeOf(SizePackage));
              inc(ByteCounter, SizeOf(UInt64));
              var Header: THeader := Copy(AData, ByteCounter, SizeOf(THeader));

              case Header.VersionData of
                0:
                  begin
                    var
                    Block := TMiningBlockV0.Create;
                    Block.SetData(Copy(AData, ByteCounter, SizeOf(THeader) + SizeOf(TMiningTrxV0)));
                    MiningChain.SetBlock(Block);
                    inc(ByteCounter, SizeOf(THeader) + SizeOf(TMiningTrxV0));
                  end;
              end;
              inc(LocalChainCounter);
            end;
          end;
      end;
      inc(Counter, LocalChainCounter);
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
    TTypesChain.Main:
      begin
        RAWMainBlock := MainChain.GetBlock(IDBlock);
        var Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    TTypesChain.Accounts:
      begin
        Result := IDBlock;
      end;
    TTypesChain.Tokens:
      begin
        RAWMainBlock := TokensChain.GetBlock(IDBlock);
        var Header: THeader := RAWMainBlock.GetHeader;
        case Header.VersionData of
          0:
            begin
              var trx: TTokensTrxV0 := TTokensBlockV0(RAWMainBlock).GetDataWithoutHeader;
              Result := trx.TokensInfo.Owner;
            end;
        end;
        RAWMainBlock.Free;
      end;
    TTypesChain.Transfers:
      begin
        RAWMainBlock := TransferChain.GetBlock(IDBlock);
        var Header: THeader := RAWMainBlock.GetHeader;
        case Header.VersionData of
          0:
            begin
              var trx: TTokensTrxV0 := TTokensBlockV0(RAWMainBlock).GetDataWithoutHeader;
              Result := trx.TokensInfo.Owner;
            end;
        end;
        RAWMainBlock.Free;
      end;
    TTypesChain.MultiSigns:
      begin
        RAWMainBlock := MultiSignChain.GetBlock(IDBlock);
        var Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    TTypesChain.VotingResults:
      begin
        RAWMainBlock := VotingResultChain.GetBlock(IDBlock);
        var Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    TTypesChain.Commissions:
      begin
        RAWMainBlock := CommissionChain.GetBlock(IDBlock);
        var Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
        RAWMainBlock.Free;
      end;
    TTypesChain.Mining:
      begin
        RAWMainBlock := MiningChain.GetBlock(IDBlock);
        var Header: THeader := RAWMainBlock.GetHeader;
        Result := Header.WitnessID;
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
    TTypesChain.Main:
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
    TTypesChain.Accounts:
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
    TTypesChain.Tokens:
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
    TTypesChain.Transfers:
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

    TTypesChain.VotingResults:
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

    TTypesChain.Commissions:
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

    TTypesChain.MultiSigns:
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
                    Pair.Create('SetValSignValSign ' + IntToStr(n) + ' ' + IntToStr(k),
                    inf.SetValSign.SetSign[n].ValSign.Data[k].ToString);
                    subRes := subRes + [Pair];
                  end;
                end;

                for var s := 0 to Xsign do
                begin
                  Pair.Create('SignLastBlock ' + IntToStr(s), inf.SignLastBlock.Data[s].ToString);
                  subRes := subRes + [Pair];
                end;
                Result := Result + [subRes];
              end;
          end;
        end;
      end;
    TTypesChain.Mining:
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
  end;
end;

function TBlockChainInquiries.GetOMs: TArray<UInt64>;
begin
  Result := MiningChain.GetOMs;
end;

function TBlockChainInquiries.GetTransactionHistory(AID, ATID: UInt64): TArray<string>;
var
  buf: TArray<TTransferHistoryData>;
  DirectFrom, DirectTo, Amount, TokenID, UnixTime, Hash: string;
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
      if item.Plus then
        Amount := (GetVolumeFromAmount(item.Amount, TokensChain.GetTokenDecimals(item.TokenID))).ToString
      else
        Amount := (-1 * GetVolumeFromAmount(item.Amount, TokensChain.GetTokenDecimals(item.TokenID))).ToString;

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
              TokensChain.SetBlock(TkBlock);
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
              TransferChain.SetBlock(TrBlock);
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
              MainChain.SetBlock(MnBlock);
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
              AccountsChain.SetBlock(AccBlock);
            end;
        else
        end;
      end;

    MultiSigns:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionMultiSign
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                MsBlock: TMultiSignBlockV0;
              var
                MsTrx: TMultiSignTrxV0;
              MsTrx := AData;
              MsBlock := TMultiSignBlockV0.Create(MsTrx, MultiSignChain.GetLastBlockHash);
              MultiSignChain.SetBlock(MsBlock);
            end;
        else
        end;
      end;

    VotingResults:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersionVotingResult
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                MsBlock: TVotingResultBlockV0;
              var
                MsTrx: TVotingResultTrxV0;
              MsTrx := AData;
              MsBlock := TVotingResultBlockV0.Create(MsTrx, VotingResultChain.GetLastBlockHash);
              VotingResultChain.SetBlock(MsBlock);
            end;
        else
        end;
      end;

    Commissions:
      begin
        if ABlockVersion = -1 then
          BlockVersion := LastVersion�ommission
        else
          BlockVersion := ABlockVersion;
        case BlockVersion of
          0:
            begin
              var
                MsBlock: TCommissionBlockV0;
              var
                MsTrx: TCommissionTrxV0;
              MsTrx := AData;
              MsBlock := TCommissionBlockV0.Create(MsTrx, CommissionChain.GetLastBlockHash);
              CommissionChain.SetBlock(MsBlock);
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
  else
  end;
end;

procedure TBlockChainInquiries.SetTrxInMainChain(TypeChain: TTypesChain; lastBlock: UInt64; Hash: THash; AWallet: TWallet);
begin
  var mainInf: TMainInfoV0;
  mainInf.IDChain := ord(TypeChain);
  mainInf.IDBlock := lastBlock;
  mainInf.HashBlock := Hash;

  var mainTrx: TMainTrxV0;
  mainTrx.MainInfo := mainInf;
  mainTrx.SignTrx(AWallet);

  var mainbaseBlock: TMainBlockV0;
  mainbaseBlock := TMainBlockV0.Create(mainTrx, MainChain.GetLastBlockHash);
  MainChain.SetBlock(mainbaseBlock);
  MainChain.ApproveBlocks(AWallet);
end;

function TBlockChainInquiries.CheckBlock(ABlock: TBaseBlock; PublicKey: TPublicKey): boolean;
var
  Header: THeader;
  EncryptedHash: THash;
  buf: TMemoryStream;
  PreviosBlock: TBaseBlock;
  PreviosHash: THash;
  SemiHash: THash;
begin
  Result := False;
  Header := ABlock.GetHeader;
  EncryptedHash := RSADecrypt(PublicKey, Header.Sign);
  buf := TMemoryStream.Create;
  case TTypesChain(Header.TypeBlock) of
    Main:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := MainChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TMainTrxV0 := TMainBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
            end;
        end;
      end;
    Accounts:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := AccountsChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TAccountTrxV0 := TAccountBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
            end;
        end;
      end;
    Tokens:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := TokensChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TTokensTrxV0 := TTokensBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
            end;
        end;
      end;
    Transfers:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := TransferChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TTransferTrxV0 := TTransferBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
            end;
        end;
      end;
    MultiSigns:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := MultiSignChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TMultiSignTrxV0 := TMultiSignBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
            end;
        end;
      end;
    VotingResults:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := VotingResultChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TVotingResultTrxV0 := TVotingResultBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
            end;
        end;
      end;
    Commissions:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := CommissionChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TCommissionTrxV0 := TCommissionBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
            end;
        end;
      end;
    VoteRequest:
      begin
        case Header.VersionData of
          0:
            begin
            end;
        end;
      end;
    Mining:
      begin
        case Header.VersionData of
          0:
            begin
              PreviosBlock := MiningChain.GetBlock(Header.IDBlock - 1);
              PreviosHash := PreviosBlock.GetHeader.CurrentHash;
              var CurrentTrx: TMiningTrxV0 := TMiningBlockV0(ABlock).GetDataWithoutHeader;
              buf.WriteData(PreviosHash + TBytes(CurrentTrx), SizeOf(THash) + Length(TBytes(CurrentTrx)));
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
  PreviosBlock.Free;
end;

function TBlockChainInquiries.CheckBlocks(AFromID, AToID: UInt64): boolean;
var
  AnyChainID: Byte;
  AnyBlockID: integer;
  RAWBlock, Block: TBaseBlock;
  Header: THeader;
begin
  Result := True;
  for var i := AFromID to AToID do
  begin
    RAWBlock := MainChain.GetBlock(i);
    Header := RAWBlock.GetHeader;

    if Header.WitnessID = 0 then
      Continue;

    if CheckBlock(RAWBlock, TryGetPublicKey(Header.WitnessID)) then
    begin
      case Header.VersionData of
        0:
          begin
            var trx: TMainTrxV0 := TMainBlockV0(RAWBlock).GetDataWithoutHeader;
            AnyChainID := trx.MainInfo.IDChain;
            AnyBlockID := trx.MainInfo.IDBlock;
          end;
      end;
      case AnyChainID of
        1:
          begin
            Block := AccountsChain.GetBlock(AnyBlockID);
          end;
        2:
          begin
            Block := TokensChain.GetBlock(AnyBlockID);
          end;
        3:
          begin
            Block := TransferChain.GetBlock(AnyBlockID);
          end;
        4:
          begin
            Block := MultiSignChain.GetBlock(AnyBlockID);
          end;
        5:
          begin
            Block := VotingResultChain.GetBlock(AnyBlockID);
          end;
        6:
          begin
            Block := CommissionChain.GetBlock(AnyBlockID);
          end;
        7:
          begin
            Block := CommissionChain.GetBlock(AnyBlockID);
          end;
        8:
          begin
            Block := MiningChain.GetBlock(AnyBlockID);
          end;
      end;
      if not CheckBlock(Block, TryGetPublicKey(Block.GetHeader.WitnessID)) then
      begin
        Result := False;
        RAWBlock.Free;
        Block.Free;
        Break;
      end;
    end
    else
    begin
      Result := False;
      RAWBlock.Free;
      Break;
    end;
    RAWBlock.Free;
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

procedure TBlockChainInquiries.CoruptedBlockChain;
begin

end;

function TBlockChainInquiries.CountCacheBlock: UInt64;
begin
  Result :=
  AccountsChain.GetCacheCount +
  MultiSignChain.GetCacheCount +
  VotingResultChain.GetCacheCount +
  CommissionChain.GetCacheCount +
  TransferChain.GetCacheCount +
  TokensChain.GetCacheCount +
  MiningChain.GetCacheCount;
end;

function TBlockChainInquiries.SetTrxCacheChain(TypeChain: TTypesChain; ABytes: TBytes; AWallet: TWallet;
out ACountBlocks: UInt64): boolean;
var
  lastBlock: UInt64;
  Hash, HashBuf: THash;
  bufA, bufB: TBytes;
begin
  bufA := Copy(ABytes, Length(ABytes) - 64, 64);
  Result := True;
  try
    case TypeChain of
      TTypesChain.Accounts:
        begin
          case LastVersionAccount of
            0:
              begin
                var trx: TAccountTrxV0;
                trx := ABytes;
                var BaseBlock: TAccountBlockV0;
                BaseBlock := TAccountBlockV0.Create(trx, AccountsChain.GetLastBlockHash);
                AccountsChain.SetBlock(BaseBlock);
              end;
          else
            Result := False;
          end;

          if (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            AccountsChain.ApproveBlocks(AWallet);
            Hash := AccountsChain.GetLastBlockHash;
            lastBlock := AccountsChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TypeChain, lastBlock, Hash, AWallet);
          end;
        end;
      TTypesChain.Tokens:
        begin
          case LastVersionTokens of
            0:
              begin
                var trx: TTokensTrxV0;
                trx := ABytes;
                if TryGetTokenID(trx.TokensInfo.Symbol) > 0 then
                  raise Exception.Create('This token already exist');

                var BaseBlock: TTokensBlockV0;
                BaseBlock := TTokensBlockV0.Create(trx, TokensChain.GetLastBlockHash);

                TokensChain.SetBlock(BaseBlock);
                if (NodeState = Speaker) and (ParamStr(1) = 'init') then
                begin
                  TokensChain.ApproveBlocks(AWallet);
                  SetTrxInMainChain(TypeChain, TokensChain.GetLastBlockID, TokensChain.GetLastBlockHash, AWallet);
                end;
                var TrxTransfer: TTransferTrxV0;
                TrxTransfer.TransferInfo.DirectFrom := 0;
                TrxTransfer.TransferInfo.DirectTo := trx.TokensInfo.Owner;
                TrxTransfer.TransferInfo.Amount := trx.TokensInfo.Volume;
                TrxTransfer.TransferInfo.TokenID := TokensChain.GetIDToken(trx.TokensInfo.Symbol);
                TrxTransfer.SignTrx(AWallet);

                var BaseBlockTrx: TTransferBlockV0;
                BaseBlockTrx := TTransferBlockV0.Create(TrxTransfer, TransferChain.GetLastBlockHash);

                TransferChain.SetBlock(BaseBlockTrx);
              end;
          else
            Result := False;
          end;
          if (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            TransferChain.ApproveBlocks(AWallet);
            Hash := TransferChain.GetLastBlockHash;
            lastBlock := TransferChain.GetLastBlockID;
            ACountBlocks := 2;
            SetTrxInMainChain(TTypesChain.Transfers, lastBlock, Hash, AWallet);
          end;
        end;
      TTypesChain.Transfers:
        begin
          case LastVersionTransfer of
            0:
              begin
                var
                  trx: TTransferTrxV0;
                trx := ABytes;
                if TransferChain.GetBalance(trx.TransferInfo.DirectFrom, trx.TransferInfo.TokenID) <
                GetVolumeFromAmount(trx.TransferInfo.Amount, TokensChain.GetTokenDecimals(trx.TransferInfo.TokenID)) then
                  raise Exception.Create('Not enough funds');
                var
                  BaseBlock: TTransferBlockV0;
                BaseBlock := TTransferBlockV0.Create(trx, TransferChain.GetLastBlockHash);
                TransferChain.SetBlock(BaseBlock);
              end;
          else
            Result := False;
          end;
          if (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            TransferChain.ApproveBlocks(AWallet);
            Hash := TransferChain.GetLastBlockHash;
            lastBlock := TransferChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TTypesChain.Transfers, lastBlock, Hash, AWallet);
          end;
        end;
      TTypesChain.MultiSigns:
        begin
          case LastVersionMultiSign of
            0:
              begin
                var trx: TMultiSignTrxV0;
                trx := ABytes;
                var BaseBlock: TMultiSignBlockV0;
                BaseBlock := TMultiSignBlockV0.Create(trx, MultiSignChain.GetLastBlockHash);
                MultiSignChain.SetBlock(BaseBlock);
              end;
          else
            Result := False;
          end;
          if (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            MultiSignChain.ApproveBlocks(AWallet);
            Hash := MultiSignChain.GetLastBlockHash;
            lastBlock := MultiSignChain.GetLastBlockID;
            ACountBlocks := 1;
            SetTrxInMainChain(TypeChain, lastBlock, Hash, AWallet);
          end;
        end;
      TTypesChain.VotingResults:
        begin
          case LastVersionVotingResult of
            0:
              begin
                var trx: TVotingResultTrxV0;
                trx := ABytes;
                var BaseBlock: TVotingResultBlockV0;
                BaseBlock := TVotingResultBlockV0.Create(trx, VotingResultChain.GetLastBlockHash);
                VotingResultChain.SetBlock(BaseBlock);
              end;
          else
            Result := False;
          end;
        end;
      TTypesChain.Commissions:
        begin
          case LastVersion�ommission of
            0:
              begin
                var trx: TCommissionTrxV0;
                trx := ABytes;
                var BaseBlock: TCommissionBlockV0;
                BaseBlock := TCommissionBlockV0.Create(trx, CommissionChain.GetLastBlockHash);
                CommissionChain.SetBlock(BaseBlock);
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
      TTypesChain.Mining:
        begin
          case LastVersionMining of
            0:
              begin
                var trx: TTransferTrxV0;
                trx := ABytes;
                if TransferChain.GetBalance(trx.TransferInfo.DirectFrom, trx.TransferInfo.TokenID) <
                GetVolumeFromAmount(trx.TransferInfo.Amount, TokensChain.GetTokenDecimals(trx.TransferInfo.TokenID)) then
                  raise Exception.Create('Not enough funds');
                var BaseBlock: TTransferBlockV0;
                BaseBlock := TTransferBlockV0.Create(trx, TransferChain.GetLastBlockHash);
                TransferChain.SetBlock(BaseBlock);

                var TrxOM: TMiningTrxV0;
                TrxOM.MiningInfo.OwnerID := trx.TransferInfo.DirectFrom;
                var BaseBlockOM: TMiningBlockV0;
                BaseBlockOM := TMiningBlockV0.Create(TrxOM, MiningChain.GetLastBlockHash);
                MiningChain.SetBlock(BaseBlockOM);
              end;
          else
            Result := False;
          end;
          if (NodeState = Speaker) and (ParamStr(1) = 'init') then
          begin
            TransferChain.ApproveBlocks(AWallet);
            MiningChain.ApproveBlocks(AWallet);
            SetTrxInMainChain(TTypesChain.Transfers, TransferChain.GetLastBlockID, TransferChain.GetLastBlockHash, AWallet);
            Hash := MiningChain.GetLastBlockHash;
            lastBlock := MiningChain.GetLastBlockID;
            ACountBlocks := 2;
            SetTrxInMainChain(TTypesChain.Mining, lastBlock, Hash, AWallet);
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
  i, Counter: integer;
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
          if CheckBlock(MainBlock, TryGetPublicKey(MainBlock.GetHeader.WitnessID)) then
            MainChain.WriteApprovedBlock(MainBlock)
          else
            CoruptedBlockChain;
          MainBlock.Free;
        end;
    end;
    Data := Copy(Data, size, Length(Data) - size);
  end;
  Counter := 0;
  while Counter < Count do
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

    inc(Counter, j);
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

function TBlockChainInquiries.TryGetTokenID(ASymbol: string): UInt64;
begin
  Result := TokensChain.GetIDToken(ASymbol);
end;

function TBlockChainInquiries.TryGetTokenInfo(ASymbol: String): TTokensInfoV0;
begin
  var
  re := TokensChain.GetBlock(TokensChain.GetIDToken(ASymbol)).GetDataWithoutHeader;
  Result := TTokensTrxV0(re).TokensInfo;
end;

function TBlockChainInquiries.TryGetTokenInfoAll: TArray<TTokensInfoV0>;
var
  info: TTokensInfoV0;
  Data: TBytes;
  Narray: TArray<TTokensInfoV0>;
begin
  Narray := [];
  for var j := 1 to TokensChain.GetLastBlockID do
  begin
    Data := TokensChain.GetBlock(j).GetDataWithoutHeader;
    info := TTokensTrxV0(Data).TokensInfo;
    Narray := Narray + [info];
  end;
  Result := Narray;
end;

function TBlockChainInquiries.TryGetCommissionsInfoAll: TArray<string>;
var
  info: TCommissionInfoV0;
  Data: TBytes;
begin
  Data := CommissionChain.GetBlock(CommissionChain.GetLastBlockID).GetDataWithoutHeader;
  info := TCommissionTrxV0(Data).CommissionInfo;
  Result := ['CommTransOrigCoin ' + UInttostr(info.CommTransOrigCoin)] + ['CommRecService ' + UInttostr(info.CommRecService)]
  + ['CommTransTokenInside ' + UInttostr(info.CommTransTokenInside)] + ['CommCreateToken ' + UInttostr(info.CommCreateToken)]
  + ['CommCreateService ' + UInttostr(info.CommCreateService)];
end;

function TBlockChainInquiries.TryGetPublicKey(AID: UInt64): TPublicKey;
var
  Block: TBaseBlock;
begin
  if CheckAnyID(TTypesChain.Accounts, AID) then
    exit;
  Result := Default (TPublicKey);

  try
    Block := AccountsChain.GetBlock(AID);
    case Block.GetHeader.VersionData of
      0:
        begin
          var re: TAccountTrxV0 := TAccountBlockV0(Block).GetDataWithoutHeader;
          Result := re.AccountInfo.PublicKey;
        end;
    end;
  finally
    Block.Free;
  end;
end;

function TBlockChainInquiries.TryGetReceivedAmountAllTime(AID, TID: UInt64): double;
var
  info: TTransferInfoV0;
  Data: TBytes;
  Amount: UInt64;
begin
  if CheckAnyID(TTypesChain.Accounts, AID) then
    exit;
  Amount := 0;
  for var j := 1 to TransferChain.GetLastBlockID do
  begin
    Data := TransferChain.GetBlock(j).GetDataWithoutHeader;
    info := TTransferTrxV0(Data).TransferInfo;
    if ((info.DirectTo = AID) and (info.TokenID = TID)) then
      Amount := Amount + info.Amount;
  end;
  Result := GetVolumeFromAmountToken(Amount, TID);
end;

function TBlockChainInquiries.TryGetSentAmountAllTime(AccID, TokenID: UInt64): double;
var
  info: TTransferInfoV0;
  Data: TBytes;
  Amount: UInt64;
begin
  Amount := 0;
  for var j := 1 to TransferChain.GetLastBlockID do
  begin
    Data := TransferChain.GetBlock(j).GetDataWithoutHeader;
    info := TTransferTrxV0(Data).TransferInfo;
    if ((info.DirectFrom = AccID) and (info.TokenID = TokenID)) then
      Amount := Amount + info.Amount;
  end;
  Result := GetVolumeFromAmountToken(Amount, TokenID);
end;

function TBlockChainInquiries.TryGetAccountInfo(AAddress: THash): TAccountInfoV0;
begin
  var
  re := AccountsChain.GetBlock(AccountsChain.GetID(AAddress)).GetDataWithoutHeader;
  Result := TAccountTrxV0(re).AccountInfo;
end;

function TBlockChainInquiries.TryGetTokenSymbol(AID: UInt64): TSymbol;
begin
  Result := TokensChain.GetTokenName(AID);
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

function TBlockChainInquiries.TryGetTransBetweenTime(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransferInfoV0>;
var
  info: TTransferInfoV0;
  head: THeader;
  Data, DataH: TBytes;
  Narray: TArray<TTransferInfoV0>;
begin
  Narray := [];
  for var j := 1 to TransferChain.GetLastBlockID do
  begin
    Data := TransferChain.GetBlock(j).GetDataWithoutHeader;
    info := TTransferTrxV0(Data).TransferInfo;
    DataH := TransferChain.GetBlock(j).GetDataHeader;
    head := THeader(DataH);
    if (((info.DirectFrom = AccID) or (info.DirectTo = AccID)) and
    ((UnixFrom <= head.UnixTime) and (head.UnixTime <= UnixTo))) then
      Narray := Narray + [info];
  end;
  Result := Narray;
end;

function TBlockChainInquiries.TryGetTransactionHistoryItems(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransHistoryItem>;
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
            if (((info.DirectFrom = AccID) or (info.DirectTo = AccID)) and
            ((UnixFrom <= Header.UnixTime) and (Header.UnixTime <= UnixTo))) then
            begin
              Data.datetime := Header.UnixTime;
              Data.block_number := i;
              Data.Afrom := TryGetAccountAddress(info.DirectFrom);
              Data.Ato := TryGetAccountAddress(info.DirectTo);
              Data.Hash := Header.CurrentHash;
              Data.token := TryGetTokenSymbol(info.TokenID);
              Data.sent := GetVolumeFromAmount(info.Amount, TryGetTokenDecimals(info.TokenID));
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

function TBlockChainInquiries.GetVolumeFromAmount(Amount: UInt64; Decimals: UInt64): double;
begin
  Result := Amount / (Power(10, Decimals));
end;

function TBlockChainInquiries.GetVolumeFromAmountToken(Amount, TokenID: UInt64): double;
begin
  Result := Amount / (Power(10, TryGetTokenDecimals(TokenID)));
end;

function TBlockChainInquiries.TryGetAccTransactions(AccID: UInt64): TArray<TTransferInfoV0>;
var
  info: TTransferInfoV0;
  Data: TBytes;
  Narray: TArray<TTransferInfoV0>;
begin
  Narray := [];
  for var j := 0 to TransferChain.GetLastBlockID do
  begin
    Data := TransferChain.GetBlock(j).GetDataWithoutHeader;
    info := TTransferTrxV0(Data).TransferInfo;
    if ((info.DirectFrom = AccID) or (info.DirectTo = AccID)) then
      Narray := Narray + [info];
  end;
  Result := Narray;
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
  Decimal := TryGetTokenDecimals(TID);

  var
  firstBalance := TransferChain.GetBalance(AID, TID);

  if firstBalance = 0 then
    Result := 0
  else
    Result := GetVolumeFromAmount(firstBalance, Decimal);
end;

procedure TBlockChainInquiries.CreateOM(const AID: UInt64);
begin

end;

end.