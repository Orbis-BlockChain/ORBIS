unit UI.GUI;

interface

{$IFDEF GUII}

uses
  System.Threading,
  System.Classes,
  System.SysUtils,
  FMX.Forms,
  FMX.Dialogs,
  App.Meta,
  UI.Types,
  UI.Abstractions,
  UI.GUI.FormsConrol;

type

  TGUI = class(TBaseUI)
  private
    Controller: TFormsControl;
  public
    procedure DoUpdate; override;
    procedure ShutDown(const Msg: string = ''); override;
    procedure DoRun;
    procedure DoTerminate;
    procedure RunCommand(Data: TCommandData);
    procedure ShowMessageGUI(AArg: string);
    constructor Create;
    destructor Destroy; override;
  end;
{$ENDIF}

implementation

{$IFDEF GUII}
{$REGION 'TGUI'}

constructor TGUI.Create;
begin
  Controller := TFormsControl.Create;
  FShowForm := Controller.ShowForm;
  ShowMessage := ShowMessageGUI;
end;

destructor TGUI.Destroy;
begin
  inherited;
end;

procedure TGUI.DoRun;
begin
  Controller.Initialize;
  Application.Run;
  Controller.Free;
end;

procedure TGUI.DoTerminate;
begin

end;

procedure TGUI.DoUpdate;
begin
  Controller.PreapareUpdate;
end;

procedure TGUI.RunCommand(Data: TCommandData);
begin

end;

procedure TGUI.ShowMessageGUI(AArg: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FMX.Dialogs.ShowMessage(AArg);
    end);
end;

procedure TGUI.ShutDown(const Msg: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      if length(trim(msg)) <>0 then
        FMX.Dialogs.ShowMessage(Msg);
      Application.Terminate;
    end);
end;

{$ENDREGION}
{$ENDIF}

end.
