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
  Commands.Add(TCommandsNames(0), TCommand.WithName('badcommand').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(1), TCommand.WithName('help').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(2), TCommand.WithName('node').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(3), TCommand.WithName('check').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(4), TCommand.WithName('update').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(5), TCommand.WithName('quit').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(6), TCommand.WithName('createwallet').HasParameter('password', ''));
  Commands.Add(TCommandsNames(7), TCommand.WithName('openwallet').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(8), TCommand.WithName('getwalletlist').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(9), TCommand.WithName('createtoken').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(10), TCommand.WithName('createtransfer').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(11), TCommand.WithName('whoami').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(12), TCommand.WithName('getbalance').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(13), TCommand.WithName('buyom').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(14), TCommand.WithName('domining').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(15), TCommand.WithName('doeasybuyom').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(16), TCommand.WithName('checkbc').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(17), TCommand.WithName('regservice').HasParameter('commandname', ''));
  Commands.Add(TCommandsNames(18), TCommand.WithName('newservicedata').HasParameter('commandname', ''));

end;

destructor TCommandsParser.Destroy;
begin
  for var item in Commands.ToArray do
    item.Value.Free;
  Commands.Clear;
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
        TCommandsNames.checkbc:
      begin
        if Commands.TryGetValue(TCommandsNames.checkbc, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
    TCommandsNames.regservice:
      begin
        if Commands.TryGetValue(TCommandsNames.regservice, PatternCommand) then
          Result := PatternCommand.Parse(args);
      end;
  else
    var Data: TCommandData;
    Data.CommandName := badcommand;
    Result := Data;
  end;
end;
{$ENDREGION}

end.
