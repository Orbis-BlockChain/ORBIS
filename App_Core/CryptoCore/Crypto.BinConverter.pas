unit Crypto.BinConverter;

interface

uses
  System.SysUtils;

const
  BytePowers: array [1 .. 8] of byte = (128, 64, 32, 16, 8, 4, 2, 1);

function IntToBin(IValue: Integer): string;
function BinToInt(BinStr: string): Integer;
function ByteToBinStr(Value: byte): string;
Function BinStringToByte(const aString: String): byte;

implementation

function ByteToBinStr(Value: byte): string;
var
  i: Integer;
begin
  Result := '00000000';
  if (Value <> 0) then
    for i := 1 to 8 do
      if (Value and BytePowers[i]) <> 0 then
        Result[i] := '1';
end;

Function BinStringToByte(const aString: String): byte;
Var
  eLoop1: byte;
Begin
  Result := 0;
  For eLoop1 := 7 downto 0 do
    Result := Result + (Ord(aString[8 - eLoop1]) - Ord('0')) shl eLoop1;
End;

function IntToBin(IValue: Integer): string;
const
  NumBits: word = 32;
var
  RetVar: string;
  i, ILen: byte;
begin
  RetVar := '';

  while IValue <> 0 do
  begin
    RetVar := char(48 + (IValue and 1)) + RetVar;
    IValue := IValue shr 1;
  end;

  if RetVar = '' then
    RetVar := '0';
  Result := RetVar;
end;

function BinToInt(BinStr: string): Integer;
var
  i: byte;
  RetVar: Integer;
begin
  BinStr := UpperCase(BinStr);
  if BinStr[length(BinStr)] = 'B' then
    Delete(BinStr, length(BinStr), 1);
  RetVar := 0;
  for i := 1 to length(BinStr) do
  begin
    if not(BinStr[i] in ['0', '1']) then
    begin
      RetVar := 0;
      Break;
    end;
    RetVar := (RetVar shl 1) + (byte(BinStr[i]) and 1);
  end;

  Result := RetVar;
end;

end.
