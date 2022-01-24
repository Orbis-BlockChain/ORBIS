unit BlockChain.FileHandler;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  System.IOUtils,
  App.Log,
  BlockChain.Types;

type
{$REGION 'Types'}
  TIndexFile = class
  strict private
    criticalSection: TCriticalSection;
    FOwnerPath: string;
    FPath: string;
    FNameOwner: string;
    FIndexFile: file of TIndexData;
    FLock: TMonitor;
    procedure CreateNewFile;
    function ReadIndex(index: integer = -1): TIndexData;
    procedure WriteIndex(var index: TIndexData);
    procedure BuildNewIndex;
  public
    function GetLastBlock: uint64;
    function TryRead(const from: integer): TIndexData;
    procedure TryWrite(var Data: TIndexData);
    procedure Corupted;
    constructor Create(const APath: string);
    destructor Destroy; override;
  end;

  TChainFile = class
  protected
    criticalSection: TCriticalSection;
    FPath: string;
    FName: string;
    FChainFile: File;
    FIndexFile: TIndexFile;
    FLock: TMonitor;
    function CheckFileSize(var size: integer): boolean;
    function ReadData(index: TIndexData): TBytes;
    procedure WriteData(const Data: TBytes; const AIndex: TIndexData);
  public
    function TryRead(const from: integer; var Data: TBytes): boolean;
    function TryWrite(const Data: TBytes; AHeader: THeader): boolean;
    function GetLastBlockNumber: uint64;
    procedure Corupted;
    // constructor Create(const APath: string; const Data: TBytes; ATypeChain: TTypesChain);
    constructor Create(const APath: string; const Data: TBytes);
    destructor Destroy; override;
  end;

  TFastIndexFile = class(TChainFile)
  public
    procedure Rewrite(AIndex: integer; AData: TBytes);
  end;
{$ENDREGION}

implementation

{$REGION 'TChainFile'}

function TChainFile.CheckFileSize(var size: integer): boolean;
var
  fs: integer;
begin
  Assign(FChainFile, FPath);
  FileMode := fmOpenRead;
  Reset(FChainFile, 1);
  fs := FileSize(FChainFile);
  size := fs;
  CloseFile(FChainFile);
  if fs >= MaxFileSize then
    Result := False
  else
    Result := True;
end;

procedure TChainFile.Corupted;
begin
  criticalSection.Enter;
  TFile.Delete(FPath);
  FIndexFile.Corupted;
  criticalSection.Leave;
end;

constructor TChainFile.Create(const APath: string; const Data: TBytes);
begin
  criticalSection:= TCriticalSection.Create;
  FPath := APath;
  if not tfile.Exists(APath) then
  begin
    AssignFile(FChainFile, APath);
    FileMode := fmOpenReadWrite;
    Rewrite(FChainFile, 1);
    BlockWrite(FChainFile, Data[0], Length(Data));
    Close(FChainFile);
  end;
  FIndexFile := TIndexFile.Create(APath);
end;

destructor TChainFile.Destroy;
begin
  FPath := '';
  FName := '';
  FIndexFile.Free;
  criticalSection.Free;
end;

function TChainFile.GetLastBlockNumber: uint64;
begin
  criticalSection.Enter;
  Result := FIndexFile.GetLastBlock;
  criticalSection.Leave;
end;

function TChainFile.ReadData(index: TIndexData): TBytes;
begin
  AssignFile(FChainFile, FPath);
  FileMode := fmOpenRead;
  Reset(FChainFile, 1);
  seek(FChainFile, index.StartByte);
  setLength(Result, index.size);
  BlockRead(FChainFile, Result[0], index.size);
  CloseFile(FChainFile);
end;

function TChainFile.TryRead(const from: integer; var Data: TBytes): boolean;
var
  index: TIndexData;
begin
  criticalSection.Enter;
  try
    Result := True;
    index := FIndexFile.TryRead(from);
    Data := ReadData(index);
  except
    Result := False;
    Data := [];
  end;
  criticalSection.Leave;
end;

function TChainFile.TryWrite(const Data: TBytes; AHeader: THeader): boolean;
var
  Locked: boolean;
  index: TIndexData;
begin
  criticalSection.Enter;
  Result := False;
  Locked := False;
  try
    try

        CheckFileSize(index.StartByte); //
        index.TypeChain := AHeader.TypeBlock;
        index.VersionData := AHeader.VersionData;
        index.size := Length(Data);
        WriteData(Data, index);
        FIndexFile.TryWrite(index);
        Result := True;

    except
      on e: Exception do
      begin
        Result := False;
      end;
    end;
  finally
    if Locked then
      FLock.Exit(self);
  end;
  criticalSection.Leave;
end;

