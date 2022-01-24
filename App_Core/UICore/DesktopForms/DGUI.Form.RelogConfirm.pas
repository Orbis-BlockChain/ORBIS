unit DGUI.Form.RelogConfirm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Layouts,
  FMX.Ani,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  UI.Animated;

type
  TRelogConfirmForm = class(TForm)
    Line: TLine;
    ExitRectangle: TRectangle;
    ExitLabel: TLabel;
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    BackRectangle: TRectangle;
    BacksLabel: TLabel;
    ReLogRectangle: TRectangle;
    ReLogLabel: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RelogConfirmForm: TRelogConfirmForm;

implementation

{$R *.fmx}

procedure TRelogConfirmForm.FormCreate(Sender: TObject);
begin
  ExitRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  ExitRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
  ReLogRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  ReLogRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
end;

end.
