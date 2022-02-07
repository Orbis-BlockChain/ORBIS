unit App.Types;

interface

uses
  App.Paths,
  App.Log,
  App.Notifyer,
  App.Meta,
  Translate.Core,
  System.Sysutils,
  System.Classes,
  System.StrUtils,
  Crypto.Encoding;

const
  SIZE_PRIVATE_KEY = 424;
  SIZE_PUBLIC_KEY = 96;
  SPEAKER_DELAY = 500;

  NaN = 18446744073709551615;

type
  TNET = (MAINNET, TESTNET, LABNET);

  TNodeState = (Validator, FullNode, Client, Speaker, Invalid);

  TMessageState = (Normal, Error, Allert);

  TUint64Helper = record helper for UINt64
    function AsBytes: TBytes;
    function AsString: string;
    procedure SetBytes(AData: TBytes);
  end;

  TIntegerHelper = record helper for
    integer

  const
    MaxValue = 2147483647;
    MinValue = -2147483648;

    function AsBytes: TBytes;
    function ToString: string; overload; inline;
    function ToBoolean: Boolean; inline;
    function ToHexString: string; overload; inline;
    function ToSingle: Single; inline;
    function ToDouble: Double; inline;
    function ToExtended: Extended; inline;

    class function Size: integer; inline; static;
    class function ToString(const Value: integer): string; overload; inline; static;
    class function TryParse(const S: string; out Value: integer): Boolean; inline; static;
  end;

  Strings = TArray<string>;

  StringsHelper = record helper for Strings
    procedure SetStrings(const AValue: string);
    function Length: UINt64;
    function AsString(const Splitter: string): string;
    function IsEmpty: Boolean;
  end;

  THash = packed record
    Hash: array [0 .. 31] of Byte;
    class operator Implicit(Buf: THash): string;
    class operator Implicit(Buf: THash): TBytes;
    class operator Implicit(Buf: string): THash;
    class operator Implicit(Buf: TBytes): THash;
    class operator Add(buf1: TBytes; buf2: THash): TBytes;
    class operator Add(buf2: THash; buf1: TBytes): TBytes;
    class operator Add(buf1: string; buf2: THash): string;
    class operator Add(buf2: THash; buf1: string): string;
    class operator Equal(a, b: THash): Boolean;
    procedure Clear;
  end;

  TSignedHash = packed record
    SignedHash: array [0 .. 63] of Byte;
    class operator Implicit(Buf: TSignedHash): string;
    class operator Implicit(Buf: TSignedHash): TBytes;
    class operator Implicit(Buf: string): TSignedHash;
    class operator Implicit(Buf: TBytes): TSignedHash;
    class operator Add(buf1: TBytes; buf2: TSignedHash): TBytes;
    class operator Add(buf2: TSignedHash; buf1: TBytes): TBytes;
    class operator Equal(a, b: TSignedHash): Boolean;
    procedure Clear;
  end;

  TPrivateKey = packed record
    PrivateKey: array [0 .. SIZE_PRIVATE_KEY - 1] of Byte;
    class operator Implicit(Buf: TPrivateKey): string;
    class operator Implicit(Buf: TPrivateKey): TBytes;
    class operator Implicit(Buf: string): TPrivateKey;
    class operator Implicit(Buf: TBytes): TPrivateKey;
    class operator Add(buf1: TBytes; buf2: TPrivateKey): TBytes;
    class operator Add(buf2: TPrivateKey; buf1: TBytes): TBytes;
    procedure Clear;
  end;

  TPublicKey = packed record
    PublicKey: array [0 .. SIZE_PUBLIC_KEY - 1] of Byte;
    class function Empty: TPublicKey; static;
    class operator Implicit(Buf: TPublicKey): string;
    class operator Implicit(Buf: TPublicKey): TBytes;
    class operator Implicit(Buf: string): TPublicKey;
    class operator Implicit(Buf: TBytes): TPublicKey;
    class operator Add(buf1: TBytes; buf2: TPublicKey): TBytes;
    class operator Add(buf2: TPublicKey; buf1: TBytes): TBytes;
    procedure Clear;
  end;

  TName = packed record
    Name: array [0 .. 31] of Byte;
    class operator Implicit(Buf: TName): string;
    class operator Implicit(Buf: TName): TBytes;
    class operator Implicit(Buf: string): TName;
    class operator Implicit(Buf: TBytes): TName;
    class operator Add(buf1: TBytes; buf2: TName): TBytes;
    class operator Add(buf2: TName; buf1: TBytes): TBytes;
    class operator Add(buf1: string; buf2: TName): string;
    class operator Add(buf2: TName; buf1: string): string;
    class operator Equal(AName: TName; AString: string): Boolean;

  end;

  TSymbol = packed record
    Symbol: array [0 .. 4] of Byte;
    class operator Implicit(Buf: TSymbol): string;
    class operator Implicit(Buf: TSymbol): TBytes;
    class operator Implicit(Buf: string): TSymbol;
    class operator Implicit(Buf: TBytes): TSymbol;
    class operator Add(buf1: TBytes; buf2: TSymbol): TBytes;
    class operator Add(buf2: TSymbol; buf1: TBytes): TBytes;
    class operator Add(buf1: string; buf2: TSymbol): string;
    class operator Add(buf2: TSymbol; buf1: string): string;
    class operator Equal(ASymbol: TSymbol; AString: string): Boolean;
  end;

  TCallBack = procedure(Arg1: TArray<string>) of object;

