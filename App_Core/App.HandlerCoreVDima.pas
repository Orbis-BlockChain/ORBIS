unit App.HandlerCore;

interface

uses
//{$DEFINE Consesus.Core.TonyEdition}
{$DEFINE Consensus.Core}
  System.SysUtils,
  System.Generics.Collections,
  System.Math,
  System.TypInfo,
  System.Classes,
  System.SyncObjs,
  {$IFDEF MACOS}
  FMX.Dialogs,
  {$ENDIF}
  BlockChain.Account,
  BlockChain.Core,
  BlockChain.Types,
  BlockChain.Tokens,
  BlockChain.Transfer,
  Wallet.Types,
  Wallet.Core,
  WebServer.HTTPCore,
  Net.Core,
  Net.ConnectedClient,
  Net.IClient,
  App.IHandlerCore,
  App.Types,
  App.Meta,
  App.Packet,
  App.Config,
  App.Notifyer,
  App.Globals,
  App.Log,
  WebServer.DataControl,
  UI.Abstractions,
  {$IFDEF Consesus.Core.TonyEdition}
  Consesus.Core.TonyEdition,
//  {$ENDIF}
//  {$IFDEF Consensus.Core}
  {$ELSE}
  Consensus.Core,
  {$ENDIF}
  Crypto.RSA,
  Updater.Core;

