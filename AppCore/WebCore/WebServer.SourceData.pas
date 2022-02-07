unit WebServer.SourceData;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.DateUtils,
  System.TypInfo,
  System.Math,
  System.Hash,
  System.JSON,
  BlockChain.Account,
  BlockChain.Core,
  BlockChain.Tokens,
  BlockChain.Transfer,
  BlockChain.ServiceResult,
  App.Globals,
  App.Types,
  App.Meta,
  App.Log,
  Wallet.Core,
  WebServer.HTTPTypes,
  WebServer.Abstractions,
  Crypto.Encoding,
  BlockChain.Types,
  BlockChain.Service;

type
  TBlockChainSource = class(TInterfacedObject, IDataSource)
  private
    BC: TBlockChainCore;
    WC: TWalletCore;

    SL: TStringList;
    Res: Boolean;
    CA, Words, Reason, addr: String;
    JSONBalances: TJSONObject;

    procedure CallBack(AArgs: TArray<string>);
    procedure CallBackCreateCrypto(AArgs: TArray<string>);
    procedure CallBackNewTrans(AArgs: TArray<string>);
    procedure CallBackBuyOM(AArgs: TArray<string>);
    procedure CallBackBalances(AArgs: TArray<string>);
    procedure CallBackNewService(AArgs: TArray<string>);
    procedure GetMyAddress(AArgs: TArray<string>);
    procedure NewTokenCallBack(AArgs: TArray<string>);
    procedure TryOpenWalletCallBack(AArgs: TArray<string>);
    procedure SetWords(AArray: TArray<string>);

  private type
    TSortType = (stDateTime, stBlockNumber, stByToken, stSent, stReceived);
  public
    function GenNewCrypto(const Password: String): TJSONObject;
    function GenNewTransaction(const FAddress, FPass, FTo, FToken, FAmount: String; FFee: Double = 0): TJSONObject;
    function CheckTransaction(const FOwnerSign: String): TJSONObject;
    function GenNewToken(const FAddress, FPass, FName, FSymbol: String; FEmission, FCapacity: UInt64): TJSONObject;
    function BuyOM(const FAddress, FPass: String): TJSONObject;
    function CheckOM(const Address: String): TJSONObject;
    function OpenWallet(const Address, Pass: String): TJSONObject;
    function RestoreCryptoContainerKeys(Keys: TStrings; Pass: String): TJSONObject;
    function CheckCryptoContainerKeys(Keys: TStrings): TJSONObject;
    function GetAccBalances(const Address: String): TJSONObject;
    function GetAccData(const Address: String; Tokens: TStrings): TJSONObject;
    function GetAccDataDetails(const Tab, Address: String; Tokens: TStrings; const PageID, Count: Integer; TransType: TTransType = All;
      DateFrom: String = ''; DateTo: String = ''): TJSONObject;
    function GetTokenListData(const Address: String): TJSONObject;
    function GetGlobalData(const Name: String; const PageID, Count: Integer; const SortBy: String = 'datetime'; const Inverse: Boolean = False)
      : TJSONObject;
    function GetTransData(const Hash: String): TJSONObject;
    function GetTokenInfoData(const Symbol: String): TJSONObject;
    function GetWalletBalance(const Address, Token: String): TJSONObject;
    function GetTokenTransactions(const Tab, Symbol: String; const PageID, Count: Integer): TJSONObject;
    function GetStatisticsData(const Tab: String; DateFrom: String = ''; DateTo: String = ''; const Step: Int64 = 86400): TJSONObject;
    function GetMiningData: TJSONObject;
    function RegNewService(const FAddress, FPass, Name: String): TJSONObject;
    function SetServiceData(const FAddress, FPass, Name: String; FData: TSRData): TJSONObject;
    function GetServiceData(const Name: String): TJSONObject;
    function GetServiceInfo(const Name: String): TJSONObject;

    constructor Create(ABlockChain: TBlockChainCore; AWalletCore: TWalletCore);
    destructor Destroy;
  end;

var
  FRealSource: TBlockChainSource;

implementation

{ TRealSource }

function TBlockChainSource.BuyOM(const FAddress, FPass: String): TJSONObject;
begin
try
  Result := TJSONObject.Create;

  Res := True;

  AppCore.GetHandler.HandleWebDataControl(CMD_GUI_OPEN_WALLET, [FAddress, FPass], TryOpenWalletCallBack);

  if not Res then
  begin
    Res := False;
    Reason := 'bad address or password';
  end
  else
  begin
    AppCore.GetHandler.HandleWebDataControl(CMD_GUI_GET_MY_ADDRESS, [], GetMyAddress);
    if BC.Inquiries.TryGetBalance(Reason, 'ORBC') < 10000 then
    begin
      Res := False;
      Result.AddPair('item', 'balance');
      Reason := 'not enough ORBC';
    end;
    if BC.Inquiries.TryGetFunctionAboutOwningOM(WalletID) then
    begin
      Res := False;
      Reason := 'you are already owner of OM';
    end;
  end;

  if Res then
    AppCore.GetHandler.HandleWebDataControl(CMD_GUI_BUY_OM, [], CallBackBuyOM);

  Result.AddPair('success', TJSONBool.Create(Res));
  if not Res then
    Result.AddPair('error', Reason);
except
  WebServerLog.DoError('SourceData.BuyOM','procedureError');
end;
end;

procedure TBlockChainSource.CallBack(AArgs: TArray<string>);
begin
try
  if AArgs[0] = 'OK' then
  begin
    Res := True;
  end
  else
    Res := False;
except
  WebServerLog.DoError('SourceData.CallBack','procedureError');
end;
end;

procedure TBlockChainSource.CallBackBalances(AArgs: TArray<string>);
var
  Counter: Integer;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
