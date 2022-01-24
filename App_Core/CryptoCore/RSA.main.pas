unit RSA.main;

interface

uses
  System.SysUtils,
  System.Hash,
  System.Generics.Collections,
  RSA.cEncrypt,
  RSA.cHugeInt,
  Crypto.BinConverter,
  Crypto.BIP39,
  App.Types;

type
  TPrivateKey = TRSAPrivateKey;
  TPublicKey = TRSAPublicKey;

const
  errPrivKeyChSm = 'Checksum does not match';
  errHexToByte = 'Invalid hex string';
  errInvalidKeySize = 'Invalid key size';

  // ******************************************************************************
procedure GenPrivKey(const KeySize: Integer; var PrK: TPrivateKey);
procedure FinalizePrivKey(var PrK: TPrivateKey);

procedure PrivKeyToBytes(const PrK: TPrivateKey; var b: TBytes);
procedure BytesToPrivKey(const b: TBytes; var PrK: TPrivateKey);

procedure PrivKeyToBytes_lt(const PrK: TPrivateKey; var b: TBytes);
procedure BytesToPrivKey_lt(const b: TBytes; var PrK: TPrivateKey);

procedure PrivKeyToWords(const PrKB: TBytes; var b: strings);
procedure WordsToPrivKey(const b: strings; var PrK: TPrivateKey; KeySize: Integer);

// ******************************************************************************
procedure GenPubKey(const PrK: TPrivateKey; var PbK: TPublicKey);
procedure FinalizePubKey(var PbK: TPublicKey);
procedure PubKeyToBytes(const PbK: TPublicKey; var b: TBytes);
procedure BytesToPubKey(const b: TBytes; var PbK: TPublicKey);
// ******************************************************************************
procedure RSAPrKEncrypt(const PrK: TPrivateKey; const Data: TBytes; var Res: TBytes);
procedure RSAPbKEncrypt(const PbK: TRSAPublicKey; const Data: TBytes; var Res: TBytes);

procedure RSAPrKDecrypt(const PrK: TPrivateKey; const Data: TBytes; var Res: TBytes);
procedure RSAPbKDecrypt(const PbK: TPublicKey; const Data: TBytes; var Res: TBytes);
// ******************************************************************************
// function HugeWordToBytes(const hw: HugeWord; var Res: TBytes): Integer;
procedure HugeWordToBytes(const hw: HugeWord; var Res: TBytes);
procedure BytesToHugeWord(const Data: TBytes; var Res: HugeWord);
// ******************************************************************************
function BytesToHex(const dat: TBytes): string;
function xHexToBin(const HexStr: String): TBytes;
// ******************************************************************************
function Checksum(const dat: TBytes): Word;
// ******************************************************************************

implementation

function Checksum(const dat: TBytes): Word;
const
  m = 64;
var
  tmp, Res: Word;
  i: Integer;
begin
  Res := 0;
  tmp := 0;
  for i := 0 to Length(dat) - 1 do
  begin
    if (i mod m = 0) then
    begin
      Res := Res xor tmp;
      // res:= res + tmp;
      tmp := 0;
    end
    else
    begin
      tmp := tmp + dat[i] * (i mod m + 1);
    end;
  end;
  Res := Res xor tmp;
  // res:= res + tmp;
  Result := Res;
end;

function ByteToHex(InByte: byte): string;
const
  Digits: array [0 .. 15] of char = '0123456789ABCDEF';
begin
  Result := Digits[InByte shr 4] + Digits[InByte and $0F];
end;

function BytesToHex(const dat: TBytes): string;
var
  i, len: Integer;
begin
  Result := '';
  len := Length(dat);
  for i := 0 to len - 1 do
    Result := Result + ByteToHex(dat[i]);
end;

function xHexToBin(const HexStr: String): TBytes;
const
  HexSymbols = '0123456789ABCDEF';
var
  i, J, k: Integer;
  b: byte;
begin

