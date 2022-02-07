
unit BlockChain.FastIndex.Account;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.IOUtils,
  App.Types,
  BlockChain.Types,
  BlockChain.FileHandler;

type
  TAccountIndex = record
    AccountID: UInt64;
    AccountName: THash;
    class operator Implicit(Buf: TAccountIndex): TBytes;
    class operator Implicit(Buf: TBytes): TAccountIndex;
  end;

  TFastIndexAccount = class
  private
    FPath: string;
    FName: string;
    ChainFile: TChainFile;
    Accounts: TArray<TAccountIndex>;
  public
    function GetID(AName: THash): UInt64;
    function GetIDB(var ID: UInt64 ; AName: THash): Boolean;
    function GetName(AID: UInt64): THash;
    procedure SetData(AID: UInt64; AHash: THash);
    constructor Create(AName: string);
    destructor Destroy; override;
  end;

implementation

{ TFastIndexAccount }

constructor TFastIndexAccount.Create(AName: string);
var
  count: integer;
begin
  FName := AName;
  FPath := TPath.Combine(Paths.GetPathFastIndex, FName);
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 0;
  var
  AI := Header + Default (TAccountIndex);
  ChainFile := TChainFile.Create(FPath, AI);
  count := ChainFile.GetLastBlockNumber;
  Accounts := Accounts + [Default (TAccountIndex)];
  if count = 0 then
    exit;

  for var i := 1 to ChainFile.GetLastBlockNumber do
  begin
    var
      Buf: TBytes;
    ChainFile.TryRead(i, Buf);
    Buf := Copy(Buf, SizeOf(THeader), Length(Buf) - SizeOf(THeader));
    AI := Buf;
    Accounts := Accounts + [AI];
  end;
end;

destructor TFastIndexAccount.Destroy;
begin
  ChainFile.Free;
end;

function TFastIndexAccount.GetID(AName: THash): UInt64;
begin
  Result := NaN;
  for var item in Accounts do
  begin
    if item.AccountName = AName then
    begin
      Result := item.AccountID;
      break;
    end;
  end;
end;

function TFastIndexAccount.GetIDB(var ID: UInt64; AName: THash): Boolean;
begin
  Result := False;
  ID := 0;
  for var item in Accounts do
  begin
    if item.AccountName = AName then
    begin
      Result := True;
      ID := item.AccountID;
      break;
    end;
  end;
end;

function TFastIndexAccount.GetName(AID: UInt64): THash;
begin
  Result := Default (THash);
  if AID <= Length(Accounts) then
    Result := Accounts[AID].AccountName;
end;

procedure TFastIndexAccount.SetData(AID: UInt64; AHash: THash);
begin
  var
    AI: TAccountIndex;
  AI.AccountID := AID;
  AI.AccountName := AHash;
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 0;
  var
    Buf: TBytes := AI;
  if ChainFile.TryWrite(Header + Buf, Header) then
    Accounts := Accounts + [AI];
end;

{ TAccountIndex }

class operator TAccountIndex.Implicit(Buf: TBytes): TAccountIndex;
begin
  Move(Buf[0], Result, SizeOf(TAccountIndex));
end;

class operator TAccountIndex.Implicit(Buf: TAccountIndex): TBytes;
begin
  SetLength(Result, SizeOf(TAccountIndex));
  Move(Buf, Result[0], SizeOf(TAccountIndex));
end;

end.
