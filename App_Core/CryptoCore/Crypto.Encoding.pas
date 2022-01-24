unit Crypto.Encoding;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Hash,
  System.NetEncoding,
  Crypto.Base58;

function BytesEncodeBase64URL(const Bytes: TBytes): string;
function BytesDecodeBase64URL(const S: string): TBytes;

function BytesEncodeHex(const Bytes: TBytes): string;
function BytesDecodeHex(const S: string): TBytes;

function BytesEncodeBase58(const Bytes: TBytes): string;
function BytesDecodeBase58(const S: string): TBytes;

function BytesEncodeBase64(const Bytes: TBytes; LineBreak: Boolean): string;
function BytesDecodeBase64(const S: string): TBytes;

function BytesDecode(const S: string): TBytes;
function CanBytesDecode(const S: string): Boolean;

implementation

function BytesDecodeBase64URL(const S: string): TBytes;
var
  Base64Encoding: TBase64Encoding;
begin
  Base64Encoding := TBase64Encoding.Create(MaxInt);
  Result := Base64Encoding.DecodeStringToBytes(S.Replace('-', '+').Replace('_', '/'));
  Base64Encoding.Free;
end;

function BytesEncodeBase64URL(const Bytes: TBytes): string;
var
  Base64Encoding: TBase64Encoding;
begin
  Base64Encoding := TBase64Encoding.Create(MaxInt);
  Result := Base64Encoding.EncodeBytesToString(Bytes).Replace('+', '-').Replace('/', '_').TrimRight(['=']);
  Base64Encoding.Free;
end;


function BytesDecodeHex(const S: string): TBytes;
begin
  SetLength(Result, Length(S) div 2);
  HexToBin(BytesOf(S), 0, Result, 0, Length(Result));
end;

function BytesEncodeHex(const Bytes: TBytes): string;
begin
  Result := THash.DigestAsString(Bytes);
end;

function BytesEncodeBase58(const Bytes: TBytes): string;

var

  FBase58: TBase58;

begin

  FBase58 := TBase58.Create;

  try

    Result := FBase58.Encode(Bytes);
  finally
    FBase58.Free;
  end;
end;

function BytesDecodeBase58(const S: string): TBytes;

var

  FBase58: TBase58;

begin

  FBase58 := TBase58.Create;

  try

    Result := FBase58.Decode(S);
  finally
    FBase58.Free;
  end;
end;

function BytesEncodeBase64(const Bytes: TBytes; LineBreak: Boolean): string;
var
  Base64Encoding: TBase64Encoding;
begin
  if LineBreak then
    Base64Encoding := TBase64Encoding.Create(32)
  else
    Base64Encoding := TBase64Encoding.Create(MaxInt);
  Result := Base64Encoding.EncodeBytesToString(Bytes);
  Base64Encoding.Free;
end;

function BytesDecodeBase64(const S: string): TBytes;
begin
  Result := TBase64Encoding.Base64.DecodeStringToBytes(S);
end;

function IsHexChar(C: Char): Boolean; inline;
begin
  Result := CharInSet(C, ['0' .. '9', 'A' .. 'F', 'a' .. 'f']);
end;

function IsHex(const S: string): Boolean;
var
  C: Char;
begin
  for C in S.ToCharArray do
    if not IsHexChar(C) then
      Exit(False);
  Result := True;
end;

function BytesDecode(const S: string): TBytes;
begin
  if IsHex(S) then
    Result := BytesDecodeHex(S)
  else
    Result := BytesDecodeBase64(S);
end;

const
  Base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='#13#10;

function CanBytesDecode(const S: string): Boolean;
var
  C: Char;
begin
  for C in S.ToCharArray do
    if not Base64Chars.Contains(C) then
      Exit(False);
  Result := not S.IsEmpty;
end;


end.
