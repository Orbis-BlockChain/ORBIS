unit App.HandlerCore;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Math,
  System.TypInfo,
  System.Classes,
  BlockChain.Account,
  BlockChain.Core,
  BlockChain.Types,
  BlockChain.Tokens,
  BlockChain.Transfer,
  BlockChain.Service,
  BlockChain.ServiceResult,
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
  App.Tools,
  WebServer.DataControl,
  UI.Abstractions,
  UI.Types,
  Consensus2.Core,
  Crypto.RSA,
  WebServer.HTTPTypes,
  Updater.Core,
  Translate.Core;

type
  THandlerCore = class(TInterfacedObject, IBaseHandler)
  private
    FBlockChain: TBlockChainCore;
    FUI: TBaseUI;
    Fnet: TNetCore;
    FWalletCore: TWalletCore;
    FWebServer: TWebServer;
    FConfig: TConfig;
    FConsensusCore: TConsensusCore2;
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
    function GetAccountAddress(AccID: UInt64): THash;
    function GetCommissionsInfoAll: TArray<string>;
    function TryGetTokensInfo(sort: string): TArray<TTokensInfoV0>;
    function GetSentAmountAllTime(AccID, TokenID: UInt64): Double;
    function GetReceivedAmountAllTime(AccID, TokenID: UInt64): Double;
    function ParseDataBalances(AData: TBytes): TArray<string>;
    function GetTransactionHistory(AID: UInt64; ATID: UInt64 = 0): TArray<string>;
    function GetTransInfoByOwnerSign(OwnerSign: string): TArray<string>;
    function GetAccTokensCount(Address: String): UInt64;
    function GetTransactioHistoryItems(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransHistoryItem>;
    function GetAllTransactionsBySymbol(Symbol: TSymbol): TArray<TTransHistoryItem>;
    function GetTransInfoByID(TID: UInt64): TTransHistoryItem;
    function GetALLTransactions(sort: string): TArray<TTransHistoryItem>;
    function GetLastMined: Int64;
    function GetCountOM: UInt64;
    function GetALLServices(sort: string): TArray<TServiceInfoV0>;
    function GetServiceInfo(ID: UInt64): TServiceInfoV0;
    function GetServiceDataByID(ID: UInt64): TArray<TServiceResultV0>;
    function GetALLAccounts(sort: string): TArray<TAccountInfoV0>;
    function GetTokenOwners(Symbol: TSymbol): TArray<TAccountInfoV0>;
    function InitializeState: TNodeState;
    function CheckID(AData: TBytes): UInt64;
    function isValid: boolean;
    procedure DoStartUpdate;
    procedure DoEndUpdate;
    function TryDoChangeNet(TagNet: NativeInt; var Error: string): boolean;
    procedure DoChangeNet;
    procedure SaveConfig(snet: string);
    procedure Restart;
    function CheckAccIDByMining(AID: UInt64): boolean;

  public
    procedure HandleReceiveTCPData(From: IClient; const ABytes: TBytes);
    procedure HandleReceiveHTTPData(From: TConnectedClient; const ABytes: TBytes);
    procedure HandleCommand(Command: Byte; Args: array of string);
    procedure HandleGUICommand(Command: Byte; Args: array of string; ACallback: TCallBack);
    procedure HandleWebDataControl(Command: Byte; Args: array of string; ACallback: TCallBack);
    procedure HandleConnectClient(ClientName: String);
    procedure HandleDisconnectClient(ClientName: String);

    function RegServiceWeb(Args: array of string): boolean;
    function RegServiceCmd(Args: array of string): boolean;
    function SetServiceDataWeb(ID: UInt64; Data: TSRData): boolean;
    function SetServiceDataCmd(ID: UInt64; Data: TSRData; var Sign: TSignedHash): boolean;
    function GetServiceData(ID: UInt64): TBlockSRData; overload;
    function GetServiceData(AName: TName): TBlockSRData; overload;
    function DoSendStartPacket: boolean;

    function CheckLocalHost(): boolean;
    property BlockChain: TBlockChainCore read FBlockChain write FBlockChain;
    property UI: TBaseUI read FUI write FUI;
    property Net: TNetCore read Fnet write Fnet;
    property WalletCore: TWalletCore read FWalletCore write FWalletCore;
    property WebServer: TWebServer read FWebServer write FWebServer;
    property Config: TConfig read FConfig write FConfig;
    property ConsensusCore: TConsensusCore2 read FConsensusCore write FConsensusCore;
    property UpdaterCore: TUpdaterCore read FUpdaterCore write FUpdaterCore;
  end;

implementation

{ TNetHandlerCore }

procedure THandlerCore.TestSerialize;
var
  Packet: TPacket;
begin

end;

function THandlerCore.CreateWallet(Password: string): integer;
var
  counter: integer;
  flag: Boolean;
  NewAddress: THash;
  Msg: string;
  Packet: TPacket;
begin
  Result := -1;
  if WalletCore.TryCreateNewWallet(Password) then
  begin
    NewAddress := WalletCore.CurrentWallet.GetAddress;
    Msg := 'Trying create your wallet: ' + NewAddress;
    Packet.CreatePacket(CMD_REQUEST_NEW_CC, BlockChain.Inquiries.CreateTrxNewWallet(WalletCore.CurrentWallet));
    Result := Net.SendPacket(Packet);
    UI.ShowMessage(Msg);
  end
  else
  begin
    Msg := 'Can''t create wallet. Try restart node.';
    UI.ShowMessage(Msg);
  end;
end;

function THandlerCore.CheckAccIDByMining(AID: UInt64): boolean;
begin
  Result := false;
  if WalletID > 0 then
  begin
    Result := BlockChain.Inquiries.TryCheckAccIDByMining(WalletID);
  end;
end;

procedure THandlerCore.CheckBC;
begin
  BlockChain.Inquiries.CheckBlocks(0, BlockChain.Inquiries.MainChainCount);
end;

function THandlerCore.DoSendStartPacket: boolean;
var
  Packet: TPacket;
begin
  Result := True;
  Packet.CreatePacket(CMD_REQUEST_AUTH, []);
  if Net.SendPacket(Packet) = -1 then
    Result := false;
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
  ID, CheckID: UInt64;
  pubKey: TPublicKey;
  buf, bufEmpty, Data: TBytes;
begin
  Result := 0;
  Move(AData[0], ID, sizeOf(ID));
  Data := Copy(AData, sizeOf(ID), Length(AData) - sizeOf(ID));
  bufEmpty := Default (TPublicKey);
  buf := BlockChain.Inquiries.TryGetPublicKey(ID);
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
  ADecimals, Counter: integer;
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

  Counter := 1;
  try
    while Counter <= Length(ASymbol) do
    begin
      if not(ASymbol[Counter] in ['A' .. 'Z']) then
      begin
        Msg := 'System ifno: The name can contain only latin letters';
        UI.ShowMessage(Msg);
        Exit;
      end
      else
        inc(Counter);
    end;
  except
    Msg := 'System ifno: Error creating token';
    UI.ShowMessage(Msg);
    Exit;
  end;

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
  if (WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress) or (WalletID = 0) then
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

function THandlerCore.RegServiceWeb(Args: array of string): boolean;
var
  Packet: TPacket;
  AName: string;
  Counter: integer;
begin
  Result := false;

  if WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress then
    Exit;

  if Length(Args) <> 2 then
    Exit;

  AName := UpperCase(Args[1]);

  Counter := 1;
  while Counter <= Length(AName) do
  begin
    if not(AName[Counter] in ['0' .. '9', 'A' .. 'Z']) then
      Exit
    else
      inc(Counter);
  end;

  if BlockChain.Inquiries.TryGetServiceID(AName) > 0 then
    Exit;

  Packet.CreatePacket(CMD_REQUEST_NEW_SERVICE, BlockChain.Inquiries.CreateNewService(AName, WalletCore.CurrentWallet));
  Net.SendPacket(Packet);
  Result := True;
end;

function THandlerCore.RegServiceCmd(Args: array of string): boolean;
var
  Msg, AName, ResHash: string;
  Packet: TPacket;
  trxInfo: TBytes;
  Counter: integer;
begin
  Msg := 'Trying create new service';

  if WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress then
  begin
    Msg := 'System: Bad wallet, please open wallet.';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Length(Args) <> 2 then
  begin
    Msg := 'System ifno: Must be 1 keys and 1 params';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if Args[0] <> 'ns' then
  begin
    Msg := 'System ifno: Bad 1 key, must be ''-ns''';
    UI.ShowMessage(Msg);
    Exit;
  end;
  if (Length(Args[1]) > 30) or (Length(Args[1]) < 3) then
  begin
    Msg := 'System ifno: Bad ''-ns'' param, min length 3 chars, max length 30 chars';
    UI.ShowMessage(Msg);
    Exit;
  end;

  AName := UpperCase(Args[1]);
  Counter := 1;

  try
    while Counter <= Length(AName) do
    begin
      if not(AName[Counter] in ['0' .. '9', 'A' .. 'Z']) then
      begin
        Msg := 'System ifno: The name can contain only latin letters';
        UI.ShowMessage(Msg);
        Exit;
      end
      else
        inc(Counter);
    end;
  except
    Msg := 'System ifno: Error creating service';
    UI.ShowMessage(Msg);
    Exit;
  end;

  if BlockChain.Inquiries.TryGetServiceID(AName) > 0 then
  begin
    Msg := 'System ifno: Sorry but such a service already exists';
    UI.ShowMessage(Msg);
    Exit;
  end;

  try
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

    Packet.CreatePacket(CMD_REQUEST_NEW_SERVICE, trxInfo + BlockChain.Inquiries.CreateNewService(AName, WalletCore.CurrentWallet));
    Net.SendPacket(Packet);
    UI.ShowMessage(Msg);
    Result := True;
  except
    on e: Exception do
    begin
      Result := false;
      Msg := e.Message;
    end;
  end;
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

procedure THandlerCore.SaveConfig(snet: string);
var
  sconf: boolean;
begin
  sconf := FConfig.SaveConfigNet(snet);
end;

procedure THandlerCore.Restart;
var
  rest: TTools;
begin
  rest := TTools.Create;
  rest.Restart;
  ShutDown('');
end;

procedure THandlerCore.SetDefaultState;
begin
  NodeState := Config.NodeState;
end;

function THandlerCore.SetServiceDataCmd(ID: UInt64; Data: TSRData; var Sign: TSignedHash): boolean;
var
  Msg: string;
  Packet: TPacket;
begin
  Result := True;
  Msg := 'Trying create your Token';

  if WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress then
  begin
    Result := false;
    Msg := 'System: Bad wallet, please open wallet.';
    UI.ShowMessage(Msg);
    Exit;
  end;

  Packet.CreatePacket(CMD_REQUEST_SERVICE_DATA, BlockChain.Inquiries.SetServiceData(ID, Data, WalletCore.CurrentWallet));
  Net.SendPacket(Packet);
  UI.ShowMessage(Msg);
end;

function THandlerCore.SetServiceDataWeb(ID: UInt64; Data: TSRData): boolean;
var
  Packet: TPacket;
begin
  Result := True;

  if WalletCore.CurrentWallet.GetAddress = Default (Twallet).GetAddress then
    Exit(false);

  Packet.CreatePacket(CMD_REQUEST_SERVICE_DATA, BlockChain.Inquiries.SetServiceData(ID, Data, WalletCore.CurrentWallet));
  Net.SendPacket(Packet);
end;

procedure THandlerCore.ShutDown(const Msg: string = '');
begin
  UI.ShutDown(Msg);
end;

procedure THandlerCore.DoChangeNet;
begin
  Try
    FConsensusCore.free;
    FWalletCore.free;
    FWebServer.Stop;
    FWebServer.free;
    Fnet.free;
    FBlockChain.free;
  except
    on e: Exception do
    begin
      FLog.DoError('THandlerCore.DoChangeNet', e.Message);
      Exit;
    end;
  End;
  FBlockChain := TBlockChainCore.Create;
  Fnet := TNetCore.Create(Self, Config.ConnectTo, Config.ApprovedConnections);
  FWebServer := TWebServer.Create(Self);
  FWalletCore := TWalletCore.Create;
  FConsensusCore := TConsensusCore2.Create(Net, BlockChain, WalletCore, UI, Config, Self);

  NetState := Config.TypeNet;
  NodeState := Invalid;

  AppCore.ShowForm(ord(fWaiting), []);

end;

procedure THandlerCore.StartNode;
var
  Packet: TPacket;
begin
  if not Net.Start(0, Config.ServerPort, Config.ClientPort) then
    ShutDown(Trnaslator.GetPhrase(index147, CurrentLanguage));

  if Config.Server then
    WebServer.Start(Config.WebServerPort);

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
    if (NodeState = Speaker) and (ParamStr(1) = 'init') then
    begin
      BlockChain.Inquiries.DoMining(WalletCore.CurrentWallet, countblocks);
      UI.ShowMessage('System: DoMining accepted');
    end
    else
      UI.ShowMessage('System: Unexpected command');
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
      BlockChain.Inquiries.TryGetBalanceString(WalletCore.CurrentWallet.GetAddress, UpperCase(Args[1])));