procedure ChangeConnected(AValue: Boolean);
function FloatEToString(Value:double):string;
function UInt64ToFloatingString(const Decimal, Value: UInt64): string;
var
  DecimalSeparator, OldDecimalSeparator : string;
  AutoConnect: Boolean;
  Paths: IBasePaths;
  NodeState: TNodeState;
  NetState: TNET;
  Connected: Boolean;
  Notifyer: TNotifyer;
  Trnaslator: TTranslateCore;
  CurrentLanguage: App.Meta.TLanguages;

implementation

function FloatEToString(Value:double):string;
begin
  result:= FormatFloat('#################0.########',Value);
end;

function UInt64ToFloatingString(const Decimal, Value: UInt64): string;
var
  returnValue: string;
begin
  ReturnValue := Value.AsString;
  if Length(ReturnValue)>decimal then
  begin
    ReturnValue := Copy(ReturnValue,1,Length(ReturnValue) - decimal)+'.'+Copy(ReturnValue,Length(ReturnValue) - decimal,decimal);
  end
  else
  begin

  end;

end;

procedure ChangeConnected(AValue: Boolean);
begin
  TThread.Queue(nil,
    procedure
    begin
      Connected := AValue;
      if Connected then
        Notifyer.DoEvent(TEvents.nOnMainConnect)
      else
        Notifyer.DoEvent(TEvents.nOnMainDisconnect);
    end);
end;

{$REGION 'StringsHelper'}

function StringsHelper.AsString(const Splitter: string): string;
var
  Value: string;
begin
  Result := '';
  for Value in Self do
    Result := Result + Splitter + Value;
end;

procedure StringsHelper.SetStrings(const AValue: string);
begin
  Self := SplitString(AValue, ' ');
end;

function StringsHelper.IsEmpty: Boolean;
begin
  Result := Length = 0;
end;

function StringsHelper.Length: UINt64;
begin
  Result := System.Length(Self);
end;
{$ENDREGION}
{$REGION 'THash'}

class operator THash.Implicit(Buf: THash): TBytes;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(THash));
  Move(Buf.Hash[0], Data[0], SizeOf(THash));
  Result := Data;
end;

class operator THash.Implicit(Buf: THash): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(THash));
  Move(Buf.Hash[0], Data[0], SizeOf(THash));
  Result := BytesEncodeBase58(Data);
end;

class operator THash.Add(buf1: TBytes; buf2: THash): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(THash));
  Move(buf2.Hash[0], LData[0], SizeOf(THash));
  RData := RData + LData;
  Result := RData;
end;

class operator THash.Add(buf2: THash; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(THash));
  Move(buf2.Hash[0], LData[0], SizeOf(THash));
  RData := LData + RData;
  Result := RData;
end;

class operator THash.Add(buf2: THash; buf1: string): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(THash));
  Move(buf2.Hash[0], Data[0], SizeOf(THash));
  Result := BytesEncodeBase58(Data) + buf1;