try
  JSONBalances := TJSONObject.Create;

  Counter := 0;
  if Length(AArgs) > 0 then
  begin
    JSONArr := TJSONArray.Create;

    while Counter < Length(AArgs) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('symbol', Trim(AArgs[Counter]));
      Inc(Counter);
      JSONNestedObject.AddPair('value', AArgs[Counter]);
      Inc(Counter);
      Inc(Counter);
    end;

    JSONBalances.AddPair('balances', JSONArr);
  end;

except
  WebServerLog.DoError('SourceData.CallBackBalances','procedureError');
end;
end;

procedure TBlockChainSource.CallBackBuyOM(AArgs: TArray<string>);
begin
try
  Res := AArgs[0] = 'OK';
  if not Res then
    Reason := 'Sorry, your transaction was not completed, please try again later';

except
  WebServerLog.DoError('SourceData.CallBackBuyOM','procedureError');
end;
end;

procedure TBlockChainSource.CallBackCreateCrypto(AArgs: TArray<string>);
begin
try
  CA := AArgs[0];
  Handler.HandleWebDataControl(CMD_GUI_GET_WORDS, [], SetWords);
except
  WebServerLog.DoError('SourceData.CallBackCreateCrypto','procedureError');
end;
end;

procedure TBlockChainSource.CallBackNewService(AArgs: TArray<string>);
begin
try
  Res := AArgs[0] = 'OK';
  if not Res then
    Reason := 'service with the specified name already exists';
except
  WebServerLog.DoError('SourceData.CallBackNewService','procedureError');
end;
end;

procedure TBlockChainSource.CallBackNewTrans(AArgs: TArray<string>);
begin
try
  Res := AArgs[0] = 'OK';
  CA := AArgs[1];


except
  WebServerLog.DoError('SourceData.CallBackNewTrans','procedureError');
end;
end;

function TBlockChainSource.CheckCryptoContainerKeys(Keys: TStrings): TJSONObject;
var
  KeysStr, Key: String;
  ind: Integer;
begin
try

  Result := TJSONObject.Create;

  KeysStr := '';
  for Key in Keys do
    KeysStr := KeysStr + ' ' + Key;

  Handler.HandleWebDataControl(CMD_WEB_CHECK_SEED_PHRASE, [Trim(KeysStr).ToUpper, ''], CallBack);
  Result.AddPair('result', TJSONBool.Create(Res));
  if Res then
    Result.AddPair('address', addr)
  else
    Result.AddPair('error', 'incorrect words');

except
  WebServerLog.DoError('SourceData.CheckCryptoContainerKeys','procedureError');
end;
end;

function TBlockChainSource.CheckOM(const Address: String): TJSONObject;
var
  AccID: UInt64;
begin
try

  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit
  else
    AccID := BC.Inquiries.TryGetAccountID(Address);

  Result.AddPair('om_holder', TJSONBool.Create(BC.Inquiries.TryGetFunctionAboutOwningOM(AccID)));

except
  WebServerLog.DoError('SourceData.CheckOM','procedureError');
end;
end;

function TBlockChainSource.CheckTransaction(const FOwnerSign: String): TJSONObject;
var
  TRXInfo: TArray<String>;
begin
try

  Result := TJSONObject.Create;

  TRXInfo := BC.Inquiries.TryGetTransInfoByOwnerSign(FOwnerSign);
  if Length(TRXInfo) <> 0 then
  begin
    Result.AddPair('status', 'confirmed');
    Result.AddPair('owner_sign', TRXInfo[0]);
    Result.AddPair('unix_time', TRXInfo[2]);
    Result.AddPair('from', BC.Inquiries.TryGetAccountAddress(TRXInfo[4].ToInt64));
    Result.AddPair('to', BC.Inquiries.TryGetAccountAddress(TRXInfo[6].ToInt64));
    Result.AddPair('amount', FloatEToString(BC.Inquiries.GetVolumeFromAmountToken(TRXInfo[8].ToInt64, TRXInfo[10].ToInt64)));
    Result.AddPair('token', Trim(BC.Inquiries.TryGetTokenSymbol(TRXInfo[10].ToInt64)));
  end
  else
    Result.AddPair('status', 'not confirmed or does not exist');

except
  WebServerLog.DoError('SourceData.CheckTransaction','procedureError');
end;
end;

function TBlockChainSource.RegNewService(const FAddress, FPass, Name: String): TJSONObject;
begin
try

  Result := TJSONObject.Create;

  Res := True;

  AppCore.GetHandler.HandleWebDataControl(CMD_GUI_OPEN_WALLET, [FAddress, FPass], TryOpenWalletCallBack);

  if not Res then
  begin
    Reason := 'bad address or password';
  end
  else
  begin
    Handler.HandleWebDataControl(CMD_WEB_REG_SERVICE, ['nameservice',Name], CallBackNewService);
  end;

  Result.AddPair('result', TJSONBool.Create(Res));
  if not Res then
    Result.AddPair('error', Reason);

except
  WebServerLog.DoError('SourceData.RegNewService','procedureError');
end;
end;

function TBlockChainSource.RestoreCryptoContainerKeys(Keys: TStrings; Pass: String): TJSONObject;
var
  KeysStr, Key: String;
  ind: Integer;
  Wallets: TArray<string>;