type
  THandlerCore = class(TInterfacedObject, IBaseHandler)
  private
    FBlockChain: TBlockChainCore;
    FUI: TBaseUI;
    Fnet: TNetCore;
    FWalletCore: TWalletCore;
    FWebServer: TWebServer;
    FConfig: TConfig;
    FConsensusCore: TConsensusCore;
    FUpdaterCore: TUpdaterCore;
    FLog: TLogs;
    { HTTTP START }

    { HTTP STOP }
    function CreateWallet(Password: string): integer;
    procedure ReadWallet;
    procedure ReadWallets;
    procedure StartNode;
    procedure BadArgs(Args: array of string);
    procedure CheckBC;
    procedure ShutDown(const Msg: string = '');
    procedure TryCreateWallet(Args: array of string);
    procedure TryOpenWallet(Args: array of string);
    procedure TestSerialize;
    procedure GetOpenedWallet;
    procedure GetBalance(Args: array of string);
    procedure DoMining;
    procedure TryBuyOM;
    procedure TryEasyBuyOM;
    procedure SetDefaultState;
    procedure CreateToken(Args: array of string);
    procedure CreateTransfer(Args: array of string);
    function TryBuyOMGUI: boolean;
    function TryCreateToken(Args: array of string; var ErrorCode: string; var Error: string): boolean;
    function TryEasySendTransfer(var AResHash: string; ASymbol, AAddress, AAValue: string; var AError: integer; var AErrorMsg: string): boolean;
    function TryEasyCreateToken(ASymbol, AName, ADec, AVolume: string; var Error: string): boolean;
    function GetTokenByName(ASymbol: String): TTokensInfoV0;
    function GetAccTransactions(AccID: UInt64): TArray<TTransferInfoV0>;
    function GetTransAmount(Trans: TTransferInfoV0): Double;
    function GetTransInfo(TransHash: THash): TTransHistoryItem;
    function GetTokenTransCount(Symbol: TSymbol): UInt64;
    function GetAccountInfo(AAddress: THash): TAccountInfoV0;
    function GetAccRegDate(Address: THash): UInt64;
    function GetAccountID(AAddress: THash): UInt64;
    function GetTokenID(ASymbol: string): UInt64;
    function CheckIfTokenExists(Symbol: TSymbol): boolean;
    function GetBalanceToken(AAddress: THash; ASymbol: String): Double;
    function GetMyAdress: string;
    // -1 if errors
    function GetAccountAddress(AccID: UInt64): THash;
    function GetCommissionsInfoAll: TArray<string>;
    function TryGetTokensInfo: TArray<TTokensInfoV0>;
    function GetSentAmountAllTime(AccID, TokenID: UInt64): Double;
    function GetReceivedAmountAllTime(AccID, TokenID: UInt64): Double;
    function ParseDataBalances(AData: TBytes): TArray<string>;
    function GetTransactionHistory(AID, ATID: UInt64): TArray<string>;
    function GetTransInfoByOwnerSign(OwnerSign: string): TArray<string>;
    function GetAccTokensCount(Address: String): UInt64;
    function GetTransactioHistoryItems(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransHistoryItem>;
    function GetAllTransactionsBySymbol(Symbol: TSymbol): TArray<TTransHistoryItem>;
    function GetTransInfoByID(TID: UInt64): TTransHistoryItem;
    function GetALLTransactions: TArray<TTransHistoryItem>;
    function GetGetALLAccounts: TArray<TAccountInfoV0>;
    function GetTokenOwners(Symbol: TSymbol): TArray<TAccountInfoV0>;
    function InitializeState: TNodeState;
    function CheckID(AData: TBytes): UInt64;
    function isValid: boolean;
    procedure DoStartUpdate;
    procedure DoEndUpdate;
  public
    procedure HandleReceiveTCPData(From: IClient; const ABytes: TBytes);
    procedure HandleReceiveHTTPData(From: TConnectedClient; const ABytes: TBytes);
    procedure HandleCommand(Command: Byte; Args: array of string);
    procedure HandleGUICommand(Command: Byte; Args: array of string; ACallback: TCallBack);
    procedure HandleWebDataControl(Command: Byte; Args: array of string; ACallback: TCallBack);
    procedure HandleConnectClient(ClientName: String);
    procedure HandleDisconnectClient(ClientName: String);
    property BlockChain: TBlockChainCore read FBlockChain write FBlockChain;
    property UI: TBaseUI read FUI write FUI;
    property Net: TNetCore read Fnet write Fnet;
    property WalletCore: TWalletCore read FWalletCore write FWalletCore;
    property WebServer: TWebServer read FWebServer write FWebServer;
    property Config: TConfig read FConfig write FConfig;
    property ConsensusCore: TConsensusCore read FConsensusCore write FConsensusCore;
    property UpdaterCore: TUpdaterCore read FUpdaterCore write FUpdaterCore;
  end;

var
  _CS: TCriticalSection;

implementation

{ TNetHandlerCore }

procedure THandlerCore.TestSerialize;
var
  Packet: TPacket;
begin
  // BlockChain.Inquiries.TryGetALLTransactions;
  // WalletCore.TryCreateNewWallet('123');
  // Packet.CreatePacket(CMD_REQUEST_NEW_CC, BlockChain.Inquiries.CreateTrxNewWallet(WalletCore.CurrentWallet));
  // HandleReceiveTCPData(nil,Packet);
  // BlockChain.Inquiries.TestDeSerializtion(buf);
end;

function THandlerCore.CreateWallet(Password: string): integer;
var
  Msg: string;
  Packet: TPacket;
begin
  Result := -1;
  if WalletCore.TryCreateNewWallet(Password) then
  begin
    Msg := 'Trying create your wallet: ' + WalletCore.CurrentWallet.GetAddress;
    Packet.CreatePacket(CMD_REQUEST_NEW_CC, BlockChain.Inquiries.CreateTrxNewWallet(WalletCore.CurrentWallet));
    Result := Net.SendPacket(Packet);
    UI.ShowMessage(Msg);
  end
  else
  begin
    Msg := 'Error 41: Can''t create wallet. Try restart node.';
    UI.ShowMessage(Msg);
  end;
end;

procedure THandlerCore.CheckBC;
begin
  BlockChain.Inquiries.CheckBlocks(0, BlockChain.Inquiries.MainChainCount)
end;

procedure THandlerCore.DoStartUpdate;
begin
  UpdaterCore.DoUpdate;
end;

procedure THandlerCore.DoEndUpdate;
begin
  ShutDown('');
end;

function THandlerCore.CheckID(AData: TBytes): UInt64;
var
  id, CheckID: UInt64;
  pubKey: TPublicKey;
  buf, bufEmpty, Data: TBytes;
begin
  Result := 0;
  Move(AData[0], id, sizeOf(id));
  Data := Copy(AData, sizeOf(id), Length(AData) - sizeOf(id));
  bufEmpty := Default (TPublicKey);
  buf := BlockChain.Inquiries.TryGetPublicKey(id);
  if not CompareMem(buf, bufEmpty, sizeOf(TPublicKey)) then
  begin
    Move(RSADecrypt(buf, Data)[0], CheckID, sizeOf(CheckID));
    Result := CheckID;
  end;

end;

function THandlerCore.isValid: boolean;
begin
  Result := True;
  if NodeState = Invalid then
  begin
    UI.ShowMessage('System Info: Sorry but your state node invalid. Please restart or update node');
    UI.ShowMessage('System Info: Please touch any key');
    readln;
    ShutDown(#13#10);
  end;
end;

function THandlerCore.CheckIfTokenExists(Symbol: TSymbol): boolean;
begin
  Result := BlockChain.Inquiries.TryCheckIfTokenExists(Symbol);
end;

function THandlerCore.GetTransInfoByID(TID: UInt64): TTransHistoryItem;
begin
  Result := BlockChain.Inquiries.TryGetTransInfoByID(TID);
end;

function THandlerCore.GetTransInfoByOwnerSign(OwnerSign: string): TArray<string>;
begin
  Result := BlockChain.Inquiries.TryGetTransInfoByOwnerSign(OwnerSign);
end;

function THandlerCore.GetAccTokensCount(Address: String): UInt64;
begin
  Result := BlockChain.Inquiries.TryGetAccTokensCount(Address);
end;

procedure THandlerCore.CreateToken(Args: array of string);
var
  Msg: string;
  Packet: TPacket;
  ASymbol, AName: string;
  ADecimals: integer;
  AVolume: UInt64;
  AToken: TToken;
begin
  Msg := 'Trying create your Token';
  if WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress then
  begin
    Msg := 'System: Bad wallet, please open wallet.';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Length(Args) <> 8 then
  begin
    Msg := 'System ifno: Must be 4 keys and 4 params';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[0] <> 'n' then
  begin
    Msg := 'System ifno: Bad 1 key, must be ''-n''';
    UI.ShowMessage(Msg);
    Exit;
  end;
  if (Length(Args[1]) > 30) or (Length(Args[1]) < 3) then
  begin
    Msg := 'System ifno: Bad ''-n'' param, min length 3 chars, max length 30 chars';
    UI.ShowMessage(Msg);
    Exit;
  end;
  AName := Args[1];

  if Args[2] <> 'sn' then
  begin
    Msg := 'System ifno: Bad 2 key, must be ''-sn''';
    UI.ShowMessage(Msg);
    Exit;
  end;
  if (Length(Args[3]) > 5) or (Length(Args[3]) < 3) then
  begin
    Msg := 'System ifno: Bad ''-sn'' param, min length 3 chars, max length 5 chars';
    UI.ShowMessage(Msg);
    Exit;
  end;
  ASymbol := UpperCase(Args[3]);
  if ASymbol = 'ORBC' then
    AToken := TToken.Coin
  else
    AToken := TToken.Token;

  if BlockChain.Inquiries.TryGetTokenID(ASymbol) > 0 then
  begin
    Msg := 'System ifno: Sorry but such a token already exists';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[4] <> 'd' then
  begin
    Msg := 'System ifno: Bad 3 key, must be ''-d''';
    UI.ShowMessage(Msg);
    Exit;
  end;

  try
    ADecimals := StrToInt(Args[5]);
    if (ADecimals < 0) or (ADecimals > 10) then
      raise Exception.Create('');
  except
    Msg := 'System ifno: Bad ''-d'' param, min value 0, max value 8';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[6] <> 'v' then
  begin
    Msg := 'System ifno: Bad 4 key, must be ''-v''';
    UI.ShowMessage(Msg);
    Exit;
  end;

  try
    AVolume := StrToUInt64(Args[7]);
    if (ADecimals < 0) or (ADecimals > Power(10, 18 - Length(Args[5]))) then
      raise Exception.Create('');
  except
    Msg := 'System ifno: Bad ''-v'' param, min value 1, max value ' + Power(10, 18 - Length(Args[5])).ToString;
    UI.ShowMessage(Msg);
    Exit;
  end;

  Packet.CreatePacket(CMD_REQUEST_NEW_TOKEN, BlockChain.Inquiries.CreateTrxNewToken(ASymbol, AName, ADecimals.ToString, AVolume.AsString, AToken,
    WalletCore.CurrentWallet));
  Net.SendPacket(Packet);
  UI.ShowMessage(Msg);
end;

procedure THandlerCore.CreateTransfer(Args: array of string);
var
  Msg: string;
  ASymbol: string;
  Address: UInt64;
  ATo, AValue, TokenID, decimal: UInt64;
  FloatValue: Extended;
  Packet: TPacket;
  ResHash: string;
begin
  Msg := 'Trying create your Transfer';
  if (WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress) or (walletId = 0) then
  begin
    Msg := 'System: Bad wallet, please open or create wallet.';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Length(Args) <> 6 then
  begin
    Msg := 'System ifno: Must be 3 keys and 3 params';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[0] <> 't' then
  begin
    Msg := 'System ifno: Bad 1 key, must be ''-t''';
    UI.ShowMessage(Msg);
    Exit;
  end;
  if (Length(Args[1]) > 5) or (Length(Args[1]) < 3) then
  begin
    Msg := 'System ifno: Bad ''-t'' param, min length 3 chars, max length 5 chars';
    UI.ShowMessage(Msg);
    Exit;
  end;
  ASymbol := Args[1];

  if Args[2] <> 'to' then
  begin
    Msg := 'System ifno: Bad 2 key, must be ''-to''';
    UI.ShowMessage(Msg);
    Exit;
  end;

  Address := BlockChain.Inquiries.TryGetAccountID(Args[3]);

  if Address = 0 then
  begin
    Msg := 'System ifno: Bad ''-to'' param, incorrect address ';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[4] <> 'v' then
  begin
    Msg := 'System ifno: Bad 2 key, must be ''-v''';
    UI.ShowMessage(Msg);
    Exit;
  end;
  if (Length(Args[5]) > 18) or (Length(Args[5]) < 1) then
  begin
    Msg := 'System ifno: Bad ''-to'' param, min length 1 chars, max length 18 chars';
    UI.ShowMessage(Msg);
    Exit;
  end;

  TokenID := BlockChain.Inquiries.TryGetTokenID(ASymbol);

  if TokenID = 0 then
  begin
    Msg := 'System ifno: Bad token name';
    UI.ShowMessage(Msg);
    Exit;
  end;
  decimal := BlockChain.Inquiries.TryGetTokenDecimals(TokenID);
  if not TryStrToFloat(Args[5], FloatValue) then
  begin
    Msg := 'System ifno: Bad ''-v'' param, incorrect value';
    UI.ShowMessage(Msg);
    Exit;
  end;

  AValue := UInt64(Round(FloatValue * Power(10, decimal)));

  if BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, ASymbol) < FloatValue then
  begin
    Msg := 'System ifno: Sorry, you dont have enough funds';
    UI.ShowMessage(Msg);
    Exit;
  end;

  Packet.CreatePacket(CMD_REQUEST_NEW_TRANSFER, BlockChain.Inquiries.CreateTrxNewTransfer(ResHash, ASymbol, Address, AValue,
    WalletCore.CurrentWallet));
  Net.SendPacket(Packet);
  UI.ShowMessage(Msg);
end;

procedure THandlerCore.ReadWallets;
begin
  UI.ShowMessage(WalletCore.GetWallets);
end;

procedure THandlerCore.ReadWallet;
var
  Data: TBytes;
  Header: THeader;
  AccInfV1: TAccountTrxV0;
  AccV1: TAccountBlockV0;
begin
  Move(Data[0], Header, sizeOf(Header));

  case Header.VersionData of
    0:
      begin
        AccV1 := TAccountBlockV0.Create;
        AccV1.SetData(Data);
        AccInfV1 := AccV1.GetTrxData;
      end;
  end;
end;

procedure THandlerCore.SetDefaultState;
begin
  // {$IFDEF GUII}
  // NodeState := FullNode;
  // {$ELSE}
  NodeState := Config.NodeState;
  // {$ENDIF}
end;

procedure THandlerCore.ShutDown(const Msg: string = '');
begin
  UI.ShutDown(Msg);
end;

procedure THandlerCore.StartNode;
var
  Packet: TPacket;
begin
  Net.Start(0, Config.ServerPort, Config.ClientPort);
  WebServer.Start(Config.WebServerPort);
  TestSerialize;
  Packet.CreatePacket(CMD_REQUEST_AUTH, []);
  if Net.SendPacket(Packet) = -1 then
  begin
    UI.ShutDown('System: Sorry, you don''t have internet');
    Exit;
  end;

  UI.ShowMessage('System Check: Start Check');
end;

procedure THandlerCore.BadArgs(Args: array of string);
begin
  UI.ShowMessage('Warning: Bad args');
end;

procedure THandlerCore.DoMining;
var
  countblocks: integer;
  Packet: TPacket;
begin
  try
    if (NodeState = Speaker) then
      BlockChain.Inquiries.DoMining(WalletCore.CurrentWallet, countblocks);
  except
    on e: Exception do
    begin
      UI.ShowMessage(e.Message);
    end;
  end;
end;

procedure THandlerCore.GetBalance(Args: array of string);
begin
  try
    UI.ShowMessage('System: Your ' + UpperCase(Args[1]) + ' token balance is ' +
      FloatToStr(BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, UpperCase(Args[1]))));
  except
    UI.ShowMessage('System: Bad Args');
  end;
