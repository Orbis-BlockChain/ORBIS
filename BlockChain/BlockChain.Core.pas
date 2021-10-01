unit BlockChain.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Hash,
  FMX.Dialogs,
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
  BlockChain.FastIndex.Account,
  BlockChain.FastIndex.Token,
  BlockChain.FastIndex.Transfer,
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

  MainChain := TMainChain.Create('MainChain', TMainBlockV0.GenerateInitBlock, Main);
  AccountsChain := TAccountChain.Create('AccountChain', TAccountBlockV0.GenerateInitBlock, Accounts);
  MultiSignChain := TMultiSignChain.Create('MultiSignChain', TMultiSignBlockV0.GenerateInitBlock, MultiSigns);
  VotingResultChain := TVotingResultChain.Create('VotingResultChain', TVotingResultBlockV0.GenerateInitBlock, VotingResults);
  CommissionChain := TCommissionChain.Create('—ommissionChain', TCommissionBlockV0.GenerateInitBlock, Commissions);
  TokensChain := TTokensChain.Create('TokensChain', TTokensBlockV0.GenerateInitBlock, Tokens);
  TransfersChain := TTransferChain.Create('TransfersChain', TTransferBlockV0.GenerateInitBlock, Transfers);
  MiningChain := TMiningChain.Create('MiningChain', TMiningBlockV0.GenerateInitBlock, Mining);

  Inquiries := TBlockChainInquiries.Create(MainChain, AccountsChain, TokensChain, TransfersChain, MultiSignChain,
  VotingResultChain, CommissionChain, MiningChain);

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
  Inquiries.Free;
  inherited;
end;

end.