procedure TChainFile.WriteData(const Data: TBytes; const AIndex: TIndexData);
begin
  AssignFile(FChainFile, FPath);
  FileMode := fmOpenReadWrite;
  Reset(FChainFile, 1);
  seek(FChainFile, AIndex.StartByte);
  BlockWrite(FChainFile, Data[0], Length(Data));
  CloseFile(FChainFile);
end;

{$ENDREGION}
{$REGION 'TIndexFile'}

procedure TIndexFile.BuildNewIndex;
var
  FAnyFile: file;
  Header: THeader;
  IndexData: TIndexData;
  pointerInFile, Counter: integer;
begin
  AssignFile(FIndexFile, FPath);
  FileMode := fmOpenReadWrite;
  Reset(FIndexFile);

  AssignFile(FAnyFile, FOwnerPath);
  FileMode := fmOpenReadWrite;
  Reset(FAnyFile, 1);

  pointerInFile := 0;
  Counter := 0;

  while pointerInFile < FileSize(FAnyFile) do
  begin
    seek(FAnyFile, pointerInFile);
    seek(FIndexFile, Counter);

    BlockRead(FAnyFile, Header, SizeOf(Header));
    IndexData.size := GetBlockSize(Header.TypeBlock, Header.VersionData);
    IndexData.TypeChain := Header.TypeBlock;
    IndexData.VersionData := Header.VersionData;
    IndexData.StartByte := pointerInFile;
    Write(FIndexFile, IndexData);
    inc(pointerInFile, IndexData.size);
    inc(Counter);
  end;

  CloseFile(FIndexFile);
  CloseFile(FAnyFile);
end;

procedure TIndexFile.Corupted;
begin
try
  criticalSection.Enter;
  TFile.Delete(FPath);
finally
  criticalSection.Leave;
end;

end;

constructor TIndexFile.Create(const APath: string);
begin
  criticalSection := TCriticalSection.Create;
  FOwnerPath := APath;
  FPath := APath + 'Index';
  if not tfile.Exists(FPath) then
    CreateNewFile
end;

procedure TIndexFile.CreateNewFile;
var
  PathName: string;
begin
  AssignFile(FIndexFile, FPath);
  FileMode := fmOpenReadWrite;
  Rewrite(FIndexFile);
  Close(FIndexFile);
  BuildNewIndex;
end;

destructor TIndexFile.Destroy;
begin
  FPath := '';
  FNameOwner := '';
  criticalSection.Free;
end;

function TIndexFile.GetLastBlock: uint64;
begin
  try
    criticalSection.Enter;
//    BlockChainLogs.DoAlert('TIndexFile.GetLastBlock','criticalSection.Enter');
    AssignFile(FIndexFile, FPath);
    FileMode := fmOpenRead;
    Reset(FIndexFile);
    Result := FileSize(FIndexFile) - 1;
    CloseFile(FIndexFile);
  finally
    criticalSection.Leave;
//    BlockChainLogs.DoAlert('TIndexFile.GetLastBlock','criticalSection.Leave');
  end;

end;

function TIndexFile.ReadIndex(index: integer = -1): TIndexData;
begin
  AssignFile(FIndexFile, FPath);
  FileMode := fmOpenRead;
  Reset(FIndexFile);
  if index = -1 then
    seek(FIndexFile, FileSize(FIndexFile) - 1)
  else
    seek(FIndexFile, index);
  Read(FIndexFile, Result);
  CloseFile(FIndexFile);
end;

function TIndexFile.TryRead(const from: integer): TIndexData;
begin
  try
    criticalSection.Enter;
    Result := ReadIndex(from);
  finally
    criticalSection.Leave;
  end;
end;

procedure TIndexFile.TryWrite(var Data: TIndexData);
var
  Locked: boolean;
begin
  try
    criticalSection.Enter;
    WriteIndex(Data);
  finally
    criticalSection.Leave;
  end;
end;

procedure TIndexFile.WriteIndex(var index: TIndexData);
begin
  AssignFile(FIndexFile, FPath);
  FileMode := fmOpenReadWrite;
  Reset(FIndexFile);
  seek(FIndexFile, FileSize(FIndexFile));
  Write(FIndexFile, index);
  CloseFile(FIndexFile);
end;

{$ENDREGION}
{ TFastIndexFile }

procedure TFastIndexFile.Rewrite(AIndex: integer; AData: TBytes);
var
  index: TIndexData;
begin
  index := FIndexFile.TryRead(AIndex);
  AssignFile(FChainFile, FPath);
  FileMode := fmOpenReadWrite;
  Reset(FChainFile, 1);
  seek(FChainFile, index.StartByte);
  BlockWrite(FChainFile, AData[0], Length(AData));
  CloseFile(FChainFile);
end;

end.