{$IFDEF POSIX}
  k := 0;
{$ELSE}
  k := 1;
{$ENDIF}
  SetLength(Result, (Length(HexStr) + 1) shr 1);
  b := 0;
  if Length(HexStr) < 2 then
  begin
    SetLength(Result, 0);
    // raise ERSA.Create(errHexToByte);
    Exit;
  end;
  i := 0;
  // while I < Length(HexStr) - (1 - k) do begin
  while i < Length(HexStr) do
  begin
    J := 0;
    while J < Length(HexSymbols) do
    begin
      if HexStr[i + k] = HexSymbols[J + k] then
        Break;
      Inc(J);
    end;
    if J = Length(HexSymbols) - (1 - k) then; // error
    if Odd(i) then
      Result[i shr 1] := b shl 4 + J
    else
      b := J;
    Inc(i);
  end;
  if Odd(i) then
    Result[i shr 1] := b;
end;

// ******************************************************************************
procedure GenPrivKey(const KeySize: Integer; var PrK: TPrivateKey);
begin
  try
    RSAPrivateKeyInit(PrK);
  except
    on e: Exception do
    begin
      Exit;
    end;
  end;
  try
    RSAGeneratePrivateKeys(KeySize, PrK);
  except
    on e: Exception do
    begin
      Exit;
    end;
  end;
end;

procedure FinalizePrivKey(var PrK: TPrivateKey);
begin
  RSAPrivateKeyFinalise(PrK);
end;

procedure FinalizePubKey(var PbK: TRSAPublicKey);
begin
  RSAPublicKeyFinalise(PbK);
end;

procedure PrivKeyToBytes(const PrK: TPrivateKey; var b: TBytes);
{
  var
  i,k: Integer;
  Res: TBytes;
  tmp: HugeWord;
  begin
  //
  HugeWordInit(tmp);
  try

  finally
  SecureHugeWordFinalise(tmp);
  end;
}
var
  s, pos, cnt: Integer;
  tmp: TBytes;
begin
  //
  pos := 0;
  s := SizeOf(PrK.KeySize);

  SetLength(b, s);

  Move(PrK.KeySize, b[pos], SizeOf(PrK.KeySize));
  Inc(pos, SizeOf(PrK.KeySize));

  // ------------------------------------------
  HugeWordToBytes(PrK.Modulus, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.Exponent, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.PublicExponent, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.Prime1, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.Prime2, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.Phi, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.Exponent1, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.Exponent2, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------

  // HugeWordToBytes(PrK.Coefficient,tmp);
  // Inc(s,Length(tmp) + SizeOf(cnt));
  // SetLength(b,s);
  // cnt:= Length(tmp);
  // Move(cnt,b[pos],SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // Move(tmp[0],b[pos],Length(tmp));

end;

procedure PrivKeyToBytes_lt(const PrK: TPrivateKey; var b: TBytes);
var
  s, pos, cnt: Integer;
  tmp: TBytes;
  chsm: Word;
begin
  //
  pos := 0;
  s := SizeOf(PrK.KeySize);

  SetLength(b, s);

  Move(PrK.KeySize, b[pos], SizeOf(PrK.KeySize));
  Inc(pos, SizeOf(PrK.KeySize));

  // ------------------------------------------
  HugeWordToBytes(PrK.Modulus, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.Exponent, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);

  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  HugeWordToBytes(PrK.PublicExponent, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);
  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));
  // ------------------------------------------
  chsm := Checksum(b);
  Inc(s, SizeOf(Word));
  SetLength(b, s);
  Move(chsm, b[pos], SizeOf(Word));

  // HugeWordToBytes(PrK.Coefficient,tmp);
  // Inc(s,Length(tmp) + SizeOf(cnt));
  // SetLength(b,s);
  // cnt:= Length(tmp);
  // Move(cnt,b[pos],SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // Move(tmp[0],b[pos],Length(tmp));

end;

procedure WordsToPrivKey(const b: strings; var PrK: TPrivateKey; KeySize: Integer);
var
  strValue: string;
  indValue, i, pos, L: Integer;
  v1, v2: TBytes;
  bin, resinttobin: string;
  value: array [0 .. 63] of byte;
const
  primeSize: Integer = 8;