end;

procedure THandlerCore.GetOpenedWallet;
var
  Msg: string;
begin
  if walletId = 0 then
    Msg := 'System: Sorry, but you dont open wallet'
  else
    Msg := WalletCore.CurrentWallet.GetAddress;

  UI.ShowMessage(Msg);
end;

function THandlerCore.GetReceivedAmountAllTime(AccID, TokenID: UInt64): Double;
begin
  Result := BlockChain.Inquiries.TryGetReceivedAmountAllTime(AccID, TokenID);
end;

function THandlerCore.GetSentAmountAllTime(AccID, TokenID: UInt64): Double;
begin
  Result := BlockChain.Inquiries.TryGetSentAmountAllTime(AccID, TokenID);
end;

function THandlerCore.GetTokenByName(ASymbol: String): TTokensInfoV0;
begin
  Result := BlockChain.Inquiries.TryGetTokenInfo(ASymbol);
end;

function THandlerCore.GetTransactioHistoryItems(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransHistoryItem>;
begin
  Result := BlockChain.Inquiries.TryGetTransactionHistoryItems(AccID, UnixFrom, UnixTo);
end;

function THandlerCore.GetTransactionHistory(AID, ATID: UInt64): TArray<string>;
begin
  Result := BlockChain.Inquiries.GetTransactionHistory(AID, ATID);
end;

function THandlerCore.GetTransAmount(Trans: TTransferInfoV0): Double;
begin
  Result := BlockChain.Inquiries.TryGetTransAmount(Trans);
end;

function THandlerCore.GetTransInfo(TransHash: THash): TTransHistoryItem;
begin
  Result := BlockChain.Inquiries.TryGetTransInfo(TransHash);
end;

function THandlerCore.GetTokenID(ASymbol: string): UInt64;
begin
  Result := BlockChain.Inquiries.TryGetTokenID(ASymbol);
end;

function THandlerCore.GetTokenOwners(Symbol: TSymbol): TArray<TAccountInfoV0>;
begin
  Result := BlockChain.Inquiries.TryGetTokenOwners(Symbol);
end;

function THandlerCore.GetTokenTransCount(Symbol: TSymbol): UInt64;
begin
  Result := BlockChain.Inquiries.TryGetTokenTransCount(Symbol);
end;

function THandlerCore.GetAccountInfo(AAddress: THash): TAccountInfoV0;
begin
  Result := BlockChain.Inquiries.TryGetAccountInfo(AAddress);
end;

function THandlerCore.GetAccRegDate(Address: THash): UInt64;
begin
  Result := BlockChain.Inquiries.TryGetAccRegDate(Address);
end;

function THandlerCore.TryGetTokensInfo: TArray<TTokensInfoV0>;
begin
  Result := BlockChain.Inquiries.TryGetTokenInfoAll;
end;

function THandlerCore.GetBalanceToken(AAddress: THash; ASymbol: String): Double;
begin
  Result := BlockChain.Inquiries.TryGetBalance(AAddress, ASymbol);
end;

function THandlerCore.GetCommissionsInfoAll: TArray<string>;
begin
  Result := BlockChain.Inquiries.TryGetCommissionsInfoAll;
end;

function THandlerCore.GetGetALLAccounts: TArray<TAccountInfoV0>;
begin
  Result := BlockChain.Inquiries.TryGetALLAccounts;
end;

function THandlerCore.GetMyAdress: string;
begin
  Result := WalletCore.CurrentWallet.GetAddress;
end;

function THandlerCore.GetAccountAddress(AccID: UInt64): THash;
begin
  Result := BlockChain.Inquiries.TryGetAccountAddress(AccID);
end;

function THandlerCore.GetAccountID(AAddress: THash): UInt64;
begin
  Result := BlockChain.Inquiries.TryGetAccountID(AAddress);
end;

function THandlerCore.GetAccTransactions(AccID: UInt64): TArray<TTransferInfoV0>;
begin
  Result := BlockChain.Inquiries.TryGetAccTransactions(AccID);
end;

function THandlerCore.GetALLTransactions: TArray<TTransHistoryItem>;
begin
  Result := BlockChain.Inquiries.TryGetALLTransactions;
end;

function THandlerCore.GetAllTransactionsBySymbol(Symbol: TSymbol): TArray<TTransHistoryItem>;
begin
  Result := BlockChain.Inquiries.TryGetAllTransactionsBySymbol(Symbol);
end;

procedure THandlerCore.TryOpenWallet(Args: array of string);
begin
  if (Length(Args) = 4) then
    if Args[0] = 'wa' then
      if trim(Args[2]) = 'p' then
        if WalletCore.OpenWallet(Args[1], Args[3]) = True then
        begin
          if BlockChain.Inquiries.CheckAddress(WalletCore.CurrentWallet.GetAddress) then
          begin
            walletId := BlockChain.Inquiries.TryGetAccountID(WalletCore.CurrentWallet.GetAddress);
            UI.ShowMessage('Wallet ' + WalletCore.CurrentWallet.GetAddress + ' successful open');
          end
          else
            UI.ShowMessage('In Command ''openwallet'' incorrect parametr ' + quotedstr(Args[2]) + ', try again');
        end
        else
          UI.ShowMessage('Incorrect password for wallet: ' + Args[1])
      else
        UI.ShowMessage('In Command ''openwallet'' incorrect parametr ' + quotedstr(Args[2]) + ', try again')
    else
      UI.ShowMessage('In Command ''openwallet'' incorrect parametr ' + quotedstr(Args[0]) + ' , try again')
  else
    UI.ShowMessage('In Command ''openwallet'' too few parameters, try again');
end;

procedure THandlerCore.TryBuyOM;
var
  Msg: string;
  Packet: TPacket;
  ResHash: string;
begin
  if walletId = 0 then
  begin
    Msg := 'System ifno: Sorry, you dont have open wallet';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, MainCoin) < 10000 then
  begin
    Msg := 'System ifno: Sorry, you dont have enough funds, you mest owned min 10000 ORBC';
    UI.ShowMessage(Msg);
    Exit;
  end;

  Packet.CreatePacket(CMD_REQUEST_NEW_OWNER_MINING, BlockChain.Inquiries.CreateTrxNewTransfer(ResHash, MainCoin, 0, 1000000000000
    { Round(10000 * Power(10, BlockChain.Inquiries.TryGetTokenDecimals(BlockChain.Inquiries.TryGetTokenID(MainCoin))) } , WalletCore.CurrentWallet));
  Net.SendPacket(Packet);
  UI.ShowMessage(Msg);
end;

function THandlerCore.TryBuyOMGUI: boolean;
var
  Packet: TPacket;
  ResHash: string;
begin
  Result := True;
  if walletId = 0 then
  begin
    Result := False;
    Exit;
  end;

  if BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, MainCoin) < 10000 then
  begin
    Result := False;
    Exit;
  end;

  Packet.CreatePacket(CMD_REQUEST_NEW_OWNER_MINING, BlockChain.Inquiries.CreateTrxNewTransfer(ResHash, MainCoin, 0,
    Round(10000 * Power(10, BlockChain.Inquiries.TryGetTokenDecimals(BlockChain.Inquiries.TryGetTokenID(MainCoin)))),
    WalletCore.CurrentWallet, True));
  Net.SendPacket(Packet);