//      FloatEToString(BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, UpperCase(Args[1]))));
  except
    UI.ShowMessage('System: Bad Args');
  end;
end;

procedure THandlerCore.GetOpenedWallet;
var
  Msg: string;
begin
  if WalletID = 0 then
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

function THandlerCore.GetServiceData(AName: TName): TBlockSRData;
begin
  var
  ID := BlockChain.Inquiries.TryGetServiceID(AName);
  Result := GetServiceData(ID);
end;

function THandlerCore.GetServiceDataByID(ID: UInt64): TArray<TServiceResultV0>;
begin
  Result := BlockChain.Inquiries.TryGetServiceDataByID(ID);
end;

function THandlerCore.GetServiceInfo(ID: UInt64): TServiceInfoV0;
begin
  Result := BlockChain.Inquiries.TryGetServiceInfo(ID);
end;

function THandlerCore.GetServiceData(ID: UInt64): TBlockSRData;
begin
  Result := BlockChain.Inquiries.GetServiceData(ID);
end;

function THandlerCore.GetTokenByName(ASymbol: String): TTokensInfoV0;
begin
  Result := BlockChain.Inquiries.TryGetTokenInfo(ASymbol);
end;

function THandlerCore.GetTransactioHistoryItems(AccID, UnixFrom, UnixTo: UInt64): TArray<TTransHistoryItem>;
begin
  Result := BlockChain.Inquiries.TryGetTransactionHistoryItems(AccID, UnixFrom, UnixTo);
