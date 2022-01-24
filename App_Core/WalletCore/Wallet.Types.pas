unit Wallet.Types;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Hash,
  App.Types,
  Crypto.RSA;

type
  TWallet = packed record
    PubKey: TPublicKey;
    PrivKey: TPrivateKey;
    procedure Create;
    function GetAddress: THash;
    function GetWords: string;
    function SetWords(AArgs: string): boolean;
    class function CheckWords(Data: strings): boolean; static;
    class operator Implicit(Buf: TWallet): TBytes;
    class operator Implicit(Buf: TBytes): TWallet;
    class operator Add(buf1: TBytes; buf2: TWallet): TBytes;
    class operator Add(buf2: TWallet; buf1: TBytes): TBytes;
  end;

implementation

{$REGION 'TWallet'}

class operator TWallet.Add(buf2: TWallet; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TWallet));
  Move(buf2, LData[0], SizeOf(TWallet));
  RData := RData + LData;
  Result := RData;
end;

class operator TWallet.Add(buf1: TBytes; buf2: TWallet): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TWallet));
  Move(buf2, LData[0], SizeOf(TWallet));
  RData := LData + RData;
  Result := RData;
end;

procedure TWallet.Create;
begin
  PrivKey := RSAGenPrivateKey;
  PubKey := RSAGetPublicKey(PrivKey);
end;

function TWallet.GetAddress: THash;
var
  Buf: TMemoryStream;
begin
  Buf := TMemoryStream.Create;
  Buf.WriteData(PubKey, SIZE_PUBLIC_KEY);
  Buf.Position := 0;
  Result := THashSHA2.GetHashBytes(Buf);
  Buf.Destroy;
end;

function TWallet.GetWords: string;
begin
  Result := GenerateWordsOnPK(PrivKey).AsString(' ');
end;

class operator TWallet.Implicit(Buf: TBytes): TWallet;
begin
  if Length(Buf) = SizeOf(Result) then
    Move(Buf[0], Result, SizeOf(Result));
end;

class function TWallet.CheckWords(Data: strings): boolean;
begin
  result := False;

  if Data.Length<>47 then
    exit;

  for var item: string in Data do
  begin
    if trim(item) = '' then
      exit;

    if SearchInBIP39(trim(item)) = -1 then
      exit;
  end;

  if not CheckWordsForCorrectness(Data) then
    exit;

  result := True;
end;

function TWallet.SetWords(AArgs: string): boolean;
var
  Data: strings;
  Buf: TBytes;
begin
  try
    Result := True;
    Data.SetStrings(AArgs);

    if not CheckWords(Data) then
      raise Exception.Create('Exception: Bad Words');

    PrivKey := GeneratePKOnWords(Data);
    PubKey := RSAGetPublicKey(PrivKey);
  except
    Result := False;
  end;
end;

class operator TWallet.Implicit(Buf: TWallet): TBytes;
begin
  SetLength(Result, SizeOf(Buf));
  Move(Buf, Result[0], SizeOf(Buf));
end;
{$ENDREGION}

end.
