unit DGUI.Form.ResCryptocontainer;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  App.Globals,
  UI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  UI.Animated;

type
  TResCryptocontainerForm = class(TForm)
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    HeadLabel: TLabel;
    LoadFileRectangle: TRectangle;
    LoadFileLabel: TLabel;
    ManuallyRectangle: TRectangle;
    ManuallyLabel: TLabel;
    EnterPassLabel: TLabel;
    LogInRectangle: TRectangle;
    LogInLabel: TLabel;
    Line: TLine;
    procedure LoadFileRectangleClick(Sender: TObject);
    procedure ManuallyRectangleClick(Sender: TObject);
    procedure LogInRectangleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ResCryptocontainerForm: TResCryptocontainerForm;

implementation

{$R *.fmx}

procedure TResCryptocontainerForm.FormCreate(Sender: TObject);
begin
  LoadFileRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  LoadFileRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  ManuallyRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;;
  ManuallyRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  LogInRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  LogInRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
end;

procedure TResCryptocontainerForm.LoadFileRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fChooseCC), []);
end;

procedure TResCryptocontainerForm.LogInRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fLogin), []);
end;

procedure TResCryptocontainerForm.ManuallyRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fEnterWods), []);
end;

end.