end;

procedure THandlerCore.TryEasyBuyOM;
var
  Msg: string;
  Packet: TPacket;
  ResHash: string;
begin
  if walletId = 0 then
  begin
    Msg := 'System ifno: Sorry, you dont have open wallet';
    UI.ShowMessage(Msg);
    Exit;
  end;

  // if BlockChain.Inquiries.TyGetBalance(WalletCore.CurrentWallet.GetAddress,MainCoin) < 10000 then
  // begin
  // Msg := 'System ifno: Sorry, you dont have enough funds, you mest owned min 10000 ORBC';
  // UI.ShowMessage(Msg);
  // Exit;
  // end;

  Packet.CreatePacket(CMD_REQUEST_EASY_NEW_OWNER_MINING, BlockChain.Inquiries.CreateTrxNewTransfer(ResHash, MainCoin, 0, 10000,
    WalletCore.CurrentWallet, True));
  Net.SendPacket(Packet);
  UI.ShowMessage(Msg);
end;

function THandlerCore.TryEasySendTransfer(var AResHash: string; ASymbol, AAddress, AAValue: string; var AError: integer;
  var AErrorMsg: string): boolean;
var
  Packet: TPacket;
  ResHash: string;
begin
  Result := False;
  var TokenID := BlockChain.Inquiries.TryGetTokenID(ASymbol);
  var decimal := BlockChain.Inquiries.TryGetTokenDecimals(TokenID);
  var FloatValue := StrToFloat(AAValue);
  var Address := BlockChain.Inquiries.TryGetAccountID(AAddress);
  var AValue: UInt64 := UInt64(Round(FloatValue * Power(10, decimal)));

  if (TokenID = 0) then
  begin
    AErrorMsg := 'Invalid Token Name';
    Exit;
  end;
  if (BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, ASymbol) < FloatValue) then
  begin
    AErrorMsg := 'insufficient funds';
    Exit;
  end;

  if (Address = NaN) or (walletId = Address) then
  begin
    AErrorMsg := 'Incorrect address';
    Exit;
  end;

  try
    Packet.CreatePacket(CMD_REQUEST_NEW_TRANSFER, BlockChain.Inquiries.CreateTrxNewTransfer(ResHash, ASymbol, Address, AValue,
      WalletCore.CurrentWallet));
    AResHash := ResHash;
    Net.SendPacket(Packet);
    Result := True;
  except
    on e: Exception do
    begin
      AErrorMsg := e.Message;
      Result := False;
    end;
  end;

end;

function THandlerCore.TryEasyCreateToken(ASymbol, AName, ADec, AVolume: string; var Error: string): boolean;
var
  Packet: TPacket;
  ResHash: string;
  trxInfo, tokenInfo, resBuf, countPacks, Size: TBytes;
begin
  if BlockChain.Inquiries.TryCheckIfTokenExists(UpperCase(ASymbol)) then
  begin
    Result := False;
    Error := 'This token already exists';
    Exit;
  end;

  if BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, 'ORBC') < 1 then
  begin
    Result := False;
    Error := 'You don''t have enough funds to create a token';
    Exit;
  end;

  try
    Result := True;
    var
    TokenID := 1;
    var
    decimal := BlockChain.Inquiries.TryGetTokenDecimals(TokenID);
    var
    FloatValue := 1;
    var
    Address := 0;
    var
      AValue: UInt64 := UInt64(Round(FloatValue * Power(10, decimal)));

    trxInfo := BlockChain.Inquiries.CreateTrxNewTransfer(ResHash, 'ORBC', Address, AValue, WalletCore.CurrentWallet, True);

    tokenInfo := BlockChain.Inquiries.CreateTrxNewToken(UpperCase(ASymbol), AName, ADec, AVolume, TToken.Token, WalletCore.CurrentWallet);

    Packet.CreatePacket(CMD_REQUEST_CREATE_TOKEN_WITH_COMMISSION, trxInfo + tokenInfo);
    Net.SendPacket(Packet);
  except
    on e: Exception do
    begin
      Result := False;
      Error := e.Message;
    end;
  end;
end;

function THandlerCore.TryCreateToken(Args: array of string; var ErrorCode: string; var Error: string): boolean;
var
  Msg: string;
  Packet: TPacket;
  ASymbol, AName: string;
  ADecimals: integer;
  AVolume: UInt64;
  AToken: TToken;
begin
  Msg := 'Trying create your Token';
  if WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress then
  begin
    Msg := 'System: Bad wallet, please open wallet.';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if (Length(Args[1]) > 30) or (Length(Args[1]) < 3) then
  begin
    Msg := 'System ifno: Bad ''-n'' param, min length 3 chars, max length 30 chars';
    UI.ShowMessage(Msg);
    Exit;
  end;
  AName := Args[1];

  if Args[2] <> 'sn' then
  begin
    Msg := 'System ifno: Bad 2 key, must be ''-sn''';
    UI.ShowMessage(Msg);
    Exit;
  end;
  if (Length(Args[3]) > 5) or (Length(Args[3]) < 3) then
  begin
    Msg := 'System ifno: Bad ''-sn'' param, min length 3 chars, max length 5 chars';
    UI.ShowMessage(Msg);
    Exit;
  end;
  ASymbol := UpperCase(Args[3]);
  if ASymbol = 'ORBC' then
    AToken := TToken.Coin
  else
    AToken := TToken.Token;

  if BlockChain.Inquiries.TryGetTokenID(ASymbol) > 0 then
  begin
    Msg := 'System ifno: Sorry but such a token already exists';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[4] <> 'd' then
  begin
    Msg := 'System ifno: Bad 3 key, must be ''-d''';
    UI.ShowMessage(Msg);
    Exit;
  end;

  try
    ADecimals := StrToInt(Args[5]);
    if (ADecimals < 0) or (ADecimals > 10) then
      raise Exception.Create('');
  except
    Msg := 'System ifno: Bad ''-d'' param, min value 0, max value 8';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[6] <> 'v' then
  begin
    Msg := 'System ifno: Bad 4 key, must be ''-v''';
    UI.ShowMessage(Msg);
    Exit;
  end;

  try
    AVolume := StrToUInt64(Args[7]);
    if (ADecimals < 0) or (ADecimals > Power(10, 18 - Length(Args[5]))) then
      raise Exception.Create('');
  except
    Msg := 'System ifno: Bad ''-v'' param, min value 1, max value ' + Power(10, 18 - Length(Args[5])).ToString;
    UI.ShowMessage(Msg);
    Exit;
  end;

  Packet.CreatePacket(CMD_REQUEST_NEW_TOKEN, BlockChain.Inquiries.CreateTrxNewToken(ASymbol, AName, ADecimals.ToString, AVolume.AsString, AToken,
    WalletCore.CurrentWallet));
  Net.SendPacket(Packet);
  UI.ShowMessage(Msg);
end;

procedure THandlerCore.TryCreateWallet(Args: array of string);
begin
  if (Length(Args) = 2) then
    if Args[0] = 'p' then
      CreateWallet(Args[1])
    else
      UI.ShowMessage('In Command ''createwallet'' incorrect parametr ' + quotedstr(Args[0]) + ', try again')
  else
    UI.ShowMessage('In Command ''createwallet'' incorrect parametrs, try again');
end;

