unit WebServer.HTTPTypes;

interface

uses
  SysUtils,
  System.TypInfo,
  App.Types,
  BlockChain.ServiceResult;

const
  NL = #13#10;
  RHCount = 5;
  BASE_URI = '/api/';

  WALLET_ADDRESS_SYMBOLS = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  TOKEN_NAME_SYMBOLS = 'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm';
  SERVICE_NAME_SYMBOLS = 'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm0123456789!@#$%^*()_+}{":?><¹;-=[]'',./`~ ';
  NO_STARTS_WITH_SYMBOLS = '!@#$%^*()_+}{":?><¹;-=[]'',./\|`~ ';

  INCORRECT_REQUEST_CODE = -1;
  UNKNOWN_METHOD_CODE = -2;
  UNSUPPORTED_HTTP_VERSION_CODE = -3;
  NOT_FOUND_CODE = -4;

  ERR_BAD_REQUEST = '400 Bad Request';
  ERR_IM_A_TEAPOT = '418 I''m a Teapot';
  ERR_NOT_FOUND = '404 Not Found';
  REQUEST_OK = '200 OK';

type

  TTransType = (Incoming, Outgoing, All);
  TNetType = (ntMain, ntLab, ntTest);

  TTokenBalanceInfo = record
    Token: TSymbol;
    Balance: Extended;
    Sent: Extended;
    Received: Extended;
    TransCount: Integer;
  end;

  TAccountInfoUpd = record
    // AccInfoV0: TAccountInfoV0;
    Id: Integer;
    PubKey: String;
    Address: String;
    Time: TDateTime;
    RegDate: TDateTime;
    Money: array of TTokenBalanceInfo;
    Transactions: array of Integer;
  end;

  TTokensInfo = packed record // 128
    Owner: UINT64;
    Name: TName;
    Symbol: TSymbol;
    Decimals: UINT64;
    Volume: int64;
    // TokenType: TTokenTypes;
    UnixTime: Integer;
    class operator Implicit(Buf: TTokensInfo): TBytes;
    class operator Implicit(Buf: TBytes): TTokensInfo;
    class operator Add(buf1: TBytes; buf2: TTokensInfo): TBytes;
    class operator Add(buf2: TTokensInfo; buf1: TBytes): TBytes;
    function GetSize: Integer;
  end;

  TTransactionInfo = record
    Time: TDateTime;
    BlockNum: Integer;
    FFrom: String;
    FTo: String;
    Hash: String;
    Token: TSymbol;
    Sent: Extended;
    Received: Extended;
    Fee: Double;
  end;

  TPosition = record
    Pos: Integer;
    Len: Integer;
  end;

  TStrings = TArray<String>;
  TAccInfoList = TArray<TAccountInfoUpd>;
  TTransInfoList = TArray<TTransactionInfo>;
  TTokensInfoList = TArray<TTokensInfo>;

function Parse(Arg: String; Delimeter: String = '_'): TStrings;
function GetNetByStr(Str: String): TNetType;
function CheckCorrectName(Name, Alphabet: String): Boolean;
function GetTSRDataIntoString(Bytes: TSRData; Delimeter: String = ' '): String;
function GetStringIntoTSRData(InString: String; Delimeter: String = ' '): TSRData;
function FixSymbols(InString: String): String;

implementation

function Parse(Arg: String; Delimeter: String = '_'): TStrings;
var
  Pos, Ind: Integer;
begin
  Pos := 1;
  Ind := 1;

  Pos := Arg.ToLower.IndexOf(Delimeter, Ind);
  while Pos <> -1 do
  begin
    Result := Result + [Copy(Arg, Ind, Pos - Ind + 1)];
    Ind := Pos + Length(Delimeter) + 1;

    Inc(Pos);
    Pos := Arg.ToLower.IndexOf(Delimeter, Pos);
  end;

  Result := Result + [Copy(Arg, Ind, Length(Arg))];
end;

function GetNetByStr(Str: String): TNetType;
begin
  Result := TNetType(GetEnumValue(TypeInfo(TNetType), 'nt' + Str));
end;

function CheckCorrectName(Name, Alphabet: String): Boolean;
var
  i: Integer;
begin
  Result := True;
  if (NO_STARTS_WITH_SYMBOLS.IndexOf(Name[1]) <> -1) then
    Exit(False);
  for i := 1 to Length(Name) do
    if Alphabet.IndexOf(Name[i]) = -1 then
      Exit(False);
end;

{ TTokensInfo }

class operator TTokensInfo.Add(buf2: TTokensInfo; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTokensInfo));
  Move(buf2, LData[0], SizeOf(TTokensInfo));
  RData := LData + RData;
  Result := RData;
end;

class operator TTokensInfo.Add(buf1: TBytes; buf2: TTokensInfo): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TTokensInfo));
  Move(buf2, LData[0], SizeOf(TTokensInfo));
  RData := RData + LData;
  Result := RData;
end;

function GetTSRDataIntoString(Bytes: TSRData; Delimeter: String = ' '): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Length(Bytes) - 1 do
    Result := Result + Bytes[i].ToString + Delimeter;
  Result := Trim(Result);
end;

function GetStringIntoTSRData(InString: String; Delimeter: String = ' '): TSRData;
begin
  var
    buf: TBytes := TEncoding.ANSI.GetBytes(Trim(InString));
  FillChar(Result[0],Length(Result),0);
  Move(buf[0],Result[0],Length(buf));
end;

function FixSymbols(InString: String): String;
begin
  Result := InString;
  Result := Result.Replace('%23','#');
  Result := Result.Replace('%22','"');
  Result := Result.Replace('%3E','>');
  Result := Result.Replace('%3C','<');
  Result := Result.Replace('%E2%84%96','¹');
  Result := Result.Replace('%27',chr(39));
  Result := Result.Replace('%20',' ');
end;

function TTokensInfo.GetSize: Integer;
begin
  Result := SizeOf(self);
end;

class operator TTokensInfo.Implicit(Buf: TBytes): TTokensInfo;
begin
  Move(Buf[0], Result, SizeOf(TTokensInfo));
end;

class operator TTokensInfo.Implicit(Buf: TTokensInfo): TBytes;
begin
  SetLength(Result, SizeOf(TTokensInfo));
  Move(Buf, Result[0], SizeOf(TTokensInfo));
end;

end.
