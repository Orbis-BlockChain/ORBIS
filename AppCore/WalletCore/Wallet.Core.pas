unit Wallet.Core;

interface

//{$DEFINE APPLOG}
{$IFDEF DEBUG}
{$DEFINE APPLOG}
{$ENDIF}

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Classes,
  System.SyncObjs,
  App.Types,
  Wallet.FileHandler,
  Wallet.Types

  {$IFDEF APPLOG}
  ,App.Log
  {$ENDIF}

  ;

type
  TWalletCore = class
  private
    WalletsFile: TWalletsFileHandler;
    CS: TCriticalSection;
    procedure DoLog(ANameProc, AMsg: string);
  public
    Wallets: TStringList;
    CurrentWallet: TWallet;
    function GetWallets: string;
    function OpenWallet(AWalletName: string; APassword: string): boolean;
    function CheckWallet(AWalletName: string): boolean;
    function CheckWords(AWords: string): string;
    function TryCreateNewWallet(APassword: string): boolean;
    function RestoreWalletWithWords(AWords: string; APassword: string): boolean;
    function RestoreWalletWithCC(APath: string; APassword: string): boolean;
    procedure RemoveWallet(AWalletHash: string);
    procedure CloseWallet;
    constructor Create;
    destructor Destroy; override;
  end;

var
  WalletID: UInt64;

implementation

{ TWalletCore }

procedure TWalletCore.DoLog(ANameProc, AMsg: string);
begin
  {$IFDEF APPLOG}
  WalletCoreLog.DoAlert(ANameProc, AMsg);
  {$ENDIF}
end;

function TWalletCore.CheckWallet(AWalletName: string): boolean;
begin
  Result := False;
  if Wallets.IndexOf(AWalletName) > -1 then
    Result := True;
end;

function TWalletCore.CheckWords(AWords: string): string;
var
  Words: strings;
  Wallet: TWallet;
begin
  Result := '';
  if Wallet.SetWords(AWords) then
    Result := Wallet.GetAddress;
end;

procedure TWalletCore.CloseWallet;
begin
  CurrentWallet := Default (TWallet);
  WalletID := 0;
  DoLog('TWalletCore.CloseWallet','WalletID: 0');
end;

constructor TWalletCore.Create;
begin
  CS := TCriticalSection.Create;
  WalletID := 0;
  Wallets := TStringList.Create;
  WalletsFile := TWalletsFileHandler.Create(Wallets);
  CurrentWallet := Default (TWallet);
end;

function TWalletCore.TryCreateNewWallet(APassword: string): boolean;
var
  Wallet: TWallet;
begin
  try
    CS.Enter;
    Result := False;
    Wallet.Create;
    if WalletsFile.TrySaveNewWallet(Wallet, APassword) then
    begin
      OpenWallet(Wallet.GetAddress, APassword);
      Result := True;
    end;
  except
    on e: exception do
    begin
      Result := False;
      e.Message := 'Bad registration wallet.';
    end;
  end;
  CS.Leave;
end;

destructor TWalletCore.Destroy;
begin
  CS.Free;
  Wallets.Free;
  WalletsFile.Free;
  inherited;
end;

function TWalletCore.GetWallets: string;
var
  str: string;
begin
  str := '';
  for var item in Wallets do
    str := item + #13#10 + str;
  Result := str;
end;

function TWalletCore.OpenWallet(AWalletName, APassword: string): boolean;
begin
  DoLog('TWalletCore.OpenWallet','WalletID: ' + WalletID.AsString);
  try
    CS.Enter;
    Result := False;
    WalletID := 0;
    CurrentWallet := WalletsFile.TryOpenWallet(AWalletName, APassword);
    if CurrentWallet.GetAddress = AWalletName then
      Result := True;

  finally
    CS.Leave;
  end;
  DoLog('TWalletCore.OpenWallet','WalletID: ' + WalletID.AsString);
end;

procedure TWalletCore.RemoveWallet(AWalletHash: string);
begin
  DoLog('TWalletCore.RemoveWallet','');
  if Wallets.IndexOf(AWalletHash) > -1 then
    Wallets.Delete(Wallets.IndexOf(AWalletHash));

  WalletsFile.RemoveWallet(AWalletHash);

  CloseWallet;
end;

function TWalletCore.RestoreWalletWithCC(APath, APassword: string): boolean;
begin
  DoLog('TWalletCore.RestoreWalletWithCC','');
  try
    CS.Enter;
    Result := False;
    if WalletsFile.TryRecover(APath, APassword) then
      Result := True;
  except
    Result := False;
  end;
  CS.Free;
end;

function TWalletCore.RestoreWalletWithWords(AWords: string; APassword: string): boolean;
var
  Wallet: TWallet;
begin
  DoLog('TWalletCore.RestoreWalletWithWords','');
  if Wallet.SetWords(AWords) then
    try
      CS.Enter;
      Result := False;
      if WalletsFile.TrySaveNewWallet(Wallet, APassword) then
        Result := True;
    except
      Result := False;
    end;
  CS.Leave;
end;

end.
