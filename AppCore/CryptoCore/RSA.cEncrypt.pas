// {$INCLUDE cCipher.inc}

unit RSA.cEncrypt;

interface

uses
  {System}
  SysUtils,
  {Fundamentals}
  RSA.cHugeInt;

var
  ep: real;
  { }
  { RSA }
  { }

type
  ERSA = class(Exception);

  TRSAPublicKey = record
    KeySize: Integer;
    Modulus: HugeWord;
    Exponent: HugeWord;
  end;

  TRSAPrivateKey = record
    KeySize: Integer;
    Modulus: HugeWord;
    Exponent: HugeWord; // d
    PublicExponent: HugeWord; // e
    Prime1: HugeWord; // p
    Prime2: HugeWord; // q
    Phi: HugeWord; // (p-1) * (q-1)
    Exponent1: HugeWord; // d mod (p - 1)
    Exponent2: HugeWord; // d mod (q - 1)
    Coefficient: HugeWord; // (inverse of q) mod p
  end;

  TRSAMessage = HugeWord;

  TRSAEncryptionType = (rsaetPKCS1, rsaetOAEP);

  { Ассимитричное RSA шифрование }

procedure RSAPublicKeyInit(var Key: TRSAPublicKey);

procedure RSAPublicKeyFinalise(var Key: TRSAPublicKey);

procedure RSAPrivateKeyInit(var Key: TRSAPrivateKey);

procedure RSAPrivateKeyFinalise(var Key: TRSAPrivateKey);

procedure RSAGenerateKeys(const KeySize: Integer; var PrivateKey: TRSAPrivateKey; var PublicKey: TRSAPublicKey);
// ******************************************************************************
procedure RSAGeneratePrivateKeys(const KeySize: Integer; var PrivateKey: TRSAPrivateKey);
procedure RSAGeneratePrivateKeysWithPrime(const KeySize: Integer; var PrivateKey: TRSAPrivateKey);
procedure RSAGeneratePublicKeys(const PrivateKey: TRSAPrivateKey; var PublicKey: TRSAPublicKey);
// ******************************************************************************

function RSACipherMessageBufSize(const KeySize: Integer): Integer;

procedure RSAEncodeMessagePKCS1(const KeySize: Integer; const Buf; const BufSize: Integer; var EncodedMessage: TRSAMessage);

procedure RSAEncodeMessageOAEP(const KeySize: Integer; const Buf; const BufSize: Integer; var EncodedMessage: TRSAMessage);

procedure RSAEncryptMessage(const Key: TRSAPrivateKey; const PlainMessage: TRSAMessage; var CipherMessage: TRSAMessage);
procedure RSAEncryptMessage_PbK(const Key: TRSAPublicKey; const PlainMessage: TRSAMessage; var CipherMessage: TRSAMessage);

function RSACipherMessageToBuf(const KeySize: Integer; const CipherMessage: TRSAMessage; var CipherBuf;
const CipherBufSize: Integer): Integer;

function RSAEncrypt(const EncryptionType: TRSAEncryptionType; const PrivateKey: TRSAPrivateKey; const PlainBuf;
const PlainBufSize: Integer; var CipherBuf; const CipherBufSize: Integer): Integer;
function RSAEncrypt_PbK(const EncryptionType: TRSAEncryptionType; const PublicKey: TRSAPublicKey; const PlainBuf;
const PlainBufSize: Integer; var CipherBuf; const CipherBufSize: Integer): Integer;

// function RSAEncryptStr(const EncryptionType: TRSAEncryptionType; const PrivateKey: TRSAPrivateKey; const Plain: AnsiString): AnsiString;
function RSAEncryptStr(const EncryptionType: TRSAEncryptionType; const PrivateKey: TRSAPrivateKey;
const Plain: String): String;

procedure RSACipherBufToMessage(const KeySize: Integer; const CipherBuf; const CipherBufSize: Integer;
var CipherMessage: TRSAMessage);

procedure RSADecryptMessage_PrK(const Key: TRSAPrivateKey; const CipherMessage: TRSAMessage;
var EncodedMessage: TRSAMessage); overload;
procedure RSADecryptMessage(const Key: TRSAPublicKey; const CipherMessage: TRSAMessage;
var EncodedMessage: TRSAMessage); overload;

function RSADecodeMessagePKCS1(const KeySize: Integer; const EncodedMessage: HugeWord; var Buf;
const BufSize: Integer): Integer;

function RSADecodeMessageOAEP(const KeySize: Integer; const EncodedMessage: HugeWord; var Buf;
const BufSize: Integer): Integer;

function RSADecrypt_PrK(const EncryptionType: TRSAEncryptionType; const Key: TRSAPrivateKey; const CipherBuf;
const CipherBufSize: Integer; var PlainBuf; const PlainBufSize: Integer): Integer;
function RSADecrypt(const EncryptionType: TRSAEncryptionType; const Key: TRSAPublicKey; const CipherBuf;
const CipherBufSize: Integer; var PlainBuf; const PlainBufSize: Integer): Integer;

// function RSADecryptStr(const EncryptionType: TRSAEncryptionType; const PublicKey: TRSAPublicKey; const Cipher: AnsiString): AnsiString;
function RSADecryptStr(const EncryptionType: TRSAEncryptionType; const PublicKey: TRSAPublicKey;
const Cipher: String): String;

// procedure EncryptAsimm(var Msg: AnsiString; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);
procedure EncryptAsimm(var Msg: String; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);

// procedure DecryptAsimm(var Msg: AnsiString; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);
procedure DecryptAsimm(var Msg: String; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);

{ Симметричное шифрование }

function gen(x1, x2: longint): int64;

function GenCiclNam(d, N: cardinal): cardinal;

function GenP(gran: cardinal): word;

procedure String_Pack(var s: string);

procedure EncryptSimm(StrIn: string; var StrOut: string);

function HexToStr(HexStr: string; const Text: boolean = True): string;

procedure String_UnPack(var s: string);

procedure DecryptSimm(var Lne: string);

{ }
{ Test cases }
{ }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
procedure SelfTest;
{$ENDIF}{$IFDEF PROFILE}
procedure Profile;
{$ENDIF}{$ENDIF}
procedure SecureHugeWordFinalise(var A: HugeWord);

implementation

uses
  {System}
{$IFDEF DEBUG}{$IFDEF PROFILE}
  Windows,
{$ENDIF}{$ENDIF}
  {Fundamentals}
  RSA.cRandom,
  RSA.cHash;

{ }
{ SecureClear }
{ }
procedure SecureClearHugeWord(var A: HugeWord);
begin
  if (A.Alloc = 0) or not Assigned(A.Data) then
    exit;
  SecureClear(A.Data^, A.Alloc * HugeWordElementSize);
end;

procedure SecureHugeWordFinalise(var A: HugeWord);
begin
  SecureClearHugeWord(A);
  HugeWordFinalise(A);
end;

