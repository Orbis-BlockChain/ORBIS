unit Crypto.RSA;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Hash,
  App.Types,
  Crypto.BIP39,
  Crypto.BinConverter,
  RSA.main;

function RSAGenPrivateKey: TBytes;
function RSAGetPublicKey(const PrivateKey: TBytes): TBytes;

function GenerateWordsOnPK(const PrivateKey: TBytes): strings;
function GeneratePKOnWords(AWords: strings): TBytes;

function RSAEncrypt(const PrivateKey, Data: TBytes): TBytes;
function RSADecrypt(const PublicKey, Data: TBytes): TBytes;

function SearchInBIP39(AWord: string): integer;
function CheckWordsForCorrectness(AWords: strings): boolean;

implementation

const
  KeySize = 512;

function CheckWordsForCorrectness(AWords: strings): boolean;
var
  bin: string;
begin
  Result := True;
  bin := '';
  for var strValue in AWords do
  begin
    var
      indValue: integer;

    TArray.BinarySearch(BIP39WordList, strValue.ToLower, indValue);

    var
    resinttobin := IntToBin(indValue);

    if Length(resinttobin) < 11 then
      for var i := 0 to 11 - Length(resinttobin) - 1 do
        resinttobin := '0' + resinttobin;

    bin := bin + resinttobin;
  end;

  var hashBin := Copy(bin, 1, 47 * 11 - 5);
  var Hash := THashSHA2.GetHashBytes(hashBin);
  var controlStr := Copy(ByteToBinStr(Hash[0]), 1, 5);
  var laststr := Copy(bin, length(bin) - 4, 5);

  if controlStr <> laststr then
    Result := False;
end;

function SearchInBIP39(AWord: string): integer;
begin
  Result := -1;
  for var i := 0 to Length(BIP39WordList) - 1 do
  begin
    if LowerCase(AWord) = BIP39WordList[i] then
    begin
      Result := i;
      break;
    end;
  end;
end;

function GenerateWordsOnPK(const PrivateKey: TBytes): strings;
begin
  PrivKeyToWords(PrivateKey, Result);
end;

function GeneratePKOnWords(AWords: strings): TBytes;
var
  Pri: TPrivateKey;
begin
  WordsToPrivKey(AWords, Pri, KeySize);
  PrivKeyToBytes(Pri, Result);
  FinalizePrivKey(Pri);
end;

function RSAGenPrivateKey: TBytes;
var
  Pri: TPrivateKey;
  words: strings;
begin
  GenPrivKey(KeySize, Pri);
  PrivKeyToBytes(Pri, Result);
  FinalizePrivKey(Pri);
end;

function RSAGetPublicKey(const PrivateKey: TBytes): TBytes;
var
  Pri: TPrivateKey;
  Pub: TPublicKey;
begin
  if Length(PrivateKey) = 0 then
    Exit(nil);
  BytesToPrivKey(PrivateKey, Pri);
  GenPubKey(Pri, Pub);
  PubKeyToBytes(Pub, Result);
  FinalizePrivKey(Pri);
  FinalizePubKey(Pub);
end;

function RSAEncrypt(const PrivateKey, Data: TBytes): TBytes;
var
  Pri: TPrivateKey;
begin
  if Length(PrivateKey) = 0 then
    Exit(nil);
  BytesToPrivKey_lt(PrivateKey, Pri);
  RSAPrKEncrypt(Pri, Data, Result);
  FinalizePrivKey(Pri);
end;

function RSADecrypt(const PublicKey, Data: TBytes): TBytes;
var
  Pub: TPublicKey;
begin
  if Length(PublicKey) = 0 then
    Exit(nil);
  BytesToPubKey(PublicKey, Pub);
  RSAPbKDecrypt(Pub, Data, Result);
  FinalizePubKey(Pub);
end;

end.
