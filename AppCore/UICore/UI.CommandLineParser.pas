unit UI.CommandLineParser;

interface

uses
  System.Classes,
  System.TypInfo,
  System.SysUtils,
  System.Generics.Collections,
  App.Types,
  UI.Types;

type
  TCommandLinePattern = class
  strict private
    FName: string;
    FParametrs: TParametrs;
    function TryParse(Args: strings; out Return: TCommandData): boolean; virtual;
  public
    property Name: string read FName write FName;
    property Parametrs: TParametrs read FParametrs write FParametrs;
    function HasParameter(const ANameParametr, AValue: string): TCommandLinePattern;
    function Parse(Args: strings): TCommandData; virtual;
    constructor Create(const AName: string);
    destructor Destroy; override;
  end;

  TCommand = class
  public
    class function WithName(const AName: string): TCommandLinePattern; static;
  end;

implementation

{$REGION 'TCommand'}

class function TCommand.WithName(const AName: string): TCommandLinePattern;
begin
  Result := TCommandLinePattern.Create(AName);
end;

{$ENDREGION}
{$REGION 'TCommandLinePattern'}

constructor TCommandLinePattern.Create(const AName: string);
begin
  FName := AName;
  FParametrs := [];
end;

destructor TCommandLinePattern.Destroy;
begin
  FName := string.Empty;
  inherited;
end;

function TCommandLinePattern.HasParameter(const ANameParametr, AValue: string): TCommandLinePattern;
var
  Parametr: TParametr;
begin
  Parametr.Name := ANameParametr;
  Parametr.Value := AValue;
  FParametrs := FParametrs + [Parametr];
  Result := Self;
end;

function TCommandLinePattern.Parse(Args: strings): TCommandData;
var
  Command: TCommandData;
begin
  try
    if TryParse(Args, Command) then
      Result := Command;
  except
    raise Exception.Create('Exception: Incorrect format string!');
  end;

end;

function TCommandLinePattern.TryParse(Args: strings; out Return: TCommandData): boolean;
var
  Parametr: TParametr;
  Name: string;
  i: uint64;
begin
  Result := True;
  if Args.IsEmpty then
  begin
    Result := False;
    exit;
  end;

  if not(Args[0] = FName) then
  begin
    Result := False;
    exit;
  end;

  Return.CommandName := TCommandsNames.AsCommand(FName);
  i := 1;
  Parametr.Name := '';
  Parametr.Value := '';
  Return.Parametrs := [];
  while i <= Args.Length - 1 do
  begin
    if Parametr.Name = '' then
    begin
      if Args[i].StartsWith('-') then
        Parametr.Name := Args[i].Substring(1);
    end
    else
    begin
      if Args[i].StartsWith('-') then
      begin
        Return.Parametrs := Return.Parametrs + [Parametr];
        Parametr.Name := Args[i].Substring(1);
      end
      else
      begin
        Parametr.Value := Args[i].Substring(0);
        Return.Parametrs := Return.Parametrs + [Parametr];
        Parametr.Name := '';
        Parametr.Value := '';
      end;
    end;
    inc(i);
  end;
end;

{$ENDREGION}

end.