end;

function THandlerCore.GetTransactionHistory(AID: UInt64; ATID: UInt64 = 0): TArray<string>;
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

function THandlerCore.TryGetTokensInfo(sort: string): TArray<TTokensInfoV0>;
begin
  Result := BlockChain.Inquiries.TryGetTokenInfoAll(sort);
end;

function THandlerCore.GetBalanceToken(AAddress: THash; ASymbol: String): Double;
begin
  Result := BlockChain.Inquiries.TryGetBalance(AAddress, ASymbol);
end;

function THandlerCore.GetCommissionsInfoAll: TArray<string>;
begin
  Result := BlockChain.Inquiries.TryGetCommissionsInfoAll;
end;

function THandlerCore.GetALLAccounts(sort: string): TArray<TAccountInfoV0>;
begin
  Result := BlockChain.Inquiries.TryGetALLAccounts(sort);
end;

function THandlerCore.GetLastMined: Int64;
begin
  Result := BlockChain.Inquiries.TryGetLastMined;
end;

function THandlerCore.GetCountOM: UInt64;
begin
  Result := BlockChain.Inquiries.TryGetCountOM;
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

function THandlerCore.GetALLServices(sort: string): TArray<TServiceInfoV0>;
begin
  Result := BlockChain.Inquiries.TryGetALLServices(sort);
