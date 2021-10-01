unit WebServer.SourceData;

interface

uses
  System.SysUtils,
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
  App.Globals,
  App.Types,
  App.Meta,
  WebServer.HTTPTypes,
  WebServer.Abstractions,
  Crypto.Encoding,
  BlockChain.Types;

type

  TTestSource = class(TInterfacedObject, IDataSource)
  private
    MainAccList, LabAccList, TestAccList: TAccInfoList;
    MainTransList, LabTransList, TestTransList: TTransInfoList;
    MainTokensList, LabTokensList, TestTokensList: TTokensInfoList;

    HCurrentNet: TNetType;
    CurAccList: ^TAccInfoList;
    CurTransList: ^TTransInfoList;
    CurTokensList: ^TTokensInfoList;
    SL: TStringList;
    function GetAccIDbyAddress(const Address: String): Integer;
    function GetAccount(const ID: Integer): TAccountInfoUpd; overload;
    function GetAccount(const Address: String): TAccountInfoUpd; overload;
    function GetTransIDByHash(const Hash: String): Integer;
    function GetTransByID(const ID: Integer): TTransactionInfo;
    function GetBalanceByName(Address, TokenName: String): TTokenBalanceInfo;
    function GetSymbolByStr(const Str: String): TSymbol;
    function GetTokenIDBySymbol(const Str: String): Integer;
    function GetTokenBySymbol(const Symbol: String; var Success: Boolean): TTokensInfo;
    function GetDecimalsBySymbol(const Symbol: String): UInt64;
    function GenerateTokenName: String;

    function GetAccCount: Integer;
    function GetTransCount: Integer;
    function GetTokensCount: Integer;

    procedure SetCurrentNet(const NetType: TNetType);
  public
    procedure GenerateAccData(const AmountAcc: Integer);
    procedure GenerateTransData(const AmountTrans: Integer);
    procedure GenerateTokensData(const AmountTokens: Integer);
    procedure ResetAll;
    procedure ResetAccList;
    procedure ResetTokensList;
    procedure ResetTransList;
    function GetData(const Name: String; const PageID, Count: Integer; const Net: String)
      : TJSONObject;
    function GetTokenListData(const Address, Net: String): TJSONObject;
    function GetAccData(const Address, Net: String; Tokens: TStrings): TJSONObject;
    function GetAccDataDetails(const Tab, Address, Net: String; Tokens: TStrings;
      const PageID, Count: Integer; TransType: TTransType = All; DateFrom: String = '';
      DateTo: String = ''): TJSONObject;
    function GetTransData(const Hash, Net: String): TJSONObject;
    function GetTokenInfoData(const Symbol, Net: String): TJSONObject;
    function GetTokenTransactions(const Tab, Symbol: String; const PageID, Count: Integer;
      const Net: String): TJSONObject;
    function GetStatisticsData(const Tab, Net: String; DateFrom: String = ''; DateTo: String = '';
      const Step: UInt64 = 86400): TJSONObject;

    function CheckCryptoContainerKeys(Keys: TStrings; Pass,Net: String): TJSONObject;
    constructor Create(const AmountAcc, AmountTrans, AmountTokens: Integer);
    destructor Destory;
    property AccCount: Integer read GetAccCount;
    property TransCount: Integer read GetTransCount;
    property TokensCount: Integer read GetTokensCount;
    property CurrentNet: TNetType write SetCurrentNet;
  end;

  TBlockChainSource = class(TInterfacedObject, IDataSource)
  private
    BC: TBlockChainCore;
    SL: TStringList;
    Res: Boolean;

    procedure Callback(AArgs: TArray<string>);
  public
    function GetAccData(const Address, Net: String; Tokens: TStrings): TJSONObject;
    function GetAccDataDetails(const Tab, Address, Net: String; Tokens: TStrings;
      const PageID, Count: Integer; TransType: TTransType = All; DateFrom: String = '';
      DateTo: String = ''): TJSONObject;
    function GetTokenListData(const Address, Net: String): TJSONObject;
    function GetData(const Name: String; const PageID, Count: Integer; const Net: String): TJSONObject;
    function GetTransData(const Hash, Net: String): TJSONObject;
    function GetTokenInfoData(const Symbol, Net: String): TJSONObject;

    function CheckCryptoContainerKeys(Keys: TStrings; Pass,Net: String): TJSONObject;
    constructor Create(ABlockChain: TBlockChainCore);
    destructor Destroy;
  end;

var
  FTestSource: TTestSource;
  FRealSource: TBlockChainSource;

implementation

{ TTestSource }

function TTestSource.CheckCryptoContainerKeys(Keys: TStrings; Pass,Net: String): TJSONObject;
begin

end;

constructor TTestSource.Create(const AmountAcc, AmountTrans, AmountTokens: Integer);
begin
  SetCurrentNet(ntMain);
  GenerateAccData(AmountAcc);
  GenerateTokensData(AmountTokens);
  GenerateTransData(AmountTrans);

  SetCurrentNet(ntLab);
  GenerateAccData(AmountAcc);
  GenerateTokensData(AmountTokens);
  GenerateTransData(AmountTrans);

  SetCurrentNet(ntTest);
  GenerateAccData(AmountAcc);
  GenerateTokensData(AmountTokens);
  GenerateTransData(AmountTrans);

  SetCurrentNet(ntMain);
end;

destructor TTestSource.Destory;
begin
  ResetAll;
end;

procedure TTestSource.GenerateAccData(const AmountAcc: Integer);
var
  i, j: Integer;
  t: Double;
