unit Crypto.Data;

interface

uses
  System.IOUtils,
  System.Classes,
  System.SysUtils,
  System.Hash,
  Unit_cryptography;

procedure decryptionFile(const pathToFile, directory, password: string);
procedure encryptionFile(const encryptedFile, originalFile, password: string);

function EncryptData(const Data: TBytes; const password: string): TBytes;
function DecryptData(const Data: TBytes; const password: string): TBytes;

implementation

procedure encryptionFile(const encryptedFile, originalFile, password: string);
var
  fstream1, fstream2: TFileStream;
begin
  fstream1 := TFileStream.Create(originalFile, fmOpenRead);
  fstream2 := TFileStream.Create(encryptedFile, fmCreate);
  fcrypt(password, @fstream1, @fstream2);
  fstream1.Free;
  fstream2.Free;
end;

procedure decryptionFile(const pathToFile, directory, password: string);
var
  fstream1, fstream2: TFileStream;
begin
  fstream1 := TFileStream.Create(pathToFile, fmOpenRead);
  fstream2 := TFileStream.Create(directory, fmCreate);
  decrypt(password, @fstream1, @fstream2);
  fstream1.Free;
  fstream2.Free;
end;

function EncryptData(const Data: TBytes; const password: string): TBytes;
var
  input_mem, output_mem: tmemorystream;
begin
  input_mem := tmemorystream.Create;
  output_mem := tmemorystream.Create;
  input_mem.Write(Data, 0, Length(Data));
  mcrypt(password, @input_mem, @output_mem);
  Result := BytesOf(output_mem.Memory, output_mem.Size);
  input_mem.Free;
  output_mem.Free;
end;

function DecryptData(const Data: TBytes; const password: string): TBytes;
var
  input_mem, output_mem: tmemorystream;
begin
  input_mem := tmemorystream.Create;
  output_mem := tmemorystream.Create;
  input_mem.Write(Data, 0, Length(Data));
  mdecrypt(password, @input_mem, @output_mem);
  Result := BytesOf(output_mem.Memory, output_mem.Size);
  input_mem.Free;
  output_mem.Free;
end;

end.Free; output_mem.Free; end; end.