begin
try

  Result := TJSONObject.Create;

  KeysStr := '';
  for Key in Keys do
    KeysStr := KeysStr + ' ' + Key;

  Handler.HandleWebDataControl(CMD_GUI_SET_WORDS, [Trim(KeysStr).ToUpper, Pass], CallBack);
  if Res then
  begin
    Key := WC.GetWallets;
    ind := Key.LastIndexOf(#$D#$A);
    Wallets := SplitString(WC.GetWallets, #$D#$A);

    Res := BC.Inquiries.CheckAddress(Wallets[0]);

    Result.AddPair('result', TJSONBool.Create(Res));
    if Res then
      Result.AddPair('address', Wallets[0])
    else
    begin
      WC.RemoveWallet(Wallets[0]);
      Result.AddPair('error', 'address does not exists');
    end;
  end else
    Result.AddPair('error', 'incorrect words');
except
  WebServerLog.DoError('SourceData.RestoreCryptoContainerKeys','procedureError');
end;
end;

constructor TBlockChainSource.Create(ABlockChain: TBlockChainCore; AWalletCore: TWalletCore);
begin
  BC := ABlockChain;
  WC := AWalletCore;
end;

destructor TBlockChainSource.Destroy;
begin
  SL.Clear;
  SL.Free;
end;

function TBlockChainSource.GenNewCrypto(const Password: String): TJSONObject;
begin
try

  Result := TJSONObject.Create;

  Handler.HandleWebDataControl(CMD_GUI_CREATE_WALLET, [Password], CallBackCreateCrypto);

  Result.AddPair('address', CA);
  Result.AddPair('words', Words);

except
  WebServerLog.DoError('SourceData.GenNewCrypto','procedureError');
end;
end;

function TBlockChainSource.GenNewToken(const FAddress, FPass, FName, FSymbol: String; FEmission, FCapacity: UInt64): TJSONObject;
begin
try
  Result := TJSONObject.Create;

  Res := True;

  AppCore.GetHandler.HandleWebDataControl(CMD_GUI_OPEN_WALLET, [FAddress, FPass], TryOpenWalletCallBack);

  if not Res then
  begin
    Result.AddPair('item', 'address');
    Reason := 'bad address or password';
    Res := False;
  end
  else if BC.Inquiries.TryCheckIfTokenExists(FSymbol) then
  begin
    Result.AddPair('item', 'symbol');
    Reason := 'this token already exists';
    Res := False;
  end
  else if BC.Inquiries.TryGetBalance(BC.Inquiries.TryGetAccountAddress(WalletID), 'ORBC') < 1 then
  begin
    Result.AddPair('item', 'balance');
    Reason := 'not enough ORBC';
    Res := False;
  end
  else
    AppCore.GetHandler.HandleWebDataControl(CMD_GUI_CREATE_TOKEN_WITH_COMMISSION, [Trim(FSymbol), Trim(FName), IntToStr(FCapacity),
      IntToStr(FEmission)], NewTokenCallBack);

  Result.AddPair('success', TJSONBool.Create(Res));
  if Res then
  begin
    Result.AddPair('name', FName);
    Result.AddPair('symbol', FSymbol);
    Result.AddPair('emission', TJSONNumber.Create(FEmission));
    Result.AddPair('capacity', TJSONNumber.Create(FCapacity));
  end
  else
    Result.AddPair('error', Reason);

except
  WebServerLog.DoError('SourceData.GenNewToken','procedureError');
end;
end;

function TBlockChainSource.GenNewTransaction(const FAddress, FPass, FTo, FToken, FAmount: String; FFee: Double = 0): TJSONObject;
begin
try

  Result := TJSONObject.Create;

  Res := True;

  AppCore.GetHandler.HandleWebDataControl(CMD_GUI_OPEN_WALLET, [FAddress, FPass], TryOpenWalletCallBack);

  if not Res then
  begin
    Result.AddPair('success', TJSONBool.Create(False));
    Result.AddPair('error', 'bad address or password');
  end
  else
    if not BC.Inquiries.CheckAddress(FTo) then
    begin
      Result.AddPair('success', TJSONBool.Create(False));
      Result.AddPair('item', 'to');
      Result.AddPair('error', 'address is not exists');
      Res := False;
    end
    else if not BC.Inquiries.TryCheckIfTokenExists(FToken) then
    begin
      Result.AddPair('success', TJSONBool.Create(False));
      Result.AddPair('item', 'token');
      Result.AddPair('error', 'token is not exists');
      Res := False;
    end
    else if FAddress = FTo then
    begin
      Result.AddPair('success', TJSONBool.Create(False));
      Result.AddPair('item', 'to');
      Result.AddPair('error', 'unable to send to current wallet');
      Res := False;
    end
    else

    if BC.Inquiries.TryGetBalance(WC.CurrentWallet.GetAddress, FToken) < FAmount.ToDouble then
    begin
      Result.AddPair('success', TJSONBool.Create(False));
      Result.AddPair('item', 'amount');
      Result.AddPair('error', 'not enough funds');
      Res := False;
    end;

  if not Res then
    exit
  else
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_CREATE_TRANSFER, [Trim(FToken), FTo, FAmount.Replace('.', ',')], CallBackNewTrans);

  Result.AddPair('success', TJSONBool.Create(Res));
  if Res then
    Result.AddPair('owner_sign', CA)
  else
    Result.AddPair('error', 'waiting for complete');

except
  WebServerLog.DoError('SourceData.GenNewTransaction','procedureError');
end;
end;

function TBlockChainSource.GetAccBalances(const Address: String): TJSONObject;
var
  AccID: UInt64;
begin
try

  if not BC.Inquiries.CheckAddress(Address) then
    exit(nil)
  else
    AccID := BC.Inquiries.TryGetAccountID(Address);

  AppCore.GetHandler.HandleWebDataControl(CMD_GUI_GET_BALANCES, [UIntToStr(AccID)], CallBackBalances);

  Result := JSONBalances;

except
  WebServerLog.DoError('SourceData.GetAccBalances','procedureError');
end;
end;

function TBlockChainSource.GetAccData(const Address: String; Tokens: TStrings): TJSONObject;
var
  TransCount: Integer;
  Received, Sent, AccID, TokenID, Decimals: UInt64;
  FToken: String;
  FTokenInfo: TTokensInfoV0;
  FTrans: TTransHistoryItem;
  FAcc: TAccountInfoV0;
  FAccTransactions: TArray<TTransHistoryItem>;
begin
try

  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit
  else
    FAcc := BC.Inquiries.TryGetAccountInfo(Address);

  Result.AddPair('address', FAcc.Address);
  AccID := BC.Inquiries.TryGetAccountID(Address);
  Result.AddPair('id', TJSONNumber.Create(AccID));

  if (Tokens[0] = 'ALL') then
  begin
    SetLength(Tokens, 0);
    for FTokenInfo in BC.Inquiries.TryGetTokenInfoAll do
      Tokens := Tokens + [Trim(String(FTokenInfo.Symbol)).ToUpper];
  end;

  try
    SL := TStringList.Create;
    SL.Clear;
    SL.Sorted := True;
    SL.Duplicates := TDuplicates.dupIgnore;

    TransCount := 0;
    FAccTransactions := BC.Inquiries.TryGetTransactionHistoryItems(AccID, 0, DateTimeToUnix(Now, False) + 1);
    for FToken in Tokens do
      for FTrans in FAccTransactions do
        if (FToken.ToUpper = Trim(String(FTrans.Token)).ToUpper) then
        begin
          SL.Add(FToken.ToUpper);
          Inc(TransCount);
        end;

    Result.AddPair('trans_count', TJSONNumber.Create(TransCount));
    Result.AddPair('tokens_count', TJSONNumber.Create(BC.Inquiries.TryGetAccTokensCount(Address)));
    if (SL.Count = 1) then
    begin
      Received := 0;
      Sent := 0;
      TokenID := BC.Inquiries.TryGetTokenID(Trim(SL.Strings[0]));
      Decimals := BC.Inquiries.TryGetTokenDecimals(TokenID);

      for FTrans in FAccTransactions do
      begin
        if (SL.Strings[0] = Trim(String(FTrans.Token))) then
          if (BC.Inquiries.TryGetAccountID(String(FTrans.Afrom)) = AccID) then
            Sent := Sent + BC.Inquiries.GetAmountFromVolume(FTrans.Sent, Decimals)
          else if (BC.Inquiries.TryGetAccountID(String(FTrans.Ato)) = AccID) then
            Received := Received + BC.Inquiries.GetAmountFromVolume(FTrans.Received, Decimals)
      end;

      Result.AddPair('symbol', Trim(SL.Strings[0]));
      Result.AddPair('received', BC.Inquiries.GetVolumeFromAmount(Received,Decimals,False));
      Result.AddPair('sent', BC.Inquiries.GetVolumeFromAmount(Sent,Decimals,False));
      Result.AddPair('balance', BC.Inquiries.TryGetBalanceString(Address, SL.Strings[0]));
    end;
  finally
    SL.Clear;
    SL.Free;
  end;
except
  WebServerLog.DoError('SourceData.GetAccData','procedureError');
end;
end;

function TBlockChainSource.GetAccDataDetails(const Tab, Address: String; Tokens: TStrings; const PageID, Count: Integer; TransType: TTransType;
  DateFrom, DateTo: String): TJSONObject;
var
  i, startp, Step, endp: Int64;
  AccID: UInt64;
  LatestTransTimeEver, EarlierTransTimeEver, LatestTransTime, EarlierTransTime, FDateFrom, FDateTo: Int64;
  FS: TFormatSettings;
  Passed: Boolean;
  FToken: String;
  FAcc: TAccountInfoV0;
  FTrans: TTransHistoryItem;
  FTokenInfo: TTokensInfoV0;
  FTransArray, FPassedTransArray: TArray<TTransHistoryItem>;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
try
  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit
  else
    FAcc := BC.Inquiries.TryGetAccountInfo(Address);

  if (Tokens[0] = 'ALL') then
  begin
    SetLength(Tokens, 0);
    for FTokenInfo in BC.Inquiries.TryGetTokenInfoAll do
      Tokens := Tokens + [Trim(String(FTokenInfo.Symbol).ToUpper)];
  end;

  try
    SL := TStringList.Create;
    SL.Clear;
    SL.Sorted := True;
    SL.Duplicates := TDuplicates.dupIgnore;

    SetLength(FTransArray, 0);

    EarlierTransTimeEver := 0;
    EarlierTransTime := 0;
    LatestTransTimeEver := DateTimeToUnix(IncSecond(Now), False);
    LatestTransTime := DateTimeToUnix(IncSecond(Now), False);

    FS.DateSeparator := '.';
    FS.TimeSeparator := ':';
    FS.ShortDateFormat := 'dd.mm.yyyy_hh:mm:ss';
    if DateFrom = '' then
      FDateFrom := 0
    else
      FDateFrom := DateTimeToUnix(StrToDateTime(DateFrom, FS), False);
    if DateTo = '' then
      FDateTo := DateTimeToUnix(IncSecond(Now), False)
    else
      FDateTo := DateTimeToUnix(IncSecond(StrToDateTime(DateTo, FS)), False);
    AccID := BC.Inquiries.TryGetAccountID(Address);

    FTransArray := BC.Inquiries.TryGetTransactionHistoryItems(AccID, EarlierTransTimeEver, LatestTransTimeEver);
    SetLength(FPassedTransArray, 0);
    for FTrans in FTransArray do
      for FToken in Tokens do
      begin
        if (FToken.ToUpper = Trim(String(FTrans.Token).ToUpper)) then
        begin
          if (FDateFrom <= FTrans.datetime) and (FDateTo >= FTrans.datetime) then
          begin
            Passed := False;
            case TransType of
              Incoming:
                Passed := (FTrans.Ato = FAcc.Address);
              Outgoing:
                Passed := (FTrans.Afrom = FAcc.Address);
              All:
                Passed := True;
            end;
            if Passed then
            begin
              FPassedTransArray := FPassedTransArray + [FTrans];
              SL.Add(Trim(String(FTrans.Token)));

              if FTrans.datetime < LatestTransTime then
                LatestTransTime := FTrans.datetime;
              if EarlierTransTime < FTrans.datetime then
                EarlierTransTime := FTrans.datetime;
            end;
          end;
          if FTrans.datetime < LatestTransTimeEver then
            LatestTransTimeEver := FTrans.datetime;
          if EarlierTransTimeEver < FTrans.datetime then
            EarlierTransTimeEver := FTrans.datetime;
        end;
      end;

    if (Tab = 'transactions') then
    begin
      startp := (PageID - 1) * Count;
      JSONArr := TJSONArray.Create;

      startp := Max(-1, Length(FPassedTransArray) - startp - 1);
      endp := Max(0, startp - Count + 1);
      Step := -1;
      i := startp;

      while i <> (endp + Step) do
      begin
        JSONArr.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

        JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(FPassedTransArray[i].datetime));
        JSONNestedObject.AddPair('block_number', TJSONNumber.Create(FPassedTransArray[i].block_number));
        JSONNestedObject.AddPair('from', FPassedTransArray[i].Afrom);
        JSONNestedObject.AddPair('to', FPassedTransArray[i].Ato);
        JSONNestedObject.AddPair('hash', FPassedTransArray[i].Hash);
        JSONNestedObject.AddPair('token', Trim(String(FPassedTransArray[i].Token)));
        JSONNestedObject.AddPair('sent', FPassedTransArray[i].Sentstr);
        JSONNestedObject.AddPair('received', FPassedTransArray[i].Sentstr);
        JSONNestedObject.AddPair('fee', TJSONNumber.Create(0));

        i := i + Step;
      end;

      if Length(FTransArray) <> 0 then
      begin
        Result.AddPair('earlier_trans_unix_date', TJSONNumber.Create(EarlierTransTime));
        Result.AddPair('latest_trans_unix_date', TJSONNumber.Create(LatestTransTime));
        Result.AddPair('earlier_trans_unix_date_ever', TJSONNumber.Create(EarlierTransTimeEver));
        Result.AddPair('latest_trans_unix_date_ever', TJSONNumber.Create(LatestTransTimeEver));
      end;
      Result.AddPair('trans_count', TJSONNumber.Create(Length(FPassedTransArray)));

      Result.AddPair('list', JSONArr);
    end
    else if (Tab = 'tokens') then
    begin
      startp := (PageID - 1) * Count;
      JSONArr := TJSONArray.Create;
      if (SL.Count > 0) then
      begin
        for i := startp to Min(startp + Count - 1, SL.Count - 1) do
        begin

          JSONArr.AddElement(TJSONObject.Create);
          JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

          JSONNestedObject.AddPair('token', SL.Strings[i]);
          JSONNestedObject.AddPair('balance', BC.Inquiries.TryGetBalanceString(Address, SL.Strings[i]));
          JSONNestedObject.AddPair('sent', FloatEToString(BC.Inquiries.TryGetSentAmountAllTime(AccID,
            BC.Inquiries.TryGetTokenID(SL.Strings[i]))));
          JSONNestedObject.AddPair('received', FloatEToString(BC.Inquiries.TryGetReceivedAmountAllTime(AccID,
            BC.Inquiries.TryGetTokenID(SL.Strings[i]))));
          JSONNestedObject.AddPair('trans_count', TJSONNumber.Create(BC.Inquiries.TryGetTransCount(AccID,
            BC.Inquiries.TryGetTokenID(SL.Strings[i]))));
        end;
      end;
      Result.AddPair('tokens_count', TJSONNumber.Create(SL.Count));

      Result.AddPair('list', JSONArr);
    end;
  finally
    SL.Clear;
    SL.Free;
  end;
