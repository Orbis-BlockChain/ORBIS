unit UI.Types;

interface

uses
  System.StrUtils,
  System.SysUtils,
  System.TypInfo,
  App.Types,
  App.Meta,
  System.Generics.Collections;

type
  TCommandsNames = (badcommand, help, node, check, update, quit, createwallet, openwallet, getwalletlist, createtoken, createtransfer, whoami,
    getbalance, buyom, domining, doeasybuyom, checkbc, regservice, newservicedata);

  TCommandsHelper = record helper for TCommandsNames
    class function InType(ACommand: string): boolean; static;
    class function AsCommand(ACommand: string): TCommandsNames; static;
  end;

  TParametr = record
    Name: string;
    Value: string;
  end;

  TParametrs = TArray<TParametr>;

  THelpParametrs = record helper for TParametrs
    function AsStringArray: TArray<string>;
  end;

  TCommandData = record
    CommandName: TCommandsNames;
    Parametrs: TParametrs;
  end;

  TDesktopForms = (fRegestrattion, fLogin, fNewTransaction, fVerification, fTransactionHistory,
                   fTransaction, fMyAddress, fRestoreSelection, fEnterWods, fChooseCC, fApproveTrx, fWords,
                   fApproveOM, fCreateToken, fProgressBar, fWaiting);

function GetCaption: string;

implementation

function GetCaption: string;
var
  NetConnected: string;
begin
  if Connected then
    NetConnected := 'Connected'
  else
    NetConnected := 'Not Connected';

  case NetState of
    MAINNET:
      result := 'ORBIS NODE MAINNET - ' + NetConnected + ' ' + GetVersionString;
    TESTNET:
      result := 'ORBIS NODE TESTNET - ' + NetConnected + ' ' + GetVersionString;
    LABNET:
      result := 'ORBIS NODE LABNET - ' + NetConnected + ' ' + GetVersionString;
  end;
end;

{$REGION 'CommandsHelper'}

class function TCommandsHelper.AsCommand(ACommand: string): TCommandsNames;
begin
  result := TCommandsNames(GetEnumValue(TypeInfo(TCommandsNames), ACommand));
end;

class function TCommandsHelper.InType(ACommand: string): boolean;
begin
  result := GetEnumValue(TypeInfo(TCommandsHelper), ACommand).ToBoolean;
end;
{$ENDREGION}
{ TCommandData }

{ THelpParametrs }

function THelpParametrs.AsStringArray: TArray<string>;
var
  Param: TParametr;
begin
  result := [];
  for Param in Self do
    result := result + [Param.Name] + [Param.Value];
end;

end.
