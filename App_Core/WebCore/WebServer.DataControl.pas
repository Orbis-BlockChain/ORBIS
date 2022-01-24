unit WebServer.DataControl;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Hash,
  System.JSON,
  App.Log,
  App.Types,
  Crypto.Encoding,
  BlockChain.Core,
  BlockChain.ServiceResult,
  Wallet.Core,
  WebServer.HTTPTypes,
  WebServer.SourceData,
  WebServer.Abstractions;

type

  TPairs = class abstract
  private
    FData: String;
    procedure Reset;
    function GetPosition(const Name: string): TPosition; virtual; abstract;
  public
    constructor Create;
    function GetKeyValue(const Key: String): String; virtual; abstract;
    property Text: String read FData write FData;
  end;

  THeaders = class(TPairs)
  private
    function GetPosition(const Name: string): TPosition; override;
  public
    constructor Create;
    function GetKeyValue(const Key: String): String; override;
    function GetKeyPos(const Name: String): Integer;
    procedure AddHeader(const Key, Value: String);
  end;

  TParams = class(TPairs)
  private
    function GetPosition(const Name: string; Pos: Integer): TPosition;
  public
    constructor Create;
    function GetKeyValue(const Key: String; Pos: Integer): String;
    function GetKeyPos(const Name: String; Pos: Integer): Integer;
    function GetArgsCount: Integer;
  end;

  ReqType = (stGet, stPost, stUnknown);

  TRequest = class
  strict private
    BlockChain: TBlockChainCore;
    StatusCode: Integer;
    ByteData: TBytes;
    StrData: String;
    Method: ReqType;
    URIPath: String;
    HTTPVer: String;
    FHeaders: THeaders;
    procedure Parse;
  public
    constructor Create(const AData: TBytes; ABlockChain: TBlockChainCore = nil);
    procedure Reset;
    property Status: Integer read StatusCode;
    property ByteRequest: TBytes read ByteData write ByteData;
    property StrRequest: String read StrData write StrData;
    property RequestType: ReqType read Method;
    property Path: String read URIPath;
    property HTTPVersion: String read HTTPVer;
    destructor Destroy; override;
  end;

  TResponse = class
  strict private
    FDataSource: IDataSource;
    ByteData: TBytes;
    StrData: String;
    FHeaders: THeaders;
    FParams: TParams;
    procedure AddLine(Line: String);
    procedure AddWords(Words: String);
  public
    constructor Create(const Request: TRequest; ABlockChain: TBlockChainCore = nil; AWalletCore: TWalletCore = nil);
    procedure Reset;
    property ByteAnswer: TBytes read ByteData write ByteData;
    property StrAnswer: String read StrData write StrData;
    destructor Destroy; override;
  end;

implementation

{ TRequest }
//
constructor TRequest.Create(const AData: TBytes; ABlockChain: TBlockChainCore = nil);
begin
  BlockChain := ABlockChain;
  FHeaders := THeaders.Create();
  Reset;
  ByteData := AData;
  StrData := TEncoding.UTF8.GetString(AData);
  Parse;
end;

destructor TRequest.Destroy;
begin
  Reset;
  FHeaders.Free;
end;

procedure TRequest.Parse;
var
  RequestLine: String;
  SubStrPos: Integer;
begin
  SubStrPos := Pos(NL, StrRequest); // Ищем Request line
  if (SubStrPos = 0) then
  begin
    StatusCode := INCORRECT_REQUEST_CODE;
    exit;
  end;
  RequestLine := Copy(StrRequest, 0, SubStrPos - 1);
  StrRequest := Copy(StrRequest, SubStrPos + 2, Length(StrRequest) - SubStrPos);

  SubStrPos := Pos(NL + NL, StrRequest); // Выделяем заголовки
  if (SubStrPos = 0) then
  begin
    StatusCode := INCORRECT_REQUEST_CODE;
    exit;
  end;
  FHeaders.Text := Copy(StrRequest, 0, SubStrPos - 1);

  StrRequest := Copy(StrRequest, SubStrPos + 4, Length(StrRequest) - SubStrPos);
  // остаётся только тело запроса

  if RequestLine.StartsWith('GET') then // далее парсим Request line
    Method := stGet
  else if RequestLine.StartsWith('POST') then
    Method := stPost
  else
  begin
    StatusCode := UNKNOWN_METHOD_CODE;
    exit;
  end;

  // if (Method = stPost) then
  // if (StrRequest = '') then
  // begin
  // StatusCode := INCORRECT_REQUEST_CODE;
  // exit;
  // end;

  SubStrPos := Pos('HTTP/', RequestLine);
  if (SubStrPos = 0) then
  begin
    StatusCode := INCORRECT_REQUEST_CODE;
    exit;
  end;
  HTTPVer := Copy(RequestLine, SubStrPos + 5, 3);
  if (HTTPVer <> '1.1') then
  begin
    StatusCode := UNSUPPORTED_HTTP_VERSION_CODE;
    exit;
  end;

  case Method of
    stGet:
      begin
        URIPath := Trim(Copy(RequestLine, 5, SubStrPos - 5));
      end;

    stPost:
      begin
        URIPath := Trim(Copy(RequestLine, 6, SubStrPos - 6));
      end;
  end;

  if not URIPath.StartsWith(BASE_URI) then
  begin
    StatusCode := INCORRECT_REQUEST_CODE;
    exit;
  end;

  // URIPath := Copy(URIPath,Length(BASE_URI) + 1,Length(URIPath) - Length(BASE_URI));

end;

procedure TRequest.Reset;
begin
  StatusCode := 0;
  SetLength(ByteData, 0);
  StrData := '';
  Method := stUnknown;
  URIPath := '';
  HTTPVer := '';
  FHeaders.Reset;
  // RequestLine := '';