except
  WebServerLog.DoError('SourceData.GetAccDataDetails','procedureError');
end;
end;

function TBlockChainSource.GetGlobalData(const Name: String; const PageID, Count: Integer; const SortBy: String = 'datetime';
  const Inverse: Boolean = False): TJSONObject;
var
  i, startp, Step, endp: Int64;
  FAllAcc: TArray<TAccountInfoV0>;
  FAllTrans: TArray<TTransHistoryItem>;
  FAllTokens: TArray<TTokensInfoV0>;
  FAllServices: TArray<TServiceInfoV0>;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
try
  Result := TJSONObject.Create;
  JSONArr := TJSONArray.Create;

  startp := (PageID - 1) * Count;

  if (Name = 'accounts') then
  begin
    FAllAcc := BC.Inquiries.TryGetALLAccounts(SortBy.ToLower);

    if Inverse then
    begin
      startp := Min(startp, Length(FAllAcc));
      endp := Min(startp + Count - 1, Length(FAllAcc) - 1);
      Step := 1;
      i := startp;
    end
    else
    begin
      startp := Max(-1, Length(FAllAcc) - startp - 1);
      endp := Max(0, startp - Count + 1);
      Step := -1;
      i := startp;
    end;

    while i <> (endp + Step) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('address', FAllAcc[i].Address);
      JSONNestedObject.AddPair('reg_unix_date', TJSONNumber.Create(BC.Inquiries.TryGetAccRegDate(FAllAcc[i].Address)));

      i := i + Step;
    end;

    Result.AddPair('amount_list', TJSONNumber.Create(Length(FAllAcc)));
  end
  else if (Name = 'transactions') then
  begin
    FAllTrans := BC.Inquiries.TryGetALLTransactions(SortBy.ToLower);

    if Inverse then
    begin
      startp := Min(startp, Length(FAllTrans));
      endp := Min(startp + Count - 1, Length(FAllTrans) - 1);
      Step := 1;
      i := startp;
    end
    else
    begin
      startp := Max(-1, Length(FAllTrans) - startp - 1);
      endp := Max(0, startp - Count + 1);
      Step := -1;
      i := startp;
    end;

    while i <> (endp + Step) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(FAllTrans[i].datetime));
      JSONNestedObject.AddPair('block_number', TJSONNumber.Create(FAllTrans[i].block_number));
      JSONNestedObject.AddPair('from', FAllTrans[i].Afrom);
      JSONNestedObject.AddPair('to', FAllTrans[i].Ato);
      JSONNestedObject.AddPair('hash', FAllTrans[i].Hash);
      JSONNestedObject.AddPair('token', Trim(String(FAllTrans[i].Token)));
      JSONNestedObject.AddPair('sent', FAllTrans[i].Sentstr);
      JSONNestedObject.AddPair('received', FAllTrans[i].Sentstr);
      JSONNestedObject.AddPair('fee', TJSONNumber.Create(0));

      i := i + Step;
    end;

    Result.AddPair('amount_list', TJSONNumber.Create(Length(FAllTrans)));
  end
  else if (Name = 'tokens') then
  begin
    FAllTokens := BC.Inquiries.TryGetTokenInfoAll(SortBy.ToLower);

    if Inverse then
    begin
      startp := Min(startp, Length(FAllTokens));
      endp := Min(startp + Count - 1, Length(FAllTokens) - 1);
      Step := 1;
      i := startp;
    end
    else
    begin
      startp := Max(-1, Length(FAllTokens) - startp - 1);
      endp := Max(0, startp - Count + 1);
      Step := -1;
      i := startp;
    end;

    while i <> (endp + Step) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('owner_id', TJSONNumber.Create(FAllTokens[i].Owner));
      JSONNestedObject.AddPair('name', Trim(String(FAllTokens[i].Name)));
      JSONNestedObject.AddPair('symbol', Trim(String(FAllTokens[i].Symbol)));
      JSONNestedObject.AddPair('decimals', TJSONNumber.Create(FAllTokens[i].Decimals));
      JSONNestedObject.AddPair('volume', TJSONNumber.Create(BC.Inquiries.GetVolumeFromAmount(FAllTokens[i].Volume, FAllTokens[i].Decimals)));
      JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(FAllTokens[i].UnixTime));

      i := i + Step;
    end;
    Result.AddPair('amount_list', TJSONNumber.Create(Length(FAllTokens)));
  end
  else if (Name = 'services') then
  begin
    FAllServices := BC.Inquiries.TryGetALLServices(SortBy.ToLower);

    if Inverse then
    begin
      startp := Min(startp, Length(FAllAcc));
      endp := Min(startp + Count - 1, Length(FAllAcc) - 1);
      Step := 1;
      i := startp;
    end
    else
    begin
      startp := Max(-1, Length(FAllServices) - startp - 1);
      endp := Max(0, startp - Count + 1);
      Step := -1;
      i := startp;
    end;

    while i <> (endp + Step) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('name', Trim(FAllServices[i].Name));
      JSONNestedObject.AddPair('owner_id', TJSONNumber.Create(FAllServices[i].Owner));
      JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(FAllServices[i].UnixTime));

      i := i + Step;
    end;

    Result.AddPair('amount_list', TJSONNumber.Create(Length(FAllServices)));
  end;
  Result.AddPair('list', JSONArr);