end;

class operator THash.Add(buf1: string; buf2: THash): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(THash));
  Move(buf2.Hash[0], Data[0], SizeOf(THash));
  Result := buf1 + BytesEncodeBase58(Data);
end;

procedure THash.Clear;
begin
  fillchar(Hash[0], SizeOf(Hash), 0);
end;

class operator THash.Equal(a, b: THash): Boolean;
begin
  Result := CompareMem(a, b, SizeOf(THash));
end;

class operator THash.Implicit(Buf: TBytes): THash;
var
  RHash: THash;
begin
  Move(Buf[0], RHash.Hash[0], Length(Buf));
  Result := RHash;
end;

class operator THash.Implicit(Buf: string): THash;
var
  RHash: THash;
  Data: TBytes;
begin
  Data := BytesDecodeBase58(Buf);

  if Length(Data) < SizeOf(RHash.Hash) then
    Move(Data[0], RHash.Hash[0], Length(Data))
  else
    Move(Data[0], RHash.Hash[0], SizeOf(RHash.Hash));
  Result := RHash;
end;
{$ENDREGION}
{$REGION 'TSignedHash'}

class operator TSignedHash.Add(buf1: TBytes; buf2: TSignedHash): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TSignedHash));
  Move(buf2.SignedHash[0], LData[0], SizeOf(TSignedHash));
  RData := RData + LData;
  Result := RData;
end;

class operator TSignedHash.Add(buf2: TSignedHash; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TSignedHash));
  Move(buf2.SignedHash[0], LData[0], SizeOf(TSignedHash));
  RData := LData + RData;
  Result := RData;
end;

procedure TSignedHash.Clear;
begin
  fillchar(SignedHash[0], SizeOf(SignedHash), 0);
end;

class operator TSignedHash.Equal(a, b: TSignedHash): Boolean;
begin
  Result := CompareMem(a, b, SizeOf(TSignedHash));
end;
class operator TSignedHash.Implicit(Buf: TSignedHash): TBytes;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TSignedHash));
  Move(Buf.SignedHash[0], Data[0], SizeOf(TSignedHash));
  Result := Data;
end;

class operator TSignedHash.Implicit(Buf: TSignedHash): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TSignedHash));
  Move(Buf.SignedHash[0], Data[0], SizeOf(TSignedHash));
  Result := BytesEncodeBase58(Data);
end;

class operator TSignedHash.Implicit(Buf: string): TSignedHash;
var
  RHash: TSignedHash;
  Data: TBytes;
begin
  Data := BytesDecodeBase58(Buf);
  Move(Data[0], RHash.SignedHash[0], Length(Data));
  Result := RHash;
end;

class operator TSignedHash.Implicit(Buf: TBytes): TSignedHash;
var
  RHash: TSignedHash;
begin
  Move(Buf[0], RHash.SignedHash[0], Length(Buf));
  Result := RHash;
end;
{$ENDREGION}
{$REGION 'TPrivateKey'}

class operator TPrivateKey.Add(buf1: TBytes; buf2: TPrivateKey): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TPrivateKey));
  Move(buf2.PrivateKey[0], LData[0], SizeOf(TPrivateKey));
  RData := RData + LData;
  Result := RData;
end;

class operator TPrivateKey.Add(buf2: TPrivateKey; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TPrivateKey));
  Move(buf2.PrivateKey[0], LData[0], SizeOf(TPrivateKey));
  RData := LData + RData;
  Result := RData;
end;

procedure TPrivateKey.Clear;
begin
  fillchar(PrivateKey[0], SizeOf(PrivateKey), 0);
end;

class operator TPrivateKey.Implicit(Buf: TPrivateKey): TBytes;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TPrivateKey));
  Move(Buf.PrivateKey[0], Data[0], SizeOf(TPrivateKey));
  Result := Data;
end;

class operator TPrivateKey.Implicit(Buf: TPrivateKey): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TPrivateKey));
  Move(Buf.PrivateKey[0], Data[0], SizeOf(TPrivateKey));
  Result := BytesEncodeBase58(Data);
end;