end;

{ THeaders }

procedure THeaders.AddHeader(const Key, Value: String);
begin
  FData := FData + Key + ': ' + Value + NL;
end;

function THeaders.GetKeyPos(const Name: String): Integer;
begin
  Result := (NL + FData.ToLower).IndexOf(NL + Name.ToLower + ':');
end;

constructor THeaders.Create;
begin
  inherited;
end;

function THeaders.GetPosition(const Name: string): TPosition;
var
  Pos, Len: Integer;
begin
  Pos := GetKeyPos(Name);

  Len := Pos;
  Pos := Pos + Length(Name) + 1;

  if Len <> -1 then
    Len := (FData.ToLower + NL).IndexOf(NL, Pos)
  else
    Pos := -1;

  Result.Pos := Pos;
  Result.Len := Len - Pos;
end;

function THeaders.GetKeyValue(const Key: String): String;
var
  P: TPosition;
begin
  P := GetPosition(Key);

  if P.Pos <> -1 then
    Result := Trim(Copy(FData, P.Pos + 1, P.Len))
  else
    Result := '';
end;

{ TPairs }

constructor TPairs.Create;
begin
  Reset;
end;

procedure TPairs.Reset;
begin
  Text := '';
end;

{ TResponse }

procedure TResponse.AddLine(Line: String);
begin
  Self.StrAnswer := Self.StrAnswer + NL + Line;
end;

procedure TResponse.AddWords(Words: String);
begin
  Self.StrAnswer := Self.StrAnswer + ' ' + Words;
end;

constructor TResponse.Create(const Request: TRequest; ABlockChain: TBlockChainCore = nil; AWalletCore: TWalletCore = nil);
var
  JSObj: TJSONObject;
  frstarg, scndarg, thrdarg, frtharg, fiftharg, sixtharg, seventharg, eightharg, nintharg: String;
  pagenum, pagesize, step, i: Integer;
  emission, capacity: UInt64;
  FData: TSRData;
  t1, t2: TDateTime;
  FS: TFormatSettings;
  DblValue, fee: Double;
  Parsed: TStrings;
  Inverse: Boolean;