begin
  ResetAccList;
  ResetTransList;
  SetLength(CurAccList^, AmountAcc);

  Randomize;
  for i := 0 to AmountAcc - 1 do
  begin
    t := (Now * 1000 - Random(5000)) / 1000;

    CurAccList^[i].PubKey := THashSHA1.GetHashString(FloatToStr(Now + Random(100)));
    SetLength(CurAccList^[i].PubKey, 20);

    CurAccList^[i].Address := THashSHA1.GetHashString(FloatToStr(Now - Random(100)));
    SetLength(CurAccList^[i].Address, 32);

    CurAccList^[i].Time := t;
    CurAccList^[i].RegDate := (t * 1000 - Random(15000)) / 1000;
    CurAccList^[i].ID := i;
    SetLength(CurAccList^[i].Transactions, 0);

    SetLength(CurAccList^[i].Money, Length(CurTokensList^));

    for j := 0 to Length(CurAccList^[i].Money) - 1 do
    begin
      CurAccList^[i].Money[j].Token := CurTokensList^[j].Symbol;
      CurAccList^[i].Money[j].Sent := 0;
      CurAccList^[i].Money[j].Received := 0;
      if (Random(100) >= 50) then
        CurAccList^[i].Money[j].Balance := (Random(100) * 10000000 + Random(1000000)) * 0.0000001
      else
        CurAccList^[i].Money[j].Balance := 0;
      CurAccList^[i].Money[j].TransCount := 0;
    end;
  end;
end;

function TTestSource.GetData(const Name: String; const PageID, Count: Integer; const Net: String)
  : TJSONObject;
var
  i, st, Step, endp: Integer;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  st := (PageID - 1) * Count;
  JSONArr := TJSONArray.Create;
  if (Name = 'accounts') or (Name = 'fee') then
  begin
    for i := st to Min(st + Count - 1, Length(CurAccList^) - 1) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('hash', CurAccList^[i].Address);
      JSONNestedObject.AddPair('time', DateTimeToStr(CurAccList^[i].Time));
      JSONNestedObject.AddPair('reg_date', DateTimeToStr(CurAccList^[i].RegDate));
    end;
    Result.AddPair('amount_list', TJSONNumber.Create(Length(CurAccList^)));
  end
  else if (Name = 'transactions') then
  begin
    st := Length(CurTransList^) - st - 1;
    for i := st downto Max(0, st - Count + 1) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('datetime', DateTimeToStr(CurTransList^[i].Time));
      JSONNestedObject.AddPair('block_number', TJSONNumber.Create(CurTransList^[i].BlockNum));
      JSONNestedObject.AddPair('from', CurTransList^[i].FFrom);
      JSONNestedObject.AddPair('to', CurTransList^[i].FTo);
      JSONNestedObject.AddPair('hash', CurTransList^[i].Hash);
      JSONNestedObject.AddPair('token', String(CurTransList^[i].Token));
      JSONNestedObject.AddPair('sent', TJSONNumber.Create(CurTransList^[i].Sent));
      JSONNestedObject.AddPair('received', TJSONNumber.Create(CurTransList^[i].Received));
      JSONNestedObject.AddPair('fee', TJSONNumber.Create(CurTransList^[i].Fee));
    end;

    Result.AddPair('amount_list', TJSONNumber.Create(Length(CurTransList^)));
  end
  else if (Name = 'tokens') then
  begin
    for i := st to Min(st + Count - 1, Length(CurTokensList^) - 1) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('owner', TJSONNumber.Create(CurTokensList^[i].Owner));
      JSONNestedObject.AddPair('name', String(CurTokensList^[i].Name));
      JSONNestedObject.AddPair('symbol', String(CurTokensList^[i].Symbol));
      JSONNestedObject.AddPair('decimals', TJSONNumber.Create(CurTokensList^[i].Decimals));
      JSONNestedObject.AddPair('volume', TJSONNumber.Create(CurTokensList^[i].Volume));
      JSONNestedObject.AddPair('unix_time', TJSONNumber.Create(CurTokensList^[i].UnixTime));
    end;
    Result.AddPair('amount_list', TJSONNumber.Create(Length(CurTokensList^)));
  end;
  Result.AddPair('list', JSONArr);
end;

function TTestSource.GetDecimalsBySymbol(const Symbol: String): UInt64;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(CurTokensList^) - 1 do
    if String(CurTokensList^[i].Symbol).ToLower = Symbol then
    begin
      Result := CurTokensList^[i].Decimals;
      exit;
    end;
end;

