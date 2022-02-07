program ServiceExplorer;

uses
  System.StartUpCopy,
  FMX.Forms,
  from in 'from.pas' {Form1},
  App.Log in '..\AppCore\App.Log.pas',
  App.Paths in '..\AppCore\App.Paths.pas',
  App.Types in '..\AppCore\App.Types.pas',
  Crypto.AlphabetBase58 in '..\AppCore\CryptoCore\Crypto.AlphabetBase58.pas',
  Crypto.Base58 in '..\AppCore\CryptoCore\Crypto.Base58.pas',
  Crypto.BinConverter in '..\AppCore\CryptoCore\Crypto.BinConverter.pas',
  Crypto.BIP39 in '..\AppCore\CryptoCore\Crypto.BIP39.pas',
  Crypto.Data in '..\AppCore\CryptoCore\Crypto.Data.pas',
  Crypto.Encoding in '..\AppCore\CryptoCore\Crypto.Encoding.pas',
  Crypto.RSA in '..\AppCore\CryptoCore\Crypto.RSA.pas',
  CryptoEntity in '..\AppCore\CryptoCore\CryptoEntity.pas',
  RSA.cEncrypt in '..\AppCore\CryptoCore\RSA.cEncrypt.pas',
  RSA.cHash in '..\AppCore\CryptoCore\RSA.cHash.pas',
  RSA.cHugeInt in '..\AppCore\CryptoCore\RSA.cHugeInt.pas',
  RSA.cRandom in '..\AppCore\CryptoCore\RSA.cRandom.pas',
  RSA.main in '..\AppCore\CryptoCore\RSA.main.pas',
  Unit_cryptography in '..\AppCore\CryptoCore\Unit_cryptography.pas',
  Wallet.Core in '..\AppCore\WalletCore\Wallet.Core.pas',
  Wallet.FileHandler in '..\AppCore\WalletCore\Wallet.FileHandler.pas',
  Wallet.Types in '..\AppCore\WalletCore\Wallet.Types.pas',
  BlockChain.Account in '..\AppCore\BlockChain\BlockChain.Account.pas',
  BlockChain.BaseBlock in '..\AppCore\BlockChain\BlockChain.BaseBlock.pas',
  BlockChain.BaseChain in '..\AppCore\BlockChain\BlockChain.BaseChain.pas',
  BlockChain.Commission in '..\AppCore\BlockChain\BlockChain.Commission.pas',
  BlockChain.Core in '..\AppCore\BlockChain\BlockChain.Core.pas',
  BlockChain.FastIndex.Account in '..\AppCore\BlockChain\BlockChain.FastIndex.Account.pas',
  BlockChain.FastIndex.Token in '..\AppCore\BlockChain\BlockChain.FastIndex.Token.pas',
  BlockChain.FastIndex.Transfer in '..\AppCore\BlockChain\BlockChain.FastIndex.Transfer.pas',
  BlockChain.FileHandler in '..\AppCore\BlockChain\BlockChain.FileHandler.pas',
  BlockChain.Inquiries in '..\AppCore\BlockChain\BlockChain.Inquiries.pas',
  BlockChain.MainChain in '..\AppCore\BlockChain\BlockChain.MainChain.pas',
  BlockChain.Mining in '..\AppCore\BlockChain\BlockChain.Mining.pas',
  BlockChain.MultiSign in '..\AppCore\BlockChain\BlockChain.MultiSign.pas',
  BlockChain.Tokens in '..\AppCore\BlockChain\BlockChain.Tokens.pas',
  BlockChain.Transfer in '..\AppCore\BlockChain\BlockChain.Transfer.pas',
  BlockChain.Types in '..\AppCore\BlockChain\BlockChain.Types.pas',
  BlockChain.VoteRequest in '..\AppCore\BlockChain\BlockChain.VoteRequest.pas',
  BlockChain.VotingResults in '..\AppCore\BlockChain\BlockChain.VotingResults.pas',
  App.Meta in '..\AppCore\App.Meta.pas',
  App.Notifyer in '..\AppCore\App.Notifyer.pas',
  BlockChain.Service in '..\AppCore\BlockChain\BlockChain.Service.pas',
  Translate.Core in '..\AppCore\Translate\Translate.Core.pas',
  BlockChain.ServiceResult in '..\AppCore\BlockChain\BlockChain.ServiceResult.pas',
  BlockChain.FastIndex.Service in '..\AppCore\BlockChain\BlockChain.FastIndex.Service.pas',
  BlockChain.Mined in '..\AppCore\BlockChain\BlockChain.Mined.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
