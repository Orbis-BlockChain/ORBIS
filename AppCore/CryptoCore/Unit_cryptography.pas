unit Unit_cryptography;

interface

uses System.Classes,
  System.SysUtils,
  System.Hash;

type
  PFileStream = ^TFileStream;
  PMemoryStream = ^TMemoryStream;

function key1(Password: string): string;
function key2(Password: string): string;
procedure fcrypt(Password: string; input_file, output_file: PFileStream);
procedure mcrypt(Password: string; input_mem, output_mem: PMemoryStream);
procedure decrypt(Password: string; input_file, output_file: PFileStream);
procedure mdecrypt(Password: string; input_mem, output_mem: PMemoryStream);

const
  REPEAT_CRYPT = 3;

implementation

function key1(Password: string): string;
begin
  key1 := THashSHA2.GetHashString(Password);
  // key_crypt2:= THashSHA2.GetHMAC(Password, key_crypt, SHA256);
end;

function key2(Password: string): string;
begin
  key2 := THashSHA2.GetHMAC(Password, key1(Password), SHA256);
end;

procedure GenArrKey(key_byte: TBytes; var arr_key: array of TBytes);
var
  l, i, j, shift, sum: Integer;
begin
  l := Length(key_byte);
  SetLength(arr_key[0], l);
  // Move(key_byte,arr_key[0],l);
  sum := 0;
  for i := 0 to l - 1 do
  begin
    if (key_byte[i] mod l <> 0) then
      arr_key[0, i] := key_byte[i]
    else
      arr_key[0, i] := key_byte[i] xor (key_byte[i] mod (i + 1));
    sum := sum + arr_key[0, i];
  end;

  shift := sum mod l;
  sum := 0;
  for i := 1 to l - 1 do
  begin
    SetLength(arr_key[i], l);
    for j := 0 to l - 1 do
    begin
      if (key_byte[(i + shift) mod l] <> 0) then
        arr_key[i, j] := arr_key[i - 1, (j + i) mod l] xor key_byte[(i + shift) mod l]
      else
        arr_key[i, j] := arr_key[i - 1, (j + i) mod l] xor (key_byte[(i + shift) mod l] + 1);
      sum := sum + arr_key[i, j];
    end;
    shift := sum mod l;
    sum := 0;
  end;

end;

procedure cr1(key_byte2: TBytes; input_file, output_file: PFileStream); overload;
var
  n, i, j: Int64;
  l, sum, nshift: Integer;
  abuf, abuf2, abuf3: TBytes;
  arr_key: array of TBytes;
  crn: Integer;
begin
  n := input_file^.Size;
  l := Length(key_byte2);
  SetLength(arr_key, l); // array of key
  GenArrKey(key_byte2, arr_key);

  SetLength(abuf, l);
  SetLength(abuf2, l);
  SetLength(abuf3, l);

  if (output_file^.Size < n) then
  begin
    output_file^.Size := n;
  end;

  i := 0;
  input_file^.Seek(i, TSeekOrigin.soBeginning);
  output_file^.Seek(i, TSeekOrigin.soBeginning);
  while (i < n) do
  begin
    if n - i < l then
    begin
      l := n - i;
      SetLength(abuf, l);
      SetLength(abuf2, l);
      SetLength(abuf3, l);
    end;
    input_file^.Read(abuf, l);

    // ---------------< encryption ----------------
    for crn := 0 to REPEAT_CRYPT do
    begin
      if l > 1 then
      begin

        for j := 0 to l - 1 do
          abuf2[j] := abuf[j] xor (arr_key[(i + crn) mod l, (i + j) mod l] + i);

        sum := 0;
        for j := 0 to l - 1 do
          sum := sum + abuf2[j];

        sum := (sum mod (l - 1)) + crn;

        nshift := key_byte2[sum mod l] mod l;
        if (nshift = 0) then
          nshift := nshift + sum mod l;

        for j := 0 to l - 1 do
        begin
          abuf3[(j + nshift) mod l] := abuf2[j];
        end;

        for j := 0 to l - 1 do
          abuf[j] := abuf3[j] xor (arr_key[i mod l, (i + j) mod l] + i);
      end
      else
      begin
        abuf[0] := abuf[0] xor arr_key[crn mod Length(key_byte2), crn mod Length(key_byte2)];
      end;
    end;
    // --------------- encryption >----------------

    output_file^.Write(abuf, l);
    i := input_file^.Position;
  end;

end;