except
  WebServerLog.DoError('SourceData.GetGlobalData','procedureError');
end;
end;

function TBlockChainSource.GetMiningData: TJSONObject;
begin
try

  Result := TJSONObject.Create;

  Result.AddPair('last_mining_date',TJSONNumber.Create(BC.Inquiries.TryGetLastMined));
  Result.AddPair('OM_count',TJSONNumber.Create(BC.Inquiries.TryGetCountOM));
except
  WebServerLog.DoError('SourceData.GetMiningData','procedureError');
end;
end;

procedure TBlockChainSource.GetMyAddress(AArgs: TArray<string>);
begin
try
  Reason := AArgs[0];

except
  WebServerLog.DoError('SourceData.GetMyAddress','procedureError');
end;
end;

function TBlockChainSource.GetServiceData(const Name: String): TJSONObject;
var
  ServiceID: UInt64;
  ServiceData: TArray<TServiceResultV0>;
  Bytes: TBytes;
  Len: Integer;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
try

  Result := TJSONObject.Create;

  Res := WalletID <> 0;
  if not Res then
    Reason := 'the wallet is not logged in'
  else
  begin
    ServiceID := BC.Inquiries.TryGetServiceID(Name);
    Res := ServiceID <> 0;
    if Res then
    begin
      ServiceData := BC.Inquiries.TryGetServiceDataByID(ServiceID);

      JSONArr := TJSONArray.Create;
      for var i := 0 to Length(ServiceData) - 1 do
      begin
        JSONArr.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

        JSONNestedObject.AddPair('id', TJSONNumber.Create(ServiceData[i].ServiceResultInfo.ID));
        JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(ServiceData[i].ServiceResultInfo.UnixTime));
        Len := Length(ServiceData[i].ServiceResultInfo.Data);
        SetLength(Bytes, Len);
        for var j := 0 to Len - 1 do
          Bytes[j] := ServiceData[i].ServiceResultInfo.Data[j];

        JSONNestedObject.AddPair('data', Trim(TEncoding.ANSI.GetString(Bytes)));
      end;
    end
    else
      Reason := 'the service with the specified name does not exist';
  end;

  Result.AddPair('result', TJSONBool.Create(Res));
  if Res then
    Result.AddPair('data_array', JSONArr)
  else
    Result.AddPair('error', Reason);