procedure THandlerCore.HandleCommand(Command: Byte; Args: array of string);
begin
  case Command of
    CMD_CREATE_WALLET:
      TryCreateWallet(Args);
    CMD_OPEN_WALLET:
      TryOpenWallet(Args);
    CMD_GET_WALLETS:
      ReadWallets;
    CMD_START:
      StartNode;
    CMD_CREATE_TOKEN:
      if (NodeState = Speaker) and (ParamStr(1) = 'init') then
        CreateToken(Args);
    CMD_CREATE_TRANSFER:
      CreateTransfer(Args);
    CMD_WHOAMI:
      GetOpenedWallet;
    CMD_GET_BALANCE:
      GetBalance(Args);
    CMD_CREATE_OM:
      TryBuyOM;
    CMD_EASY_CREATE_OM:
      TryEasyBuyOM;
    CMD_DO_MINING:
      DoMining;
    CMD_BAD_ARG:
      BadArgs(Args);
    CMD_CHECK_BC:
      CheckBC;
    CMD_DO_END_UPDATE:
      DoEndUpdate;
    CMD_DO_START_UPDATE:
      DoStartUpdate;

  else
    begin
      UI.ShowMessage('System: Unexpected command');
    end;
  end;
end;

procedure THandlerCore.HandleConnectClient(ClientName: String);
begin
  //
end;

procedure THandlerCore.HandleDisconnectClient(ClientName: String);
begin
  //
end;

procedure THandlerCore.HandleGUICommand(Command: Byte; Args: array of string; ACallback: TCallBack);
begin

  case Command of
    CMD_GUI_CREATE_WALLET:
      begin
        if CreateWallet(Args[0]) > 0 then
          ACallback([WalletCore.CurrentWallet.GetAddress])
        else
          ACallback(['']);
      end;
    CMD_CHECK_COUNT_WALLETS:
      begin
        var
        return := WalletCore.GetWallets;
        ACallback([return]);
      end;
    CMD_GUI_OPEN_WALLET:
      begin
        var
        return := 'BAD';
        if WalletCore.OpenWallet(Args[0], Args[1]) then
        begin
          walletId := BlockChain.Inquiries.TryGetAccountID(Args[0]);
          if (walletId <> NaN) and (walletId > 0) then
            return := 'OK';
        end;
        ACallback([return]);
      end;
    CMD_GUI_CHECK_NEW_WALLET:
      begin
        if BlockChain.Inquiries.TryGetAccountID(Args[0]) > 0 then
          ACallback([]);
      end;
    CMD_GUI_GET_BALANCES:
      begin
        var
        Data := BlockChain.Inquiries.GetBalances(walletId);
        var
        isOMOwner := BlockChain.Inquiries.TryGetFunctionAboutOwningOM(walletId);
        if Length(Data) > 0 then
        begin
          if isOMOwner then
            ACallback(ParseDataBalances(Data) + ['OM', '1'])
          else
            ACallback(ParseDataBalances(Data) + ['OM', '0']);
        end
        else if isOMOwner then
          ACallback(['ORBC', '0', 'OM', '1'])
        else
          ACallback(['ORBC', '0', 'OM', '0'])
      end;
    CMD_GUI_CREATE_TRANSFER:
      begin
        var ErrorCode: integer;
        var HashTrx, Error: string;
        if TryEasySendTransfer(HashTrx, Args[0], Args[1], Args[2], ErrorCode, Error) then
          ACallback(['OK', HashTrx])
        else
          ACallback(['BAD', Error]);
      end;
    CMD_GUI_TRANSACTION_HISTORY:
      begin
        if trim(Args[0]) = 'OM' then
          ACallback(GetTransactionHistory(walletId, GetTokenID(trim(Args[0]))))
        else
          ACallback(GetTransactionHistory(walletId, GetTokenID(trim(Args[0]))));
      end;
    CMD_GUI_GET_WORDS:
      begin
        ACallback([WalletCore.CurrentWallet.GetWords]);
        // WalletCore.CloseWallet;
      end;
    CMD_GUI_SET_WORDS:
      begin
        if WalletCore.RestoreWalletWithWords(Args[0], Args[1]) then
          ACallback(['OK'])
        else
          ACallback(['BAD']);
      end;
    CMD_GUI_SET_CC:
      begin
        if WalletCore.RestoreWalletWithCC(Args[0], Args[1]) then
          ACallback(['OK'])
        else
          ACallback(['BAD']);
      end;
    CMD_GUI_BUY_OM:
      begin
        if TryBuyOMGUI then
          ACallback(['OK'])
        else
          ACallback(['BAD']);
      end;
    CMD_GUI_REMOVE_CC:
      begin
        WalletCore.RemoveWallet(Args[0]);
        var
        returnWaleets := WalletCore.GetWallets;
        ACallback([returnWaleets]);
      end;
    CMD_GUI_CREATE_TOKEN_WITH_COMMISSION:
      begin
        var
          Error: String;
        if TryEasyCreateToken(Args[0], Args[1], Args[2], Args[3], Error) then
          ACallback(['OK'])
        else
          ACallback(['BAD', Error]);
      end;
    CMD_GUI_GET_MY_ADDRESS:
      begin
        ACallback([GetMyAdress]);
      end;

  end;
end;

procedure THandlerCore.HandleReceiveHTTPData(From: TConnectedClient; const ABytes: TBytes);
var
  Request: TRequest;
  Response: TResponse;
begin
  try
    Request := TRequest.Create(ABytes);
    Response := TResponse.Create(Request, BlockChain, WalletCore);
    From.SendMessage(Response.ByteAnswer);
    From.Disconnect;
  finally
    if Assigned(Request) then
      Request.Free;
    if Assigned(Response) then
      Response.Free;
  end;
end;

procedure THandlerCore.HandleReceiveTCPData(From: IClient; const ABytes: TBytes);
var
  requestPacket: TPacket;
  responsePacket: TPacket;
  Packet: TPacket;
