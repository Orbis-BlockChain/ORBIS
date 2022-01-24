unit WebServer.HTTPTypes;

interface

uses
  SysUtils,
  System.TypInfo,
  App.Types;

const
  NL = #13#10;
  RHCount = 5;
  BASE_URI = '/api/';
  WALLET_ADDRESS_LENGTH = 40;

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
    Ind := Pos + 2;

    Inc(Pos);
    Pos := Arg.ToLower.IndexOf(Delimeter, Pos);
  end;

  Result := Result + [Copy(Arg, Ind, Length(Arg))];
end;

function GetNetByStr(Str: String): TNetType;
begin
  Result := TNetType(GetEnumValue(TypeInfo(TNetType), 'nt' + Str));
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
