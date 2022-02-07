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
  MajorVersion: byte = 1;
  MinorVersion: byte = 0;
  PatchVersion: byte = 6;
  EDGEUp = '======================================ORBIS=====================================';
  EDGEDown =
    '================================================================================';
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
  CMD_CHECK_BC = 9;
  CMD_REGSERVICE = 10;
  { SYSTEM }
  CMD_BAD_ARG = 252;
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
  CMD_GUI_BUY_OM = 9;
  CMD_GUI_REMOVE_CC = 10;
  CMD_GUI_CREATE_TOKEN_WITH_COMMISSION = 11;
  CMD_GUI_GET_MY_ADDRESS = 12;
  CMD_GUI_CHECK_ADDRESS = 13;
  CMD_GUI_DO_CHANGE_CONFIG = 14;
  CMD_GUI_DO_CHANGE_NET = 15;
  CMD_GUI_DO_SAVE_CONFIG = 16;
  CMD_GUI_DO_RESTART = 17;
  CMD_GUI_CHECK_ACC_BY_MINING = 18;
  CMD_GUI_DO_CHANGE_NET_STATE = 19;

  CMD_DO_END_UPDATE = 251;
  CMD_DO_START_UPDATE = 250;
  CMD_CHECK_COUNT_WALLETS = 255;

  { WEB }
  CMD_WEB_CHECK_SEED_PHRASE = 13;
  CMD_WEB_REG_SERVICE = 14;
  CMD_WEB_SET_SERVICE_DATA = 15;

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
  Result := intTostr(MajorVersion) + '.' + intTostr(MinorVersion) + '.' +
    intTostr(PatchVersion);
end;

function GetTextGreeting(ALang: TLanguages): string;
begin
  Result := EDGEUp + #13#10;
  case ALang of
    TLanguages.Russian:
      begin
        Result := Result +
          'Добро пожаловать в блкочейн ORBIS. Актуальная версия системы:' +
          intTostr(MajorVersion) + '.' + intTostr(MinorVersion) + '.' +
          intTostr(PatchVersion);
      end;
    TLanguages.English:
      begin
        Result := Result +
          'Welcome to the ORBIS blockchain. Current system version:' +
          intTostr(MajorVersion) + '.' + intTostr(MinorVersion) + '.' +
          intTostr(PatchVersion);
      end;
  else
    Result := 'Welcome to the ORBIS blockchain. Current system version:' +
      intTostr(MajorVersion) + '.' + intTostr(MinorVersion) + '.' +
      intTostr(PatchVersion);
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