{ }
{ RSA }
{ }
const
  SRSAInvalidKeySize = 'Invalid RSA key size';
  SRSAInvalidBufferSize = 'Invalid RSA buffer size';
  SRSAInvalidMessage = 'Invalid RSA message';
  SRSAMessageTooLong = 'RSA message too long';
  SRSAInvalidEncryptionType = 'Invalid RSA encryption type';

procedure RSAPublicKeyInit(var Key: TRSAPublicKey);
begin
  Key.KeySize := 0;
  HugeWordInit(Key.Modulus);
  HugeWordInit(Key.Exponent);
end;

procedure RSAPublicKeyFinalise(var Key: TRSAPublicKey);
begin
  SecureHugeWordFinalise(Key.Exponent);
  SecureHugeWordFinalise(Key.Modulus);
end;

procedure RSAPrivateKeyInit(var Key: TRSAPrivateKey);
begin
  Key.KeySize := 0;
  HugeWordInit(Key.Modulus);
  HugeWordInit(Key.Exponent);
  HugeWordInit(Key.PublicExponent);
  HugeWordInit(Key.Prime1);
  HugeWordInit(Key.Prime2);
  HugeWordInit(Key.Phi);
  HugeWordInit(Key.Exponent1);
  HugeWordInit(Key.Exponent2);
  HugeWordInit(Key.Coefficient);
end;

procedure RSAPrivateKeyFinalise(var Key: TRSAPrivateKey);
begin
  SecureHugeWordFinalise(Key.Coefficient);
  SecureHugeWordFinalise(Key.Exponent2);
  SecureHugeWordFinalise(Key.Exponent1);
  SecureHugeWordFinalise(Key.Phi);
  SecureHugeWordFinalise(Key.Prime2);
  SecureHugeWordFinalise(Key.Prime1);
  SecureHugeWordFinalise(Key.PublicExponent);
  SecureHugeWordFinalise(Key.Exponent);
  SecureHugeWordFinalise(Key.Modulus);
end;

{ RSA Key Random Number }
{ Returns a random number for use in RSA key generation. }
procedure RSAKeyRandomNumber(const Bits: Integer; var A: HugeWord);
var
  L: Integer;
