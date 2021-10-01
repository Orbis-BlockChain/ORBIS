unit UI.ParserCommand;

interface

uses
  System.Classes,
  System.TypInfo,
  System.SysUtils,
  System.Generics.Collections,
  App.Types,
  UI.CommandLineParser,
  UI.Types;

type
  TCommandsParser = class
  private
    FDelegate: TProc<strings>;
    Commands: TObjectDictionary<TCommandsNames, TCommandLinePattern>;
  public
    function TryParse(const args: strings): TCommandData;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TCommandsParser'}

constructor TCommandsParser.Create;
begin
  Commands := TObjectDictionary<TCommandsNames, TCommandLinePattern>.Create;
  Commands.Add(TCommandsNames(0), TCommand.WithName('help').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(1), TCommand.WithName('node').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(2), TCommand.WithName('check').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(3), TCommand.WithName('update').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(4), TCommand.WithName('quit').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(5), TCommand.WithName('createwallet').HasParameter('password', ''));
  Commands.Add(TCommandsNames(6), TCommand.WithName('openwallet').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(7), TCommand.WithName('getwalletlist').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(8), TCommand.WithName('createtoken').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(9), TCommand.WithName('createtransfer').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(10), TCommand.WithName('whoami').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(11), TCommand.WithName('getbalance').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(12), TCommand.WithName('buyom').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(13), TCommand.WithName('domining').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(14), TCommand.WithName('doeasybuyom').HasParameter('commandname', ''));
end;

destructor TCommandsParser.Destroy;
begin
  Commands.Free;
  inherited;
end;

function TCommandsParser.TryParse(const args: strings): TCommandData;
var
  PatternCommand: TCommandLinePattern;
begin
  case TCommandsNames.AsCommand(LowerCase(args[0])) of
    TCommandsNames.help:
      begin
        if Commands.TryGetValue(TCommandsNames.help, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.node:
      begin
        if Commands.TryGetValue(TCommandsNames.node, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.check:
      begin
        if Commands.TryGetValue(TCommandsNames.check, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.update:
      begin
        if Commands.TryGetValue(TCommandsNames.update, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.quit:
      begin
        if Commands.TryGetValue(TCommandsNames.quit, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.createwallet:
      begin
        if Commands.TryGetValue(TCommandsNames.createwallet, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.openwallet:
      begin
        if Commands.TryGetValue(TCommandsNames.openwallet, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.getwalletlist:
      begin
        if Commands.TryGetValue(TCommandsNames.getwalletlist, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.createtoken:
      begin
        if Commands.TryGetValue(TCommandsNames.createtoken, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.createtransfer:
      begin
        if Commands.TryGetValue(TCommandsNames.createtransfer, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.whoami:
      begin
        if Commands.TryGetValue(TCommandsNames.whoami, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.getbalance:
      begin
        if Commands.TryGetValue(TCommandsNames.getbalance, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.buyom:
      begin
        if Commands.TryGetValue(TCommandsNames.buyom, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.domining:
      begin
        if Commands.TryGetValue(TCommandsNames.domining, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.doeasybuyom:
      begin
        if Commands.TryGetValue(TCommandsNames.doeasybuyom, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
  else
    TThread.Queue(nil,
      procedure
      begin
        raise Exception.Create('Error syntax command! No command with name: ' + quotedstr(args[0]));
      end);
  end;
end;
{$ENDREGION}

end.
