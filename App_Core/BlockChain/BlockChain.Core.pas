unit BlockChain.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Hash,
  BlockChain.BaseBlock,
  BlockChain.MainChain,
  BlockChain.Account,
  BlockChain.MultiSign,
  BlockChain.VotingResults,
  BlockChain.Commission,
  BlockChain.Tokens,
  BlockChain.Transfer,
  BlockChain.Types,
  BlockChain.Inquiries,
  BlockChain.Mining,
  BlockChain.Service,
  BlockChain.ServiceResult,
  BlockChain.FastIndex.Account,
  BlockChain.FastIndex.Token,
  BlockChain.FastIndex.Transfer,
  BlockChain.FastIndex.Service,
  BlockChain.Mined,
  Crypto.RSA;

type
  TBlockChainCore = class
  private
    MainChain: TMainChain;
    AccountsChain: TAccountChain;
    MultiSignChain: TMultiSignChain;
    VotingResultChain: TVotingResultChain;
    CommissionChain: TCommissionChain;
    TokensChain: TTokensChain;
    TransfersChain: TTransferChain;
    MiningChain: TMiningChain;
    ServiceChain: TServiceChain;
    ServiceResultChain: TServiceResultChain;
    MinedChain: TMinedChain;
  public
    Inquiries: TBlockChainInquiries;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TBlockChainCore }

constructor TBlockChainCore.Create;
begin
  SIZE_MAIN_CHAIN_INFO_V0 := Length(TMainBlockV0.GenerateInitBlock);
  SIZE_ACCOUNT_INFO_V0 := Length(TAccountBlockV0.GenerateInitBlock);
  SIZE_MULTISIGN_INFO_V0 := Length(TMultiSignBlockV0.GenerateInitBlock);
  SIZE_VOTINGRESULT_INFO_V0 := Length(TVotingResultBlockV0.GenerateInitBlock);
  SIZE_COMMISSION_INFO_V0 := Length(TCommissionBlockV0.GenerateInitBlock);
  SIZE_TOKENS_INFO_V0 := Length(TTokensBlockV0.GenerateInitBlock);
  SIZE_MINING_INFO_V0 := Length(TMiningBlockV0.GenerateInitBlock);
  SIZE_TRANSFER_INFO_V0 := Length(TTransferBlockV0.GenerateInitBlock);
  SIZE_FAST_INDEX_ACCOUNT := SizeOf(THeader) + SizeOf(TAccountIndex);
  SIZE_FAST_INDEX_TOKENS := SizeOf(THeader) + SizeOf(TTokensIndex);
  SIZE_FAST_INDEX_TRANSFERS := SizeOf(THeader) + SizeOf(TBalancesIndex);
  SIZE_SERVICE_INFO_V0 := Length(TServiceBlockV0.GenerateInitBlock);
  SIZE_FAST_INDEX_SERVICE := SizeOf(THeader) + SizeOf(TServiceIndex);
  SIZE_SERVICERESULT_INFO_V0 := Length(TServiceResultBlockV0.GenerateInitBlock);
  SIZE_MINED_INFO_V0 := Length(TMinedBlockV0.GenerateInitBlock);

  MainChain := TMainChain.Create('MainChain', TMainBlockV0.GenerateInitBlock, Main);
  AccountsChain := TAccountChain.Create('AccountChain', TAccountBlockV0.GenerateInitBlock, Accounts);
  MultiSignChain := TMultiSignChain.Create('MultiSignChain', TMultiSignBlockV0.GenerateInitBlock, MultiSigns);
  VotingResultChain := TVotingResultChain.Create('VotingResultChain', TVotingResultBlockV0.GenerateInitBlock, VotingResults);
  CommissionChain := TCommissionChain.Create('ÑommissionChain', TCommissionBlockV0.GenerateInitBlock, Commissions);
  TokensChain := TTokensChain.Create('TokensChain', TTokensBlockV0.GenerateInitBlock, Tokens);
  TransfersChain := TTransferChain.Create('TransfersChain', TTransferBlockV0.GenerateInitBlock, Transfers);
  MiningChain := TMiningChain.Create('MiningChain', TMiningBlockV0.GenerateInitBlock, Mining);
  ServiceChain := TServiceChain.Create('ServicesChain', TServiceBlockV0.GenerateInitBlock, Service);
  ServiceResultChain := TServiceResultChain.Create('ServicesResultChain', TServiceResultBlockV0.GenerateInitBlock, ServiceResult);
  MinedChain:= TMinedChain.Create('MinedChain', TMinedBlockV0.GenerateInitBlock, Mined);
  Inquiries := TBlockChainInquiries.Create(MainChain, AccountsChain, TokensChain, TransfersChain,
    MultiSignChain, VotingResultChain, CommissionChain, MiningChain, ServiceChain, ServiceResultChain, MinedChain);
end;

destructor TBlockChainCore.Destroy;
begin
  MainChain.Free;
  AccountsChain.Free;
  MultiSignChain.Free;
  VotingResultChain.Free;
  CommissionChain.Free;
  TokensChain.Free;
  TransfersChain.Free;
  MiningChain.Free;
  ServiceChain.Free;
  ServiceResultChain.Free;
  MinedChain.Free;
  Inquiries.Free;
  inherited;
end;

end.