except
  WebServerLog.DoError('SourceData.GetServiceData','procedureError');
end;
end;

function TBlockChainSource.GetServiceInfo(const Name: String): TJSONObject;
var
  ServiceID: UInt64;
  ServiceInfo: TServiceInfoV0;
begin
try

  Result := TJSONObject.Create;

  ServiceID := BC.Inquiries.TryGetServiceID(Name);
  Res := ServiceID <> 0;
  if not Res then
    Reason := 'the service with the specified name does not exist'
  else
    ServiceInfo := BC.Inquiries.TryGetServiceInfo(ServiceID);

  Result.AddPair('result', TJSONBool.Create(Res));
  if Res then
  begin
    Result.AddPair('name', Trim(ServiceInfo.Name));
    Result.AddPair('owner_id', TJSONNumber.Create(ServiceInfo.Owner));
    Result.AddPair('unix_time', TJSONNumber.Create(ServiceInfo.UnixTime));
  end
  else
    Result.AddPair('error', Reason);
except
  WebServerLog.DoError('SourceData.GetServiceInfo','procedureError');
end;
end;

function TBlockChainSource.GetStatisticsData(const Tab: String; DateFrom, DateTo: String; const Step: Int64): TJSONObject;
var
  i: Integer;
  FS: TFormatSettings;
  LatestTransTime, EarlierTransTime, PDateFrom, PDateTo: Int64;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