end;

function THandlerCore.GetALLTransactions(sort: string): TArray<TTransHistoryItem>;
begin
  Result := BlockChain.Inquiries.TryGetALLTransactions(sort);
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
            WalletID := BlockChain.Inquiries.TryGetAccountID(WalletCore.CurrentWallet.GetAddress);
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
  if WalletID = 0 then
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
  if WalletID = 0 then
  begin
    Result := false;
    Exit;
  end;

  if BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, MainCoin) < 10000 then
  begin
    Result := false;
    Exit;
  end;

  Packet.CreatePacket(CMD_REQUEST_NEW_OWNER_MINING, BlockChain.Inquiries.CreateTrxNewTransfer(ResHash, MainCoin, 0,
    Round(10000 * Power(10, BlockChain.Inquiries.TryGetTokenDecimals(BlockChain.Inquiries.TryGetTokenID(MainCoin)))),
    WalletCore.CurrentWallet, True));
  Net.SendPacket(Packet);
end;

function THandlerCore.TryEasySendTransfer(var AResHash: string; ASymbol, AAddress, AAValue: string; var AError: integer;
  var AErrorMsg: string): boolean;
var
  Packet: TPacket;
  ResHash: string;
begin
  Result := false;
  var
  TokenID := BlockChain.Inquiries.TryGetTokenID(ASymbol);
  var
  decimal := BlockChain.Inquiries.TryGetTokenDecimals(TokenID);
  var
  FloatValue := StrToFloat(AAValue.Replace(OldDecimalSeparator, DecimalSeparator));
  var
  Address := BlockChain.Inquiries.TryGetAccountID(AAddress);
  var
    AValue: UInt64 := UInt64(Round(FloatValue * Power(10, decimal)));

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

  if (Address = NaN) or (WalletID = Address) then
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
      Result := false;
    end;
  end;

end;