procedure cr1(key_byte2: TBytes; input_mem, output_mem: PMemoryStream); overload;
var
  n, i, j: Int64;
  l, sum, nshift: Integer;
  abuf, abuf2, abuf3: TBytes;
  arr_key: array of TBytes;
  crn: Integer;
begin
  n := input_mem^.Size;
  l := Length(key_byte2);
  SetLength(arr_key, l); // array of key
  GenArrKey(key_byte2, arr_key);

  SetLength(abuf, l);
  SetLength(abuf2, l);
  SetLength(abuf3, l);

  if (output_mem^.Size < n) then
  begin
    output_mem^.Size := n;
  end;

  i := 0;
  input_mem^.Seek(i, TSeekOrigin.soBeginning);
  output_mem^.Seek(i, TSeekOrigin.soBeginning);
  while (i < n) do
  begin
    if n - i < l then
    begin
      l := n - i;
      SetLength(abuf, l);
      SetLength(abuf2, l);
      SetLength(abuf3, l);
    end;
    input_mem^.Read(abuf, l);

    // ---------------< encryption ----------------
    for crn := 0 to REPEAT_CRYPT do
    begin
      if l > 1 then
      begin

        for j := 0 to l - 1 do
          abuf2[j] := abuf[j] xor (arr_key[(i + crn) mod l, (i + j) mod l] + i);

        sum := 0;
        for j := 0 to l - 1 do
          sum := sum + abuf2[j];

        sum := (sum mod (l - 1)) + crn;

        nshift := key_byte2[sum mod l] mod l;
        if (nshift = 0) then
          nshift := nshift + sum mod l;

        for j := 0 to l - 1 do
        begin
          abuf3[(j + nshift) mod l] := abuf2[j];
        end;

        for j := 0 to l - 1 do
          abuf[j] := abuf3[j] xor (arr_key[i mod l, (i + j) mod l] + i);
      end
      else
      begin
        abuf[0] := abuf[0] xor arr_key[crn mod Length(key_byte2), crn mod Length(key_byte2)];
      end;
    end;
    // --------------- encryption >----------------

    output_mem^.Write(abuf, l);
    i := input_mem^.Position;
  end;

end;

procedure cr2(key_byte2: TBytes; input_file, output_file: PFileStream); overload;
var
  n, i, j, cnt: Int64;
  buf1, buf2, buf3: Byte;
  l, lk, sum, nshift: Integer;
  abuf, abuf2, abuf3: TBytes;
  arr_key: array of TBytes;
  crn: Integer;
begin
  n := input_file^.Size;
  l := Length(key_byte2);
  lk := Length(key_byte2);
  SetLength(abuf, l);
  SetLength(abuf2, l);
  SetLength(abuf3, l);
  SetLength(arr_key, l); // array of key
  GenArrKey(key_byte2, arr_key);

  if (output_file^.Size < n) then
  begin
    output_file^.Size := n;
  end;

  i := 0;
  input_file^.Seek(i, TSeekOrigin.soBeginning);
  output_file^.Seek(i, TSeekOrigin.soBeginning);
  while (i < n) do
  begin
    if n - i < l then
    begin
      l := n - i;
      SetLength(abuf, l);
      SetLength(abuf2, l);
      SetLength(abuf3, l);
    end;
    input_file^.Read(abuf, l);

    // ---------------< decryption ----------------
    for crn := REPEAT_CRYPT downto 0 do
    begin
      if l > 1 then
      begin

        for j := 0 to l - 1 do
          abuf2[j] := abuf[j] xor (arr_key[i mod l, (i + j) mod l] + i);

        sum := 0;
        for j := 0 to l - 1 do
          sum := sum + abuf2[j];

        if l > 1 then
          sum := (sum mod (l - 1)) + crn
        else
          sum := sum;

        nshift := key_byte2[sum mod l] mod l;
        if (nshift = 0) then
          nshift := nshift + sum mod l;

        for j := 0 to l - 1 do
        begin
          abuf3[j] := abuf2[(j + nshift) mod l];
        end;

        for j := 0 to l - 1 do
          abuf[j] := abuf3[j] xor (arr_key[(i + crn) mod l, (i + j) mod l] + i);
      end
      else
      begin
        abuf[0] := abuf[0] xor arr_key[crn mod Length(key_byte2), crn mod Length(key_byte2)];
      end;
    end;
    // --------------- decryption >----------------

    output_file^.Write(abuf, l);
    i := input_file^.Position;
  end;

end;

