unit CryptoEntity;

interface

uses
  System.Math,
  System.Generics.Collections,
  System.SysUtils;

const
  keySize = 512;
  FermaRSANums: array [0 .. 4] of integer = (3, 5, 17, 257, 65537);

type
  TRSAPairKeysHandler = record
  private
    p: Int64;
    q: Int64;
    composition: Int64;
    Euler: Int64;
    OpenExp: Int64;
    SecretExp: Int64;
  public
    procedure SetPrivateKey(Key: TBytes);
    procedure GeneratePairKeys;
    function GetPublicKey: TBytes;
    function GetPrivateKey: TBytes;
  end;

  TCryptoEntity = class
    class function GeneratePrivateKey: TBytes; static;
    class function GeneratePublicKey(const PrivateKey: TBytes): TBytes; static;
    class function EncryptData(PrivateKey: TBytes): TBytes; static;
    class function DecruptData(PublicKey: TBytes): TBytes; static;
  end;

  // function FourBytesToHex(const bytes: TBytes): string;

implementation

{ TCryptoEntity }

class function TCryptoEntity.DecruptData(PublicKey: TBytes): TBytes;
begin

end;

class function TCryptoEntity.EncryptData(PrivateKey: TBytes): TBytes;
begin

end;

class function TCryptoEntity.GeneratePrivateKey: TBytes;
var
  PrivateKey: TRSAPairKeysHandler;
begin
  PrivateKey.GeneratePairKeys;
end;

class function TCryptoEntity.GeneratePublicKey(const PrivateKey: TBytes): TBytes;
begin

end;

{ TPrivateKey }

function IsPlaneNumeral(X: integer): Boolean;
var
  i: integer;
begin
  result := false;
  for i := 2 to Round(sqrt(X)) do
    result := result or ((X mod i) = 0);
  result := not result;
end;

function GCD(a, b: integer): integer;
begin
  while a <> b do
  begin
    if a > b then
      a := a - b
    else
      b := b - a;
  end;
  result := a;
end;
//
// function Swap32(value: integer): integer;
// asm
// bswap eax
// end;

// function FourBytesToHex(const bytes: TBytes): string;
// var
// IntBytes: PInteger;
// FullResult: string;
// begin
// // Assert(Length(bytes) = SizeOf(IntBytes^));
// IntBytes := PInteger(bytes);
// FullResult := IntToHex(Swap32(IntBytes^), 8);
// result := FullResult[2] + FullResult[4] + FullResult[6] + FullResult[8];
// end;

procedure TRSAPairKeysHandler.GeneratePairKeys;
var
  flag: Boolean;
  d: integer;
begin
  flag := True;
  while flag do
  begin
    p := RandomRange(3, Int8.MaxValue);
    q := RandomRange(3, Int8.MaxValue);
    if IsPlaneNumeral(p) and IsPlaneNumeral(q) then
      flag := false;
  end;
  flag := True;

  composition := p * q;
  Euler := (p - 1) * (q - 1);
{$REGION 'Euqlid'}
  // flag := True;
  // while flag do
  // begin
  // OpenExp := RandomRange(3,Euler - 1);
  // if GCD(OpenExp, Euler) = 1 then
  // flag := False;
  // end;
{$ENDREGION}
  repeat
    OpenExp := FermaRSANums[RandomRange(0, 4)];
  until OpenExp <= Euler;
  flag := True;
  d := 1;
  while flag do
  begin
    if ((d * OpenExp) mod Euler = 1) then
    begin
      SecretExp := d;
      flag := false;
    end
    else
      inc(d);
  end;
end;

function TRSAPairKeysHandler.GetPrivateKey: TBytes;
var
  Return: TBytes;
begin
  SetLength(Return, 16);
  Move(SecretExp, Return[0], 8);
  Move(composition, Return[8], 8);
  result := Return;
end;

function TRSAPairKeysHandler.GetPublicKey: TBytes;
var
  Return: TBytes;
begin
  SetLength(Return, 16);
  Move(OpenExp, Return[0], 8);
  Move(composition, Return[8], 8);
  result := Return;
end;

procedure TRSAPairKeysHandler.SetPrivateKey(Key: TBytes);
begin
  Move(Key[0], Self, SizeOf(TRSAPairKeysHandler));
end;

end.