function THandlerCore.TryDoChangeNet(TagNet: NativeInt; var Error: string): boolean;
begin
  try
    Result := Config.DoChangeConfigurate(TagNet);

  except
    on e: Exception do
    begin
      Result := false;
      Error := e.Message;
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
    Result := false;
    Error := 'This token already exists';
    Exit;
  end;

  if BlockChain.Inquiries.TryGetBalance(WalletCore.CurrentWallet.GetAddress, 'ORBC') < 1 then
  begin
    Result := false;
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
      Result := false;
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
      CreateToken(Args);
    CMD_CREATE_TRANSFER:
      CreateTransfer(Args);
    CMD_WHOAMI:
      GetOpenedWallet;
    CMD_GET_BALANCE:
      GetBalance(Args);
    CMD_CREATE_OM:
      TryBuyOM;
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
    CMD_REGSERVICE:
      RegServiceCmd(Args);
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
        var
        return := '';
        var
        Error := '';
        if connected then
        begin
          if CreateWallet(Args[0]) > 0 then
            return := WalletCore.CurrentWallet.GetAddress;
        end
        else
          Error := Trnaslator.GetPhrase(index147, CurrentLanguage);
        ACallback([return, Error]);
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
        var
        Error := '';
        var
        ID := BlockChain.Inquiries.TryGetAccountID(Args[0]);
        if connected then // connected?
        begin
          if (ID > 0) and (ID < NaN) then // inBC?
          begin
            if WalletCore.OpenWallet(Args[0], Args[1]) then
            begin
              WalletID := ID;
              return := 'OK';
            end
            else
              Error := Trnaslator.GetPhrase(index109, CurrentLanguage);
          end
          else
            Error := Trnaslator.GetPhrase(index148, CurrentLanguage);
        end
        else
          Error := Trnaslator.GetPhrase(index147, CurrentLanguage);
        ACallback([return, Error]);
      end;
    CMD_GUI_CHECK_NEW_WALLET:
      begin
        if BlockChain.Inquiries.TryGetAccountID(Args[0]) > 0 then
          ACallback([]);
      end;
    CMD_GUI_GET_BALANCES:
      begin
        var
        Data := BlockChain.Inquiries.GetBalances(WalletID);
        if WalletID = 0 then
          Data := [];
        var
        isOMOwner := BlockChain.Inquiries.TryGetFunctionAboutOwningOM(WalletID);
        if Length(Data) > 0 then
        begin
          if isOMOwner then
            ACallback(ParseDataBalances(Data) + ['OM', '1', '0'])
          else
            ACallback(ParseDataBalances(Data) + ['OM', '0', '0']);
        end
        else if isOMOwner then
          ACallback(['ORBC', '0', '0', 'OM', '1', '0'])
        else
          ACallback(['ORBC', '0', '0', 'OM', '0', '0'])
      end;
    CMD_GUI_CREATE_TRANSFER:
      begin
        var
          ErrorCode: integer;
        var
          HashTrx, Error: string;
        if TryEasySendTransfer(HashTrx, Args[0], Args[1], Args[2], ErrorCode, Error) then
          ACallback(['OK', HashTrx])
        else
          ACallback(['BAD', Error]);
      end;
    CMD_GUI_TRANSACTION_HISTORY:
      begin
        if trim(Args[0]) = 'OM' then
          ACallback(GetTransactionHistory(WalletID, GetTokenID(trim(Args[0]))))
        else
          ACallback(GetTransactionHistory(WalletID, GetTokenID(trim(Args[0]))));
      end;
    CMD_GUI_GET_WORDS:
      begin
        ACallback([WalletCore.CurrentWallet.GetWords]);
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

    CMD_GUI_DO_CHANGE_CONFIG:
      begin
        var
          Error: String;
        if TryDoChangeNet(StrToInt(Args[0]), Error) then
          ACallback(['OK'])
        else
        begin
          ACallback(['BAD', Error]);
        end;
      end;

    CMD_GUI_DO_CHANGE_NET:
      begin
        DoChangeNet;
      end;

    CMD_GUI_DO_CHANGE_NET_STATE:
      begin
        if Args[0] = 'Validator' then
        begin
          if GetMyIP <> Config.StaticIP then
          begin
            ACallback(['BAD', Trnaslator.GetPhrase(index131, CurrentLanguage), Trnaslator.GetPhrase(index129, CurrentLanguage)]);
            Exit;
          end;

          ConsensusCore.Active := True;
          if ConsensusCore.Active then
          begin
            SaveConfig('Validator');
            ACallback(['OK', Trnaslator.GetPhrase(index132, CurrentLanguage)]);
          end
          else
          begin
            SaveConfig('FullNode');
            ACallback(['BAD', Trnaslator.GetPhrase(index131, CurrentLanguage), Trnaslator.GetPhrase(index130, CurrentLanguage)]);
          end;
        end;

        if Args[0] = 'FullNode' then
        begin
          ConsensusCore.Active := false;
          SaveConfig('FullNode');
          ACallback(['OK', Trnaslator.GetPhrase(index131, CurrentLanguage)]);
        end;
      end;

    CMD_GUI_DO_SAVE_CONFIG:
      begin
        SaveConfig(Args[0]);
      end;

    CMD_GUI_DO_RESTART:
      begin
        Restart;
      end;
    CMD_GUI_CHECK_ACC_BY_MINING:
      begin

        if CheckAccIDByMining(0) then
          ACallback(['OK', Config.NodeStateAsStr])
        else
          ACallback(['BAD']);
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
      Request.free;
    if Assigned(Response) then
      Response.free;
  end;
end;

procedure THandlerCore.HandleReceiveTCPData(From: IClient; const ABytes: TBytes);
var
  requestPacket: TPacket;
  responsePacket: TPacket;
  Packet: TPacket;
