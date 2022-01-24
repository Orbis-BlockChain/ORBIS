unit UI.Abstractions;

interface

uses
  System.SysUtils,
  System.Classes,
{$IFDEF GUII}
  UI.GUI.FormsConrol,
  UI.GUI.Types,
{$ENDIF}
  App.IHandlerCore;

type

  TBaseUI = class abstract
  private
    procedure EmptyProc;
    procedure EmtyProcStr(str: string);
    procedure EmtyProcByteStr(atype: byte; aargs: TArray<string>);
  protected
    FShowForm: TProc<byte, TArray<string>>;
    FShowMessage: TProc<string>;
    FHandler: IBaseHandler;
{$IFDEF GUII}
    // FForms: TFormsControl;
{$ENDIF}
  public
    property ShowMessage: TProc<string> read FShowMessage write FShowMessage;
    property Handler: IBaseHandler read FHandler write FHandler;
    property ShowForm: TProc < byte, TArray < string >> read FShowForm write FShowForm;
    procedure ShutDown(const Msg: string = ''); virtual; abstract;
    procedure DoRun; virtual; abstract;
    procedure DoTerminate; virtual; abstract;
    procedure DoUpdate; virtual; abstract;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

implementation

{ TBaseUI }

constructor TBaseUI.Create;
begin
  ShowMessage := EmtyProcStr;
  ShowForm := EmtyProcByteStr;
end;

destructor TBaseUI.Destroy;
begin

end;

procedure TBaseUI.EmptyProc;
begin

end;

procedure TBaseUI.EmtyProcByteStr(atype: byte; aargs: TArray<string>);
begin

end;

procedure TBaseUI.EmtyProcStr(str: string);
begin

end;

end.
