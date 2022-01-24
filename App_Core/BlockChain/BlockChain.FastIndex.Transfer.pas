unit BlockChain.FastIndex.Transfer;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.IOUtils,
  App.Types,
  BlockChain.Types,
  BlockChain.FileHandler;

type
  TBalancesIndex = record
    AccountID: UInt64;
    TokenID: UInt64;
    Balance: UInt64;
    class operator Implicit(Buf: TBalancesIndex): TBytes;
    class operator Implicit(Buf: TBytes): TBalancesIndex;
  end;

  TFastIndexBalances = class
  private
    FPath: string;
    FName: string;
    ChainFile: TFastIndexFile;
    Balances: TArray<TBalancesIndex>;
    procedure ReplaceData(AHeader: THeader; ABalance: TBalancesIndex);
  public
    function BalanceExist(AAccountID, ATokenID: UInt64): boolean;
    function GetBalance(AAccountID, ATokenID: UInt64): UInt64;
    function GetBalanceWide(AAccountID, ATokenID: UInt64; var AAccauntBool, ATokenBool: boolean): UInt64;
    function GetAllBalances(AAccountID: UInt64): TBytes;
    procedure SetData(const AAccountID, ATokenID, ABalance: UInt64;const Plus: boolean);
    constructor Create(AName: string);
    destructor Destroy; override;
  end;

implementation

{ TFastIndexAccount }

function TFastIndexBalances.BalanceExist(AAccountID, ATokenID: UInt64): boolean;
begin
  Result := False;
  for var item in Self.Balances do
    if (item.AccountID = AAccountID) and (item.TokenID = ATokenID) then
    begin
      Result := True;
      break;
    end;
end;

constructor TFastIndexBalances.Create(AName: string);
begin
  FName := AName;
  FPath := TPath.Combine(Paths.GetPathFastIndex, FName);
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 2;

  var
  TI := Header + Default (TBalancesIndex);
  ChainFile := TFastIndexFile.Create(FPath, TI);
  var
  count := ChainFile.GetLastBlockNumber;

  if count = 0 then
  begin
    Balances := Balances + [Default (TBalancesIndex)];
    exit;
  end;

  for var i := 0 to count do
  begin
    var Buf: TBytes;
    ChainFile.TryRead(i, Buf);
    Buf := Copy(Buf, SizeOf(THeader), Length(Buf) - SizeOf(THeader));
    TI := Buf;
    Balances := Balances + [TI];
  end;

end;

destructor TFastIndexBalances.Destroy;
begin
  ChainFile.Free;
end;

function TFastIndexBalances.GetAllBalances(AAccountID: UInt64): TBytes;
begin
  Result := [];
  for var item in Self.Balances do
    if (item.AccountID = AAccountID) then
    begin
      Result := Result + item.TokenID.AsBytes + item.Balance.AsBytes;
    end;
end;

function TFastIndexBalances.GetBalance(AAccountID, ATokenID: UInt64): UInt64;
begin
  Result := 0;
  for var item in Self.Balances do
    if (item.AccountID = AAccountID)and (item.TokenID = ATokenID) then
    begin
      Result := item.Balance;
      break;
    end;
end;

function TFastIndexBalances.GetBalanceWide(AAccountID, ATokenID: UInt64; var AAccauntBool, ATokenBool: boolean): UInt64;
begin
  Result := 0;
  AAccauntBool := False;
  ATokenBool := False;
  for var item in Self.Balances do
  begin
    if (item.AccountID = AAccountID) then
    begin
      AAccauntBool := True;
      if (item.TokenID = ATokenID) then
      begin
        ATokenBool := True;
        Result := item.Balance;
        break;
      end;
    end;
  end;
end;

procedure TFastIndexBalances.ReplaceData(AHeader: THeader; ABalance: TBalancesIndex);
var
  index: integer;
begin
  for var i := 0 to Length(Balances) do
    if (ABalance.AccountID = Balances[i].AccountID) and (ABalance.TokenID = Balances[i].TokenID) then
    begin
      Balances[i] := ABalance;
      index := i;
      break;
    end;
  ChainFile.Rewrite(index, AHeader + ABalance);
end;

procedure TFastIndexBalances.SetData(const AAccountID, ATokenID, ABalance: UInt64;const Plus: boolean);
var
  TI: TBalancesIndex;
begin
  TI.AccountID := AAccountID;
  TI.TokenID := ATokenID;
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 2;
  if (GetBalance(TI.AccountID, TI.TokenID) = 0) and (BalanceExist(TI.AccountID, TI.TokenID) = False) then
  begin
    if Plus then
    begin
      TI.Balance := ABalance;
      if ChainFile.TryWrite(Header + TI, Header) then
        Balances := Balances + [TI];
    end;
  end
  else
  begin
    if (NodeState = Speaker) and (paramStr(1) = 'init') and (TI.TokenID = 1) then
      TI.Balance := GetBalance(AAccountID, ATokenID) + ABalance
    else
    begin
      if Plus then
        TI.Balance := GetBalance(AAccountID, ATokenID) + ABalance
      else
        TI.Balance := GetBalance(AAccountID, ATokenID) - ABalance;

    end;
    ReplaceData(Header, TI);
  end;
end;

{ TAccountIndex }

class operator TBalancesIndex.Implicit(Buf: TBytes): TBalancesIndex;
begin
  Move(Buf[0], Result, SizeOf(TBalancesIndex));
end;

class operator TBalancesIndex.Implicit(Buf: TBalancesIndex): TBytes;
begin
  SetLength(Result, SizeOf(TBalancesIndex));
  Move(Buf, Result[0], SizeOf(TBalancesIndex));
end;

end.