begin
  _CS.Enter;
  try
    requestPacket := ABytes;
    case requestPacket.PacketType of
      // Простейшая проверка протокола
      CMD_REQUEST_AUTH: // проверяем пакет авторизации
        begin
          if ABytes[1] = 0 then
          begin
            responsePacket.CreatePacket(CMD_RESPONSE_AUTH_OK, []);
            From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_AUTH: CMD_RESPONSE_AUTH_OK');
          end
          else
          begin
            responsePacket.CreatePacket(CMD_RESPONSE_AUTH_BAD, []);
            From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_AUTH: CMD_RESPONSE_AUTH_BAD');
          end;

          From.SendMessage(responsePacket);
        end;
      CMD_RESPONSE_AUTH_OK:
        begin
          if NodeState = Invalid then
          begin
            SetDefaultState;
            UI.ShowMessage('System Check: You have correct protocol');
            Packet.CreatePacket(CMD_REQUEST_VERSION, []);
            From.SendMessage(Packet);
            UI.ShowMessage('System Check: Check version...');
            Notifyer.DoEvent(nOnOkAuth);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_AUTH_OK: CMD_REQUEST_VERSION');
          end;
        end;
      CMD_RESPONSE_AUTH_BAD:
        begin
          if NodeState = Invalid then
          begin
            ShutDown('System Check: You have a bad protocol of the node. Please download the correct application. Please press the key');
            Notifyer.DoEvent(nOnBadAuth);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_AUTH_BAD: EXIT');
          end;
        end;
      // Запрос актуальной версии ноды в сети
      CMD_REQUEST_VERSION:
        begin
          responsePacket.CreatePacket(CMD_RESPONSE_VERSION, GetVersion);
          From.SendMessage(responsePacket);
          From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_VERSION: CMD_RESPONSE_VERSION');
        end;
      CMD_RESPONSE_VERSION:
        begin
          if not isValid then
            Exit;
          if CompareMem(GetVersion, requestPacket.PacketBody, Length(requestPacket.PacketBody)) then
          begin
            UI.ShowMessage('System Check: Congratulations, you have the latest version - ' + GetVersionString);
            responsePacket.CreatePacket(CMD_REQUEST_COUNT_BLOCK, []);
            From.SendMessage(responsePacket);
            UI.ShowMessage('System Check: Check count block''s');
            Notifyer.DoEvent(nOnGoodVersion);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_VERSION: CMD_REQUEST_COUNT_BLOCK');
          end
          else
          begin
            UI.ShowMessage('System Check: Sorry, but you have''t the latest version. You have ' + GetVersionString + ' of ' +
              intToStr(requestPacket.PacketBody[0]) + '.' + intToStr(requestPacket.PacketBody[0]) + '.' + intToStr(requestPacket.PacketBody[0]));
            UI.ShutDown('System Check: End');
            Notifyer.DoEvent(nOnBadVersion);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_VERSION: EXIT');
          end;
        end;
      // Запрос актуального количества блоков в сети
      CMD_REQUEST_COUNT_BLOCK:
        begin
          responsePacket.CreatePacket(CMD_RESPONSE_COUNT_BLOCK, BlockChain.Inquiries.MainChainCount);
          From.SendMessage(responsePacket);
          From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_COUNT_BLOCK: CMD_RESPONSE_COUNT_BLOCK');
        end;
      CMD_RESPONSE_COUNT_BLOCK:
        begin
          if not isValid then
            Exit;
          var
            CountMainBlock: UInt64;

          Move(requestPacket.PacketBody[0], CountMainBlock, requestPacket.PacketSize);
          UI.ShowMessage('System Check: End Check');

          if CountMainBlock < BlockChain.Inquiries.MainChainCount then
          begin
            BlockChain.Inquiries.DoCorruptedBC;
            ShutDown('System: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
            From.DoLog('HandleReceiveTCPData',
              'CMD_RESPONSE_COUNT_BLOCK: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
            Exit;
          end;

          if CountMainBlock = BlockChain.Inquiries.MainChainCount then
          begin
            UI.ShowMessage('System: Congratulations, you have all blocks');
            if not BlockChain.Inquiries.CheckBlocks(0, BlockChain.Inquiries.MainChainCount) then
            begin
              BlockChain.Inquiries.DoCorruptedBC;
              ShutDown('System: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
              From.DoLog('HandleReceiveTCPData',
                'CMD_RESPONSE_COUNT_BLOCK: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
              Exit;
            end;

            Notifyer.DoEvent(nOnStartDownalodBlocks);
            Notifyer.DoEvent(nOnEndDownloadBlocks);
            InitializeState;
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_COUNT_BLOCK: InitializeState');
            UI.ShowMessage(GetTextRequestForInput(English));
          end
          else
          begin
            UI.ShowMessage('System: Sorry, but you have''t the latest block. You have ' + intToStr(BlockChain.Inquiries.MainChainCount) + ' of ' +
              intToStr(CountMainBlock));
            responsePacket.CreatePacket(CMD_REQUEST_GET_BLOCK_FROM, BlockChain.Inquiries.MainChainCount);
            From.SendMessage(responsePacket);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_COUNT_BLOCK: CMD_REQUEST_GET_BLOCK_FROM');
            if BlockChain.Inquiries.MainChainCount > CountMainBlock then
              UI.ShutDown;

            UI.ShowMessage('System: Start Download blocks');
            Notifyer.DoEvent(nOnStartDownalodBlocks);
          end;
        end;
      // Запрос всех блоков начиная со своего последнего
      CMD_REQUEST_GET_BLOCK_FROM:
        begin
          var
            buf: TBytes;
          var
            FromBlock: UInt64;
          Move(requestPacket.PacketBody[0], FromBlock, requestPacket.PacketSize);
          buf := BlockChain.Inquiries.GetBlocksFrom(FromBlock); //
          responsePacket.CreatePacket(CMD_RESPONSE_GET_BLOCK_FROM, buf);
          From.SendMessage(responsePacket);
          From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_GET_BLOCK_FROM: CMD_RESPONSE_GET_BLOCK_FROM');
        end;
      CMD_RESPONSE_GET_BLOCK_FROM:
        begin
          if not isValid then
            Exit;
          if (Length(requestPacket.PacketBody) > 0) and (requestPacket.PacketBody[0] = 0) then
          begin
            BlockChain.Inquiries.SetNewBlocks(requestPacket.PacketBody);

            if not BlockChain.Inquiries.CheckBlocks(0, BlockChain.Inquiries.MainChainCount) then
            begin
              BlockChain.Inquiries.DoCorruptedBC;
              ShutDown('System: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
              From.DoLog('HandleReceiveTCPData',
                'CMD_RESPONSE_GET_BLOCK_FROM: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
              Exit;
            end;

            Notifyer.DoEvent(nOnEndDownloadBlocks);
            UI.ShowMessage('System: End Download blocks');
            responsePacket.CreatePacket(CMD_REQUEST_COUNT_BLOCK, BlockChain.Inquiries.MainChainCount);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_BLOCK_FROM: CMD_REQUEST_COUNT_BLOCK');
            From.SendMessage(responsePacket);
          end;
        end;
      // Новый криптоконтейнер
      CMD_REQUEST_NEW_CC:
        begin
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            var
              countblocks: UInt64;
            if BlockChain.Inquiries.SetTrxCacheChain(Accounts, requestPacket.PacketBody, WalletCore.CurrentWallet, countblocks) then
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_CC, [ord(True)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_CC: CMD_RESPONSE_NEW_CC - TRUE');
            end
            else
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_CC, [ord(False)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_CC: CMD_RESPONSE_NEW_CC - FALSE');
            end;
            From.SendMessage(responsePacket);
          end;
        end;
      CMD_RESPONSE_NEW_CC:
        begin
          if not isValid then
            Exit;
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your Wallet ' + WalletCore.CurrentWallet.GetAddress + ' accepted. Wait for confirmation ');
            UI.ShowMessage('System: Your 47 words. Please Save him.' + WalletCore.CurrentWallet.GetWords);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_CC: ' + WalletCore.CurrentWallet.GetAddress + ' - GOOD');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your Wallet' + WalletCore.CurrentWallet.GetAddress + ' not accepted.');
            UI.ShowMessage('System: Please, try again later.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_CC: ' + WalletCore.CurrentWallet.GetAddress + ' - BAD');
          end;
        end;
      // Новый токен
      CMD_REQUEST_NEW_TOKEN:
        begin
          if not isValid then
            Exit;
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            var
              countblocks: UInt64;
            if BlockChain.Inquiries.SetTrxCacheChain(Tokens, requestPacket.PacketBody, WalletCore.CurrentWallet, countblocks) then
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_TOKEN, [ord(True)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_TOKEN: CMD_RESPONSE_NEW_TOKEN - FALSE');
            end
            else
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_TOKEN, [ord(False)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_TOKEN: CMD_RESPONSE_NEW_TOKEN - FALSE');
            end;

            From.SendMessage(responsePacket);
          end;
        end;
      CMD_RESPONSE_NEW_TOKEN:
        begin
          if not isValid then
            Exit;
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your Token accepted. Wait for confirmation ');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_TOKEN:  - GOOD TRX');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your Token not accepted.');
            UI.ShowMessage('System: Please, try again later.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_TOKEN:  - BAD TRX');
          end;
        end;
      // Новый факт владения токеном (в простонародье транзакция)
      CMD_REQUEST_NEW_TRANSFER:
        begin
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            var
              countblocks: UInt64;
            if BlockChain.Inquiries.SetTrxCacheChain(Transfers, requestPacket.PacketBody, WalletCore.CurrentWallet, countblocks) then
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_TRANSFER, [ord(True)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_TRANSFER: CMD_RESPONSE_NEW_TRANSFER - GOOD');
            end
            else
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_TRANSFER, [ord(False)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_TRANSFER: CMD_RESPONSE_NEW_TRANSFER - BAD');
            end;
            From.SendMessage(responsePacket);
          end;
        end;
      CMD_RESPONSE_NEW_TRANSFER:
        begin
          if not isValid then
            Exit;
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your Transfer accepted. Wait for confirmation ');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_TRANSFER: - GOOD');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your Transfer not accepted.');
            UI.ShowMessage('System: Please, try again later.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_TRANSFER: - BAD');
          end;
        end;
      // покупка OM за ORBC
      CMD_REQUEST_NEW_OWNER_MINING:
        begin
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            var
              countblocks: UInt64;
            if BlockChain.Inquiries.SetTrxCacheChain(Mining, requestPacket.PacketBody, WalletCore.CurrentWallet, countblocks) then
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_OWNER_MINING, [ord(True)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_OWNER_MINING: CMD_RESPONSE_NEW_OWNER_MINING - GOOD');
            end
            else
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_OWNER_MINING, [ord(False)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_OWNER_MINING: CMD_RESPONSE_NEW_OWNER_MINING - BAD');
            end;
            From.SendMessage(responsePacket);
          end;
        end;
      CMD_RESPONSE_NEW_OWNER_MINING:
        begin
          if not isValid then
            Exit;
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your Transfer on Buy OM accepted. Wait for confirmation ');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_OWNER_MINING:  - GOOD');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your Transfer not accepted.');
            UI.ShowMessage('System: Please, try again later.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_OWNER_MINING:  - BAD');
          end;
        end;

      // Покупка OM без наличия ORBC
      CMD_REQUEST_EASY_NEW_OWNER_MINING:
        begin
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            var
              countblocks: UInt64;
            if BlockChain.Inquiries.DoEasyBuyOm(Mining, requestPacket.PacketBody, WalletCore.CurrentWallet, countblocks) then
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_EASY_NEW_OWNER_MINING, [ord(True)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_EASY_NEW_OWNER_MINING: CMD_RESPONSE_EASY_NEW_OWNER_MINING  - GOOD');
            end
            else
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_EASY_NEW_OWNER_MINING, [ord(False)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_EASY_NEW_OWNER_MINING: CMD_RESPONSE_EASY_NEW_OWNER_MINING  - BAD');
            end;

            From.SendMessage(responsePacket);
          end;
        end;
      CMD_RESPONSE_EASY_NEW_OWNER_MINING:
        begin
          if not isValid then
            Exit;
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your Transfer on Buy OM accepted. Wait for confirmation ');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_EASY_NEW_OWNER_MINING:  - GOOD');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your Transfer not accepted.');
            UI.ShowMessage('System: Please, try again later.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_EASY_NEW_OWNER_MINING: - BAD');
          end;
        end;
      // Блоки сформированные оратором
      CMD_RESPONSE_GET_NEW_BLOCKS:
        begin
          var controlSize: UInt64;
          controlSize.SetBytes(Copy(requestPacket.PacketBody, 1, sizeOf(controlSize)));
          From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_NEW_BLOCKS: RECIVED BLOCKS ' +controlSize.AsString + ' > COUN BLOCKS ' + BlockChain.Inquiries.MainChainCount.AsString);
          if controlSize > BlockChain.Inquiries.MainChainCount then
          begin
            if (requestPacket.PacketBody[0] = 0) then
            begin

              BlockChain.Inquiries.SetNewBlocks(requestPacket.PacketBody);

              Notifyer.DoEvent(nOnEndDownloadBlocks);
              UI.ShowMessage('System: data blocks received');

            end;
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_NEW_BLOCKS:  BLOCK ACCEPTED - GOOD');


            if (NodeState = Validator) then
              Net.SendAll(requestPacket);
          end
          else
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_NEW_BLOCKS:  - BAD');

        end;
      // Предлагаем валидатору стать оратором
      CMD_REQUEST_YOU_SPEAKER:
        begin
          if NodeState = Validator then
            responsePacket.CreatePacket(CMD_RESPONSE_YOU_SPEAKER, [ord(True)])
          else
            responsePacket.CreatePacket(CMD_RESPONSE_AUTH_BAD, [ord(False)]);
          From.SendMessage(responsePacket);

          if NodeState = Validator then
          begin
            NodeState := Speaker;
            UI.ShowMessage('System Info: Now you are - Speaker');
            ConsensusCore.Active:= True;
//            ConsensusCore.StartSpeakerWork;
          end;

        end;
      CMD_RESPONSE_YOU_SPEAKER:
        begin
          // if not isValid then
          // Exit;
          // if requestPacket.PacketBody[0].ToBoolean then
          // ConsensusCore.SuccessfulСhangeSpeaker
          // else
          // ConsensusCore.StartSpeakerWork;
        end;

      // Запрос всех кешированных блоков, для подтверждения
      CMD_REQUEST_GET_CACHE:
        begin
          if NodeState = Validator then
          begin
            responsePacket.CreatePacket(CMD_RESPONSE_GET_CACHE, BlockChain.Inquiries.GetAllCacheTrx);
            if responsePacket.PacketSize > 0 then
            begin
              UI.ShowMessage('System Info: Send Blocks to ' + From.IDNode.AsString);
              From.SendMessage(responsePacket);
            end;
          end;
        end;
      CMD_RESPONSE_GET_CACHE:
        begin
          if not isValid then
            Exit;
          if (NodeState = Validator) or (NodeState = Speaker) then
            if requestPacket.PacketSize > 0 then
            begin
              UI.ShowMessage('System: Receive blocks');
              BlockChain.Inquiries.SetAllCacheTrx(requestPacket.PacketBody);
            end;
        end;
      {$IFDEF Consesus.Core.TonyEdition}
      CMD_REQUEST_ID_IN_SYSTEM:
        begin
          var
          idClient := CheckID(requestPacket.PacketBody);
          if (idClient > 0) then
          begin
            From.IDNode := idClient;
            var
              cli: IClient;
            try
              cli := Net.NewValidatorClient(From.getIp, Config.ClientPort, idClient);
              ConsensusCore.AddToValidators(idClient, From.getIp, cli);
              // Если не получится подключиться будет ошибка
              var
                buffer: TBytes;
              SetLength(buffer, sizeOf(walletId));
              Move(walletId, buffer[0], sizeOf(walletId));
              var
                cryptoBuf: TBytes := RSAEncrypt(WalletCore.CurrentWallet.PrivKey, buffer);
              Packet.CreatePacket(CMD_REQUEST_ID_IN_SYSTEM_NO_ANSWER, buffer + cryptoBuf);
              cli.SendMessage(Packet);
            except
              idClient := 0;
              responsePacket.CreatePacket(CMD_ERROR, 255000);
              From.SendMessage(responsePacket);
              Exit;
            end;
          end
          else
            idClient := 0;

          responsePacket.CreatePacket(CMD_RESPONSE_ID_IN_SYSTEM, walletId);
          From.SendMessage(responsePacket);
        end;
      {$ENDIF}
      CMD_REQUEST_ID_IN_SYSTEM_NO_ANSWER:
        begin
          var
          ClientID := CheckID(requestPacket.PacketBody);
          if (ClientID > 0) then
            From.IDNode := ClientID
          else
            ClientID := 0;
        end;

      CMD_RESPONSE_ID_IN_SYSTEM:
        begin
          if not isValid then
            Exit;
          if (NodeState = Validator) then
          begin
            var
              id: UInt64;
            id.SetBytes(requestPacket.PacketBody);
            if (id > 0) then
            begin
              NodeState := Validator;
              From.IDNode := id;
            end
            else
              NodeState := FullNode;

            responsePacket.CreatePacket(CMD_REQUEST_GET_VALIDATORS, []);
            From.SendMessage(responsePacket);
          end;
        end;
      {$IFDEF Consesus.Core.TonyEdition}
      CMD_REQUEST_GET_VALIDATORS:
        begin
          ConsensusCore.UpdateValidators(From.IDNode);
          responsePacket.CreatePacket(CMD_RESPONSE_GET_VALIDATORS, ConsensusCore.GetValidators);
          From.SendMessage(responsePacket);
        end;
      CMD_RESPONSE_GET_VALIDATORS:
        begin
          if not isValid then
            Exit;
          if (NodeState = Validator) or (NodeState = Speaker) then
            ConsensusCore.SetValidators(requestPacket.PacketBody)
            // Проблема при определении своего IP
          else
            ConsensusCore.ChangeConnect(requestPacket.PacketBody);
        end;
      {$ENDIF}
      CMD_ERROR:
        begin
          var
            ErrorType: UInt64;
          ErrorType.SetBytes(requestPacket.PacketBody);
          case ErrorType of
            255000:
              begin
                NodeState := FullNode;
                WalletCore.CloseWallet;
                UI.ShowMessage('System Info: Error #255000. (You have closed 30000 port)');
                UI.ShowMessage('System Info: Close actual wallet.');
                UI.ShowMessage('System Info: Yout state - FullNode');
              end;
          end;
        end;
      CMD_REQUEST_CREATE_TOKEN_WITH_COMMISSION:
        begin
          if not isValid then
            Exit;
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            if BlockChain.Inquiries.CreateTokenWithCommisson(requestPacket.PacketBody, WalletCore.CurrentWallet) then
              responsePacket.CreatePacket(CMD_RESPONSE_CREATE_TOKEN_WITH_COMMISSION, [ord(True)])
            else
              responsePacket.CreatePacket(CMD_RESPONSE_CREATE_TOKEN_WITH_COMMISSION, [ord(False)]);

            From.SendMessage(responsePacket);
          end;
        end;
      CMD_RESPONSE_CREATE_TOKEN_WITH_COMMISSION:
        begin
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your Transfer on Create Token accepted. Wait for confirmation ');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your Transfer not accepted.');
            UI.ShowMessage('System: Please, try again later.');
          end;
        end;
      TP_VALIDATOR..TP_VALIDATOR_OFF:
        begin
          UI.ShowMessage(' >>> FConsensusCore.ReceiveData. <<<'
                        + '[' + IntToStr(From.IDNode) + '] '
                        + 'b: ' + Length(ABytes).ToString);
          try
            ConsensusCore.ReceiveData(From,requestPacket.PacketBody);
          except
            on e: Exception do
            begin
              UI.ShowMessage(' >>> ERROR FConsensusCore.ReceiveData. <<<'
                            + '[' + IntToStr(From.IDNode) + '] '
                            + 'err: ' + e.Message);
//              FConsensusCore.Active:= False;
//              FConsensusCore.Active:= True;
            end;
          end;
        end;
    end;
  except
    on e: Exception do
      From.DoLog('HandleReceiveTCPData', e.Message);
  end;
  _CS.Leave;
end;

procedure THandlerCore.HandleWebDataControl(Command: Byte; Args: array of string; ACallback: TCallBack);
begin
  case Command of
    CMD_GUI_CREATE_WALLET:
      begin
        if CreateWallet(Args[0]) > 0 then
          ACallback([WalletCore.CurrentWallet.GetAddress])
        else
          ACallback(['']);
      end;
    CMD_OPEN_WALLET:
      begin
        var
        return := 'BAD';
        if WalletCore.OpenWallet(Args[0], Args[1]) then
        begin
          walletId := BlockChain.Inquiries.TryGetAccountID(Args[0]);
          if walletId > 0 then
            return := 'OK';
        end;
        ACallback([return]);
      end;
    CMD_GUI_CREATE_TRANSFER:
      begin
        var
          ErrorCode: integer;
        var
          HashTrx, ErrorMsg: string;
        if TryEasySendTransfer(HashTrx, Args[0], Args[1], Args[2], ErrorCode, ErrorMsg) then
          ACallback(['OK', HashTrx])
        else
          ACallback(['BAD', ErrorMsg]);
      end;
    CMD_GUI_GET_WORDS:
      begin
        ACallback([WalletCore.CurrentWallet.GetWords]);
        // WalletCore.CloseWallet;
      end;
    CMD_GUI_SET_WORDS:
      begin
        if WalletCore.RestoreWalletWithWords(Args[0], Args[1]) then
          ACallback(['OK'])
        else
          ACallback(['BAD']);
      end;
    CMD_GUI_SET_CC:
      begin
        if WalletCore.RestoreWalletWithCC(Args[0], Args[1]) then
          ACallback(['OK'])
        else
          ACallback(['BAD']);
      end;
    CMD_GUI_BUY_OM:
      begin
        if TryBuyOMGUI then
          ACallback(['OK'])
        else
          ACallback(['BAD']);
      end;
    CMD_GUI_CREATE_TOKEN_WITH_COMMISSION:
      begin
        var
          Error: String;
        if TryEasyCreateToken(Args[0], Args[1], Args[2], Args[3], Error) then
          ACallback(['OK'])
        else
          ACallback(['BAD', Error]);
      end;
    CMD_GUI_GET_MY_ADDRESS:
      begin
        ACallback([GetMyAdress]);
      end;

    CMD_GUI_GET_BALANCES:
      begin
        var
        AccID := StrToUInt64(Args[0]);
        var
        Data := BlockChain.Inquiries.GetBalances(AccID);
        var
        isOMOwner := BlockChain.Inquiries.TryGetFunctionAboutOwningOM(AccID);
        if Length(Data) > 0 then
        begin
          if isOMOwner then
            ACallback(ParseDataBalances(Data) + ['OM', '1'])
          else
            ACallback(ParseDataBalances(Data) + ['OM', '0']);
        end
        else if isOMOwner then
          ACallback(['ORBC', '0', 'OM', '1'])
        else
          ACallback(['ORBC', '0', 'OM', '0'])
      end;
    CMD_WEB_CHECK_SEED_PHRASE:
      begin
        var
          Address: string := WalletCore.CheckWords(Args[0]);

        if Length(Address) > 0 then
          ACallback(['OK', Address])
        else
          ACallback(['BAD']);
      end;
  end;
end;

function THandlerCore.InitializeState: TNodeState;
begin
  if Not((NodeState = Speaker) and (ParamStr(1) = 'init')) then
  begin
    var
      flag: boolean := WalletCore.OpenWallet(Config.WalletName, Config.WalletPassword);
    if not BlockChain.Inquiries.CheckAddress(WalletCore.CurrentWallet.GetAddress) then
    begin
      flag := False;
      WalletCore.CloseWallet;
    end
    else
      walletId := BlockChain.Inquiries.TryGetAccountID(Config.WalletName);

    if not flag then
      NodeState := FullNode;

    UI.ShowMessage('System: Node State - ' + GetEnumName(TypeInfo(TNodeState), ord(NodeState)));

    if not flag then
      UI.ShowMessage('System: Node have not active wallet')
    else
      UI.ShowMessage('System: Node have active wallet - ' + Config.WalletName);
  end;
  {$IFDEF Consesus.Core.TonyEdition}
  ConsensusCore.DoConfigurate;
  {$ELSE}
  if (NodeState = Validator) or (NodeState = Speaker) or (ParamStr(1) = 'init') then
  begin
    ConsensusCore.ValID:= WalletID;
    ConsensusCore.ServerIPv4:= '127.0.0.1';
    ConsensusCore.ServerPort:= Config.ServerPort;
    ConsensusCore.Active:= True;
  end;
  {$ENDIF}
end;

function THandlerCore.ParseDataBalances(AData: TBytes): TArray<string>;
var
  counter: integer;
  TokenID: UInt64;
  firstBalance: UInt64;
  balance: real;
  decimal: integer;
  floatingFormat: string;
  pairBalance: TPair<string, real>;
  ExistORBC: boolean;
begin
  Result := [];
  counter := 0;
  ExistORBC := False;
  while counter < Length(AData) do
  begin
    Move(AData[counter], TokenID, sizeOf(TokenID));
    inc(counter, sizeOf(UInt64));
    Move(AData[counter], firstBalance, sizeOf(firstBalance));
    inc(counter, sizeOf(UInt64));
    decimal := BlockChain.Inquiries.TryGetTokenDecimals(TokenID);
    balance := firstBalance / (Power(10, BlockChain.Inquiries.TryGetTokenDecimals(TokenID)));
    if decimal > 0 then
    begin
      floatingFormat := '0.';
      for var i := 0 to decimal - 1 do
        floatingFormat := floatingFormat + '0';
      floatingFormat := floatingFormat + '##';
    end
    else
      floatingFormat := '0';

    var
      flags: TReplaceFlags;
    flags := [rfReplaceAll];
    if TokenID <> 1 then
    begin
      Result := Result + [StringReplace(BlockChain.Inquiries.TryGetTokenSymbol(TokenID), ',', '.', flags)] +
        [StringReplace(FormatFloat(floatingFormat, balance), ',', '.', flags)];

    end
    else
    begin
      Result := [StringReplace(BlockChain.Inquiries.TryGetTokenSymbol(TokenID), ',', '.', flags)] +
        [StringReplace(FormatFloat(floatingFormat, balance), ',', '.', flags)] + Result;
      ExistORBC := True;
    end;
  end;
  if not ExistORBC then
    Result := ['ORBC', '0'] + Result;
end;


initialization
  _CS:= TCriticalSection.Create;

finalization
  _CS.Free;

end.