try

  Result := TJSONObject.Create;

  EarlierTransTime := 0;
  LatestTransTime := DateTimeToUnix(Now, False);

  FS.DateSeparator := '.';
  FS.TimeSeparator := ':';
  FS.ShortDateFormat := 'dd.mm.yyyy_hh:mm:ss';
  if DateFrom = '' then
    PDateFrom := DateTimeToUnix(IncDay(Now, -7), False)
  else
    PDateFrom := DateTimeToUnix(StrToDateTime(DateFrom, FS), False);
  if DateTo = '' then
    PDateTo := DateTimeToUnix(Now, False)
  else
    PDateTo := DateTimeToUnix(StrToDateTime(DateTo, FS), False);

  JSONArr := TJSONArray.Create;

  if (Tab = 'validators') then
  begin
    Randomize;
    for i := 0 to (PDateTo - PDateFrom) div Step do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(PDateFrom + i * Step + 1));
      JSONNestedObject.AddPair('count', TJSONNumber.Create(1));
    end;
  end;

  Result.AddPair('list', JSONArr);
except
  WebServerLog.DoError('SourceData.GetStatisticsData','procedureError');
end;
end;

function TBlockChainSource.GetTokenInfoData(const Symbol: String): TJSONObject;
var
  TransCount, OwnersCount: UInt64;
  TokenInfo: TTokensInfoV0;
begin
try
  WebServerLog.DoAlert('SourceData.GetTokenInfoData','procedureEnter');

  Result := TJSONObject.Create;
  WebServerLog.DoAlert('SourceData.GetTokenInfoData','TryCheckIfTokenExists');
  if not BC.Inquiries.TryCheckIfTokenExists(Symbol) then
    exit;
  WebServerLog.DoAlert('SourceData.GetTokenInfoData','TryGetTokenInfo');
  TokenInfo := BC.Inquiries.TryGetTokenInfo(Symbol);
  WebServerLog.DoAlert('SourceData.GetTokenInfoData','TryGetTokenOwners');
  OwnersCount := Length(BC.Inquiries.TryGetTokenOwners(Symbol));
  WebServerLog.DoAlert('SourceData.GetTokenInfoData','TryGetTokenTransCount');
  TransCount := BC.Inquiries.TryGetTokenTransCount(Symbol);

  with TokenInfo do
  begin
    Result.AddPair('owner_id', TJSONNumber.Create(Owner));
    Result.AddPair('name', Trim(String(Name)));
    Result.AddPair('symbol', Trim(String(Symbol)));
    Result.AddPair('decimals', TJSONNumber.Create(Decimals));
    WebServerLog.DoAlert('SourceData.GetTokenInfoData','GetVolumeFromAmount');
    Result.AddPair('volume', TJSONNumber.Create(BC.Inquiries.GetVolumeFromAmount(Volume, Decimals)));
    Result.AddPair('unix_time', TJSONNumber.Create(UnixTime));
    Result.AddPair('trans_count', TJSONNumber.Create(TransCount));
    Result.AddPair('owners_count', TJSONNumber.Create(OwnersCount));
  end;

  WebServerLog.DoAlert('SourceData.GetTokenInfoData','procedureLeave');
except
  WebServerLog.DoError('SourceData.GetTokenInfoData','procedureError');
end;
end;

function TBlockChainSource.GetTokenListData(const Address: String): TJSONObject;
var
  i, j, ID: Integer;
  PAcc: TAccountInfoV0;
  PTransArray: TArray<TTransHistoryItem>;
  PTrans: TTransHistoryItem;
  PToken: TTokensInfoV0;
  l: Char;
  tname: String;
  JSONArr, JSONArrIn: TJSONArray;
  JSONNestedObject, JSONNestedObjectIn: TJSONObject;
  Found: Boolean;
begin
try

  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit
  else
    PAcc := BC.Inquiries.TryGetAccountInfo(Address);

  PTransArray := BC.Inquiries.TryGetTransactionHistoryItems(BC.Inquiries.TryGetAccountID(Address), 0, High(Int64));

  JSONArr := TJSONArray.Create;
  for l := 'A' to 'Z' do
  begin
    JSONArr.AddElement(TJSONObject.Create);
    JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

    JSONArrIn := TJSONArray.Create;
    for PTrans in PTransArray do
    begin
      tname := Trim(String(PTrans.Token));
      if tname.StartsWith(l) then
      begin
        Found := False;
        for j := 0 to pred(JSONArrIn.Count) do
          if (JSONArrIn.Items[j] as TJSONObject).Values['symbol'].Value = tname then
            Found := True;
        if not Found then
        begin
          JSONArrIn.AddElement(TJSONObject.Create);
          JSONNestedObjectIn := JSONArrIn.Items[pred(JSONArrIn.Count)] as TJSONObject;

          PToken := BC.Inquiries.TryGetTokenInfo(tname);
          JSONNestedObjectIn.AddPair('symbol', Trim(String(PToken.Symbol)));
          JSONNestedObjectIn.AddPair('name', Trim(String(PToken.Name)));
        end;
      end;
    end;
    JSONNestedObject.AddPair(l, JSONArrIn);
  end;

  Result.AddPair('tokens', JSONArr);

except
  WebServerLog.DoError('SourceData.GetTokenListData','procedureError');
end;
end;

function TBlockChainSource.GetTokenTransactions(const Tab, Symbol: String; const PageID, Count: Integer): TJSONObject;
var
  i, startp, endp, Step: Integer;
  TransArr: TArray<TTransHistoryItem>;
  OwnersArr: TArray<TAccountInfoV0>;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
