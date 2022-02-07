program ORBISConsole;

uses
  System.SysUtils,
  App.Abstractions in 'AppCore\App.Abstractions.pas',
  App.Core in 'AppCore\App.Core.pas',
  App.Globals in 'AppCore\App.Globals.pas',
  App.Types in 'AppCore\App.Types.pas',
  Net.Client in 'AppCore\NetCore\Net.Client.pas',
  Net.ConnectedClient in 'AppCore\NetCore\Net.ConnectedClient.pas',
  Net.Core in 'AppCore\NetCore\Net.Core.pas',
  Net.Server in 'AppCore\NetCore\Net.Server.pas',
  App.Meta in 'AppCore\App.Meta.pas',
  Crypto.RSA in 'AppCore\CryptoCore\Crypto.RSA.pas',
  CryptoEntity in 'AppCore\CryptoCore\CryptoEntity.pas',
  RSA.cEncrypt in 'AppCore\CryptoCore\RSA.cEncrypt.pas',
  RSA.cHash in 'AppCore\CryptoCore\RSA.cHash.pas',
  RSA.cHugeInt in 'AppCore\CryptoCore\RSA.cHugeInt.pas',
  RSA.cRandom in 'AppCore\CryptoCore\RSA.cRandom.pas',
  RSA.main in 'AppCore\CryptoCore\RSA.main.pas',
  Net.Types in 'AppCore\NetCore\Net.Types.pas',
  Wallet.Core in 'AppCore\WalletCore\Wallet.Core.pas',
  Wallet.Types in 'AppCore\WalletCore\Wallet.Types.pas',
  Wallet.FileHandler in 'AppCore\WalletCore\Wallet.FileHandler.pas',
  Unit_cryptography in 'AppCore\CryptoCore\Unit_cryptography.pas',
  Crypto.Encoding in 'AppCore\CryptoCore\Crypto.Encoding.pas',
  Crypto.Data in 'AppCore\CryptoCore\Crypto.Data.pas',
  App.Packet in 'AppCore\App.Packet.pas',
  Crypto.BinConverter in 'AppCore\CryptoCore\Crypto.BinConverter.pas',
  Crypto.Base58 in 'AppCore\CryptoCore\Crypto.Base58.pas',
  Crypto.AlphabetBase58 in 'AppCore\CryptoCore\Crypto.AlphabetBase58.pas',
  Crypto.BIP39 in 'AppCore\CryptoCore\Crypto.BIP39.pas',
  App.Log in 'AppCore\App.Log.pas',
  App.Config in 'AppCore\App.Config.pas',
  App.Paths in 'AppCore\App.Paths.pas',
  WebServer.DataControl in 'AppCore\WebCore\WebServer.DataControl.pas',
  WebServer.HTTPConnectedClient in 'AppCore\WebCore\WebServer.HTTPConnectedClient.pas',
  WebServer.HTTPCore in 'AppCore\WebCore\WebServer.HTTPCore.pas',
  WebServer.HTTPServer in 'AppCore\WebCore\WebServer.HTTPServer.pas',
  WebServer.HTTPTypes in 'AppCore\WebCore\WebServer.HTTPTypes.pas',
  WebServer.SourceData in 'AppCore\WebCore\WebServer.SourceData.pas',
  BlockChain.Account in 'AppCore\BlockChain\BlockChain.Account.pas',
  BlockChain.BaseBlock in 'AppCore\BlockChain\BlockChain.BaseBlock.pas',
  BlockChain.BaseChain in 'AppCore\BlockChain\BlockChain.BaseChain.pas',
  BlockChain.Core in 'AppCore\BlockChain\BlockChain.Core.pas',
  BlockChain.FileHandler in 'AppCore\BlockChain\BlockChain.FileHandler.pas',
  BlockChain.Inquiries in 'AppCore\BlockChain\BlockChain.Inquiries.pas',
  BlockChain.MainChain in 'AppCore\BlockChain\BlockChain.MainChain.pas',
  BlockChain.MultiSign in 'AppCore\BlockChain\BlockChain.MultiSign.pas',
  BlockChain.Tokens in 'AppCore\BlockChain\BlockChain.Tokens.pas',
  BlockChain.Transfer in 'AppCore\BlockChain\BlockChain.Transfer.pas',
  BlockChain.Mined in 'AppCore\BlockChain\BlockChain.Mined.pas',
  BlockChain.Types in 'AppCore\BlockChain\BlockChain.Types.pas',
  Net.IClient in 'AppCore\NetCore\Net.IClient.pas',
  BlockChain.VotingResults in 'AppCore\BlockChain\BlockChain.VotingResults.pas',
  BlockChain.Commission in 'AppCore\BlockChain\BlockChain.Commission.pas',
  BlockChain.VoteRequest in 'AppCore\BlockChain\BlockChain.VoteRequest.pas',
  BlockChain.Mining in 'AppCore\BlockChain\BlockChain.Mining.pas',
  BlockChain.FastIndex.Account in 'AppCore\BlockChain\BlockChain.FastIndex.Account.pas',
  BlockChain.FastIndex.Token in 'AppCore\BlockChain\BlockChain.FastIndex.Token.pas',
  BlockChain.FastIndex.Transfer in 'AppCore\BlockChain\BlockChain.FastIndex.Transfer.pas',
  App.HandlerCore in 'AppCore\App.HandlerCore.pas',
  App.IHandlerCore in 'AppCore\App.IHandlerCore.pas',
  App.Notifyer in 'AppCore\App.Notifyer.pas',
  UHandlerResultComandLineParse in 'AppCore\UICore\UHandlerResultComandLineParse.pas',
  UI.Abstractions in 'AppCore\UICore\UI.Abstractions.pas',
  UI.CommandLineParser in 'AppCore\UICore\UI.CommandLineParser.pas',
  UI.ConsoleUI in 'AppCore\UICore\UI.ConsoleUI.pas',
  UI.ParserCommand in 'AppCore\UICore\UI.ParserCommand.pas',
  UI.Types in 'AppCore\UICore\UI.Types.pas',
  Test.BIP39 in 'Test.BIP39.pas',
  WebServer.Abstractions in 'AppCore\WebCore\WebServer.Abstractions.pas',
  Updater.Core in 'AppCore\Updater\Updater.Core.pas',
  Translate.Core in 'AppCore\Translate\Translate.Core.pas',
  BlockChain.FastIndex.RegistredService in 'AppCore\BlockChain\BlockChain.FastIndex.RegistredService.pas',
  BlockChain.FastIndex.Service in 'AppCore\BlockChain\BlockChain.FastIndex.Service.pas',
  BlockChain.Service in 'AppCore\BlockChain\BlockChain.Service.pas',
  BlockChain.ServiceResult in 'AppCore\BlockChain\BlockChain.ServiceResult.pas',
  App.Tools in 'AppCore\App.Tools.pas',
  Consensus.Logic in 'AppCore\Consensus\Consensus.Logic.pas',
  Consensus.Types in 'AppCore\Consensus\Consensus.Types.pas',
  Consensus2.Core in 'AppCore\Consensus\Consensus2.Core.pas',
  App.FileLocker in 'AppCore\App.FileLocker.pas';

{$APPTYPE CONSOLE}
{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutDown := True;
{$ENDIF}
  try
    AppCore := TAppCore.Create;
    AppCore.DoRun;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
