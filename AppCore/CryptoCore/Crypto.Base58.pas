unit Crypto.Base58;

interface

uses
  System.SysUtils,
  Crypto.AlphabetBase58;

type

  TBase58Alphabet = class(TEncodingAlphabet)
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TBase58 = class
  strict private
    Falphabet: TBase58Alphabet;

  const
    TBaseLength = Int32(58);

  public
    function Encode(const Bytes: TBytes): String;
    function Decode(const InText: String): TBytes;

    constructor Create;
    destructor Destroy; override;
  end;

function StringToCharArray(const S: String): TCharArr;

implementation

function StringToCharArray(const S: String): TCharArr;
begin
  Result := Nil;
  if System.Length(S) > 0 then
  begin
    System.SetLength(Result, System.Length(S) + 1);
    StrPLCopy(PChar(Result), S, System.Length(Result));
    System.SetLength(Result, System.Length(S));
  end;
end;

{ TBase58 }

constructor TBase58.Create;
begin
  Falphabet := TBase58Alphabet.Create;
end;

function TBase58.Decode(const InText: String): TBytes;
const
  reductionFactor = Int32(733);
var
  textLen, numZeroes, outputLen, carry, resultLen, LowPoint: Int32;
  tempDouble: Double;
  inputPtr, pEnd, pInput: PChar;
  outputPtr, pOutputEnd, pDigit, pOutput: PByte;
  FirstChar, c: Char;
  Value: string;
  Text: TArray<Char>;
  output, table: TBytes;
begin
  Text := StringToCharArray(InText);

  Result := Nil;
  textLen := System.Length(Text);
  if (textLen = 0) then
  begin
    Exit;
  end;

  inputPtr := PChar(Text);

  pEnd := inputPtr + textLen;
  pInput := inputPtr;
{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(String);
{$ELSE}
  LowPoint := 1;
{$ENDIF DELPHIXE3_UP}
  Value := Falphabet.Value;
  FirstChar := Value[LowPoint];
  while ((pInput^ = FirstChar) and (pInput <> pEnd)) do
  begin
    System.Inc(pInput);
  end;

  numZeroes := Int32(pInput - inputPtr);
  if (pInput = pEnd) then
  begin
    System.SetLength(Result, numZeroes);
    Exit;
  end;

  tempDouble := ((textLen * reductionFactor) / 1000.0) + 1;
  outputLen := Int32(Round(tempDouble));
  table := Falphabet.ReverseLookupTable;
  System.SetLength(output, outputLen);
  outputPtr := PByte(output);

  pOutputEnd := outputPtr + outputLen - 1;
  while (pInput <> pEnd) do
  begin
    c := pInput^;
    System.Inc(pInput);
    carry := table[Ord(c)] - 1;
    if (carry < 0) then
    begin
      Falphabet.InvalidCharacter(c);
    end;
    pDigit := pOutputEnd;
    while pDigit >= outputPtr do
    begin
      carry := carry + (TBaseLength * pDigit^);
      pDigit^ := Byte(carry);
      // carry := carry div 256;
      carry := carry shr 8;
      System.Dec(pDigit);
    end;

  end;

  pOutput := outputPtr;
  while ((pOutput <> pOutputEnd) and (pOutput^ = 0)) do
  begin
    System.Inc(pOutput);
  end;

  resultLen := Int32(pOutputEnd - pOutput) + 1;
  if (resultLen = outputLen) then
  begin
    Result := output;
    Exit;
  end;
  System.SetLength(Result, numZeroes + resultLen);
  System.Move(output[Int32(pOutput - outputPtr)], Result[numZeroes], resultLen);
end;

destructor TBase58.Destroy;
begin
  Falphabet.Free;
  inherited Destroy;
end;

function TBase58.Encode(const Bytes: TBytes): String;
const
  growthPercentage = Int32(138);
var
  bytesLen, numZeroes, outputLen, Length, carry, i, resultLen: Int32;
  inputPtr, pInput, pEnd, outputPtr, pOutputEnd, pDigit, pOutput: PByte;
  alphabetPtr, resultPtr, pResult: PChar;
  ZeroChar: Char;
  output: TBytes;
  Value: String;
begin
  Result := '';
  bytesLen := System.Length(Bytes);
  if (bytesLen = 0) then
  begin
    Exit;
  end;
  inputPtr := PByte(Bytes);
  Value := Falphabet.Value;
  alphabetPtr := PChar(Value);

  pInput := inputPtr;
  pEnd := inputPtr + bytesLen;
  while ((pInput <> pEnd) and (pInput^ = 0)) do
  begin
    System.Inc(pInput);
  end;
  numZeroes := Int32(pInput - inputPtr);

  ZeroChar := alphabetPtr^;

  if (pInput = pEnd) then
  begin
    Result := StringOfChar(ZeroChar, numZeroes);
    Exit;
  end;

  outputLen := bytesLen * growthPercentage div 100 + 1;
  Length := 0;
  System.SetLength(output, outputLen);
  outputPtr := PByte(output);

  pOutputEnd := outputPtr + outputLen - 1;
  while (pInput <> pEnd) do
  begin
    carry := pInput^;
    i := 0;
    pDigit := pOutputEnd;
    while (((carry <> 0) or (i < Length)) and (pDigit >= outputPtr)) do
    begin
      carry := carry + (256 * pDigit^);
      pDigit^ := Byte(carry mod TBaseLength);
      carry := carry div TBaseLength;
      System.Dec(pDigit);
      System.Inc(i);
    end;

    Length := i;
    System.Inc(pInput);
  end;

  System.Inc(pOutputEnd);
  pOutput := outputPtr;
  while ((pOutput <> pOutputEnd) and (pOutput^ = 0)) do
  begin
    System.Inc(pOutput);
  end;

  resultLen := numZeroes + Int32(pOutputEnd - pOutput);
  Result := StringOfChar(ZeroChar, resultLen);
  resultPtr := PChar(Result);

  pResult := resultPtr + numZeroes;
  while (pOutput <> pOutputEnd) do
  begin
    pResult^ := alphabetPtr[pOutput^];
    System.Inc(pOutput);
    System.Inc(pResult);
  end;

end;

{ TBase58Alphabet }

constructor TBase58Alphabet.Create;
begin
  Inherited Create(58, '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');
end;

destructor TBase58Alphabet.Destroy;
begin
  inherited Destroy;
end;

end.