try

  Result := TJSONObject.Create;

  if not BC.Inquiries.TryCheckIfTokenExists(Symbol) then
    exit;

  if (Tab = 'transactions') then
  begin
    TransArr := BC.Inquiries.TryGetAllTransactionsBySymbol(Symbol);

    startp := (PageID - 1) * Count;
    JSONArr := TJSONArray.Create;

    startp := Max(-1, Length(TransArr) - startp - 1);
    endp := Max(0, startp - Count + 1);
    Step := -1;
    i := startp;

    while i <> (endp + Step) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(TransArr[i].datetime));
      JSONNestedObject.AddPair('block_number', TJSONNumber.Create(TransArr[i].block_number));
      JSONNestedObject.AddPair('from', TransArr[i].Afrom);
      JSONNestedObject.AddPair('to', TransArr[i].Ato);
      JSONNestedObject.AddPair('hash', TransArr[i].Hash);
      JSONNestedObject.AddPair('token', Trim(String(TransArr[i].Token)));
      JSONNestedObject.AddPair('sent', TransArr[i].Sentstr);
      JSONNestedObject.AddPair('received', TransArr[i].Sentstr);
      JSONNestedObject.AddPair('fee', TJSONNumber.Create(0));

      i := i + Step;
    end;
  end
  else if (Tab = 'owners') then
  begin
    OwnersArr := BC.Inquiries.TryGetTokenOwners(Symbol);

    startp := (PageID - 1) * Count;
    JSONArr := TJSONArray.Create;

    startp := Max(-1, Length(OwnersArr) - startp - 1);
    endp := Max(0, startp - Count + 1);
    Step := -1;
    i := startp;

    while i <> (endp + Step) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('id', TJSONNumber.Create(BC.Inquiries.TryGetAccountID(OwnersArr[i].Address)));
      JSONNestedObject.AddPair('address', OwnersArr[i].Address);
      JSONNestedObject.AddPair('reg_unix_date', TJSONNumber.Create(BC.Inquiries.TryGetAccRegDate(OwnersArr[i].Address)));
      JSONNestedObject.AddPair('balance', BC.Inquiries.TryGetBalanceString(OwnersArr[i].Address, Symbol));

      i := i + Step;
    end;
  end;

  Result.AddPair('list', JSONArr);

except
  WebServerLog.DoError('SourceData.GetTokenTransactions','procedureError');
end;
end;

function TBlockChainSource.GetTransData(const Hash: String): TJSONObject;
var
  THI: TTransHistoryItem;
begin
try

  Result := TJSONObject.Create;

  THI := BC.Inquiries.TryGetTransInfo(Hash);
  if (THI.datetime = 0) then
    exit;

  Result.AddPair('hash', THI.Hash);
  Result.AddPair('block_number', TJSONNumber.Create(THI.block_number));
  Result.AddPair('unix_time', TJSONNumber.Create(THI.datetime));
  Result.AddPair('from', THI.Afrom);
  Result.AddPair('to', THI.Ato);
  Result.AddPair('token', Trim(String(THI.Token)));
  Result.AddPair('sent', THI.Sentstr);
  Result.AddPair('received', THI.Sentstr);
  Result.AddPair('fee', TJSONNumber.Create(0));

except
  WebServerLog.DoError('SourceData.GetTransData','procedureError');
end;
end;

function TBlockChainSource.GetWalletBalance(const Address, Token: String): TJSONObject;
var
  Balance: String;
begin
try

  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit;

  Balance := BC.Inquiries.TryGetBalanceString(Address, Token);
  if Balance = '' then
    exit;

  Result.AddPair('wallet', Address);
  Result.AddPair('token', Token);
  Result.AddPair('balance', Balance);

except
  WebServerLog.DoError('SourceData.GetWalletBalance','procedureError');
end;
end;

procedure TBlockChainSource.NewTokenCallBack(AArgs: TArray<string>);
begin
try

  Res := AArgs[0] = 'OK';
  if not Res then
    Reason := AArgs[1];

except
  WebServerLog.DoError('SourceData.NewTokenCallBack','procedureError');
end;
end;

function TBlockChainSource.OpenWallet(const Address, Pass: String): TJSONObject;
begin
try

  Result := TJSONObject.Create;

  AppCore.GetHandler.HandleWebDataControl(CMD_GUI_OPEN_WALLET, [Address, Pass], TryOpenWalletCallBack);

  Result.AddPair('success', TJSONBool.Create(Res));
  if not Res then
    Result.AddPair('error', 'bad address or password');
except
  WebServerLog.DoError('SourceData.OpenWallet','procedureError');
end;
end;

function TBlockChainSource.SetServiceData(const FAddress, FPass, Name: String; FData: TSRData): TJSONObject;
var
  ServiceID: UInt64;
begin
try

  Result := TJSONObject.Create;

  Res := True;

  AppCore.GetHandler.HandleWebDataControl(CMD_GUI_OPEN_WALLET, [FAddress, FPass], TryOpenWalletCallBack);

  if not Res then
  begin
    Reason := 'bad address or password';
  end
  else
  begin
    ServiceID := BC.Inquiries.TryGetServiceID(Name);
    Res := ServiceID <> 0;
    if not Res then
      Reason := 'the service with the specified name does not exist'
    else
      AppCore.GetHandler.HandleWebDataControl(CMD_WEB_SET_SERVICE_DATA, [ServiceID.AsString, TEncoding.ANSI.GetString(FData)], CallBack);
  end;

  Result.AddPair('result', TJSONBool.Create(Res));
  if not Res then
    Result.AddPair('error', Reason);

except
  WebServerLog.DoError('SourceData.SetServiceData','procedureError');
end;
end;

procedure TBlockChainSource.SetWords(AArray: TArray<string>);
begin
try

  Words := Trim(AArray[0]);

except
  WebServerLog.DoError('SourceData.SetWords','procedureError');
end;
end;

procedure TBlockChainSource.TryOpenWalletCallBack(AArgs: TArray<string>);
begin
try

  Res := AArgs[0] = 'OK';

except
  WebServerLog.DoError('SourceData.TryOpenWalletCallBack','procedureError');
end;
end;

end.