begin
  RSAPrivateKeyInit(PrK);
  PrK.KeySize := KeySize;

  bin := '';

  for strValue in b do
  begin
    TArray.BinarySearch(BIP39WordList, strValue.ToLower, indValue);
    resinttobin := IntToBin(indValue);
    if Length(resinttobin) < 11 then
      // ƒобавл€ем нули вперед пока не получим 11 бит
      for i := 0 to 11 - Length(resinttobin) - 1 do
        resinttobin := '0' + resinttobin;

    bin := bin + resinttobin;
  end;

  for i := 0 to 63 do
    value[i] := BinStringToByte(Copy(bin, i * 8 + 1, 8));

  SetLength(v1, 32);
  SetLength(v2, 32);

  Move(value[0], v1[0], 32);
  Move(value[32], v2[0], 32);

  Move(primeSize, PrK.Prime1.Used, SizeOf(Integer));
  Move(primeSize, PrK.Prime1.Alloc, SizeOf(Integer));
  HugeWordAlloc(PrK.Prime1, PrK.Prime1.Used);
  L := PrK.Prime1.Used;
  Move(v1[0], PrK.Prime1.Data^, 32);

  Move(primeSize, PrK.Prime2.Used, SizeOf(Integer));
  Move(primeSize, PrK.Prime2.Alloc, SizeOf(Integer));
  HugeWordAlloc(PrK.Prime2, PrK.Prime2.Used);
  L := PrK.Prime2.Used;
  Move(v2[0], PrK.Prime2.Data^, 32);

  // HugeWordSetSize(prk.prime1, 8);
  // HugeWordSetSize(prk.prime2, 8);
  //
  // PrimeToHugeWord(prk.prime1,v1);
  // PrimeToHugeWord(prk.prime2,v2);
  // Int64ToHugeWord(prk.PublicExponent, 3);

  RSAGeneratePrivateKeysWithPrime(KeySize, PrK);
end;

procedure PrivKeyToWords(const PrKB: TBytes; var b: strings);
var
  i, lastValue: Integer;
  v1, v2, v3: TBytes;
  binArr, lastStr: string;
  Hash: TBytes;
  value: array [0 .. 63] of byte;
  str: string;
  PrK: TPrivateKey;
begin
  binArr := '';

  fillChar(value[0], 32, 0);

  BytesToPrivKey(PrKB, PrK);

  SetLength(v1, 255);
  SetLength(v2, 255);

  HugeWordToBytes(PrK.Prime1, v1);
  HugeWordToBytes(PrK.Prime2, v2);

  FinalizePrivKey(PrK);

  Move(v1[8], value[0], 32);
  Move(v2[8], value[32], 32);

  for i := 0 to 63 do
    binArr := binArr + ByteToBinStr(value[i]);

  for i := 0 to 45 do
    b := b + [BIP39WordList[BinToInt(Copy(binArr, i * 11 + 1, 11))]];

  Hash := THashSHA2.GetHashBytes(binArr);

  lastStr := Copy(binArr, 46 * 11 + 1, 6) + Copy(ByteToBinStr(Hash[0]), 1, 5);

  b := b + [BIP39WordList[BinToInt(lastStr)]];
end;

procedure BytesToPrivKey(const b: TBytes; var PrK: TPrivateKey);
var
  s, pos, cnt, ks: Integer;
  tmp: TBytes;
begin

  if Length(b) < 16 then
    Exit;
  RSAPrivateKeyInit(PrK);

  pos := 0;

  Move(b[pos], PrK.KeySize, SizeOf(PrK.KeySize));
  Inc(pos, SizeOf(PrK.KeySize));

  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Modulus);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Exponent);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.PublicExponent);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Prime1);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Prime2);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Phi);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Exponent1);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Exponent2);
  // ------------------------------------------
  // Move(b[pos],cnt,SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // SetLength(tmp,cnt);
  // Move(b[pos],tmp[0],cnt);
  // Inc(pos,cnt);
  // BytesToHugeWord(tmp, PrK.Coefficient);
end;

procedure BytesToPrivKey_lt(const b: TBytes; var PrK: TRSAPrivateKey);
var
  s, pos, cnt, ks: Integer;
  tmp: TBytes;