begin
  Assert(HugeWordElementBits >= 32);
  if (Bits <= 0) or (Bits mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  // generate non-zero random number
  L := Bits div HugeWordElementBits;
  repeat
    HugeWordRandom(A, L);
  until not HugeWordIsZero(A);
  // set least significant bit to make odd
  HugeWordSetBit(A, 0);
  // set one of the 15 most significant bits to ensure product is Bits * 2 large
  // and this number allocates requested number of Bits in the HugeWord structure
  HugeWordSetBit(A, Bits - RandomUniform(15) - 1);
  // validate
  Assert(HugeWordIsOdd(A));
  Assert(HugeWordGetBitCount(A) = Bits);
end;

{ RSA Key Random Prime1 }
{ Returns the first of two random primes for use in RSA key generation. }
procedure RSAKeyRandomPrime1(const Bits: Integer; var P: HugeWord);
begin
  repeat
    RSAKeyRandomNumber(Bits, P);
    // set the 2 most significant bits to:
    // i) ensure that first prime is large enough so that there are
    // enough smaller primes to choose from for the second prime;
    // ii) the product is large enough
    HugeWordSetBit(P, Bits - 1);
    HugeWordSetBit(P, Bits - 2);
  until HugeWordIsPrime(P) <> pNotPrime;
end;

{ RSA Key Random Prime2 }
{ Returns the second of two random primes for use in RSA key generation. }
procedure RSAKeyRandomPrime2(const Bits: Integer; const P: HugeWord; var Q: HugeWord);
var
  L: HugeWord;
  C: Integer;
  N: LongWord;
begin
  C := Bits div HugeWordElementBits;
  HugeWordInit(L);
  try
    repeat
      repeat
        repeat
          repeat
            // choose a new random number with every iteration to maintain
            // uniform distribution
            RSAKeyRandomNumber(Bits, Q);
            // "Numbers p and q should not be 'too close', lest the Fermat factorization for n be successful,
            // if p - q, for instance is less than 2n^1/4 (which for even small 1024-bit values of n is 3Ч10^77)
            // solving for p and q is trivial"
            HugeWordAssignOne(L);
            HugeWordShl(L, (Bits div 4) + 1);
            HugeWordAdd(L, Q);
          until HugeWordCompare(P, L) > 0;
          // ensure p > 2q - prevents certain attacks
          HugeWordAssign(L, Q);
          HugeWordShl1(L);
        until HugeWordCompare(P, L) > 0;
        // ensure N = P * Q large enough
        N := Byte(HugeWordGetElement(P, C - 1) shr (HugeWordElementBits - 8)) *
        Byte(HugeWordGetElement(Q, C - 1) shr (HugeWordElementBits - 8));
      until N >= $0100;
      // ensure prime
    until HugeWordIsPrime(Q) <> pNotPrime;
  finally
    SecureHugeWordFinalise(L);
  end;
end;

{ RSA Key Random Prime Pair }
{ Returns a pair of random primes for use in RSA key generation. }
procedure RSAKeyRandomPrimePair(const Bits: Integer; var P, Q: HugeWord);
begin
  RSAKeyRandomPrime1(Bits, P);
  RSAKeyRandomPrime2(Bits, P, Q);
end;

{ RSA Generate Keys }
{ Returns a randomly generated PrivateKey/PublicKey pair. }
const
  RSAExpCount = 7;
  RSAExp: array [0 .. RSAExpCount - 1] of Integer = (3, 5, 7, 11, 17, 257, 65537);

procedure RSAGenerateKeys(const KeySize: Integer; var PrivateKey: TRSAPrivateKey; var PublicKey: TRSAPublicKey);
var
  Bits: Integer;
  P, Q, N, E, d, G: HugeWord;
  F, T: LongWord;
  R: boolean;
begin
  if (KeySize <= 0) or (KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  HugeWordInit(P);
  HugeWordInit(Q);
  HugeWordInit(N);
  HugeWordInit(E);
  HugeWordInit(d);
  HugeWordInit(G);
  try
    Bits := KeySize div 2;
    repeat
      R := False;
      repeat
        // generate random prime values for p and q
        RSAKeyRandomPrimePair(Bits, P, Q);
        // calculate n = p * q
        HugeWordMultiply(N, P, Q);
        Assert(HugeWordGetBitCount(N) = KeySize);
        // save private key primes
        HugeWordAssign(PrivateKey.Prime1, P);
        HugeWordAssign(PrivateKey.Prime2, Q);
        // calculate phi = (p-1) * (q-1)
        HugeWordDec(P);
        HugeWordDec(Q);
        HugeWordMultiply(PrivateKey.Phi, P, Q);
        // choose e such that 1 < e < phi and gcd(e, phi) = 1
        // try 3 values for e before giving up
        T := 0;
        repeat
          Inc(T);
          F := RSAExp[RandomUniform(RSAExpCount)];
          HugeWordAssignWord32(E, F);
          HugeWordGCD(E, PrivateKey.Phi, G);
          if HugeWordIsOne(G) then
            R := True;
        until R or (T = 3);
      until R;
      // d = inverse(e) mod phi
    until HugeWordModInv(E, PrivateKey.Phi, d);
    // populate PrivateKey and PublicKey
    PrivateKey.KeySize := KeySize;
    HugeWordMod(d, P, PrivateKey.Exponent1); // d mod (p - 1)
    HugeWordMod(d, Q, PrivateKey.Exponent2); // d mod (q - 1)
    HugeWordAssign(PrivateKey.Modulus, N);
    HugeWordAssign(PrivateKey.Exponent, d);
    HugeWordAssign(PrivateKey.PublicExponent, E);
    PublicKey.KeySize := KeySize;
    HugeWordAssign(PublicKey.Modulus, N);
    HugeWordAssign(PublicKey.Exponent, E);
  finally
    SecureHugeWordFinalise(G);
    SecureHugeWordFinalise(d);
    SecureHugeWordFinalise(E);
    SecureHugeWordFinalise(N);
    SecureHugeWordFinalise(Q);
    SecureHugeWordFinalise(P);
  end;
end;

procedure HugeWordToBytes(const hw: HugeWord; var Res: TBytes);
// function HugeWordToBytes(const hw: HugeWord; var Res: TBytes): Integer;
var
  i, j, L, pos: Integer;
  P: PLongWord;
  F: LongWord;
begin
  pos := 0;
  if HugeWordIsZero(hw) then
  begin
    SetLength(Res, 1);
    Res[0] := 0;
    exit;
  end;
  L := hw.Used;
  // SetLength(Res, SizeOf(Integer)*2 + L * 8);
  SetLength(Res, SizeOf(Integer) * 2 + L * SizeOf(F));

  Move(hw.Used, Res[pos], SizeOf(Integer));
  Inc(pos, SizeOf(hw.Used));
  Move(hw.Alloc, Res[pos], SizeOf(Integer));
  Inc(pos, SizeOf(hw.Alloc));

  Move(hw.Data^, Res[pos], L * HugeWordElementSize);
end;

procedure BytesToHugeWord(const Data: TBytes; var Res: HugeWord);
var
  i, j, L, pos: Integer;
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

procedure RSAGeneratePrivateKeysWithPrime(const KeySize: Integer; var PrivateKey: TRSAPrivateKey);
var
  Bits: Integer;
  P, Q, N, E, d, G: HugeWord;
  F, T: LongWord;
  R, CheckOnInt64: boolean;
begin
  HugeWordInit(P);
  HugeWordInit(Q);
  HugeWordInit(N);
  HugeWordInit(E);
  HugeWordInit(d);
  HugeWordInit(G);
  try
    Bits := KeySize div 2;
    repeat
      R := False;
      CheckOnInt64 := False;
      repeat

        HugeWordAssign(P, PrivateKey.Prime1);
        HugeWordAssign(Q, PrivateKey.Prime2);

        // calculate n = p * q
        HugeWordMultiply(N, P, Q);
        Assert(HugeWordGetBitCount(N) = KeySize);
        // save private key primes

        HugeWordAssign(PrivateKey.Prime1, P);
        HugeWordAssign(PrivateKey.Prime2, Q);

        // calculate phi = (p-1) * (q-1)
        HugeWordDec(P);
        HugeWordDec(Q);
        HugeWordMultiply(PrivateKey.Phi, P, Q);
        // choose e such that 1 < e < phi and gcd(e, phi) = 1
        // try 3 values for e before giving up
        T := 0;
        repeat
          Inc(T);
          F := RSAExp[0];
          // F := RSAExp[RandomUniform(RSAExpCount)];
          HugeWordAssignWord32(E, F);
          HugeWordGCD(E, PrivateKey.Phi, G);
          if HugeWordIsOne(G) then
            R := True;
        until R or (T = 3);
      until R;
      // d = inverse(e) mod phi
    until HugeWordModInv(E, PrivateKey.Phi, d);
    // populate PrivateKey and PublicKey
    PrivateKey.KeySize := KeySize;

    HugeWordMod(d, P, PrivateKey.Exponent1); // d mod (p - 1)
    HugeWordMod(d, Q, PrivateKey.Exponent2); // d mod (q - 1)
    HugeWordAssign(PrivateKey.Modulus, N);
    HugeWordAssign(PrivateKey.Exponent, d);
    HugeWordAssign(PrivateKey.PublicExponent, E);

  finally
    SecureHugeWordFinalise(G);
    SecureHugeWordFinalise(d);
    SecureHugeWordFinalise(E);
    SecureHugeWordFinalise(N);
    SecureHugeWordFinalise(Q);
    SecureHugeWordFinalise(P);
  end;
end;

procedure RSAGeneratePrivateKeys(const KeySize: Integer; var PrivateKey: TRSAPrivateKey);
var
  Bits: Integer;
  P, Q, N, E, d, G: HugeWord;
  F, T: LongWord;
  R, CheckOnInt64: boolean;
begin
  if (KeySize <= 0) or (KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  HugeWordInit(P);
  HugeWordInit(Q);
  HugeWordInit(N);
  HugeWordInit(E);
  HugeWordInit(d);
  HugeWordInit(G);
  try
    Bits := KeySize div 2;
    repeat
      R := False;
      CheckOnInt64 := False;
      repeat
        // generate random prime values for p and q
        RSAKeyRandomPrimePair(Bits, P, Q);

        // calculate n = p * q
        HugeWordMultiply(N, P, Q);
        Assert(HugeWordGetBitCount(N) = KeySize);
        // save private key primes

        HugeWordAssign(PrivateKey.Prime1, P);
        HugeWordAssign(PrivateKey.Prime2, Q);

        // calculate phi = (p-1) * (q-1)
        HugeWordDec(P);
        HugeWordDec(Q);
        HugeWordMultiply(PrivateKey.Phi, P, Q);
        // choose e such that 1 < e < phi and gcd(e, phi) = 1
        // try 3 values for e before giving up
        T := 0;
        repeat
          Inc(T);
          F := RSAExp[0];
          // F := RSAExp[RandomUniform(RSAExpCount)];
          HugeWordAssignWord32(E, F);
          HugeWordGCD(E, PrivateKey.Phi, G);
          if HugeWordIsOne(G) then
            R := True;
        until R or (T = 3);
      until R;
      // d = inverse(e) mod phi
    until HugeWordModInv(E, PrivateKey.Phi, d);
    // populate PrivateKey and PublicKey
    PrivateKey.KeySize := KeySize;

    HugeWordMod(d, P, PrivateKey.Exponent1); // d mod (p - 1)
    HugeWordMod(d, Q, PrivateKey.Exponent2); // d mod (q - 1)
    HugeWordAssign(PrivateKey.Modulus, N);
    HugeWordAssign(PrivateKey.Exponent, d);
    HugeWordAssign(PrivateKey.PublicExponent, E);

  finally
    SecureHugeWordFinalise(G);
    SecureHugeWordFinalise(d);
    SecureHugeWordFinalise(E);
    SecureHugeWordFinalise(N);
    SecureHugeWordFinalise(Q);
    SecureHugeWordFinalise(P);
  end;
end;

procedure RSAGeneratePublicKeys(const PrivateKey: TRSAPrivateKey; var PublicKey: TRSAPublicKey);
var
  Bits: Integer;
  F, T: LongWord;
  R: boolean;
begin
  if (PrivateKey.KeySize <= 0) or (PrivateKey.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  try
    PublicKey.KeySize := PrivateKey.KeySize;
    HugeWordAssign(PublicKey.Modulus, PrivateKey.Modulus);
    HugeWordAssignInt64(PublicKey.Exponent, 3);
  finally
  end;
end;

{ RSA Cipher Message Buf Size }
function RSACipherMessageBufSize(const KeySize: Integer): Integer;
begin
  Result := KeySize div 8;
end;

{ RSA Encode Message PKCS1 }
{ Encodes a message buffer as a RSA message. }
{ Uses EME-PKCS1-v1_5 encoding. }
{ EM = 0x00 || 0x02 || PS || 0x00 || M }
procedure RSAEncodeMessagePKCS1(const KeySize: Integer; const Buf; const BufSize: Integer; var EncodedMessage: TRSAMessage);
var
  N, L, i, C: Integer;
  P, Q: PByte;
begin
  // validate
  if (KeySize <= 0) or (KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  // message size
  N := KeySize div 8; // number of bytes in key (max message size)
  C := BufSize;
  if C < 0 then
    C := 0;
  L := N - 3 - C; // number of padding bytes in PS
  if L < 8 then
    raise ERSA.Create(SRSAMessageTooLong);
  HugeWordSetSize(EncodedMessage, N div HugeWordElementSize);
  // 0x00
  P := EncodedMessage.Data;
  Inc(P, N - 1);
  P^ := 0;
  // 0x02
  Dec(P);
  P^ := 2;
  // PS
  Dec(P);
  for i := 0 to L - 1 do
  begin
    P^ := RandomByteNonZero;
    Dec(P);
  end;
  // 0x00
  P^ := 0;
  Dec(P);
  // M
  if C = 0 then
    exit;
  Q := @Buf;
  for i := 0 to C - 1 do
  begin
    P^ := Q^;
    Dec(P);
    Inc(Q);
  end;
end;

{ RSA OAEP MGF1 }
{ Mask generation function (MGF) function for OAEP encoding. }
{ This implements MGF1 from PKCS1v2-1 using SHA1 hashing. }
{ }
{ MGF1 (mgfSeed, maskLen) }
{ mgfSeed = seed from which mask is generated, an octet string }
{ maskLen = intended length in octets of the mask, at most 2^32 * hLen }
{ Hash = hash function }
{ hLen = length in octets of the hash function output }
{ mask = mask, an octet string of length maskLen }
{ Steps: }
{ 1. If maskLen > 2^32 * hLen, output “mask too long” and stop. }
{ 2. Let T be the empty octet string. }
{ 3. For counter from 0 to [ maskLen / hLen ] – 1, do the following: }
{ a. Convert counter to an octet string C of length 4 octets }
{ C = I2OSP (counter, 4) }
{ b. Concatenate the hash of the seed mgfSeed and C to the octet string T }
{ T = T || Hash (mgfSeed || C) }
{ 4. Output the leading maskLen octets of T as the octet string mask. }
procedure RSAOAEPMGF1(const SeedBuf; const SeedBufSize: Integer; var MaskBuf; const MaskBufSize: Integer);
var
  N, i, C, d, j: Integer;
  // HashStr: AnsiString;
  HashStr: String;
  HashSHA1: T160BitDigest;
  P, Q, R: PByte;
const
  hLen = SizeOf(T160BitDigest);
begin
  Assert(SeedBufSize > 0);
  Assert(MaskBufSize > 0);

  SetLength(HashStr, SeedBufSize + 4);
  N := (MaskBufSize + hLen - 1) div hLen;
  C := MaskBufSize;
  P := @MaskBuf;
  for i := 0 to N - 1 do
  begin
    // HashStr = mgfSeed || C
    Move(SeedBuf, HashStr[1], SeedBufSize);
    R := @HashStr[SeedBufSize + 1];
    Q := @i;
    Inc(Q, 3);
    for j := 0 to 3 do
    begin
      R^ := Q^;
      Inc(R);
      Dec(Q);
    end;
    // HashSHA1 = Hash (mgfSeed || C)
    HashSHA1 := CalcSHA1(HashStr);
    // T = T || Hash (mgfSeed || C)
    d := C;
    if d > hLen then
      d := hLen;
    Move(HashSHA1, P^, d);
    Inc(P, d);
    Dec(C, d);
  end;
end;

{ RSA XOR Buf }
procedure RSAXORBuf(var Buf; const BufSize: Integer; const MaskBuf; const MaskSize: Integer);
var
  N, i, j, C: Integer;
  P, Q: PByte;
begin
  Assert(MaskSize > 0);

  C := BufSize;
  if C < 0 then
    C := 0;
  if C = 0 then
    exit;
  N := (C + MaskSize - 1) div MaskSize;
  P := @Buf;
  for i := 0 to N - 1 do
  begin
    Q := @MaskBuf;
    for j := 0 to MaskSize - 1 do
    begin
      P^ := P^ xor Q^;
      Inc(P);
      Inc(Q);
      Dec(C);
      if C = 0 then
        exit;
    end;
  end;
end;

{ RSA Encode Message OAEP }
{ Encodes a message buffer as a RSA message. }
{ Uses EME-OAEP encoding using SHA1 hashing. }
{ }
{ EME-OAEP-Encode(M, P,emLen) }
{ M = message to be encoded, length at most emLen - 2 - 2 * hLen }
{ mLen = length in octets of the message M }
{ hLen = length in octets of the hash function output }
{ PS = emLen - mLen - 2 * hLen - 2 zero octets }
{ P = encoding parameters, an octet string (default empty) }
{ pHash = Hash(P), an octet string of length hLen }
{ DB = pHash || PS || 01 || M }
{ seed = random octet string of length hLen }
{ dbMask = MGF(seed, emLen - hLen) }
{ maskedDB = DB x dbMask }
{ seedMask = MGF(maskedDB, hLen) }
{ maskedSeed = seed x seedMask }
{ EM = 0x00 || maskedSeed || maskedDB }
const
  RSAOAEPHashBufSize = SizeOf(T160BitDigest);

  { .DEFINE DEBUG_RSAFixedSeed }
procedure RSAEncodeMessageOAEP(const KeySize: Integer; const Buf; const BufSize: Integer; var EncodedMessage: TRSAMessage);
var
  mLen, emLen, psLen, dbMaskLen, dbLen, i: Integer;
  // seed, PS, dbMask, pHash, DB, maskedDB, seedMask, maskedSeed, EM: AnsiString;
  seed, PS, dbMask, pHash, DB, maskedDB, seedMask, maskedSeed, EM: String;
  P, Q: PByte;
const
  hLen = RSAOAEPHashBufSize;
begin
  // validate
  if (KeySize <= 0) or (KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  // message size
  emLen := KeySize div 8; // number of bytes in key (max message size)
  mLen := BufSize;
  if mLen < 0 then
    mLen := 0;
  if mLen > emLen - 2 * hLen - 2 then
    raise ERSA.Create(SRSAMessageTooLong);
  HugeWordSetSize(EncodedMessage, emLen div HugeWordElementSize);
  // pHash = Hash(P), an octet string of length hLen
  // SetLength(pHash, hLen);
  // HashP := CalcSHA1('');
  // Move(HashP, pHash[1], hLen);
  pHash := #$DA#$39#$A3#$EE#$5E#$6B#$4B#$0D#$32#$55 + #$BF#$EF#$95#$60#$18#$90#$AF#$D8#$07#$09;
  // seed = random octet string of length hLen
{$IFDEF DEBUG_RSAFixedSeed}
  seed := #$aa#$fd#$12#$f6#$59#$ca#$e6#$34#$89#$b4 + #$79#$e5#$07#$6d#$de#$c2#$f0#$6c#$b5#$8f;
{$ELSE}
  SetLength(seed, hLen);
  for i := 1 to hLen do
    // seed[I] := AnsiChar(RandomByteNonZero);
    seed[i] := Char(RandomByteNonZero);
{$ENDIF}
  // PS = emLen - mLen - 2 * hLen - 2 zero octets
  psLen := emLen - mLen - 2 * hLen - 2;
  SetLength(PS, psLen);
  for i := 1 to psLen do
    PS[i] := #0;
  // dbMask = MGF(seed, emLen - hLen - 1)
  dbMaskLen := emLen - hLen - 1;
  SetLength(dbMask, dbMaskLen);
  RSAOAEPMGF1(seed[1], hLen, dbMask[1], dbMaskLen);
  // DB = pHash || PS || 01 || M
  dbLen := hLen + psLen + 1 + mLen;
  SetLength(DB, dbLen);
  P := @DB[1];
  Move(pHash[1], P^, hLen);
  Inc(P, hLen);
  Move(PS[1], P^, psLen);
  Inc(P, psLen);
  P^ := 1;
  Inc(P);
  Move(Buf, P^, mLen);
  // maskedDB = DB x dbMask
  SetLength(maskedDB, dbLen);
  Move(DB[1], maskedDB[1], dbLen);
  RSAXORBuf(maskedDB[1], dbLen, dbMask[1], dbMaskLen);
  // seedMask = MGF(maskedDB, hLen)
  SetLength(seedMask, hLen);
  RSAOAEPMGF1(maskedDB[1], dbLen, seedMask[1], hLen);
  // maskedSeed = seed x seedMask
  SetLength(maskedSeed, hLen);
  Move(seed[1], maskedSeed[1], hLen);
  RSAXORBuf(maskedSeed[1], hLen, seedMask[1], hLen);
  // EM = 0x00 || maskedSeed || maskedDB
  SetLength(EM, emLen);
  P := @EM[1];
  P^ := 0;
  Inc(P);
  Move(maskedSeed[1], P^, hLen);
  Inc(P, hLen);
  Move(maskedDB[1], P^, dbLen);
  // populate message
  P := EncodedMessage.Data;
  Inc(P, emLen - 1);
  Q := @EM[1];
  for i := 0 to emLen - 1 do
  begin
    P^ := Q^;
    Dec(P);
    Inc(Q);
  end;
end;

{ RSA Encrypt Message }
procedure RSAEncryptMessage(const Key: TRSAPrivateKey; const PlainMessage: TRSAMessage; var CipherMessage: TRSAMessage);
begin
  // validate
  if (Key.KeySize <= 0) or (Key.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if HugeWordCompare(PlainMessage, Key.Modulus) >= 0 then
    raise ERSA.Create(SRSAInvalidMessage);
  Assert(HugeWordGetBitCount(PlainMessage) = Key.KeySize);
  // encrypt
  HugeWordPowerAndMod(CipherMessage, PlainMessage, Key.Exponent, Key.Modulus);
  Assert(HugeWordGetBitCount(CipherMessage) = Key.KeySize);
end;

procedure RSAEncryptMessage_PbK(const Key: TRSAPublicKey; const PlainMessage: TRSAMessage; var CipherMessage: TRSAMessage);
begin
  // validate
  if (Key.KeySize <= 0) or (Key.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if HugeWordCompare(PlainMessage, Key.Modulus) >= 0 then
    raise ERSA.Create(SRSAInvalidMessage);
  Assert(HugeWordGetBitCount(PlainMessage) = Key.KeySize);
  // encrypt
  HugeWordPowerAndMod(CipherMessage, PlainMessage, Key.Exponent, Key.Modulus);
  Assert(HugeWordGetBitCount(CipherMessage) = Key.KeySize);
end;

{ RSA Cipher Message To Buf }
{ Copies cipher message to buffer. }
{ Returns the buffer size required for the message. }
function RSACipherMessageToBuf(const KeySize: Integer; const CipherMessage: TRSAMessage; var CipherBuf;
const CipherBufSize: Integer): Integer;
var
  L, i: Integer;
  P, Q: PByte;
begin
  if HugeWordGetBitCount(CipherMessage) <> KeySize then
    raise ERSA.Create(SRSAInvalidMessage);
  L := KeySize div 8;
  Result := L;
  if CipherBufSize <= 0 then
    exit;
  P := CipherMessage.Data;
  Inc(P, L - 1);
  Q := @CipherBuf;
  for i := 0 to L - 1 do
  begin
    if i >= CipherBufSize then
      exit;
    Q^ := P^;
    Inc(Q);
    Dec(P);
  end;
end;

{ RSA Encrypt }
function RSAEncrypt(const EncryptionType: TRSAEncryptionType; const PrivateKey: TRSAPrivateKey; const PlainBuf;
const PlainBufSize: Integer; var CipherBuf; const CipherBufSize: Integer): Integer;
var
  EncodedMsg, CipherMsg: HugeWord;
begin
  Result := 0;
  // validate
  if (PrivateKey.KeySize <= 0) or (PrivateKey.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if (PlainBufSize < 0) or (CipherBufSize <= 0) then
    raise ERSA.Create(SRSAInvalidBufferSize);
  // encrypt
  HugeWordInit(EncodedMsg);
  HugeWordInit(CipherMsg);
  try
    case EncryptionType of
      rsaetPKCS1:
        RSAEncodeMessagePKCS1(PrivateKey.KeySize, PlainBuf, PlainBufSize, EncodedMsg);
      rsaetOAEP:
        RSAEncodeMessageOAEP(PrivateKey.KeySize, PlainBuf, PlainBufSize, EncodedMsg);
    else
      raise ERSA.Create(SRSAInvalidEncryptionType);
    end;
    RSAEncryptMessage(PrivateKey, EncodedMsg, CipherMsg);
    Result := RSACipherMessageToBuf(PrivateKey.KeySize, CipherMsg, CipherBuf, CipherBufSize);
    if Result > CipherBufSize then
      raise ERSA.Create(SRSAInvalidBufferSize);
  finally
    SecureHugeWordFinalise(CipherMsg);
    SecureHugeWordFinalise(EncodedMsg);
  end;
end;

{ RSA Encrypt }
function RSAEncrypt_PbK(const EncryptionType: TRSAEncryptionType; const PublicKey: TRSAPublicKey; const PlainBuf;
const PlainBufSize: Integer; var CipherBuf; const CipherBufSize: Integer): Integer;
var
  EncodedMsg, CipherMsg: HugeWord;
begin
  Result := 0;
  // validate
  if (PublicKey.KeySize <= 0) or (PublicKey.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if (PlainBufSize < 0) or (CipherBufSize <= 0) then
    raise ERSA.Create(SRSAInvalidBufferSize);
  // encrypt
  HugeWordInit(EncodedMsg);
  HugeWordInit(CipherMsg);
  try
    case EncryptionType of
      rsaetPKCS1:
        RSAEncodeMessagePKCS1(PublicKey.KeySize, PlainBuf, PlainBufSize, EncodedMsg);
      rsaetOAEP:
        RSAEncodeMessageOAEP(PublicKey.KeySize, PlainBuf, PlainBufSize, EncodedMsg);
    else
      raise ERSA.Create(SRSAInvalidEncryptionType);
    end;
    RSAEncryptMessage_PbK(PublicKey, EncodedMsg, CipherMsg);
    Result := RSACipherMessageToBuf(PublicKey.KeySize, CipherMsg, CipherBuf, CipherBufSize);
    if Result > CipherBufSize then
      raise ERSA.Create(SRSAInvalidBufferSize);
  finally
    SecureHugeWordFinalise(CipherMsg);
    SecureHugeWordFinalise(EncodedMsg);
  end;
end;
{ RSA Encrypt Str }
// function RSAEncryptStr(const EncryptionType: TRSAEncryptionType; const PrivateKey: TRSAPrivateKey; const Plain: AnsiString): AnsiString;
// var
// L: Integer;
// begin
// L := RSACipherMessageBufSize(PrivateKey.KeySize);
// SetLength(Result, L);
// L := RSAEncrypt(EncryptionType, PrivateKey, PAnsiChar(Plain)^, Length(Plain), PAnsiChar(Result)^, L);
// SetLength(Result, L);
// end;

function RSAEncryptStr(const EncryptionType: TRSAEncryptionType; const PrivateKey: TRSAPrivateKey;
const Plain: String): String;
var
  L: Integer;
begin
  L := RSACipherMessageBufSize(PrivateKey.KeySize);
  SetLength(Result, L);
  L := RSAEncrypt(EncryptionType, PrivateKey, PChar(Plain)^, Length(Plain), PChar(Result)^, L);
  SetLength(Result, L);
end;

{ RSA Cipher Buf To Message }
procedure RSACipherBufToMessage(const KeySize: Integer; const CipherBuf; const CipherBufSize: Integer;
var CipherMessage: TRSAMessage);
var
  L, i: Integer;
  P, Q: PByte;
begin
  // validate
  if (KeySize <= 0) or (KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  // message size
  L := KeySize div 8;
  if CipherBufSize <> L then
    raise ERSA.Create(SRSAInvalidBufferSize);
  HugeWordSetSize(CipherMessage, L div HugeWordElementSize);
  // move data
  P := CipherMessage.Data;
  Inc(P, L - 1);
  Q := @CipherBuf;
  for i := 0 to L - 1 do
  begin
    P^ := Q^;
    Dec(P);
    Inc(Q);
  end;
end;

{ RSA Decrypt Message }
{ Decrypts using m = c^d mod n }
procedure RSADecryptMessage_PrK(const Key: TRSAPrivateKey; const CipherMessage: TRSAMessage;
var EncodedMessage: TRSAMessage);
begin
  // validate
  if (Key.KeySize <= 0) or (Key.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if HugeWordGetBitCount(CipherMessage) <> Key.KeySize then
    raise ERSA.Create(SRSAInvalidMessage);
  // decrypt
  HugeWordPowerAndMod(EncodedMessage, CipherMessage, Key.Exponent, Key.Modulus);
end;

procedure RSADecryptMessage(const Key: TRSAPublicKey; const CipherMessage: TRSAMessage; var EncodedMessage: TRSAMessage);
begin
  // validate
  if (Key.KeySize <= 0) or (Key.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if HugeWordGetBitCount(CipherMessage) <> Key.KeySize then
    raise ERSA.Create(SRSAInvalidMessage);
  // decrypt
  HugeWordPowerAndMod(EncodedMessage, CipherMessage, Key.Exponent, Key.Modulus);
end;

{ RSA Decode Message PKCS1 }
{ Decodes message previously encoded with RSAEncodeMessagePKCS1. }
{ Uses EME-PKCS1-v1_5 encoding. }
{ EM = 0x00 || 0x02 || PS || 0x00 || M }
{ Returns number of bytes needed to decode message. }
function RSADecodeMessagePKCS1(const KeySize: Integer; const EncodedMessage: HugeWord; var Buf;
const BufSize: Integer): Integer;
var
  L, i: Integer;
  P, Q: PByte;
begin
  // validate
  if (KeySize <= 0) or (KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if HugeWordGetBitCount(EncodedMessage) <> KeySize then
    raise ERSA.Create(SRSAInvalidMessage);
  // decode
  L := HugeWordGetSize(EncodedMessage) * HugeWordElementSize;
  if L < 3 then
    raise ERSA.Create(SRSAInvalidMessage);
  // 0x00
  P := EncodedMessage.Data;
  Inc(P, L - 1);
  if P^ <> 0 then
    raise ERSA.Create(SRSAInvalidMessage);
  // 0x02
  Dec(P);
  if P^ <> 2 then
    raise ERSA.Create(SRSAInvalidMessage);
  Dec(L, 2);
  // PS
  if L < 9 then
    raise ERSA.Create(SRSAInvalidMessage);
  repeat
    Dec(P);
    Dec(L);
  until (L = 0) or (P^ = 0);
  // 0x00
  if P^ <> 0 then
    raise ERSA.Create(SRSAInvalidMessage);
  // M
  Result := L;
  if L = 0 then
    exit;
  if BufSize = 0 then
    exit;
  Dec(P);
  Q := @Buf;
  for i := 0 to L - 1 do
  begin
    Q^ := P^;
    if i >= BufSize then
      exit;
    Dec(P);
    Inc(Q);
  end;
end;

{ RSA Decode Message OAEP }
{ Decodes message previously encoded with RSAEncodeMessageOAEP. }
{ Uses EME-OAEP encoding using SHA1 hashing. }
{ }
{ EME-OAEP-Encode(M, P,emLen) }
{ M = message to be encoded, length at most emLen - 2 - 2h * Len }
{ mLen = length in octets of the message M }
{ hLen = length in octets of the hash function output }
{ PS = emLen - mLen - 2 * hLen - 2 zero octets }
{ P = encoding parameters, an octet string (default empty) }
{ pHash = Hash(P), an octet string of length hLen }
{ DB = pHash || PS || 01 || M }
{ seed = random octet string of length hLen }
{ dbMask = MGF(seed, emLen - hLen) }
{ maskedDB = DB x dbMask }
{ seedMask = MGF(maskedDB, hLen) }
{ maskedSeed = seed x seedMask }
{ EM = 0x00 || maskedSeed || maskedDB }
function RSADecodeMessageOAEP(const KeySize: Integer; const EncodedMessage: HugeWord; var Buf;
const BufSize: Integer): Integer;
var
  i, L, emLen, dbLen: Integer;
  // maskedSeed, maskedDB, seedMask, seed, dbMask, DB, pHash, pHashPr: AnsiString;
  maskedSeed, maskedDB, seedMask, seed, dbMask, DB, pHash, pHashPr: String;
  P, Q: PByte;
const
  hLen = RSAOAEPHashBufSize;
begin
  // validate
  if (KeySize <= 0) or (KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  if HugeWordGetBitCount(EncodedMessage) <> KeySize then
    raise ERSA.Create(SRSAInvalidMessage);
  // decode
  emLen := HugeWordGetSize(EncodedMessage) * HugeWordElementSize;
  // EM = 0x00 || maskedSeed || maskedDB
  dbLen := emLen - hLen - 1;
  SetLength(maskedSeed, hLen);
  SetLength(maskedDB, dbLen);
  P := EncodedMessage.Data;
  Inc(P, emLen - 1);
  if P^ <> 0 then
    raise ERSA.Create(SRSAInvalidMessage);
  Dec(P);
  Q := @maskedSeed[1];
  for i := 0 to hLen - 1 do
  begin
    Q^ := P^;
    Dec(P);
    Inc(Q);
  end;
  Q := @maskedDB[1];
  for i := 0 to dbLen - 1 do
  begin
    Q^ := P^;
    Dec(P);
    Inc(Q);
  end;
  // Let seedMask = MGF(maskedDB, hLen)
  SetLength(seedMask, hLen);
  RSAOAEPMGF1(maskedDB[1], dbLen, seedMask[1], hLen);
  // Let seed = maskedSeed xor seedMask
  SetLength(seed, hLen);
  Move(maskedSeed[1], seed[1], hLen);
  RSAXORBuf(seed[1], hLen, seedMask[1], hLen);
  // Let dbMask = MGF(seed, ||EM|| - hLen)
  SetLength(dbMask, dbLen);
  RSAOAEPMGF1(seed[1], hLen, dbMask[1], dbLen);
  // Let DB = maskedDB xor dbMask.
  SetLength(DB, dbLen);
  Move(maskedDB[1], DB[1], dbLen);
  RSAXORBuf(DB[1], dbLen, dbMask[1], dbLen);
  // Let pHash = Hash(P), an octet string of length hLen
  // SetLength(pHash, hLen);
  // Hash := CalcSHA1('');
  // Move(Hash, pHash[1], hLen);
  pHash := #$DA#$39#$A3#$EE#$5E#$6B#$4B#$0D#$32#$55 + #$BF#$EF#$95#$60#$18#$90#$AF#$D8#$07#$09;
  // DB = pHash' || PS || 01 || M
  // Decode pHash'
  SetLength(pHashPr, hLen);
  Move(DB[1], pHashPr[1], hLen);
  if pHashPr <> pHash then
    raise ERSA.Create(SRSAInvalidMessage);
  // Decode PS || 01
  i := hLen + 1;
  while i <= dbLen do
    case Byte(DB[i]) of
      0:
        Inc(i);
      1:
        break;
    else
      raise ERSA.Create(SRSAInvalidMessage);
    end;
  if i > dbLen then
    raise ERSA.Create(SRSAInvalidMessage);
  if Byte(DB[i]) <> 1 then
    raise ERSA.Create(SRSAInvalidMessage);
  Inc(i);
  // Decode M
  L := dbLen - i + 1;
  Result := L;
  if L > BufSize then
    L := BufSize;
  if L > 0 then
    Move(DB[i], Buf, L);
end;

{ RSA Decrypt }
function RSADecrypt_PrK(const EncryptionType: TRSAEncryptionType; const Key: TRSAPrivateKey; const CipherBuf;
const CipherBufSize: Integer; var PlainBuf; const PlainBufSize: Integer): Integer;
var
  CipherMsg, EncodedMsg: HugeWord;
begin
  Result := 0;
  // validate
  if (Key.KeySize <= 0) or (Key.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  // decrypt
  HugeWordInit(CipherMsg);
  HugeWordInit(EncodedMsg);
  try
    RSACipherBufToMessage(Key.KeySize, CipherBuf, CipherBufSize, CipherMsg);
    RSADecryptMessage_PrK(Key, CipherMsg, EncodedMsg);
    case EncryptionType of
      rsaetPKCS1:
        Result := RSADecodeMessagePKCS1(Key.KeySize, EncodedMsg, PlainBuf, PlainBufSize);
      rsaetOAEP:
        Result := RSADecodeMessageOAEP(Key.KeySize, EncodedMsg, PlainBuf, PlainBufSize);
    else
      raise ERSA.Create(SRSAInvalidEncryptionType);
    end;
  finally
    SecureHugeWordFinalise(EncodedMsg);
    SecureHugeWordFinalise(CipherMsg);
  end;
end;

function RSADecrypt(const EncryptionType: TRSAEncryptionType; const Key: TRSAPublicKey; const CipherBuf;
const CipherBufSize: Integer; var PlainBuf; const PlainBufSize: Integer): Integer;
var
  CipherMsg, EncodedMsg: HugeWord;
begin
  Result := 0;
  // validate
  if (Key.KeySize <= 0) or (Key.KeySize mod HugeWordElementBits <> 0) then
    raise ERSA.Create(SRSAInvalidKeySize);
  // decrypt
  HugeWordInit(CipherMsg);
  HugeWordInit(EncodedMsg);
  try
    RSACipherBufToMessage(Key.KeySize, CipherBuf, CipherBufSize, CipherMsg);
    RSADecryptMessage(Key, CipherMsg, EncodedMsg);
    case EncryptionType of
      rsaetPKCS1:
        Result := RSADecodeMessagePKCS1(Key.KeySize, EncodedMsg, PlainBuf, PlainBufSize);
      rsaetOAEP:
        Result := RSADecodeMessageOAEP(Key.KeySize, EncodedMsg, PlainBuf, PlainBufSize);
    else
      raise ERSA.Create(SRSAInvalidEncryptionType);
    end;
  finally
    SecureHugeWordFinalise(EncodedMsg);
    SecureHugeWordFinalise(CipherMsg);
  end;
end;

{ RSA Decrypt Str }
// function RSADecryptStr(const EncryptionType: TRSAEncryptionType; const PublicKey: TRSAPublicKey; const Cipher: AnsiString): AnsiString;
// var
// L, N: Integer;
// begin
// L := Length(Cipher);
// if L = 0 then
// raise ERSA.Create(SRSAInvalidMessage);
// N := RSACipherMessageBufSize(PublicKey.KeySize);
// SetLength(Result, N);
// N := RSADecrypt(EncryptionType, PublicKey, PAnsiChar(Cipher)^, L, PAnsiChar(Result)^, N);
// SetLength(Result, N);
// end;

function RSADecryptStr(const EncryptionType: TRSAEncryptionType; const PublicKey: TRSAPublicKey;
const Cipher: String): String;
var
  L, N: Integer;
begin
  L := Length(Cipher);
  if L = 0 then
    raise ERSA.Create(SRSAInvalidMessage);
  N := RSACipherMessageBufSize(PublicKey.KeySize);
  SetLength(Result, N);
  N := RSADecrypt(EncryptionType, PublicKey, PChar(Cipher)^, L, PChar(Result)^, N);
  SetLength(Result, N);
end;

// procedure EncryptAsimm(var Msg: AnsiString; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);
// const
// KeySize = 1024;
// begin
// //Генерируем ключи
// RSAPrivateKeyInit(Pri);
// RSAPublicKeyInit(Pub);
// RSAGenerateKeys(KeySize, Pri, Pub);
//
// //Выполняем RSA шифрование
// Msg := RSAEncryptStr(rsaetPKCS1, Pri, Msg);
// end;

procedure EncryptAsimm(var Msg: String; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);
const
  KeySize = 1024;
begin
  // Генерируем ключи
  RSAPrivateKeyInit(Pri);
  RSAPublicKeyInit(Pub);
  RSAGenerateKeys(KeySize, Pri, Pub);

  // Выполняем RSA шифрование
  Msg := RSAEncryptStr(rsaetPKCS1, Pri, Msg);
end;

// procedure DecryptAsimm(var Msg: AnsiString; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);
// begin
// //Выпоняем RSA дешифрование
// Msg := RSADecryptStr(rsaetPKCS1, Pub, Msg);
// //Удаляем ключи
// RSAPublicKeyFinalise(Pub);
// RSAPrivateKeyFinalise(Pri);
// end;

procedure DecryptAsimm(var Msg: String; var Pri: TRSAPrivateKey; var Pub: TRSAPublicKey);
begin
  // Выпоняем RSA дешифрование
  Msg := RSADecryptStr(rsaetPKCS1, Pub, Msg);
  // Удаляем ключи
  RSAPublicKeyFinalise(Pub);
  RSAPrivateKeyFinalise(Pri);
end;

function gen(x1, x2: longint): int64;
const
  p1 = 10000;
var
  L, h: int64;
  m: real;
begin
  m := time * p1 + random;
  h := trunc(m);
  m := m - h;
  L := trunc(m * p1);
  gen := L * (x2 - x1 + 1) div (p1) + x1;
end;

function GenCiclNam(d, N: cardinal): cardinal;
var
  i: cardinal;
begin
  ep := d;
  for i := 1 to N do
  begin
    ep := abs(sin(ep));
    ep := ep * 429496729;
  end;
  GenCiclNam := trunc(ep);
end;

function GenP(gran: cardinal): word; // gran-верхняя граница диапазона
begin
  ep := abs(sin(ep));
  ep := ep * 100;
  ep := ep - trunc(ep);
  GenP := trunc(ep * gran);
end;

procedure String_Pack(var s: string);
var
  i: cardinal;
  d: Byte;
  k: Integer;
begin
  GenCiclNam(15436757, 1);
  k := Length(s);
  for i := 1 to k do
  begin
    d := ord(s[i]) + GenP(20);
    s[i] := chr(d);
  end;
end;

procedure EncryptSimm(StrIn: string; var StrOut: string);
var
  s: string;
  R, i: cardinal;

  procedure String_Pack_self(R, X, N: cardinal; var s: string);
  var
    i: cardinal;
    d: Byte;
    _ep: real;

    function _GenCiclNam(R, d, N: cardinal): cardinal;
    var
      i: cardinal;
    begin
      _ep := d;
      for i := 1 to N do
      begin
        _ep := abs(sin(_ep));
        _ep := _ep * R;
      end;
      _GenCiclNam := trunc(_ep);
    end;

    function _GenP(gran: cardinal): word;
    begin
      _ep := abs(sin(_ep));
      _ep := _ep * 100;
      _ep := _ep - trunc(_ep);
      _GenP := trunc(_ep * gran);
    end;

  begin
    _GenCiclNam(R, X, N);
    for i := 1 to Length(s) do
    begin
      d := ord(s[i]) + _GenP(20);
      s[i] := chr(d);
    end;
    s := inttostr(R) + s;
    String_Pack(s);
  end;

begin
  // for i:=1 to 1000 do begin
  s := StrIn;
  R := gen(100, 990) * 10 + gen(1, 9); // 429496729;
  String_Pack_self(R, 11, 1, s);
  StrOut := '';
  for i := 1 to Length(s) do
    StrOut := StrOut + inttohex(ord(s[i]), 2);
end;

function HexToStr(HexStr: string; const Text: boolean = True): string;
var
  Hex: Byte;
  sTemp: string;
  i: Integer;
begin
  Result := '';
  if Length(HexStr) mod 2 <> 0 then
    exit;

  for i := 2 to Length(HexStr) do
    if i mod 2 = 0 then
    begin
      sTemp := '$' + Copy(HexStr, i - 1, 2);
      Hex := Byte(StrToInt(sTemp));

      if Hex = $00 then
      begin
        if Text then
          Result := Result + ' '
        else
          Result := Result + #$00;
        Continue;
      end;
      Result := Result + chr(Hex);
    end;
end;

procedure String_UnPack(var s: string);
var
  i: cardinal;
  d: Byte;
begin
  GenCiclNam(15436757, 1);
  for i := 1 to Length(s) do
  begin
    d := ord(s[i]) - GenP(20);
    s[i] := chr(d);
  end;
end;

procedure DecryptSimm(var Lne: string);
var
  s, h: string;
  R: cardinal;
  i: Integer;

  procedure String_UnPack_self(R, X, N: cardinal; var s: string);
  var
    i: cardinal;
    d: Byte;
    _ep: real;

    function _GenCiclNam(d, N: cardinal): cardinal;
    var
      i: cardinal;
    begin
      _ep := d;
      for i := 1 to N do
      begin
        _ep := abs(sin(_ep));
        _ep := _ep * R;
      end;
      _GenCiclNam := trunc(ep);
    end;

    function _GenP(gran: cardinal): word; // gran-верхняя граница диапазона
    begin
      _ep := abs(sin(_ep));
      _ep := _ep * 100;
      _ep := _ep - trunc(_ep);
      _GenP := trunc(_ep * gran);
    end;

  begin
    _GenCiclNam(X, N);
    for i := 1 to Length(s) do
    begin
      d := ord(s[i]) - _GenP(20);
      s[i] := chr(d);
    end;
  end;

begin
  s := HexToStr(Lne, True);
  String_UnPack(s);
  h := s;
  SetLength(h, 4);
  R := strtointdef(h, 0);
  if R = 0 then
  begin
    Lne := '';
    exit;
  end;
  h := '';
  for i := 5 to Length(s) do
    h := h + s[i];
  String_UnPack_self(R, 11, 1, h);
  Lne := h;
end;

end.
