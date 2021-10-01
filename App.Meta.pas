unit App.Meta;

interface

uses
  System.SysUtils;

const
  { UI CONST }
  MainCoin = 'ORBC';
  Percent = 0.00314;
  ActivePercent = 0.62;
  PassivePercent = 0.38;
  MajorVersion: byte = 0;
  MinorVersion: byte = 0;
  PatchVersion: byte = 0;
  EDGEUp = '====================================================ORBIS====================================================';
  EDGEDown = '=============================================================================================================';
  Carriage = #13#10;
  { CONSOLE COMMAND CONST }
  CMD_CREATE_WALLET = 0;
  CMD_OPEN_WALLET = 1;
  CMD_GET_WALLETS = 2;
  CMD_CREATE_TOKEN = 3;
  CMD_CREATE_TRANSFER = 4;
  CMD_WHOAMI = 5;
  CMD_GET_BALANCE = 6;
  CMD_CREATE_OM = 7;
  CMD_EASY_CREATE_OM = 8;
  { SYSTEM }
  CMD_DO_MINING = 253;
  CMD_TEST_PLATFORM = 254;
  CMD_START = 255;
  { GUI COMMAND CONST }
  CMD_GUI_CREATE_WALLET = 0;
  CMD_GUI_OPEN_WALLET = 1;
  CMD_GUI_CHECK_NEW_WALLET = 2;
  CMD_GUI_GET_BALANCES = 3;
  CMD_GUI_CREATE_TRANSFER = 4;
  CMD_GUI_TRANSACTION_HISTORY = 5;
  CMD_GUI_GET_WORDS = 6;
  CMD_GUI_SET_WORDS = 7;
  CMD_GUI_SET_CC = 8;

  CMD_CHECK_COUNT_WALLETS = 255;

type
  TLanguages = (Russian, English);
function GetTextGreeting(ALang: TLanguages): string;
function GetTextRequestForInput(ALang: TLanguages): string;
function GetVersion: TBytes;
function GetVersionString: string;

implementation

function GetVersion: TBytes;
begin
  Result := [MajorVersion] + [MinorVersion] + [PatchVersion];
end;

function GetVersionString: string;
begin
  Result := intTostr(MajorVersion) + '.' + intTostr(MinorVersion) + '.' + intTostr(PatchVersion);
end;

function GetTextGreeting(ALang: TLanguages): string;
begin
  Result := EDGEUp + #13#10;
  case ALang of
    TLanguages.Russian:
      begin
        Result := Result + 'Добро пожаловать в блкочейн ORBIS. Актуальная версия системы:' + intTostr(MajorVersion) + '.' +
        intTostr(MinorVersion) + '.' + intTostr(PatchVersion);
      end;
    TLanguages.English:
      begin
        Result := Result + 'Welcome to the ORBIS blockchain. Current system version:' + intTostr(MajorVersion) + '.' +
        intTostr(MinorVersion) + '.' + intTostr(PatchVersion);
      end;
  else
    Result := 'Welcome to the ORBIS blockchain. Current system version:' + intTostr(MajorVersion) + '.' +
    intTostr(MinorVersion) + '.' + intTostr(PatchVersion);
  end;
  Result := Result + #13#10 + EDGEDown;
end;

function GetTextRequestForInput(ALang: TLanguages): string;
begin
  case ALang of
    TLanguages.Russian:
      Result := 'Пожалуйста, введите команду: ';
    TLanguages.English:
      Result := 'Please enter the command: ';
  else
    Result := 'Please enter the command: ';
  end;
end;

end.