begin

  if Length(b) < 16 then
    Exit;
  RSAPrivateKeyInit(PrK);

  pos := 0;

  Move(b[pos], PrK.KeySize, SizeOf(PrK.KeySize));
  if PrK.KeySize <> 512 then
    raise Exception.Create(errInvalidKeySize);
  Inc(pos, SizeOf(PrK.KeySize));

  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Modulus);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Exponent);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.PublicExponent);
  // ------------------------------------------
  // Move(b[pos],cnt,SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // SetLength(tmp,cnt);
  // Move(b[pos],tmp[0],cnt);
  // Inc(pos,cnt);
  // BytesToHugeWord(tmp, PrK.Prime1);
  // ------------------------------------------
  // Move(b[pos],cnt,SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // SetLength(tmp,cnt);
  // Move(b[pos],tmp[0],cnt);
  // Inc(pos,cnt);
  // BytesToHugeWord(tmp, PrK.Prime2);
  // ------------------------------------------
  // Move(b[pos],cnt,SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // SetLength(tmp,cnt);
  // Move(b[pos],tmp[0],cnt);
  // Inc(pos,cnt);
  // BytesToHugeWord(tmp, PrK.Phi);
  // ------------------------------------------
  // Move(b[pos],cnt,SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // SetLength(tmp,cnt);
  // Move(b[pos],tmp[0],cnt);
  // Inc(pos,cnt);
  // BytesToHugeWord(tmp, PrK.Exponent1);
  // ------------------------------------------
  // Move(b[pos],cnt,SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // SetLength(tmp,cnt);
  // Move(b[pos],tmp[0],cnt);
  // Inc(pos,cnt);
  // BytesToHugeWord(tmp, PrK.Exponent2);
  // ------------------------------------------
  // Move(b[pos],cnt,SizeOf(cnt));
  // Inc(pos,SizeOf(cnt));
  // SetLength(tmp,cnt);
  // Move(b[pos],tmp[0],cnt);
  // Inc(pos,cnt);
  // BytesToHugeWord(tmp, PrK.Coefficient);
end;

// ******************************************************************************
procedure BytesToPrivKey_lt2(const b: TBytes; var PrK: TPrivateKey);
var
  s, pos, cnt, ks: Integer;
  tmp: TBytes;
  chsm, chsm2: Word;
begin

  if Length(b) < 16 then
  begin
    RSAPrivateKeyFinalise(PrK);
    Exit;
  end;

  SetLength(tmp, Length(b) - SizeOf(Word));
  Move(b[0], tmp[0], Length(b) - SizeOf(Word));
  chsm := Checksum(tmp);
  Move(b[Length(b) - SizeOf(Word)], chsm2, SizeOf(Word));

  if chsm <> chsm2 then
  begin
    RSAPrivateKeyFinalise(PrK);
    raise Exception.Create(errPrivKeyChSm);
  end;

  RSAPrivateKeyFinalise(PrK);
  RSAPrivateKeyInit(PrK);

  pos := 0;

  Move(b[pos], PrK.KeySize, SizeOf(PrK.KeySize));
  Inc(pos, SizeOf(PrK.KeySize));

  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Modulus);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.Exponent);
  // ------------------------------------------
  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);
  BytesToHugeWord(tmp, PrK.PublicExponent);
  // ------------------------------------------

end;

// ******************************************************************************
procedure GenPubKey(const PrK: TPrivateKey; var PbK: TPublicKey);
begin
  RSAPublicKeyInit(PbK);
  RSAGeneratePublicKeys(PrK, PbK);
end;

procedure PubKeyToBytes(const PbK: TPublicKey; var b: TBytes);
var
  s, pos, cnt: Integer;
  tmp: TBytes;
begin
  //
  pos := 0;
  s := SizeOf(PbK.KeySize);

  SetLength(b, s);

  Move(PbK.KeySize, b[pos], SizeOf(PbK.KeySize));
  Inc(pos, SizeOf(PbK.KeySize));

  HugeWordToBytes(PbK.Modulus, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));

  SetLength(b, s);

  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));
  Inc(pos, Length(tmp));

  HugeWordToBytes(PbK.Exponent, tmp);
  Inc(s, Length(tmp) + SizeOf(cnt));
  SetLength(b, s);

  cnt := Length(tmp);
  Move(cnt, b[pos], SizeOf(cnt));
  Inc(pos, SizeOf(cnt));
  Move(tmp[0], b[pos], Length(tmp));

end;

procedure BytesToPubKey(const b: TBytes; var PbK: TPublicKey);
var
  pos, cnt: Integer;
  tmp: TBytes;
