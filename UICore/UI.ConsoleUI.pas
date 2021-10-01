unit UI.ConsoleUI;

interface

uses
  System.SysUtils,
  System.Classes,
  App.Types,
  App.Abstractions,
  App.Meta,
  App.IHandlerCore,
  UI.Abstractions,
  UI.ParserCommand,
  UI.GUI,
  UI.Types;

type
  TConsoleUI = class(TBaseUI)
  private
    { Fields }
    fversion: string;
    isTerminate: boolean;
    { Instances }
    parser: TCommandsParser;
  public
    procedure ShutDown(const Msg: string = ''); override;
    procedure DoRun;
    procedure DoTerminate;
    procedure RunCommand(Data: TCommandData);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TConsoleUI'}

constructor TConsoleUI.Create;
begin
  isTerminate := False;
  parser := TCommandsParser.Create;
end;

destructor TConsoleUI.Destroy;
begin
  parser.Free;
  inherited;
end;

procedure TConsoleUI.RunCommand(Data: TCommandData);
begin
  case Data.CommandName of
    TCommandsNames.help:
      begin
        try
          case TCommandsNames.AsCommand(Data.Parametrs[0].Name) of
            TCommandsNames.node:
              begin
                ShowMessage('INFO: Node - command for work with node app.');
              end;
          end;
        except
          ShowMessage('createwallet -p pswrd            Create wallet, pswrd - password');
          ShowMessage('quit                             Quit');
          ShowMessage('node                             Node');
          ShowMessage('check                            ECHO: check');
          ShowMessage('update                           Update');
          ShowMessage('getwalletlist                    Getwalletlist');
          ShowMessage('openwallet -wa wlt -p pswrd      Open wallet: wlt-wallet, pswrd - password');
        end;
      end;
    TCommandsNames.node:
      begin
      end;
    TCommandsNames.check:
      begin
        ShowMessage('ECHO: check');
      end;
    TCommandsNames.update:
      begin
      end;
    TCommandsNames.quit:
      begin
        ShutDown;
      end;
    TCommandsNames.createwallet:
      begin
        handler.HandleCommand(CMD_CREATE_WALLET, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.openwallet:
      begin
        handler.HandleCommand(CMD_OPEN_WALLET, Data.Parametrs.AsStringArray)
      end;
    TCommandsNames.getwalletlist:
      begin
        handler.HandleCommand(CMD_GET_WALLETS, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.createtoken:
      begin
        handler.HandleCommand(CMD_CREATE_TOKEN, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.createtransfer:
      begin
        handler.HandleCommand(CMD_CREATE_TRANSFER, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.whoami:
      begin
        handler.HandleCommand(CMD_WHOAMI, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.getbalance:
      begin
        handler.HandleCommand(CMD_GET_BALANCE, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.buyom:
      begin
        handler.HandleCommand(CMD_CREATE_OM, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.domining:
      begin
        handler.HandleCommand(CMD_DO_MINING, Data.Parametrs.AsStringArray);
      end;
    TCommandsNames.doeasybuyom:
      begin
        handler.HandleCommand(CMD_EASY_CREATE_OM, Data.Parametrs.AsStringArray);
      end;
  end;
end;

procedure TConsoleUI.ShutDown(const Msg: string = '');
var
  str: string;
begin
  ShowMessage(Msg);
  isTerminate := True;
end;

procedure TConsoleUI.DoRun;
var
  inputString: string;
  args: strings;
  buf: Tbytes;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      while not isTerminate do
      begin
        readln(inputString);
        if length(trim(inputString)) = 0 then
          Continue;

        args.SetStrings(inputString);
        RunCommand(parser.TryParse(args));
      end;
    end).Start;
  handler.HandleCommand(CMD_START, []);
  while not isTerminate do
  begin
    CheckSynchronize(100);
  end;
end;

procedure TConsoleUI.DoTerminate;
begin
  isTerminate := True;
end;
{$ENDREGION}

end.