begin
  try
    requestPacket := ABytes;
    case requestPacket.PacketType of
      CMD_REQUEST_AUTH:
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

          SetDefaultState;
          UI.ShowMessage('System Check: You have correct protocol');
          Packet.CreatePacket(CMD_REQUEST_VERSION, []);
          From.SendMessage(Packet);
          UI.ShowMessage('System Check: Check version...');
          Notifyer.DoEvent(nOnOkAuth);
          From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_AUTH_OK: CMD_REQUEST_VERSION');
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
              intToStr(requestPacket.PacketBody[0]) + '.' + intToStr(requestPacket.PacketBody[1]) + '.' + intToStr(requestPacket.PacketBody[2]));
            UI.ShutDown('System Check: Bad Version');
            Notifyer.DoEvent(nOnBadVersion);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_VERSION: EXIT');
          end;
        end;
      CMD_REQUEST_COUNT_BLOCK:
        begin
          responsePacket.CreatePacket(CMD_RESPONSE_COUNT_BLOCK, BlockChain.Inquiries.MainChainCount);
          From.SendMessage(responsePacket);
          From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_COUNT_BLOCK: CMD_RESPONSE_COUNT_BLOCK');
        end;
      CMD_RESPONSE_COUNT_BLOCK:
        begin
          From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_COUNT_BLOCK IDNode: ' + From.IDNode.AsString);
          if not isValid then
            Exit;
          var
            CountMainBlock: UInt64;

          Move(requestPacket.PacketBody[0], CountMainBlock, requestPacket.PacketSize);
          UI.ShowMessage('System Check: End Check');
          From.DoLog('CMD_RESPONSE_COUNT_BLOCK :CountMainBlock', CountMainBlock.AsString);
          if CountMainBlock < BlockChain.Inquiries.MainChainCount then
          begin
            ConsensusCore.EventEndDownloadBlocks(false);
            ConsensusCore.Active := false;
            BlockChain.Inquiries.DoCorruptedBC;
            ShutDown('System: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
            From.DoLog('HandleReceiveTCPData',
              'CMD_RESPONSE_COUNT_BLOCK: Sorry, your blockchain corrupted. Please restart application, for download blockchain now.' +
              '  There are more blocks on the MAIN chain than the Speaker');
            Exit;
          end;
          From.DoLog('CMD_RESPONSE_COUNT_BLOCK :CountMainBlock < BlockChain.Inquiries.MainChainCount', CountMainBlock.AsString);
          if CountMainBlock = BlockChain.Inquiries.MainChainCount then
          begin
            From.DoLog('CMD_RESPONSE_COUNT_BLOCK :CountMainBlock = BlockChain.Inquiries.MainChainCount', CountMainBlock.AsString);

            UI.ShowMessage('System: Congratulations, you have all blocks: ' + BlockChain.Inquiries.MainChainCount.AsString);
            if not BlockChain.Inquiries.CheckBlocks(0, BlockChain.Inquiries.MainChainCount) then
            begin
              ConsensusCore.EventEndDownloadBlocks(false);
              ConsensusCore.Active := false;
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
          From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_BLOCK_FROM IDNode: ' + From.IDNode.AsString);
          if (Length(requestPacket.PacketBody) > 0) and (requestPacket.PacketBody[0] = 0) then
          begin
            var
              Error: string;
            if BlockChain.Inquiries.SetNewBlocks(requestPacket.PacketBody, Error) then
            begin
              From.DoLog('HandleReceiveTCPData', Error);
              Exit;
            end;
            var
              controlSize: UInt64;
            Move(requestPacket.PacketBody[1], controlSize, sizeOf(controlSize));
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_BLOCK_FROM controlSize: ' + controlSize.AsString);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_BLOCK_FROM BlockChain.Inquiries.MainChainCount: ' +
              BlockChain.Inquiries.MainChainCount.AsString);

            if (BlockChain.Inquiries.MainChainCount <> controlSize) and not BlockChain.Inquiries.CheckBlocks(0, BlockChain.Inquiries.MainChainCount)
            then
            begin
              ConsensusCore.EventEndDownloadBlocks(false);
              ConsensusCore.Active := false;
              BlockChain.Inquiries.DoCorruptedBC;
              ShutDown('System: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');
              From.DoLog('HandleReceiveTCPData',
                'CMD_RESPONSE_GET_BLOCK_FROM: Sorry, your blockchain corrupted. Please restart application, for download blockchain now');

              Exit;
            end;

            Notifyer.DoEvent(nOnEndDownloadBlocks);
            UI.ShowMessage('System: End Download blocks');
            ConsensusCore.EventEndDownloadBlocks(True);
            responsePacket.CreatePacket(CMD_REQUEST_COUNT_BLOCK, BlockChain.Inquiries.MainChainCount);
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_BLOCK_FROM: CMD_REQUEST_COUNT_BLOCK');
            From.SendMessage(responsePacket);
          end;
        end;
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
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_CC, [ord(false)]);
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
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_TOKEN, [ord(false)]);
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
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_TRANSFER, [ord(false)]);
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
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_OWNER_MINING, [ord(false)]);
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

      CMD_RESPONSE_GET_NEW_BLOCKS:
        begin
          var
            controlSize: UInt64;
          controlSize.SetBytes(Copy(requestPacket.PacketBody, 1, sizeOf(controlSize)));
          From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_NEW_BLOCKS: RECIVED BLOCKS ' + controlSize.AsString + ' > COUN BLOCKS ' +
            BlockChain.Inquiries.MainChainCount.AsString + 'From:' + From.GetIP);
          if controlSize > BlockChain.Inquiries.MainChainCount then
          begin
            if (requestPacket.PacketBody[0] = 0) then
            begin
              var
                Error: string;
              if BlockChain.Inquiries.SetNewBlocks(requestPacket.PacketBody, Error) then
              begin
                From.DoLog('BlockChain.Inquiries.SetNewBlocks', Error);
                Exit;
              end;

              Notifyer.DoEvent(nOnEndDownloadBlocks);
              UI.ShowMessage('System: data blocks received');

            end;
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_NEW_BLOCKS:  BLOCK ACCEPTED - GOOD');

            if (NodeState = Validator) then
              Net.SendAll(requestPacket);

          end
          else
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_GET_NEW_BLOCKS:  - BAD');
          ConsensusCore.EventEndDownloadBlocks(True);
        end;
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
      CMD_REQUEST_ID_IN_SYSTEM:
        begin
        end;
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
              ID: UInt64;
            ID.SetBytes(requestPacket.PacketBody);
            if (ID > 0) then
            begin
              NodeState := Validator;
              From.IDNode := ID;
            end
            else
              NodeState := FullNode;

            responsePacket.CreatePacket(CMD_REQUEST_GET_VALIDATORS, []);
            From.SendMessage(responsePacket);
          end;
        end;

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
              responsePacket.CreatePacket(CMD_RESPONSE_CREATE_TOKEN_WITH_COMMISSION, [ord(false)]);

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

      CMD_REQUEST_NEW_SERVICE:
        begin
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            var
              countblocks: UInt64;
            if BlockChain.Inquiries.SetTrxCacheChain(Service, requestPacket.PacketBody, WalletCore.CurrentWallet, countblocks) then
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_SERVICE, [ord(True)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_SERVICE: CMD_RESPONSE_NEW_SERVICE - TRUE');
            end
            else
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_NEW_SERVICE, [ord(false)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_NEW_SERVICE: CMD_RESPONSE_NEW_SERVICE - FALSE');
            end;
            From.SendMessage(responsePacket);
          end;
        end;

      CMD_RESPONSE_NEW_SERVICE:
        begin
          if not isValid then
            Exit;
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your service accepted! Wait for confirmation.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_SERVICE: ' + WalletCore.CurrentWallet.GetAddress + ' - GOOD');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your service not accepted.');
            UI.ShowMessage('System: Please, try again later.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_NEW_SERVICE: ' + WalletCore.CurrentWallet.GetAddress + ' - BAD');
          end;
        end;

      CMD_REQUEST_SERVICE_DATA:
        begin
          if (NodeState = Speaker) or (NodeState = Validator) then
          begin
            var
              countblocks: UInt64;
            if BlockChain.Inquiries.SetTrxCacheChain(ServiceResult, requestPacket.PacketBody, WalletCore.CurrentWallet, countblocks) then
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_SERVICE_DATA, [ord(True)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_SERVICE_DATA: CMD_RESPONSE_SERVICE_DATA - TRUE');
            end
            else
            begin
              responsePacket.CreatePacket(CMD_RESPONSE_SERVICE_DATA, [ord(false)]);
              From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_SERVICE_DATA: CMD_RESPONSE_SERVICE_DATA - FALSE');
            end;
            From.SendMessage(responsePacket);
          end;
        end;

      CMD_RESPONSE_SERVICE_DATA:
        begin
          if not isValid then
            Exit;
          if requestPacket.PacketBody[0] = 1 then
          begin
            UI.ShowMessage('System: Ok. Your data accepted! Wait for confirmation.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_SERVICE_DATA: ' + WalletCore.CurrentWallet.GetAddress + ' - GOOD');
          end
          else
          begin
            UI.ShowMessage('System: Bad. Your data not accepted.');
            UI.ShowMessage('System: Please, try again later.');
            From.DoLog('HandleReceiveTCPData', 'CMD_RESPONSE_SERVICE_DATA: ' + WalletCore.CurrentWallet.GetAddress + ' - BAD');
          end;
        end;
      CMD_REQUEST_GET_BLOCK_V2:
        begin
          var
            buf: TBytes;
          var
            FromBlock: UInt64;
          Move(requestPacket.PacketBody[0], FromBlock, requestPacket.PacketSize);
          buf := BlockChain.Inquiries.GetBlocksFrom(FromBlock); //
          responsePacket.CreatePacket(CMD_RESPONSE_GET_NEW_BLOCKS, buf);
          From.SendMessage(responsePacket);
          From.DoLog('HandleReceiveTCPData', 'CMD_REQUEST_GET_BLOCK_V2: CMD_RESPONSE_GET_NEW_BLOCKS');
        end;
      CMD_REQUEST_HEART_BEAT:
        begin
          responsePacket.CreatePacket(CMD_RESPONSE_HEART_BEAT, []);
          From.SendMessage(responsePacket);
        end;
      CMD_RESPONSE_HEART_BEAT:
        begin
        end;

      TP_VALIDATOR .. TP_VALIDATOR_OFF:
        begin
          if ConsensusCore.Active then
          begin
            try
              ConsensusCore.ReceiveData(From, requestPacket.PacketBody);
            except
              on e: Exception do
              begin
                UI.ShowMessage(' >>> ERROR FConsensusCore.ReceiveData. <<<' + '[' + intToStr(From.IDNode) + '] ' + 'err: ' + e.Message);
              end;
            end;
          end;
        end;

    end;
  except
    on e: Exception do
      From.DoLog('HandleReceiveTCPData', e.Message + '   IDNode: ' + From.IDNode.AsString);
  end;
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
          WalletID := BlockChain.Inquiries.TryGetAccountID(Args[0]);
          if WalletID > 0 then
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
        if AccID = 0 then
          Data := [];
        var
        isOMOwner := BlockChain.Inquiries.TryGetFunctionAboutOwningOM(AccID);
        if Length(Data) > 0 then
        begin
          if isOMOwner then
            ACallback(ParseDataBalances(Data) + ['OM', '1', '0'])
          else
            ACallback(ParseDataBalances(Data) + ['OM', '0', '0']);
        end
        else if isOMOwner then
          ACallback(['ORBC', '0', '0', 'OM', '1', '0'])
        else
          ACallback(['ORBC', '0', '0', 'OM', '0', '0'])
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
    CMD_WEB_REG_SERVICE:
      begin
        var
        Res := RegServiceWeb([Args[0], Args[1]]);

        if Res = True then
          ACallback(['OK', Args[1]])
        else
          ACallback(['BAD']);
      end;
    CMD_WEB_SET_SERVICE_DATA:
      begin
        var
          ID: UInt64 := StrToUInt64(Args[0]);
        var
        Res := SetServiceDataWeb(ID, GetStringIntoTSRData(Args[1]));

        if Res = True then
          ACallback(['OK', Args[0]])
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
      flag := false;
      WalletCore.CloseWallet;
    end
    else
      WalletID := BlockChain.Inquiries.TryGetAccountID(Config.WalletName);

    if not flag then
      NodeState := FullNode;

    UI.ShowMessage('System: Node State - ' + GetEnumName(TypeInfo(TNodeState), ord(NodeState)));

    if not flag then
      UI.ShowMessage('System: Node have not active wallet')
    else
      UI.ShowMessage('System: Node have active wallet - ' + Config.WalletName);
  end;

  if (WalletID > 0) and ((NodeState = Validator)
    // or (NodeState = Speaker)
{$IFDEF DEBUG}
    or (ParamStr(1) = 'init')
{$ENDIF}
    ) and CheckLocalHost() then
  begin
    ConsensusCore.ValID := WalletID;
    ConsensusCore.ServerIPv4 := Config.StaticIP;
    ConsensusCore.ServerPort := Config.ServerPort;
    ConsensusCore.Active := True;
  end
  else
  begin

  end;

  // ConsensusCore.DoConfigurate;
end;

function THandlerCore.CheckLocalHost(): boolean;
begin
  if ((Config.ConnectTo[0] = '127.0.0.1') and (Config.StaticIP = '127.0.0.1')) or
    ((Config.ConnectTo[0] <> '127.0.0.1') and (Config.StaticIP <> '127.0.0.1')) then
  begin
    Result := True;
  end
  else
  begin
    Result := false;
  end;
end;

function THandlerCore.ParseDataBalances(AData: TBytes): TArray<string>;
var
  Counter, decimal: integer;
  TokenID: UInt64;
  firstBalance: UInt64;
  balance: string;
  ExistORBC: boolean;
begin
  Result := [];
  Counter := 0;
  ExistORBC := false;
  while Counter < Length(AData) do
  begin
    Move(AData[Counter], TokenID, sizeOf(TokenID));
    inc(Counter, sizeOf(UInt64));
    Move(AData[Counter], firstBalance, sizeOf(firstBalance));
    inc(Counter, sizeOf(UInt64));
    decimal := BlockChain.Inquiries.TryGetTokenDecimals(TokenID);
    balance := firstBalance.AsString;

    if decimal > 0 then
    begin
      while Length(balance) < decimal do
        balance := '0' + balance;

      balance := balance.Insert(Length(balance) - decimal, DecimalSeparator);
      if balance.StartsWith(DecimalSeparator) then
        balance := '0' + balance;

      while balance.EndsWith('0') do
      begin
        balance := Copy(balance, 1, Length(balance) - 1);
        if balance.EndsWith(DecimalSeparator) then
        begin
          balance := Copy(balance, 1, Length(balance) - 1);
          break;
        end;
      end;
    end;

    var
      flags: TReplaceFlags;
    flags := [rfReplaceAll];

    if TokenID <> 1 then
    begin
      Result := Result + [StringReplace(BlockChain.Inquiries.TryGetTokenSymbol(TokenID), OldDecimalSeparator, DecimalSeparator, flags)] +
        [StringReplace(balance, OldDecimalSeparator, DecimalSeparator, flags)] + [decimal.ToString];
    end
    else
    begin
      Result := [StringReplace(BlockChain.Inquiries.TryGetTokenSymbol(TokenID), OldDecimalSeparator, DecimalSeparator, flags)] +
        [StringReplace(balance, OldDecimalSeparator, DecimalSeparator, flags)] + [decimal.ToString];
      ExistORBC := True;
    end;
  end;
  if not ExistORBC then
    Result := ['ORBC', '0', '8'] + Result;
end;

end.