procedure cr2(key_byte2: TBytes; input_file, output_file: PMemoryStream); overload;
var
  n, i, j, cnt: Int64;
  buf1, buf2, buf3: Byte;
  l, lk, sum, nshift: Integer;
  abuf, abuf2, abuf3: TBytes;
  arr_key: array of TBytes;
  crn: Integer;
begin
  n := input_file^.Size;
  l := Length(key_byte2);
  lk := Length(key_byte2);
  SetLength(abuf, l);
  SetLength(abuf2, l);
  SetLength(abuf3, l);
  SetLength(arr_key, l); // array of key
  GenArrKey(key_byte2, arr_key);

  if (output_file^.Size < n) then
  begin
    output_file^.Size := n;
  end;

  i := 0;
  input_file^.Seek(i, TSeekOrigin.soBeginning);
  output_file^.Seek(i, TSeekOrigin.soBeginning);
  while (i < n) do
  begin
    if n - i < l then
    begin
      l := n - i;
      SetLength(abuf, l);
      SetLength(abuf2, l);
      SetLength(abuf3, l);
    end;
    input_file^.Read(abuf, l);

    // ---------------< decryption ----------------
    for crn := REPEAT_CRYPT downto 0 do
    begin
      if l > 1 then
      begin

        for j := 0 to l - 1 do
          abuf2[j] := abuf[j] xor (arr_key[i mod l, (i + j) mod l] + i);

        sum := 0;
        for j := 0 to l - 1 do
          sum := sum + abuf2[j];

        if l > 1 then
          sum := (sum mod (l - 1)) + crn
        else
          sum := sum;

        nshift := key_byte2[sum mod l] mod l;
        if (nshift = 0) then
          nshift := nshift + sum mod l;

        for j := 0 to l - 1 do
        begin
          abuf3[j] := abuf2[(j + nshift) mod l];
        end;

        for j := 0 to l - 1 do
          abuf[j] := abuf3[j] xor (arr_key[(i + crn) mod l, (i + j) mod l] + i);
      end
      else
      begin
        abuf[0] := abuf[0] xor arr_key[crn mod Length(key_byte2), crn mod Length(key_byte2)];
      end;
    end;
    // --------------- decryption >----------------

    output_file^.Write(abuf, l);
    i := input_file^.Position;
  end;

end;

procedure fcrypt(Password: string; input_file, output_file: PFileStream);
var
  key_crypt, key_crypt2: string;
  // key_byte: array [0..32] of Byte;
  key_byte2: TBytes;
  k: Byte;
begin
  key_crypt := THashSHA2.GetHashString(Password);
  // key_crypt2:= THashSHA2.GetHMAC(Password, key_crypt, SHA256);

  key_byte2 := THashSHA2.GetHMACAsBytes(Password, key_crypt, SHA256);
  cr1(key_byte2, input_file, output_file);

end;

procedure mcrypt(Password: string; input_mem, output_mem: PMemoryStream);
var
  key_crypt, key_crypt2: string;
  // key_byte: array [0..32] of Byte;
  key_byte2: TBytes;
  k: Byte;
begin
  key_crypt := THashSHA2.GetHashString(Password);
  // key_crypt2:= THashSHA2.GetHMAC(Password, key_crypt, SHA256);

  key_byte2 := THashSHA2.GetHMACAsBytes(Password, key_crypt, SHA256);
  cr1(key_byte2, input_mem, output_mem);

end;

procedure decrypt(Password: string; input_file, output_file: PFileStream);
var
  key_crypt, key_crypt2: string;
  // key_byte: array [0..32] of Byte;
  key_byte2: TBytes;
  k: Byte;
begin
  // crypt(Password,input_file, output_file);
  key_crypt := THashSHA2.GetHashString(Password);
  // key_crypt2:= THashSHA2.GetHMAC(Password, key_crypt, SHA256);

  key_byte2 := THashSHA2.GetHMACAsBytes(Password, key_crypt, SHA256);
  cr2(key_byte2, input_file, output_file);
end;

procedure mdecrypt(Password: string; input_mem, output_mem: PMemoryStream);
var
  key_crypt, key_crypt2: string;
  // key_byte: array [0..32] of Byte;
  key_byte2: TBytes;
  k: Byte;
begin
  // crypt(Password,input_file, output_file);
  key_crypt := THashSHA2.GetHashString(Password);
  // key_crypt2:= THashSHA2.GetHMAC(Password, key_crypt, SHA256);

  key_byte2 := THashSHA2.GetHMACAsBytes(Password, key_crypt, SHA256);
  cr2(key_byte2, input_mem, output_mem);
end;

end.
