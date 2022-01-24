unit App.IHandlerCore;

interface

uses
  App.Types,
  Net.IClient,
  Net.ConnectedClient,
  WebServer.HTTPConnectedClient,
  System.SysUtils;

const
  CMD_REQUEST_AUTH = 0;
  CMD_RESPONSE_AUTH_OK = 1;
  CMD_RESPONSE_AUTH_BAD = 2;
  CMD_REQUEST_VERSION = 3;
  CMD_RESPONSE_VERSION = 4;
  CMD_REQUEST_COUNT_BLOCK = 5;
  CMD_RESPONSE_COUNT_BLOCK = 6;
  CMD_REQUEST_GET_BLOCK_FROM = 7;
  CMD_RESPONSE_GET_BLOCK_FROM = 8;
  CMD_REQUEST_NEW_CC = 9;
  CMD_RESPONSE_NEW_CC = 10;
  CMD_REQUEST_NEW_TOKEN = 11;
  CMD_RESPONSE_NEW_TOKEN = 12;
  CMD_REQUEST_NEW_TRANSFER = 13;
  CMD_RESPONSE_NEW_TRANSFER = 14;
  CMD_REQUEST_NEW_OWNER_MINING = 15;
  CMD_RESPONSE_NEW_OWNER_MINING = 16;
  CMD_REQUEST_EASY_NEW_OWNER_MINING = 17;
  CMD_RESPONSE_EASY_NEW_OWNER_MINING = 18;
  CMD_RESPONSE_GET_NEW_BLOCKS = 19;
  CMD_REQUEST_GET_VALIDATORS = 20;
  CMD_RESPONSE_GET_VALIDATORS = 21;
  CMD_REQUEST_YOU_SPEAKER = 22;
  CMD_RESPONSE_YOU_SPEAKER = 23;
  CMD_REQUEST_GET_CACHE = 24;
  CMD_RESPONSE_GET_CACHE = 25;
  CMD_REQUEST_ID_IN_SYSTEM = 26;
  CMD_RESPONSE_ID_IN_SYSTEM = 27;
  CMD_REQUEST_ID_IN_SYSTEM_NO_ANSWER = 28;
  CMD_REQUEST_CREATE_TOKEN_WITH_COMMISSION = 29;
  CMD_RESPONSE_CREATE_TOKEN_WITH_COMMISSION = 30;
  CMD_REQUEST_NEW_SERVICE = 31;
  CMD_RESPONSE_NEW_SERVICE = 32;
  CMD_REQUEST_SERVICE_DATA  = 33;
  CMD_RESPONSE_SERVICE_DATA  = 34;
  CMD_REQUEST_GET_BLOCK_V2 = 35;
  CMD_REQUEST_HEART_BEAT = 36;
  CMD_RESPONSE_HEART_BEAT = 37;

  CMD_ERROR = 255;

  TP_VALIDATOR = 40;
  TP_VALIDATOR_INFO = 41;
  TP_VALIDATOR_01 = 42;
  TP_VALIDATOR_02 = 43;
  TP_VALIDATOR_03 = 44;
  TP_VALIDATOR_ON = 45;
  TP_VALIDATOR_OFF = 46;

type
  IBaseHandler = interface
    procedure HandleReceiveTCPData(From: IClient; const ABytes: TBytes);
    procedure HandleReceiveHTTPData(From: TConnectedClient; const ABytes: TBytes);
    procedure HandleCommand(Command: Byte; args: array of string);
    procedure HandleGUICommand(Command: Byte; args: array of string; ACallback: TCallBack);
    procedure HandleWebDataControl(Command: Byte; args: array of string; ACallback: TCallBack);
    procedure HandleConnectClient(ClientName: String);
    procedure HandleDisconnectClient(ClientName: String);
    function CheckLocalHost(): Boolean;
  end;

implementation

end.
