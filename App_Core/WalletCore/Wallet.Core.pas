unit Wallet.Core;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Classes,
  App.Types,
  Wallet.FileHandler,
  Wallet.Types;

type
  TWalletCore = class
  private
    WalletsFile: TWalletsFileHandler;
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
  Result :='';
  if Wallet.SetWords(AWords) then
    Result := Wallet.GetAddress;
end;

procedure TWalletCore.CloseWallet;
begin
  CurrentWallet := Default (TWallet);
  WalletID := 0;
end;

constructor TWalletCore.Create;
begin
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
    Result := False;
    Wallet.Create;
    if WalletsFile.TrySaveNewWallet(Wallet, APassword) then
    begin
      OpenWallet(Wallet.GetAddress, APassword);
      Result := True;
    end;
  except
    Result := False;
  end;
end;

destructor TWalletCore.Destroy;
begin
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
  Result := False;
  WalletID := 0;
  CurrentWallet := WalletsFile.TryOpenWallet(AWalletName, APassword);
  if CurrentWallet.GetAddress = AWalletName then
    Result := True;
end;

procedure TWalletCore.RemoveWallet(AWalletHash: string);
begin
  if Wallets.IndexOf(AWalletHash) > -1 then
    Wallets.Delete(Wallets.IndexOf(AWalletHash));

  WalletsFile.RemoveWallet(AWalletHash);

  CloseWallet;
end;

function TWalletCore.RestoreWalletWithCC(APath, APassword: string): boolean;
begin
  try
    Result := False;
    if WalletsFile.TryRecover(APath, APassword) then
      Result := True;
  except
    Result := False;
  end;
end;

function TWalletCore.RestoreWalletWithWords(AWords: string; APassword: string): boolean;
var
  Wallet: TWallet;
begin
  if Wallet.SetWords(AWords) then
    try
      Result := False;
      if WalletsFile.TrySaveNewWallet(Wallet, APassword) then
        Result := True;
    except
      Result := False;
    end;
end;

end.