begin
  if Length(b) < 16 then
    Exit;
  // RSAPublicKeyFinalise(PbK);
  RSAPublicKeyInit(PbK);

  pos := 0;

  Move(b[pos], PbK.KeySize, SizeOf(PbK.KeySize));
  Inc(pos, SizeOf(PbK.KeySize));

  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(PbK.KeySize));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);

  BytesToHugeWord(tmp, PbK.Modulus);

  Move(b[pos], cnt, SizeOf(cnt));
  Inc(pos, SizeOf(PbK.KeySize));
  SetLength(tmp, cnt);
  Move(b[pos], tmp[0], cnt);
  Inc(pos, cnt);

  BytesToHugeWord(tmp, PbK.Exponent);

end;

// ******************************************************************************
procedure RSAPrKEncrypt(const PrK: TPrivateKey; const Data: TBytes; var Res: TBytes);
var
  L, L2: Integer;
begin
  //
  L := Length(Data);
  L2 := RSACipherMessageBufSize(PrK.KeySize);
  SetLength(Res, L2);
  RSAEncrypt(rsaetPKCS1, PrK, Pchar(Data)^, L, Pchar(Res)^, L2);
end;

procedure RSAPbKEncrypt(const PbK: TRSAPublicKey; const Data: TBytes; var Res: TBytes);
var
  L, L2: Integer;
begin
  //
  L := Length(Data);
  L2 := RSACipherMessageBufSize(PbK.KeySize);
  SetLength(Res, L2);
  RSAEncrypt_PbK(rsaetPKCS1, PbK, Pchar(Data)^, L, Pchar(Res)^, L2);
end;

procedure RSAPrKDecrypt(const PrK: TPrivateKey; const Data: TBytes; var Res: TBytes);
var
  i, L, N: Integer;
begin
  //
  L := Length(Data);
  N := RSACipherMessageBufSize(PrK.KeySize);
  SetLength(Res, N);
  N := RSADecrypt_PrK(rsaetPKCS1, PrK, Pchar(Data)^, L, Pchar(Res)^, N);
  SetLength(Res, N);
end;

procedure RSAPbKDecrypt(const PbK: TPublicKey; const Data: TBytes; var Res: TBytes);
var
  i, L, N: Integer;
begin
  //
  L := Length(Data);
  N := RSACipherMessageBufSize(PbK.KeySize);
  SetLength(Res, N);
  N := RSADecrypt(rsaetPKCS1, PbK, Pchar(Data)^, L, Pchar(Res)^, N);
  SetLength(Res, N);
end;

// ******************************************************************************
procedure HugeWordToBytes(const hw: HugeWord; var Res: TBytes);
// function HugeWordToBytes(const hw: HugeWord; var Res: TBytes): Integer;
var
  i, J, L, pos: Integer;
  P: PLongWord;
  F: LongWord;
begin
  pos := 0;
  if HugeWordIsZero(hw) then
  begin
    SetLength(Res, 1);
    Res[0] := 0;
    Exit;
  end;
  L := hw.Used;
  // SetLength(Res, SizeOf(Integer)*2 + L * 8);
  SetLength(Res, SizeOf(Integer) * 2 + L * SizeOf(F));

  Move(hw.Used, Res[pos], SizeOf(Integer));
  Inc(pos, SizeOf(hw.Used));
  Move(hw.Alloc, Res[pos], SizeOf(Integer));
  Inc(pos, SizeOf(hw.Alloc));

  Move(hw.Data^, Res[pos], L * HugeWordElementSize);
  {
    P := hw.Data;
    //Inc(P, L - 1);
    for I := 0 to L - 1 do
    begin
    F := P^;

    Move(F,Res[pos],SizeOf(F));

    Inc(Pos, SizeOf(F));
    Inc(P);
    end;
  }
  // Result:= Pos;
end;

procedure BytesToHugeWord(const Data: TBytes; var Res: HugeWord);
var
  i, J, L, pos: Integer;
  P: PLongWord;
  F: LongWord;
begin
  pos := 0;

  Move(Data[pos], Res.Used, SizeOf(Integer));
  Inc(pos, SizeOf(Res.Used));
  Move(Data[pos], Res.Alloc, SizeOf(Integer));
  Inc(pos, SizeOf(Res.Alloc));

  HugeWordAlloc(Res, Res.Used);

  L := Res.Used;

  Move(Data[pos], Res.Data^, L * HugeWordElementSize);
end;

end.