function TTestSource.GetTokenIDBySymbol(const Str: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(CurTokensList^) - 1 do
    if (String(CurTokensList^[i].Symbol).ToLower = Str.ToLower) then
    begin
      Result := i;
      exit;
    end;
end;

function TTestSource.GetStatisticsData(const Tab, Net: String; DateFrom: String = '';
  DateTo: String = ''; const Step: UInt64 = 86400): TJSONObject;
var
  i: Integer;
  FS: TFormatSettings;
  LatestTransTime, EarlierTransTime, PDateFrom, PDateTo: TDateTime;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  EarlierTransTime := 0;
  LatestTransTime := Now;

  FS.DateSeparator := '.';
  FS.TimeSeparator := ':';
  FS.ShortDateFormat := 'dd.mm.yyyy_hh:mm:ss';
  if DateFrom = '' then
    PDateFrom := IncDay(Now, -7)
  else
    PDateFrom := StrToDateTime(DateFrom, FS);
  if DateTo = '' then
    PDateTo := Now
  else
    PDateTo := StrToDateTime(DateTo, FS);

  JSONArr := TJSONArray.Create;

  if (Tab = 'validators') then
  begin
    Randomize;
    for i := 0 to SecondsBetween(PDateFrom, PDateTo) div Step do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('date', DateTimeToStr(IncSecond(PDateFrom, i * Step)));
      JSONNestedObject.AddPair('count', TJSONNumber.Create(Random(50001)));
    end;
  end;

  Result.AddPair('list', JSONArr);
end;

function TTestSource.GetSymbolByStr(const Str: String): TSymbol;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Length(CurTokensList^) - 1 do
    if String(CurTokensList^[i].Symbol).ToLower = Str.ToLower then
    begin
      Result := CurTokensList^[i].Symbol;
      exit;
    end;
end;

function TTestSource.GetTokenBySymbol(const Symbol: String; var Success: Boolean): TTokensInfo;
var
  TInfo: TTokensInfo;
begin
  for TInfo in CurTokensList^ do
    if (String(TInfo.Symbol).ToLower = Symbol.ToLower) then
    begin
      Result := TInfo;
      Success := True;
      exit;
    end;
  Success := False;
end;

function TTestSource.GetTokenInfoData(const Symbol, Net: String): TJSONObject;
var
  i, TransCount: Integer;
  TokenInfo: TTokensInfo;
  Found: Boolean;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  TokenInfo := GetTokenBySymbol(Symbol, Found);
  if not Found then
    exit;

  i := Length(CurTransList^) - 1;
  TransCount := 0;
  while not(i < 0) do
  begin
    if (String(CurTransList^[i].Token).ToLower = Symbol) then
      Inc(TransCount);
    Dec(i);
  end;

  with TokenInfo do
  begin
    Result.AddPair('owner', TJSONNumber.Create(Owner));
    Result.AddPair('name', String(Name));
    Result.AddPair('symbol', String(Symbol));
    Result.AddPair('decimals', TJSONNumber.Create(Decimals));
    Result.AddPair('volume', TJSONNumber.Create(Volume));
    Result.AddPair('unix_time', TJSONNumber.Create(UnixTime));
    Result.AddPair('trans_count', TJSONNumber.Create(TransCount));
  end;
end;

function TTestSource.GetTokenListData(const Address, Net: String): TJSONObject;
var
  i, j, ID: Integer;
  l: Char;
  tname: String;
  TInfo: TTokensInfo;
  JSONArr, JSONArrIn: TJSONArray;
  JSONNestedObject, JSONNestedObjectIn: TJSONObject;
  Found: Boolean;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  ID := GetAccIDbyAddress(Address);
  if (ID = -1) then
    exit;

  JSONArr := TJSONArray.Create;
  for l := 'A' to 'Z' do
  begin
    JSONArr.AddElement(TJSONObject.Create);
    JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

    JSONArrIn := TJSONArray.Create;
    for i := 0 to Length(CurAccList^[ID].Transactions) - 1 do
    begin
      tname := String(CurTransList^[CurAccList^[ID].Transactions[i]].Token);
      if tname.StartsWith(l) then
      begin
        Found := False;
        for j := 0 to pred(JSONArrIn.Count) do
          if (JSONArrIn.Items[j] as TJSONObject).Values['title'].Value = tname then
            Found := True;
        if not Found then
        begin
          JSONArrIn.AddElement(TJSONObject.Create);
          JSONNestedObjectIn := JSONArrIn.Items[pred(JSONArrIn.Count)] as TJSONObject;

          TInfo := GetTokenBySymbol(tname, Found);
          if Found then
          begin
            JSONNestedObjectIn.AddPair('title', String(TInfo.Symbol));
            JSONNestedObjectIn.AddPair('name', String(TInfo.Name));
          end;
        end;
      end;
    end;
    JSONNestedObject.AddPair(l, JSONArrIn);
  end;

  Result.AddPair('tokens', JSONArr);
end;

function TTestSource.GetTokensCount: Integer;
begin
  Result := Length(CurTokensList^);
end;

function TTestSource.GetTokenTransactions(const Tab, Symbol: String; const PageID, Count: Integer;
  const Net: String): TJSONObject;
var
  i, ID, st: Integer;
  TokenExists: Boolean;
  PTransArray: TArray<TTransactionInfo>;
  PAccArray: TArray<TAccountInfoUpd>;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  GetTokenBySymbol(Symbol, TokenExists);
  if not TokenExists then
    exit;

  if (Tab = 'transactions') then
  begin
    SetLength(PTransArray, 0);
    for i := 0 to Length(CurTransList^) - 1 do
      if (String(CurTransList^[i].Token).ToLower = Symbol) then
        PTransArray := PTransArray + [CurTransList^[i]];

    st := (PageID - 1) * Count;
    JSONArr := TJSONArray.Create;

    for i := st to Min(st + Count - 1, Length(PTransArray) - 1) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('datetime', DateTimeToStr(PTransArray[i].Time));
      JSONNestedObject.AddPair('block_number', TJSONNumber.Create(PTransArray[i].BlockNum));
      JSONNestedObject.AddPair('from', PTransArray[i].FFrom);
      JSONNestedObject.AddPair('to', PTransArray[i].FTo);
      JSONNestedObject.AddPair('hash', PTransArray[i].Hash);
      JSONNestedObject.AddPair('token', String(PTransArray[i].Token));
      JSONNestedObject.AddPair('sent', TJSONNumber.Create(PTransArray[i].Sent));
      JSONNestedObject.AddPair('received', TJSONNumber.Create(PTransArray[i].Received));
      JSONNestedObject.AddPair('fee', TJSONNumber.Create(PTransArray[i].Fee));
    end;
  end
  else if (Tab = 'owners') then
  begin
    ID := GetTokenIDBySymbol(Symbol);

    SetLength(PAccArray, 0);
    for i := 0 to Length(CurAccList^) - 1 do
      if (CurAccList^[i].Money[ID].Balance > 0) then
        PAccArray := PAccArray + [CurAccList^[i]];

    st := (PageID - 1) * Count;
    JSONArr := TJSONArray.Create;

    for i := st to Min(st + Count - 1, Length(PAccArray) - 1) do
    begin
      JSONArr.AddElement(TJSONObject.Create);
      JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

      JSONNestedObject.AddPair('id', TJSONNumber.Create(PAccArray[i].ID));
      JSONNestedObject.AddPair('address', PAccArray[i].Address);
      JSONNestedObject.AddPair('reg_date', DateTimeToStr(PAccArray[i].RegDate));
      JSONNestedObject.AddPair('balance', TJSONNumber.Create(PAccArray[i].Money[ID].Balance));
    end;
  end;

  Result.AddPair('list', JSONArr);
end;

function TTestSource.GetTransByID(const ID: Integer): TTransactionInfo;
begin
  try
    Result := CurTransList^[ID];
  except
    Result.BlockNum := -1;
  end;
end;

function TTestSource.GetTransCount: Integer;
begin
  Result := Length(CurTransList^);
end;

function TTestSource.GetTransData(const Hash, Net: String): TJSONObject;
var
  i, ID: Integer;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  ID := GetTransIDByHash(Hash);
  if (ID = -1) then
    exit;

  Result.AddPair('hash', CurTransList^[ID].Hash);
  Result.AddPair('block_number', TJSONNumber.Create(CurTransList^[ID].BlockNum));
  Result.AddPair('datetime', DateTimeToStr(CurTransList^[ID].Time));
  Result.AddPair('from', CurTransList^[ID].FFrom);
  Result.AddPair('to', CurTransList^[ID].FTo);
  Result.AddPair('token', String(CurTransList^[ID].Token));
  Result.AddPair('sent', TJSONNumber.Create(CurTransList^[ID].Sent));
  Result.AddPair('received', TJSONNumber.Create(CurTransList^[ID].Received));
  Result.AddPair('fee', TJSONNumber.Create(CurTransList^[ID].Fee));
end;

function TTestSource.GetTransIDByHash(const Hash: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(CurTransList^) - 1 do
    if (CurTransList^[i].Hash = Hash) then
    begin
      Result := i;
      break;
    end;
end;

function TTestSource.GenerateTokenName: String;
var
  i: Integer;
  Alphabet: String;
begin
  Alphabet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Randomize;
  repeat
    Result := '';
    for i := 0 to 4 do
      Result := Result + Alphabet[Random(Length(Alphabet)) + 1];
  until (SL.IndexOf(Result) = -1);
end;

procedure TTestSource.GenerateTokensData(const AmountTokens: Integer);
var
  i, j: Integer;
  t: Double;
  TBI: TTokenBalanceInfo;
begin
  if Length(CurAccList^) <> 0 then
    ResetTokensList
  else
    exit;

  SL := TStringList.Create;
  SL.Sorted := True;
  SL.Duplicates := TDuplicates.dupIgnore;

  SetLength(CurTokensList^, AmountTokens);

  Randomize;
  try
    for i := 0 to AmountTokens - 1 do
    begin
      with CurTokensList^[i] do
      begin
        Owner := CurAccList^[Random(Length(CurAccList^))].ID;
        Symbol := GenerateTokenName;
        SL.Add(String(Symbol));
        Name := 'Here''s a fullname of token ' + Symbol;
        Decimals := 8;
        Volume := Random(15000000) + 100000;

        t := (Now * 1000 - Random(5000)) / 1000;
        UnixTime := DateTimeToUnix(TDateTime(t));
      end;

      TBI.Token := CurTokensList^[i].Symbol;
      TBI.Sent := 0;
      TBI.Received := 0;
      TBI.TransCount := 0;

      for j := 0 to Length(CurAccList^) - 1 do
      begin
        if (Random(100) >= 50) then
          TBI.Balance := (Random(100) * 10000000 + Random(1000000)) * 0.0000001
        else
          TBI.Balance := 0;

        CurAccList^[j].Money := CurAccList^[j].Money + [TBI];
      end;
    end;
  finally
    SL.Clear;
    SL.Free;
  end;
end;

procedure TTestSource.GenerateTransData(const AmountTrans: Integer);
var
  i, j, idfrom, idto: Integer;
  Stop: UInt64;
  t: Double;
begin
  ResetTransList;

  SetLength(CurTransList^, AmountTrans);
  Randomize;
  t := (Now * 1000 - Random(200)) / 1000;

  for i := AmountTrans - 1 downto 0 do
  begin
    Stop := 0;
    repeat
      if (Stop = 100000000) then
      begin
        ResetTransList;
        exit;
      end;

      idfrom := Random(Length(CurAccList^));

      idto := Random(Length(CurAccList^));
      j := Random(Length(CurTokensList^));

      Inc(Stop);
    until ((idfrom <> idto) and (CurAccList^[idfrom].Money[j].Balance > 0));

    t := (t * 1000 - Random(1000) - 500) / 1000 - Random(3);

    with CurTransList^[i] do
    begin
      Time := t;
      BlockNum := i;
      Hash := BytesEncodeBase58(THashSHA1.GetHashBytes(FloatToStr(Now + Random(1000)))).ToLower;
      FFrom := CurAccList^[idfrom].Address;
      FTo := CurAccList^[idto].Address;
      Token := CurTokensList^[j].Symbol;
      Fee := 0.01 * (Random(4) + 1);

      if Random(100) < 5 then
        Sent := CurAccList^[idfrom].Money[j].Balance
      else
        Sent := (Random(Round(CurAccList^[idfrom].Money[j].Balance * 10000000)) + 1) * 0.0000001;
      Received := Trunc((Sent * (1 - Fee)) * 100000000) * 0.00000001;

      CurAccList^[idfrom].Money[j].Balance := CurAccList^[idfrom].Money[j].Balance - Sent;
      CurAccList^[idto].Money[j].Balance := CurAccList^[idto].Money[j].Balance + Received;

      CurAccList^[idfrom].Money[j].Sent := CurAccList^[idfrom].Money[j].Sent + Sent;
      CurAccList^[idto].Money[j].Received := CurAccList^[idto].Money[j].Received + Received;
      Inc(CurAccList^[idfrom].Money[j].TransCount);
      Inc(CurAccList^[idto].Money[j].TransCount);
    end;

    CurAccList^[idfrom].Transactions := CurAccList^[idfrom].Transactions + [i];
    CurAccList^[idto].Transactions := CurAccList^[idto].Transactions + [i];
  end;
end;

function TTestSource.GetAccCount: Integer;
begin
  Result := Length(CurAccList^);
end;

function TTestSource.GetAccData(const Address, Net: String; Tokens: TStrings): TJSONObject;
var
  i, TransCount: Integer;
  PToken: String;
  PTrans: TTransactionInfo;
  PAcc: TAccountInfoUpd;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  PAcc := GetAccount(Address);
  if (PAcc.ID = -1) then
    exit;

  Result.AddPair('address', PAcc.Address);
  Result.AddPair('id', TJSONNumber.Create(PAcc.ID));

  if (Tokens[0] = 'all') then
  begin
    SetLength(Tokens, 0);
    for i := 0 to Length(CurTokensList^) - 1 do
      Tokens := Tokens + [CurTokensList^[i].Symbol];
  end;

  try
    SL := TStringList.Create;
    SL.Clear;
    SL.Sorted := True;
    SL.Duplicates := TDuplicates.dupIgnore;

    TransCount := 0;
    for PToken in Tokens do
      for i in PAcc.Transactions do
      begin
        PTrans := GetTransByID(i);
        if (String(GetSymbolByStr(PToken)) = String(PTrans.Token)) then
        begin
          SL.Add(PToken);
          Inc(TransCount);
        end;
      end;

    Result.AddPair('trans_count', TJSONNumber.Create(TransCount));
    if (SL.Count = 1) then
    begin
      i := GetTokenIDBySymbol(PToken);
      Result.AddPair('received', TJSONNumber.Create(PAcc.Money[i].Received));
      Result.AddPair('sent', TJSONNumber.Create(PAcc.Money[i].Sent));
      Result.AddPair('balance', TJSONNumber.Create(PAcc.Money[i].Balance));
    end;
  finally
    SL.Clear;
    SL.Free;
  end;
end;

function TTestSource.GetAccIDbyAddress(const Address: String): Integer;
var
  Acc: TAccountInfoUpd;
begin
  Result := -1;
  for Acc in CurAccList^ do
    if (Acc.Address = Address) then
    begin
      Result := Acc.ID;
      break;
    end;
end;

function TTestSource.GetAccDataDetails(const Tab, Address, Net: String; Tokens: TStrings;
  const PageID, Count: Integer; TransType: TTransType; DateFrom, DateTo: String): TJSONObject;
var
  i, j, k, st: Integer;
  LatestTransTimeEver, EarlierTransTimeEver, LatestTransTime, EarlierTransTime, PDateFrom,
    PDateTo: TDateTime;
  FS: TFormatSettings;
  Passed: Boolean;
  PToken: String;
  PAcc: TAccountInfoUpd;
  PTrans: TTransactionInfo;
  PTransArray: TArray<TTransactionInfo>;
  tn: TSymbol;
  TBI: TTokenBalanceInfo;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
  Result := TJSONObject.Create;

  SetCurrentNet(GetNetByStr(Net));

  PAcc := GetAccount(Address);
  if (PAcc.ID = -1) then
    exit;

  if (Tokens[0] = 'all') then
  begin
    SetLength(Tokens, 0);
    for i := 0 to Length(CurTokensList^) - 1 do
      Tokens := Tokens + [CurTokensList^[i].Symbol];
  end;

  try
    SL := TStringList.Create;
    SL.Sorted := True;
    SL.Duplicates := TDuplicates.dupIgnore;

    SetLength(PTransArray, 0);

    EarlierTransTimeEver := 0;
    EarlierTransTime := 0;
    LatestTransTimeEver := Now;
    LatestTransTime := Now;

    FS.DateSeparator := '.';
    FS.TimeSeparator := ':';
    FS.ShortDateFormat := 'dd.mm.yyyy_hh:mm:ss';
    if DateFrom = '' then
      PDateFrom := 0
    else
      PDateFrom := StrToDateTime(DateFrom, FS);
    if DateTo = '' then
      PDateTo := Now
    else
      PDateTo := IncSecond(StrToDateTime(DateTo, FS));

    for PToken in Tokens do
    begin
      for i in PAcc.Transactions do
      begin
        PTrans := GetTransByID(i);
        tn := GetSymbolByStr(PToken);

        if (String(PTrans.Token) = String(tn)) then
        begin
          if (CompareDateTime(PDateFrom, PTrans.Time) <= 0) and
            (CompareDateTime(PDateTo, PTrans.Time) >= 0) then
          begin
            Passed := False;
            case TransType of
              Incoming:
                Passed := (PTrans.FTo = PAcc.Address);
              Outgoing:
                Passed := (PTrans.FFrom = PAcc.Address);
              All:
                Passed := True;
            end;
            if Passed then
            begin
              PTransArray := PTransArray + [PTrans];
              SL.Add(String(tn));

              if PTrans.Time < LatestTransTime then
                LatestTransTime := PTrans.Time;
              if EarlierTransTime < PTrans.Time then
                EarlierTransTime := PTrans.Time;
            end;
          end;
          if PTrans.Time < LatestTransTimeEver then
            LatestTransTimeEver := PTrans.Time;
          if EarlierTransTimeEver < PTrans.Time then
            EarlierTransTimeEver := PTrans.Time;
        end;
      end;
    end;

    if (Tab = 'transactions') then
    begin
      st := (PageID - 1) * Count;
      JSONArr := TJSONArray.Create;

      for i := st to Min(st + Count - 1, Length(PTransArray) - 1) do
      begin
        JSONArr.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

        JSONNestedObject.AddPair('datetime', DateTimeToStr(PTransArray[i].Time));
        JSONNestedObject.AddPair('block_number', TJSONNumber.Create(PTransArray[i].BlockNum));
        JSONNestedObject.AddPair('from', PTransArray[i].FFrom);
        JSONNestedObject.AddPair('to', PTransArray[i].FTo);
        JSONNestedObject.AddPair('hash', PTransArray[i].Hash);
        JSONNestedObject.AddPair('token', String(PTransArray[i].Token));
        JSONNestedObject.AddPair('sent', TJSONNumber.Create(PTransArray[i].Sent));
        JSONNestedObject.AddPair('received', TJSONNumber.Create(PTransArray[i].Received));
        JSONNestedObject.AddPair('fee', TJSONNumber.Create(PTransArray[i].Fee));
      end;

      if Length(PTransArray) <> 0 then
      begin
        Result.AddPair('earlier_trans_date', DateTimeToStr(EarlierTransTime));
        Result.AddPair('latest_trans_date', DateTimeToStr(LatestTransTime));
        Result.AddPair('earlier_trans_date_ever', DateTimeToStr(EarlierTransTimeEver));
        Result.AddPair('latest_trans_date_ever', DateTimeToStr(LatestTransTimeEver));
      end;
      Result.AddPair('trans_count', TJSONNumber.Create(Length(PTransArray)));

      Result.AddPair('list', JSONArr);
    end
    else if (Tab = 'tokens') then
    begin
      st := (PageID - 1) * Count;
      JSONArr := TJSONArray.Create;
      if (SL.Count > 1) then
      begin
        for i := st to Min(st + Count - 1, SL.Count - 1) do
        begin
          TBI := GetBalanceByName(Address, SL.Strings[i]);

          JSONArr.AddElement(TJSONObject.Create);
          JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

          JSONNestedObject.AddPair('name', String(TBI.Token));
          JSONNestedObject.AddPair('balance', TJSONNumber.Create(TBI.Balance));
          JSONNestedObject.AddPair('sent', TJSONNumber.Create(TBI.Sent));
          JSONNestedObject.AddPair('received', TJSONNumber.Create(TBI.Received));
          JSONNestedObject.AddPair('trans_count', TJSONNumber.Create(TBI.TransCount));
        end;
      end;
      Result.AddPair('tokens_count', TJSONNumber.Create(SL.Count));

      Result.AddPair('list', JSONArr);
    end;
  finally
    SL.Clear;
    SL.Free;
  end;
end;

function TTestSource.GetAccount(const ID: Integer): TAccountInfoUpd;
begin
  try
    Result := CurAccList^[ID];
  except
    Result.ID := -1;
  end;
end;

function TTestSource.GetAccount(const Address: String): TAccountInfoUpd;
var
  Acc: TAccountInfoUpd;
begin
  Result.ID := -1;
  for Acc in CurAccList^ do
    if (Acc.Address = Address) then
    begin
      Result := Acc;
      break;
    end;
end;

function TTestSource.GetBalanceByName(Address, TokenName: String): TTokenBalanceInfo;
var
  ID, i: Integer;
  PAcc: TAccountInfoUpd;
begin
  ID := -1;
  PAcc := GetAccount(Address);
  for i := 0 to Length(PAcc.Money) - 1 do
    if (String(PAcc.Money[i].Token) = TokenName) then
    begin
      ID := i;
      break;
    end;
  if ID <> -1 then
    Result := GetAccount(Address).Money[ID];
end;

procedure TTestSource.ResetAccList;
var
  i: Integer;
begin
  for i := 0 to Length(CurAccList^) - 1 do
  begin
    SetLength(CurAccList^[i].Transactions, 0);
    SetLength(CurAccList^[i].Money, 0);
  end;
  SetLength(CurAccList^, 0);
end;

procedure TTestSource.ResetAll;
begin
  SetCurrentNet(ntMain);
  ResetAccList;
  ResetTransList;
  ResetTokensList;

  SetCurrentNet(ntLab);
  ResetAccList;
  ResetTransList;
  ResetTokensList;

  SetCurrentNet(ntTest);
  ResetAccList;
  ResetTransList;
  ResetTokensList;
end;

procedure TTestSource.ResetTokensList;
var
  i: Integer;
begin
  SetLength(CurTokensList^, 0);
  SetLength(CurTransList^, 0);
  for i := 0 to Length(CurAccList^) - 1 do
  begin
    SetLength(CurAccList^[i].Transactions, 0);
    SetLength(CurAccList^[i].Money, 0);
  end;
end;

procedure TTestSource.ResetTransList;
var
  i: Integer;
begin
  SetLength(CurTransList^, 0);
  for i := 0 to Length(CurAccList^) - 1 do
    SetLength(CurAccList^[i].Transactions, 0);
end;

procedure TTestSource.SetCurrentNet(const NetType: TNetType);
begin
  case NetType of

    ntMain:
      begin
        CurAccList := @MainAccList;
        CurTokensList := @MainTokensList;
        CurTransList := @MainTransList;
      end;

    ntLab:
      begin
        CurAccList := @LabAccList;
        CurTokensList := @LabTokensList;
        CurTransList := @LabTransList;
      end;

    ntTest:
      begin
        CurAccList := @TestAccList;
        CurTokensList := @TestTokensList;
        CurTransList := @TestTransList;
      end;

  end;

  HCurrentNet := NetType;
end;

{ TRealSource }

procedure TBlockChainSource.Callback(AArgs: TArray<string>);
begin
  Res := False;
  if AArgs[0] = 'OK' then
    Res := True
  else
    Res := False;
end;

function TBlockChainSource.CheckCryptoContainerKeys(Keys: TStrings; Pass,Net: String): TJSONObject;
var
  KeysStr, Key: String;
  ind: Integer;
begin
  Result := TJSONObject.Create;

  KeysStr := '';
  for Key in Keys do
    KeysStr := KeysStr + ' ' + Key;

  Handler.HandleWebDataControl(CMD_GUI_SET_WORDS, [Trim(KeysStr).ToUpper, Pass], CallBack);
  if Res then
  begin
    ind := Key.LastIndexOf(#$D#$A);
    Result.AddPair('Address', Copy(Key, ind + 3, Length(Key)));
  end;
  Result.AddPair('Result', TJSONBool.Create(Res));
end;

constructor TBlockChainSource.Create(ABlockChain: TBlockChainCore);
begin
  BC := ABlockChain;
end;

destructor TBlockChainSource.Destroy;
begin
  SL.Clear;
  SL.Free;
end;

function TBlockChainSource.GetAccData(const Address, Net: String;
  Tokens: TStrings): TJSONObject;
var
  TransCount: Integer;
  Received,Sent: UInt64;
  AccID: UInt64;
  PToken: String;
  PTokenInfo: TTokensInfoV0;
  PTrans: TTransferInfoV0;
  PAcc: TAccountInfoV0;
  PAccTransactions: TArray<TTransferInfoV0>;
begin
  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit
  else
    PAcc := BC.Inquiries.TryGetAccountInfo(Address);

  Result.AddPair('address', PAcc.Address);
  AccID := BC.Inquiries.TryGetAccountID(Address);
  Result.AddPair('id', TJSONNumber.Create(AccID));

  if (Tokens[0] = 'all') then
  begin
    SetLength(Tokens, 0);
    for PTokenInfo in BC.Inquiries.TryGetTokenInfoAll do
      Tokens := Tokens + [Trim(String(PTokenInfo.Symbol))];
  end;

  try
    SL := TStringList.Create;
    SL.Clear;
    SL.Sorted := True;
    SL.Duplicates := TDuplicates.dupIgnore;

    TransCount := 0;
    PAccTransactions := BC.Inquiries.TryGetAccTransactions(AccID);
    for PToken in Tokens do
      for PTrans in PAccTransactions do
      begin
        if (PToken = Trim(String(BC.Inquiries.TryGetTokenSymbol(PTrans.TokenID)))) then
        begin
          SL.Add(PToken);
          Inc(TransCount);
        end;
      end;

    Result.AddPair('trans_count', TJSONNumber.Create(TransCount));
    if (SL.Count = 1) then
    begin
      Received := 0;
      Sent := 0;
      for PTrans in PAccTransactions do
      begin
        if (SL.Strings[0] = Trim(String(BC.Inquiries.TryGetTokenSymbol(PTrans.TokenID)))) then
          if (PTrans.DirectFrom = AccID) then
            Sent := Sent + PTrans.Amount
          else if (PTrans.DirectTo = AccID) then
            Received := Received + PTrans.Amount;
      end;

      Result.AddPair('received', TJSONNumber.Create(Received));
      Result.AddPair('sent', TJSONNumber.Create(Sent));
      Result.AddPair('balance', TJSONNumber.Create(BC.Inquiries.TryGetBalance(Address, SL.Strings[0])));
    end;
  finally
    SL.Clear;
    SL.Free;
  end;
end;

function TBlockChainSource.GetAccDataDetails(const Tab, Address, Net: String;
  Tokens: TStrings; const PageID, Count: Integer; TransType: TTransType;
  DateFrom, DateTo: String): TJSONObject;
var
  i, st: Integer;
  AccID: UInt64;
  LatestTransTimeEver, EarlierTransTimeEver, LatestTransTime, EarlierTransTime, FDateFrom,
    FDateTo: UInt64;
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
  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit
  else
    FAcc := BC.Inquiries.TryGetAccountInfo(Address);

  if (Tokens[0] = 'all') then
  begin
    SetLength(Tokens, 0);
    for FTokenInfo in BC.Inquiries.TryGetTokenInfoAll do
      Tokens := Tokens + [Trim(String(FTokenInfo.Symbol))];
  end;

  try
    SL := TStringList.Create;
    SL.Sorted := True;
    SL.Duplicates := TDuplicates.dupIgnore;

    SetLength(FTransArray, 0);

    EarlierTransTimeEver := 0;
    EarlierTransTime := 0;
    LatestTransTimeEver := DateTimeToUnix(Now);
    LatestTransTime := DateTimeToUnix(Now);

    FS.DateSeparator := '.';
    FS.TimeSeparator := ':';
    FS.ShortDateFormat := 'dd.mm.yyyy_hh:mm:ss';
    if DateFrom = '' then
      FDateFrom := 0
    else
      FDateFrom := DateTimeToUnix(StrToDateTime(DateFrom, FS));
    if DateTo = '' then
      FDateTo := DateTimeToUnix(Now)
    else
      FDateTo := DateTimeToUnix(IncSecond(StrToDateTime(DateTo, FS)));
    AccID := BC.Inquiries.TryGetAccountID(Address);

    FTransArray := BC.Inquiries.TryGetTransactionHistoryItems(AccID,FDateFrom,FDateTo);
    SetLength(FPassedTransArray,0);
    for FToken in Tokens do
      for FTrans in FTransArray do
      begin
        if (FToken = Trim(String(FTrans.token))) then
        begin
          if (FDateFrom <= FTrans.datetime) and
            (FDateTo >= FTrans.datetime) then
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
              SL.Add(Trim(String(FTrans.token)));
//
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
      st := (PageID - 1) * Count;
      JSONArr := TJSONArray.Create;

      for i := st to Min(st + Count - 1, Length(FPassedTransArray) - 1) do
      begin
        JSONArr.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

        JSONNestedObject.AddPair('datetime', TJSONNumber.Create(FPassedTransArray[i].datetime));
        JSONNestedObject.AddPair('block_number', TJSONNumber.Create(FPassedTransArray[i].block_number));
        JSONNestedObject.AddPair('from', FPassedTransArray[i].Afrom);
        JSONNestedObject.AddPair('to', FPassedTransArray[i].Ato);
        JSONNestedObject.AddPair('hash', FPassedTransArray[i].hash);
        JSONNestedObject.AddPair('token', Trim(String(FPassedTransArray[i].token)));
        JSONNestedObject.AddPair('sent', TJSONNumber.Create(FPassedTransArray[i].sent));
      end;

      if Length(FTransArray) <> 0 then
      begin
        Result.AddPair('earlier_trans_date', TJSONNumber.Create(EarlierTransTime));
        Result.AddPair('latest_trans_date', TJSONNumber.Create(LatestTransTime));
        Result.AddPair('earlier_trans_date_ever', TJSONNumber.Create(EarlierTransTimeEver));
        Result.AddPair('latest_trans_date_ever', TJSONNumber.Create(LatestTransTimeEver));
      end;
      Result.AddPair('trans_count', TJSONNumber.Create(Length(FPassedTransArray)));

      Result.AddPair('list', JSONArr);
    end
    else if (Tab = 'tokens') then
    begin
      st := (PageID - 1) * Count;
      JSONArr := TJSONArray.Create;
      if (SL.Count = 1) then
      begin
        for i := st to Min(st + Count - 1, SL.Count - 1) do
        begin

          JSONArr.AddElement(TJSONObject.Create);
          JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

          JSONNestedObject.AddPair('name', SL.Strings[i]);
          JSONNestedObject.AddPair('balance', TJSONNumber.Create(BC.Inquiries.TryGetBalance(Address, SL.Strings[i])));
          JSONNestedObject.AddPair('sent', TJSONNumber.Create(BC.Inquiries.TryGetSentAmountAllTime(AccId,
                                                              BC.Inquiries.TryGetTokenID(SL.Strings[i]))));
          JSONNestedObject.AddPair('received', TJSONNumber.Create(BC.Inquiries.TryGetReceivedAmountAllTime(AccId,
                                                              BC.Inquiries.TryGetTokenID(SL.Strings[i]))));
          JSONNestedObject.AddPair('trans_count', TJSONNumber.Create(
            BC.Inquiries.TryGetTransCount(AccID,BC.Inquiries.TryGetTokenID(SL.Strings[i]))));
        end;
      end;
      Result.AddPair('tokens_count', TJSONNumber.Create(SL.Count));

      Result.AddPair('list', JSONArr);
      end;
  finally
    SL.Clear;
    SL.Free;
  end;
end;

function TBlockChainSource.GetData(const Name: String; const PageID,
  Count: Integer; const Net: String): TJSONObject;
var
  i, st, Step, endp: Integer;
  JSONArr: TJSONArray;
  JSONNestedObject: TJSONObject;
begin
  Result := TJSONObject.Create;

  st := (PageID - 1) * Count;
  JSONArr := TJSONArray.Create;
  if (Name = 'accounts') or (Name = 'fee') then
  begin
  end
  else if (Name = 'transactions') then
  begin
  end
  else if (Name = 'tokens') then
  begin
  end;
  Result.AddPair('list', JSONArr);
end;

function TBlockChainSource.GetTokenInfoData(const Symbol,    //GetTokenTransCount
  Net: String): TJSONObject;
var
  i, TransCount: Integer;
  TokenInfo: TTokensInfoV0;
begin
end;

function TBlockChainSource.GetTokenListData(const Address, Net: String): TJSONObject;
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
  Result := TJSONObject.Create;

  if not BC.Inquiries.CheckAddress(Address) then
    exit
  else
    PAcc := BC.Inquiries.TryGetAccountInfo(Address);

  JSONArr := TJSONArray.Create;
  for l := 'A' to 'Z' do
  begin
    JSONArr.AddElement(TJSONObject.Create);
    JSONNestedObject := JSONArr.Items[pred(JSONArr.Count)] as TJSONObject;

    PTransArray := BC.Inquiries.TryGetTransactionHistoryItems(BC.Inquiries.TryGetAccountID(Address),0,High(UInt64));

    JSONArrIn := TJSONArray.Create;
    for PTrans in PTransArray do
    begin
      tname := Trim(String(PTrans.token));
      if tname.StartsWith(l) then
      begin
        Found := False;
        for j := 0 to pred(JSONArrIn.Count) do
          if (JSONArrIn.Items[j] as TJSONObject).Values['title'].Value = tname then
            Found := True;
        if not Found then
        begin
          JSONArrIn.AddElement(TJSONObject.Create);
          JSONNestedObjectIn := JSONArrIn.Items[pred(JSONArrIn.Count)] as TJSONObject;

          PToken := BC.Inquiries.TryGetTokenInfo(tname);
          if Found then
          begin
            JSONNestedObjectIn.AddPair('title', Trim(String(PToken.Symbol)));
            JSONNestedObjectIn.AddPair('name', Trim(String(PToken.Name)));
          end;
        end;
      end;
    end;
    JSONNestedObject.AddPair(l, JSONArrIn);
  end;

  Result.AddPair('tokens', JSONArr);
end;

function TBlockChainSource.GetTransData(const Hash, Net: String): TJSONObject;  //GetTransInfo
var
  i, ID: Integer;
begin

end;

end.