begin
  FDataSource := TBlockChainSource.Create(ABlockChain, AWalletCore);

  FHeaders := THeaders.Create;
  FParams := TParams.Create;
  Reset;
  Self.StrAnswer := 'HTTP/1.1';
  case Request.Status of
    -1,-2:
      AddWords(ERR_BAD_REQUEST);
    -3:
      AddWords(ERR_IM_A_TEAPOT);
    -4:
      AddWords(ERR_NOT_FOUND);
     0:
      AddWords(REQUEST_OK);
  end;

  Self.FHeaders.AddHeader('Content-Type', 'application/json');
  Self.AddLine(FHeaders.FData);

  if (Request.Status = 0) then
  try
    JSObj := TJSONObject.Create;
    try
      case Request.RequestType of
        stGet:
          begin
            if (Request.Path.ToLower.StartsWith('/api/restore/cryptocontainer/keys/')) then     //done
            begin
            try
              WebServerLog.DoAlert('DataControl.RestoreCryptocontainer','procedureEnter');
              FParams.FData := Copy(Request.Path, 35, Length(Request.Path));
              if (FParams.GetArgsCount <> 2) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('keys', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''keys'' is not found');
              Parsed := Parse(frstarg,'_');
              if Length(Parsed) <> 47 then
                raise Exception.Create('incorrect keys count');

              scndarg := FParams.GetKeyValue('pass', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''pass'' is not found');
              if (Length(scndarg) < 6) then
                raise Exception.Create('incorrect pass argument value (too short)');

              JSObj.Free;
              JSObj := FDataSource.RestoreCryptoContainerKeys(Parsed, scndarg);
              WebServerLog.DoAlert('DataControl.RestoreCryptocontainer','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.RestoreCryptocontainer','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/check/cryptocontainer/keys/')) then     //done
            begin
            try
              WebServerLog.DoAlert('DataControl.CheckCryptocontainer','procedureEnter');
              FParams.FData := Copy(Request.Path, 33, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('keys', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''keys'' is not found');
              Parsed := Parse(frstarg,'_');
              if Length(Parsed) <> 47 then
                raise Exception.Create('incorrect keys count');

              JSObj.Free;
              JSObj := FDataSource.CheckCryptoContainerKeys(Parsed);
              WebServerLog.DoAlert('DataControl.CheckCryptocontainer','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.CheckCryptocontainer','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/create/transaction/')) then        //done
            begin
            try
              WebServerLog.DoAlert('DataControl.CreateTransaction','procedureEnter');
              FParams.FData := Copy(Request.Path, 25, Length(Request.Path));
              if (FParams.GetArgsCount <> 5) then
                raise Exception.Create('bad arguments count');
              WebServerLog.DoAlert('DataControl.CreateTransaction','Pase args');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');
              WebServerLog.DoAlert('DataControl.CreateTransaction','StartPase arg1');

              scndarg := FParams.GetKeyValue('pass', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''pass'' is not found');
              WebServerLog.DoAlert('DataControl.CreateTransaction','StartPase arg2');

              thrdarg := FParams.GetKeyValue('to', 3);
              if (thrdarg = NL) then
                raise Exception.Create('argument ''to'' is not found');
              if (Length(thrdarg) < 22) or (Length(thrdarg) > 64) or (not CheckCorrectName(thrdarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect to argument value');
              WebServerLog.DoAlert('DataControl.CreateTransaction','StartPase arg3');

              frtharg := FParams.GetKeyValue('symbol', 4);
              if (frtharg = NL) then
                raise Exception.Create('argument ''symbol'' is not found');
              WebServerLog.DoAlert('DataControl.CreateTransaction','StartPase arg4');

              fiftharg := FParams.GetKeyValue('amount', 5);
              if (fiftharg = NL) then
                raise Exception.Create('argument ''amount'' is not found');
              if not(TryStrToFloat(fiftharg.Replace(OldDecimalSeparator, DecimalSeparator), DblValue) and (DblValue > 0)) then
                raise Exception.Create('incorrect amount');
              WebServerLog.DoAlert('DataControl.CreateTransaction','StartPase arg5');

              JSObj.Free;
              JSObj := FDataSource.GenNewTransaction(frstarg, scndarg, thrdarg, frtharg.ToUpper, fiftharg.Replace(OldDecimalSeparator, DecimalSeparator));
              WebServerLog.DoAlert('DataControl.CreateTransaction','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.CreateTransaction','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/check/transaction/')) then     //done
            begin
            try
              WebServerLog.DoAlert('DataControl.CheckTransaction','procedureEnter');
              FParams.FData := Copy(Request.Path, 24, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('owner_sign', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''owner_sign'' is not found');
//              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg)) then
//                raise Exception.Create('incorrect to argument value');

              JSObj.Free;
              JSObj := FDataSource.CheckTransaction(frstarg);
              WebServerLog.DoAlert('DataControl.CheckTransaction','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.CheckTransaction','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/create/cryptocontainer/')) then     //done
            begin
            try
              WebServerLog.DoAlert('DataControl.CreateCryptocontainer','procedureEnter');
              FParams.FData := Copy(Request.Path, 29, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('pass', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''pass'' is not found');
              if (Length(frstarg) < 6) then
                raise Exception.Create('password must be at least 6 characters');

              JSObj.Free;
              JSObj := FDataSource.GenNewCrypto(frstarg);
              WebServerLog.DoAlert('DataControl.CreateCryptocontainer','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.CreateCryptocontainer','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/create/token/')) then     //done
            begin
            try
              WebServerLog.DoAlert('DataControl.CreateToken','procedureEnter');
              FParams.FData := Copy(Request.Path, 19, Length(Request.Path));
              if (FParams.GetArgsCount <> 6) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              scndarg := FParams.GetKeyValue('pass', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''pass'' is not found');

              thrdarg := FParams.GetKeyValue('name', 3);
              if (thrdarg = NL) then
              begin
                JSObj.AddPair('item','name');
                raise Exception.Create('argument ''name'' is not found');
              end;
              if (Length(thrdarg) < 1) or (Length(thrdarg) > 32) then
              begin
                JSObj.AddPair('item','name');
                raise Exception.Create('incorrect name argument length');
              end;
              if not CheckCorrectName(thrdarg, TOKEN_NAME_SYMBOLS) then
              begin
                JSObj.AddPair('item','name');
                raise Exception.Create('incorrect name argument value');
              end;

              frtharg := FParams.GetKeyValue('symbol', 4);
              if (frtharg = NL) then
              begin
                JSObj.AddPair('item','symbol');
                raise Exception.Create('argument ''symbol'' is not found');
              end;
              if (Length(frtharg) < 2) or (Length(frtharg) > 4) then
              begin
                JSObj.AddPair('item','symbol');
                raise Exception.Create('incorrect symbol argument length');
              end;
              if not CheckCorrectName(frtharg, TOKEN_NAME_SYMBOLS) then
              begin
                JSObj.AddPair('item','symbol');
                raise Exception.Create('incorrect symbol argument value');
              end;

              fiftharg := FParams.GetKeyValue('emission', 5);
              if (fiftharg = NL) then
              begin
                JSObj.AddPair('item','emission');
                raise Exception.Create('argument ''emission'' is not found');
              end;
              if not(TryStrToUInt64(fiftharg, emission) and (emission > 1)) then
              begin
                JSObj.AddPair('item','emission');
                raise Exception.Create('incorrect emission value');
              end;

              sixtharg := FParams.GetKeyValue('capacity', 6);
              if (sixtharg = NL) then
              begin
                JSObj.AddPair('item','capacity');
                raise Exception.Create('argument ''capacity'' is not found');
              end;
              if not(TryStrToUInt64(sixtharg, capacity) and (capacity > 1) and (capacity < 9)) then
              begin
                JSObj.AddPair('item','capacity');
                raise Exception.Create('incorrect capacity value');
              end;

              JSObj.Free;
              JSObj := FDataSource.GenNewToken(frstarg, scndarg, thrdarg, frtharg.ToUpper + 'O', emission, capacity);
              WebServerLog.DoAlert('DataControl.CreateToken','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.CreateToken','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/buy/om/')) then  //done
            begin
            try
              WebServerLog.DoAlert('DataControl.BuyOM','procedureEnter');
              FParams.FData := Copy(Request.Path, 13, Length(Request.Path));
              if (FParams.GetArgsCount <> 2) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              scndarg := FParams.GetKeyValue('pass', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''pass'' is not found');

              JSObj.Free;
              JSObj := FDataSource.BuyOM(frstarg, scndarg);
              WebServerLog.DoAlert('DataControl.BuyOM','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.BuyOM','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/checkom/')) then
            begin
            try
              WebServerLog.DoAlert('DataControl.CheckOM','procedureEnter');
              FParams.FData := Copy(Request.Path, 14, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              JSObj.Free;
              JSObj := FDataSource.CheckOM(frstarg);

              if JSObj.Count = 0 then
                raise Exception.Create('wallet is not exists');
              WebServerLog.DoAlert('DataControl.CheckOM','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.CheckOM','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/address_balances/')) then
            begin
            try
              WebServerLog.DoAlert('DataControl.AddressBalances','procedureEnter');
              FParams.FData := Copy(Request.Path, 23, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              JSObj.Free;
              JSObj := FDataSource.GetAccBalances(frstarg);

              if not Assigned(JSObj) then
              begin
                JSObj := TJSONObject.Create;
                raise Exception.Create('wallet is not exists');
              end;
              WebServerLog.DoAlert('DataControl.AddressBalances','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.AddressBalances','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/address_info/')) then      //done
            begin
            try
              WebServerLog.DoAlert('DataControl.AddressInfo','procedureEnter');
              FParams.FData := Copy(Request.Path, 19, Length(Request.Path));
              if (FParams.GetArgsCount <> 2) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              scndarg := FParams.GetKeyValue('tokens', 2).ToUpper;
              if (scndarg = NL) then
                raise Exception.Create('argument ''tokens'' is not found');
              Parsed := Parse(scndarg);
              if (Length(Parsed) = 0) or ((Parsed[0] = 'ALL') and (Length(Parsed) <> 1)) then
                raise Exception.Create('incorrect ''tokens'' argument value');

              JSObj.Free;
              JSObj := FDataSource.GetAccData(frstarg,Parsed);

              if JSObj.Count = 0 then
                raise Exception.Create('wallet is not exists');
              WebServerLog.DoAlert('DataControl.AddressInfo','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.AddressInfo','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/address_info_details/')) then   //done
            begin
            try
              WebServerLog.DoAlert('DataControl.AddressInfoDetails','procedureEnter');
              FParams.FData := Copy(Request.Path, 27, Length(Request.Path));
              if (FParams.GetArgsCount <> 5) and (FParams.GetArgsCount <> 6) and
                (FParams.GetArgsCount <> 8) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('tab', 1).ToLower;
              if (frstarg = NL) then
                raise Exception.Create('argument ''tab'' is not found');
              if (frstarg <> 'transactions') and (frstarg <> 'tokens') then
                raise Exception.Create('incorrect tab argument value');

              scndarg := FParams.GetKeyValue('address', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(scndarg) < 22) or (Length(scndarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              thrdarg := FParams.GetKeyValue('tokens', 3).ToUpper;
              if (thrdarg = NL) then
                raise Exception.Create('argument ''tokens'' is not found');
              Parsed := Parse(thrdarg);
              if (Length(Parsed) = 0) or ((Parsed[0] = 'ALL') and (Length(Parsed) <> 1)) then
                raise Exception.Create('incorrect ''tokens'' argument value');

              frtharg := FParams.GetKeyValue('page', 4);
              if (frtharg = NL) then
                raise Exception.Create('argument ''page'' is not found');
              if not(TryStrToInt(frtharg, pagenum) and (pagenum > 0)) then
                raise Exception.Create('incorrect page number');

              fiftharg := FParams.GetKeyValue('pagesize', 5);
              if (fiftharg = NL) then
                raise Exception.Create('argument ''pagesize'' is not found');
              if not(TryStrToInt(fiftharg, pagesize) and (pagesize > 0)) then
                raise Exception.Create('incorrect page size number');

              case FParams.GetArgsCount of
                5:
                  begin
                    JSObj.Free;
                    JSObj := FDataSource.GetAccDataDetails(frstarg,scndarg,Parsed,pagenum,pagesize);
                  end;
                6:
                  begin
                    sixtharg := FParams.GetKeyValue('type', 6).ToLower;
                    if (sixtharg = NL) then
                      raise Exception.Create('argument ''type'' is not found');
                    if not((sixtharg = 'incoming') or (sixtharg = 'outgoing') or (sixtharg = 'all'))
                    then
                      raise Exception.Create('incorrect ''type'' value');

                    JSObj.Free;
                    JSObj := FDataSource.GetAccDataDetails(frstarg,scndarg,Parsed,pagenum,pagesize,
                                                         TTransType(GetEnumValue(TypeInfo(TTransType),sixtharg)));
                  end;
                8:
                  begin
                    FS.DateSeparator := '.';
                    FS.TimeSeparator := ':';
                    FS.ShortDateFormat := 'dd.mm.yyyy_hh:mm:ss';

                    sixtharg := FParams.GetKeyValue('date_from', 6);
                    if (sixtharg = NL) then
                      raise Exception.Create('argument ''date_from'' is not found');
                    if not(TryStrToDateTime(sixtharg, t1, FS) and (t1 > 0)) then
                      raise Exception.Create('incorrect ''date_from'' value');

                    seventharg := FParams.GetKeyValue('date_to', 7);
                    if (seventharg = NL) then
                      raise Exception.Create('argument ''date_to'' is not found');
                    if not(TryStrToDateTime(seventharg, t2, FS) and (t2 > 0) and (t1 <= t2)) then
                      raise Exception.Create('incorrect ''date_to'' value');

                    eightharg := FParams.GetKeyValue('type', 8).ToLower;
                    if (eightharg = NL) then
                      raise Exception.Create('argument ''type'' is not found');
                    if not((eightharg = 'incoming') or (eightharg = 'outgoing') or (eightharg = 'all')) then
                      raise Exception.Create('incorrect ''type'' value');

                    JSObj.Free;
                    JSObj := FDataSource.GetAccDataDetails(frstarg,scndarg,Parsed,pagenum,pagesize,
                                TTransType(GetEnumValue(TypeInfo(TTransType),eightharg)),sixtharg,seventharg);
                  end else
                    raise Exception.Create('bad arguments count');
              end;

              if JSObj.Count = 0 then
                raise Exception.Create('wallet is not exists');
              WebServerLog.DoAlert('DataControl.AddressInfoDetails','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.AddressInfoDetails','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/address_tokens/')) then          //done
            begin
            try
              WebServerLog.DoAlert('DataControl.AddressTokens','procedureEnter');
              FParams.FData := Copy(Request.Path, 21, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect id argument value');

              JSObj.Free;
              JSObj := FDataSource.GetTokenListData(frstarg);
              if JSObj.Count = 0 then
                raise Exception.Create('wallet is not exists');
              WebServerLog.DoAlert('DataControl.AddressTokens','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.AddressTokens','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/general_info/')) then        //done
            begin
            try
              WebServerLog.DoAlert('DataControl.GeneralInfo','procedureEnter');
              FParams.FData := Copy(Request.Path, 19, Length(Request.Path)).ToLower;
              if (FParams.GetArgsCount < 3) or (FParams.GetArgsCount > 5) then
                raise Exception.Create('bad arguments count');

              case FParams.GetArgsCount of
                3:
                  begin
                    frstarg := FParams.GetKeyValue('name', 1);
                    if (frstarg = NL) then
                      raise Exception.Create('argument ''name'' is not found');
                    if not((frstarg = 'accounts') or (frstarg = 'transactions') or (frstarg = 'tokens') or
                          (frstarg = 'services'))
                    then
                      raise Exception.Create('incorrect name argument value');

                    scndarg := FParams.GetKeyValue('page', 2);
                    if (scndarg = NL) then
                      raise Exception.Create('argument ''page'' is not found');
                    if not(TryStrToInt(scndarg, pagenum) and (pagenum > 0)) then
                      raise Exception.Create('incorrect page number');

                    thrdarg := FParams.GetKeyValue('pagesize', 3);
                    if (thrdarg = NL) then
                      raise Exception.Create('argument ''pagesize'' is not found');
                    if not(TryStrToInt(thrdarg, pagesize) and (pagesize > 0)) then
                      raise Exception.Create('incorrect page size number');

                    JSObj.Free;
                    JSObj := FDataSource.GetGlobalData(frstarg,pagenum,pagesize);
                  end;
                5:
                  begin
                    frstarg := FParams.GetKeyValue('name', 1);
                    if (frstarg = NL) then
                      raise Exception.Create('argument ''name'' is not found');
                    if not((frstarg = 'accounts') or (frstarg = 'transactions') or (frstarg = 'tokens') or
                          (frstarg = 'services'))
                    then
                      raise Exception.Create('incorrect name argument value');

                    scndarg := FParams.GetKeyValue('sortby', 2).ToLower;
                    if (scndarg = NL) then
                      raise Exception.Create('argument ''sortby'' is not found');
                    if (frstarg = 'accounts') then
                    begin
                      if not(scndarg = 'datetime') then
                        raise Exception.Create('incorrect sortby argument value');
                    end else
                    if (frstarg = 'transactions') then
                    begin
                      if not((scndarg = 'datetime') or (scndarg = 'blocknum') or
                        (scndarg = 'token') or (scndarg = 'sent')) then
//                        (scndarg = 'received')) then    //позже добавится
                        raise Exception.Create('incorrect sortby argument value');
                    end else
                    if (frstarg = 'tokens') then
                    begin
                      if not((scndarg = 'ownerid') or (scndarg = 'datetime') or
                        (scndarg = 'name') or (scndarg = 'symbol') or
                        (scndarg = 'decimals') or (scndarg = 'volume')) then
                        raise Exception.Create('incorrect sortby argument value');
                    end else
                    if (frstarg = 'services') then
                    begin
                      if not((scndarg = 'datetime') or (scndarg = 'ownerid') or
                        (scndarg = 'name')) then
                        raise Exception.Create('incorrect sortby argument value');
                    end;

                    thrdarg := FParams.GetKeyValue('inverse', 3).ToLower;
                    if (thrdarg = NL) then
                      raise Exception.Create('argument ''inverse'' is not found');
                    if not TryStrToBool(thrdarg,Inverse) then
                      raise Exception.Create('incorrect inverse argument value');

                    frtharg := FParams.GetKeyValue('page', 4);
                    if (frtharg = NL) then
                      raise Exception.Create('argument ''page'' is not found');
                    if not(TryStrToInt(frtharg, pagenum) and (pagenum > 0)) then
                      raise Exception.Create('incorrect page number');

                    fiftharg := FParams.GetKeyValue('pagesize', 5);
                    if (fiftharg = NL) then
                      raise Exception.Create('argument ''pagesize'' is not found');
                    if not(TryStrToInt(fiftharg, pagesize) and (pagesize > 0)) then
                      raise Exception.Create('incorrect page size number');

                    JSObj.Free;
                    JSObj := FDataSource.GetGlobalData(frstarg,pagenum,pagesize,scndarg,Inverse);
                  end;
                6:
                  begin
                    frstarg := FParams.GetKeyValue('parent', 1);
                    if (frstarg = NL) then
                      raise Exception.Create('argument ''parent'' is not found');
                    if not(frstarg = 'tokens') then
                      raise Exception.Create('incorrect parent argument value');

                    scndarg := FParams.GetKeyValue('name', 2);
                    if (scndarg = NL) then
                      raise Exception.Create('argument ''name'' is not found');
                    raise Exception.Create('incorrect name argument value');
//                    if not(scndarg = 'fee') then
//                      raise Exception.Create('incorrect name argument value');

                    thrdarg := FParams.GetKeyValue('sortby', 3).ToLower;
                    if (thrdarg = NL) then
                      raise Exception.Create('argument ''sortby'' is not found');
                    if (scndarg = 'accounts') then
                    begin
                      if not(thrdarg = 'datetime') then
                        raise Exception.Create('incorrect sortby argument value');
                    end else
                    if (scndarg = 'transactions') then
                    begin
                      if not((thrdarg = 'datetime') or (thrdarg = 'blocknum') or
                        (thrdarg = 'token') or (thrdarg = 'sent') or
                        (thrdarg = 'received')) then
                        raise Exception.Create('incorrect sortby argument value');
                    end else
                    if (scndarg = 'tokens') then
                    begin
                      if not((thrdarg = 'ownerid') or (thrdarg = 'datetime') or
                        (thrdarg = 'name') or (thrdarg = 'symbol') or
                        (thrdarg = 'decimals') or (thrdarg = 'volume')) then
                        raise Exception.Create('incorrect sortby argument value');
                    end;

                    frtharg := FParams.GetKeyValue('inverse', 4).ToLower;
                    if (frtharg = NL) then
                      raise Exception.Create('argument ''inverse'' is not found');
                    if not TryStrToBool(frtharg,Inverse) then
                      raise Exception.Create('incorrect inverse argument value');

                    fiftharg := FParams.GetKeyValue('page', 5);
                    if (fiftharg = NL) then
                      raise Exception.Create('argument ''page'' is not found');
                    if not(TryStrToInt(fiftharg, pagenum) and (pagenum > 0)) then
                      raise Exception.Create('incorrect page number');

                    sixtharg := FParams.GetKeyValue('pagesize', 6);
                    if (sixtharg = NL) then
                      raise Exception.Create('argument ''pagesize'' is not found');
                    if not(TryStrToInt(sixtharg, pagesize) and (pagesize > 0)) then
                      raise Exception.Create('incorrect page size number');

                    JSObj.Free;
                    JSObj := FDataSource.GetGlobalData(scndarg,pagenum,pagesize,thrdarg,Inverse);
                  end;
              else
                raise Exception.Create('bad arguments count');
              end;
              WebServerLog.DoAlert('DataControl.GeneralInfo','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.GeneralInfo','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/transaction_info/')) then      //done
            begin
            try
              WebServerLog.DoAlert('DataControl.TransactionInfo','procedureEnter');
              FParams.FData := Copy(Request.Path, 23, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('hash', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''hash'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect hash argument value');

              JSObj.Free;
              JSObj := FDataSource.GetTransData(frstarg);
              if JSObj.Count = 0 then
                raise Exception.Create('transaction is not exists');
              WebServerLog.DoAlert('DataControl.TransactionInfo','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.TransactionInfo','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/balance/')) then     //done
            begin
            try
              WebServerLog.DoAlert('DataControl.Balance','procedureEnter');
              FParams.FData := Copy(Request.Path, 14, Length(Request.Path));
              if (FParams.GetArgsCount <> 2) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              scndarg := FParams.GetKeyValue('token', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''token'' is not found');

              JSObj.Free;
              JSObj := FDataSource.GetWalletBalance(frstarg, scndarg.ToUpper);

              if JSObj.Count = 0 then
                raise Exception.Create('wallet or token is not exists');
              WebServerLog.DoAlert('DataControl.Balance','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.Balance','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/token_info_details/')) then             //done
            begin
            try
              WebServerLog.DoAlert('DataControl.TokenInfoDetails','procedureEnter');
              FParams.FData := Copy(Request.Path, 25, Length(Request.Path)).ToLower;
              if (FParams.GetArgsCount <> 4) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('tab', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''tab'' is not found');
              if (frstarg <> 'transactions') and (frstarg <> 'owners') then
                raise Exception.Create('incorrect tab argument value');

              scndarg := FParams.GetKeyValue('symbol', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''symbol'' is not found');

              thrdarg := FParams.GetKeyValue('page', 3);
              if (thrdarg = NL) then
                raise Exception.Create('argument ''page'' is not found');
              if not(TryStrToInt(thrdarg, pagenum) and (pagenum > 0)) then
                raise Exception.Create('incorrect page number');

              frtharg := FParams.GetKeyValue('pagesize', 4);
              if (frtharg = NL) then
                raise Exception.Create('argument ''pagesize'' is not found');
              if not(TryStrToInt(frtharg, pagesize) and (pagesize > 0)) then
                raise Exception.Create('incorrect page size number');

              JSObj.Free;
              JSObj := FDataSource.GetTokenTransactions(frstarg, scndarg.ToUpper, pagenum, pagesize);
              if JSObj.Count = 0 then
                raise Exception.Create('token is not exists');
              WebServerLog.DoAlert('DataControl.TokenInfoDetails','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.TokenInfoDetails','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/token_info/')) then                      //done
            begin
            try
              WebServerLog.DoAlert('DataControl.TokenInfo','procedureEnter');
              FParams.FData := Copy(Request.Path, 17, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('symbol', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''symbol'' is not found');

              JSObj.Free;
              JSObj := FDataSource.GetTokenInfoData(frstarg.ToUpper);
              if JSObj.Count = 0 then
                raise Exception.Create('token is not exists');
              WebServerLog.DoAlert('DataControl.TokenInfo','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.TokenInfo','procedureError');
            end;
            end
            else

//            if (Request.Path.ToLower.StartsWith('/api/open_wallet/')) then                      //done
//            begin
//            try
//              WebServerLog.DoAlert('DataControl.OpenWallet','procedureEnter');
//              FParams.FData := Copy(Request.Path, 18, Length(Request.Path));
//              if (FParams.GetArgsCount <> 2) then
//                raise Exception.Create('bad arguments count');
//
//              frstarg := FParams.GetKeyValue('address', 1);
//              if (frstarg = NL) then
//                raise Exception.Create('argument ''address'' is not found');
//              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
//                raise Exception.Create('incorrect address argument value');
//
//              scndarg := FParams.GetKeyValue('pass', 2);
//              if (scndarg = NL) then
//                raise Exception.Create('argument ''pass'' is not found');
//
//              JSObj.Free;
//              JSObj := FDataSource.OpenWallet(frstarg, scndarg);
//              WebServerLog.DoAlert('DataControl.OpenWallet','procedureLeave');
//            except
//              on E: Exception do
//              begin
//                JSObj.AddPair('success', TJSONBool.Create(False));
//                JSObj.AddPair('error', E.Message);
//              end
//              else
//                WebServerLog.DoError('DataControl.OpenWallet','procedureError');
//            end;
//            end
//            else

          {$REGION 'Statistics requests'}
            if (Request.Path.ToLower.StartsWith('/api/statistics/')) then       //done
            begin
            try
              WebServerLog.DoAlert('DataControl.Statistics','procedureEnter');
              FParams.FData := Copy(Request.Path, 17, Length(Request.Path)).ToLower;
              if (FParams.GetArgsCount <> 1) and (FParams.GetArgsCount <> 4) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('tab', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''tab'' is not found');
              if (frstarg <> 'validators') then
                raise Exception.Create('incorrect tab argument value');

              case FParams.GetArgsCount of
                1:
                  begin
                    JSObj.Free;
                    JSObj := FDataSource.GetStatisticsData(frstarg);
                  end;
                4:
                  begin
                    FS.DateSeparator := '.';
                    FS.TimeSeparator := ':';
                    FS.ShortDateFormat := 'dd.mm.yyyy_hh:mm:ss';

                    scndarg := FParams.GetKeyValue('date_from', 2);
                    if (scndarg = NL) then
                      raise Exception.Create('argument ''date_from'' is not found');
                    if not(TryStrToDateTime(scndarg, t1, FS) and (t1 > 0)) then
                      raise Exception.Create('incorrect ''date_from'' value');

                    thrdarg := FParams.GetKeyValue('date_to', 3);
                    if (thrdarg = NL) then
                      raise Exception.Create('argument ''date_to'' is not found');
                    if not(TryStrToDateTime(thrdarg, t2, FS) and (t2 > 0) and (t1 <= t2))
                    then
                      raise Exception.Create('incorrect ''date_to'' value');

                    frtharg := FParams.GetKeyValue('step', 4);
                    if (frtharg = NL) then
                      raise Exception.Create('argument ''date_to'' is not found');
                    if not(TryStrToInt(frtharg, step) and (step > 0)) then
                      raise Exception.Create('incorrect page size number');

                    JSObj.Free;
                    JSObj := FDataSource.GetStatisticsData(frstarg, scndarg, thrdarg, step);
                  end;
              end;
              WebServerLog.DoAlert('DataControl.Statistics','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.Statistics','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/mining_info/')) then       //done
            begin
            try
              WebServerLog.DoAlert('DataControl.MiningInfo','procedureEnter');
              FParams.FData := Copy(Request.Path, 18, Length(Request.Path)).ToLower;
              if (FParams.GetArgsCount <> 0) then
                raise Exception.Create('no arguments expected');

              JSObj.Free;
              JSObj := FDataSource.GetMiningData;

              WebServerLog.DoAlert('DataControl.MiningInfo','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.MiningInfo','procedureError');
            end;
            end
            else
          {$ENDREGION}

          {$REGION 'Services requests'}
            if (Request.Path.ToLower.StartsWith('/api/create/service/')) then       //done
            begin
            try
              WebServerLog.DoAlert('DataControl.CreateService','procedureEnter');
              FParams.FData := Copy(Request.Path, 21, Length(Request.Path));
              if (FParams.GetArgsCount <> 3) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              scndarg := FParams.GetKeyValue('pass', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''pass'' is not found');

              thrdarg := FParams.GetKeyValue('name', 3);
              if (thrdarg = NL) then
                raise Exception.Create('argument ''name'' is not found');
              thrdarg := FixSymbols(thrdarg);
              if (Length(thrdarg) < 1) or (Length(thrdarg) > 32) or
                (not CheckCorrectName(thrdarg, SERVICE_NAME_SYMBOLS)) then
                raise Exception.Create('incorrect name argument value');

              JSObj.Free;
              JSObj := FDataSource.RegNewService(frstarg, scndarg, Trim(thrdarg));
              WebServerLog.DoAlert('DataControl.CreateService','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.CreateService','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/service/set_data/')) then      //done
            begin
            try
              WebServerLog.DoAlert('DataControl.ServiceSetData','procedureEnter');
              FParams.FData := Copy(Request.Path, 23, Length(Request.Path));
              if (FParams.GetArgsCount <> 4) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('address', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''address'' is not found');
              if (Length(frstarg) < 22) or (Length(frstarg) > 64) or (not CheckCorrectName(frstarg, WALLET_ADDRESS_SYMBOLS)) then
                raise Exception.Create('incorrect address argument value');

              scndarg := FParams.GetKeyValue('pass', 2);
              if (scndarg = NL) then
                raise Exception.Create('argument ''pass'' is not found');

              thrdarg := FParams.GetKeyValue('name', 3);
              if (thrdarg = NL) then
                raise Exception.Create('argument ''name'' is not found');
              thrdarg := FixSymbols(thrdarg);
              if (Length(thrdarg) < 1) or (Length(thrdarg) > 32) or
                (not CheckCorrectName(thrdarg, SERVICE_NAME_SYMBOLS)) then
                raise Exception.Create('incorrect name argument value');

              frtharg := FParams.GetKeyValue('data', 4);
              if (frtharg = NL) then
                raise Exception.Create('argument ''data'' is not found');
              if (Length(frtharg) < 1) then
                raise Exception.Create('incorrect data argument value');

              var Bytes := TEncoding.ANSI.GetBytes(FixSymbols(frtharg));
              if Length(Bytes) > 100 then
                raise Exception.Create('incorrect data argument size(must be not more than 100 bytes)')
              else
              begin
                FillChar(FData[0],Length(FData),0);
                Move(Bytes[0],FData[0],Length(Bytes));
              end;

              JSObj.Free;
              JSObj := FDataSource.SetServiceData(frstarg, scndarg, Trim(thrdarg), FData);
              WebServerLog.DoAlert('DataControl.ServiceSetData','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.ServiceSetData','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/service/get_data/')) then         //done
            begin
            try
              WebServerLog.DoAlert('DataControl.ServiceGetData','procedureEnter');
              FParams.FData := Copy(Request.Path, 23, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('name', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''name'' is not found');
              frstarg := FixSymbols(frstarg);
              if (Length(frstarg) < 1) or (Length(frstarg) > 32) or
                (not CheckCorrectName(frstarg, SERVICE_NAME_SYMBOLS)) then
                raise Exception.Create('incorrect name argument value');

              JSObj.Free;
              JSObj := FDataSource.GetServiceData(Trim(frstarg));
//              JSObj := FDataSource.SetServiceData(Trim(frstarg), FData);
              WebServerLog.DoAlert('DataControl.ServiceGetData','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.ServiceGetData','procedureError');
            end;
            end
            else

            if (Request.Path.ToLower.StartsWith('/api/service_info/')) then             //done
            begin
            try
              WebServerLog.DoAlert('DataControl.ServiceInfo','procedureEnter');
              FParams.FData := Copy(Request.Path, 19, Length(Request.Path));
              if (FParams.GetArgsCount <> 1) then
                raise Exception.Create('bad arguments count');

              frstarg := FParams.GetKeyValue('name', 1);
              if (frstarg = NL) then
                raise Exception.Create('argument ''name'' is not found');
              frstarg := FixSymbols(frstarg);
              if (Length(frstarg) < 1) or (Length(frstarg) > 32) or
                (not CheckCorrectName(frstarg, SERVICE_NAME_SYMBOLS)) then
                raise Exception.Create('incorrect name argument value');

              JSObj.Free;
              JSObj := FDataSource.GetServiceInfo(Trim(frstarg));
              if JSObj.Count = 0 then
                raise Exception.Create('service is not exists');
              WebServerLog.DoAlert('DataControl.ServiceInfo','procedureLeave');
            except
              on E: Exception do
              begin
                JSObj.AddPair('success', TJSONBool.Create(False));
                JSObj.AddPair('error', E.Message);
              end
              else
                WebServerLog.DoError('DataControl.ServiceInfo','procedureError');
            end;
            end
          {$ENDREGION}
            else
              raise Exception.Create('bad request');
          end;

        stPost:
          begin
//
//            else
              raise Exception.Create('bad request');
          end;
      end;
    except
      on E: Exception do
      begin
        JSObj.AddPair('success', TJSONBool.Create(False));
        JSObj.AddPair('error', E.Message);
      end;
    end;
  finally
    Self.AddLine(JSObj.ToString);
    JSObj.Free;
  end;

  Self.ByteData := TEncoding.UTF8.GetBytes(Trim(Self.StrData));
end;

destructor TResponse.Destroy;
begin
  Reset;
  FHeaders.Free;
  FParams.Free;
end;

procedure TResponse.Reset;
begin
  SetLength(ByteData, 0);
  StrData := '';
  FHeaders.Reset;
  FParams.Reset;
end;

{ TParams }

constructor TParams.Create;
begin
  inherited;
end;

function TParams.GetKeyPos(const Name: String; Pos: Integer): Integer;
var
  i: Integer;
begin
  if (Pos = 1) then
  begin
    if (FData.ToLower.IndexOf('?' + Name.ToLower) = 0) then
      Result := 0
    else
      Result := -1;
  end
  else
  begin
    Result := 0;
    for i := 2 to Pos do
      Result := FData.ToLower.IndexOf('&', Result + 1);
    if (Copy(FData, Result + 2, Length(Name)) <> Name) then
      Result := -1;
  end;
end;

function TParams.GetPosition(const Name: string; Pos: Integer): TPosition;
var
  ind, Len: Integer;
begin
  ind := GetKeyPos(Name, Pos);

  Len := ind;
  ind := ind + Length(Name) + 1;

  if Len <> -1 then
  begin
    Len := FData.ToLower.IndexOf('=', ind);
    if Len <> ind then
    begin
      ind := -1;
      Len := -1;
    end
    else
    begin
      Len := FData.ToLower.IndexOf('&', Len);
      if (Len = -1) then
        Len := Length(FData.ToLower);
    end;
  end
  else
    ind := -1;

  Result.Pos := ind;
  Result.Len := Len - ind;
end;

function TParams.GetArgsCount: Integer;
var
  Pos: Integer;
begin
  Result := 0;
  if Length(FData) = 0 then
    exit;

  Pos := 1;
  if not(FData[Pos] = '?') then
    exit
  else
    Inc(Result);

  while Pos < Length(FData) do
  begin
    if (FData[Pos] = '&') then
      Inc(Result);
    Inc(Pos);
  end;
end;

function TParams.GetKeyValue(const Key: String; Pos: Integer): String;
var
  P: TPosition;
begin
  P := GetPosition(Key, Pos);

  if P.Pos <> -1 then
    Result := Trim(Copy(FData, P.Pos + 2, P.Len - 1))
  else
    Result := NL;
end;

end.