class operator TPrivateKey.Implicit(Buf: string): TPrivateKey;
var
  RKey: TPrivateKey;
  Data: TBytes;
begin
  Data := BytesDecodeBase58(Buf);
  Move(Data[0], RKey.PrivateKey[0], Length(Data));
  Result := RKey;
end;

class operator TPrivateKey.Implicit(Buf: TBytes): TPrivateKey;
var
  RKey: TPrivateKey;
begin
  Move(Buf[0], RKey.PrivateKey[0], Length(Buf));
  Result := RKey;
end;
{$ENDREGION}
{$REGION 'TPublicKey'}

class operator TPublicKey.Add(buf1: TBytes; buf2: TPublicKey): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TPublicKey));
  Move(buf2.PublicKey[0], LData[0], SizeOf(TPublicKey));
  RData := RData + LData;
  Result := RData;
end;

class operator TPublicKey.Add(buf2: TPublicKey; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TPublicKey));
  Move(buf2.PublicKey[0], LData[0], SizeOf(TPublicKey));
  RData := LData + RData;
  Result := RData;
end;

procedure TPublicKey.Clear;
begin
  fillchar(PublicKey[0], SizeOf(PublicKey), 0);
end;

class function TPublicKey.Empty: TPublicKey;
begin
  fillchar(Result.PublicKey, Length(Result.PublicKey), 0);
end;

class operator TPublicKey.Implicit(Buf: TPublicKey): TBytes;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TPublicKey));
  Move(Buf.PublicKey[0], Data[0], SizeOf(TPublicKey));
  Result := Data;
end;

class operator TPublicKey.Implicit(Buf: TPublicKey): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TPublicKey));
  Move(Buf.PublicKey[0], Data[0], SizeOf(TPublicKey));
  Result := BytesEncodeBase58(Data);
end;

class operator TPublicKey.Implicit(Buf: string): TPublicKey;
var
  RKey: TPublicKey;
  Data: TBytes;
begin
  Data := BytesDecodeBase58(Buf);
  Move(Data[0], RKey.PublicKey[0], Length(Data));
  Result := RKey;
end;

class operator TPublicKey.Implicit(Buf: TBytes): TPublicKey;
var
  RKey: TPublicKey;
begin
  Move(Buf[0], RKey.PublicKey[0], Length(Buf));
  Result := RKey;
end;
{$ENDREGION}
{$REGION 'TUint64Helperý}

function TUint64Helper.AsBytes: TBytes;
var
  Buf: TBytes;
begin
  SetLength(Buf, SizeOf(UINt64));
  Move(Self, Buf[0], SizeOf(UINt64));
  Result := Buf;
end;

function TUint64Helper.AsString: string;
begin
  Result := UIntToStr(Uint64(Self));
end;

procedure TUint64Helper.SetBytes(AData: TBytes);
begin
  Move(AData[0], Self, SizeOf(Self));
end;

{$ENDREGION}
{$REGION 'TintegerHelper'}

function TIntegerHelper.AsBytes: TBytes;
var
  Buf: TBytes;
begin
  SetLength(Buf, SizeOf(integer));
  Move(Self, Buf[0], SizeOf(integer));
  Result := Buf;
end;

class function TIntegerHelper.Size: integer;
begin
  Result := SizeOf(integer);
end;

class function TIntegerHelper.ToString(const Value: integer): string;
begin
  Result := IntToStr(Value);
end;

class function TIntegerHelper.TryParse(const S: string; out Value: integer): Boolean;
var
  E: integer;
begin
  Val(S, Value, E);
  Result := (E = 0);
end;

function TIntegerHelper.ToString: string;
begin
  Result := IntToStr(Self);
end;

function TIntegerHelper.ToBoolean: Boolean;
begin
  Result := Self <> 0;
end;

function TIntegerHelper.ToHexString: string;
begin
  Result := IntToHex(Self);
end;

function TIntegerHelper.ToSingle: Single;
begin
  Result := Self;
end;

function TIntegerHelper.ToDouble: Double;
begin
  Result := Self;
end;

function TIntegerHelper.ToExtended: Extended;
begin
  Result := Self;
end;
{$ENDREGION}
{$REGION 'TName'}

class operator TName.Add(buf1: TBytes; buf2: TName): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TName));
  Move(buf2.Name[0], LData[0], SizeOf(TName));
  RData := RData + LData;
  Result := RData;
end;

class operator TName.Add(buf2: TName; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TName));
  Move(buf2.Name[0], LData[0], SizeOf(TName));
  RData := LData + RData;
  Result := RData;
end;

class operator TName.Add(buf2: TName; buf1: string): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TName));
  Move(buf2.Name[0], Data[0], SizeOf(TName));
  Result := TEncoding.UTF8.GetString(Data) + buf1;
end;

class operator TName.Equal(AName: TName; AString: string): Boolean;
begin
  Result := string(AName) = AString;
end;

class operator TName.Add(buf1: string; buf2: TName): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TName));
  Move(buf2.Name[0], Data[0], SizeOf(TName));
  Result := buf1 + TEncoding.UTF8.GetString(Data);
end;

class operator TName.Implicit(Buf: TName): TBytes;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TName));
  Move(Buf.Name[0], Data[0], SizeOf(TName));
  Result := Data;
end;

class operator TName.Implicit(Buf: TName): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TName));
  Move(Buf.Name[0], Data[0], SizeOf(TName));
  Result := TEncoding.UTF8.GetString(Data);
end;

class operator TName.Implicit(Buf: string): TName;
var
  RName: TName;
  Data: TBytes;
begin
  Data := TEncoding.UTF8.GetBytes(Buf);
  fillchar(RName.Name[0], Length(RName.Name), 0);
  Move(Data[0], RName.Name[0], Length(Data));
  Result := RName;
end;

class operator TName.Implicit(Buf: TBytes): TName;
var
  RName: TName;
begin
  Move(Buf[0], RName.Name[0], Length(Buf));
  Result := RName;
end;


{$ENDREGION}
{$REGION 'TSymbol'}

class operator TSymbol.Add(buf1: TBytes; buf2: TSymbol): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TSymbol));
  Move(buf2.Symbol[0], LData[0], SizeOf(TSymbol));
  RData := RData + LData;
  Result := RData;
end;

class operator TSymbol.Add(buf2: TSymbol; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TSymbol));
  Move(buf2.Symbol[0], LData[0], SizeOf(TSymbol));
  RData := LData + RData;
  Result := RData;
end;

class operator TSymbol.Add(buf2: TSymbol; buf1: string): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TSymbol));
  Move(buf2.Symbol[0], Data[0], SizeOf(TSymbol));
  Result := TEncoding.UTF8.GetString(Data) + buf1;
end;

class operator TSymbol.Equal(ASymbol: TSymbol; AString: string): Boolean;
begin
  Result := string(ASymbol) = AString;
end;

class operator TSymbol.Add(buf1: string; buf2: TSymbol): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TSymbol));
  Move(buf2.Symbol[0], Data[0], SizeOf(TSymbol));
  Result := buf1 + TEncoding.UTF8.GetString(Data);
end;

class operator TSymbol.Implicit(Buf: TSymbol): TBytes;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TSymbol));
  Move(Buf.Symbol[0], Data[0], SizeOf(TSymbol));
  Result := Data;
end;

class operator TSymbol.Implicit(Buf: TSymbol): string;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TSymbol));
  fillchar(Data[0], Length(Data), 0);
  Move(Buf.Symbol[0], Data[0], SizeOf(TSymbol));
  Result := TEncoding.UTF8.GetString(Data);
end;

class operator TSymbol.Implicit(Buf: string): TSymbol;
var
  RSymbol: TSymbol;
  Data: TBytes;
begin
  Data := TEncoding.UTF8.GetBytes(Buf);
  fillchar(RSymbol.Symbol[0], Length(RSymbol.Symbol), 0);
  Move(Data[0], RSymbol.Symbol[0], Length(Data));
  Result := RSymbol;
end;

class operator TSymbol.Implicit(Buf: TBytes): TSymbol;
var
  RSymbol: TSymbol;
begin
  Move(Buf[0], RSymbol.Symbol[0], Length(Buf));
  Result := RSymbol;
end;
{$ENDREGION}

end.
