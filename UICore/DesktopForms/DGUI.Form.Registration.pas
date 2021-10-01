unit DGUI.Form.Registration;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  App.Globals,
  App.IHandlerCore,
  UI.Animated,
  UI.Types,
  UI.GUI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.Objects,
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Ani,
  DGUI.Form.Resources;

type
  TRegistrationForm = class(TForm)
    OrbisLogoPath1: TPath;
    OrbisLogoPath2: TPath;
    OrbisLogoPath3: TPath;
    LogoLayout: TLayout;
    HeadLabel: TLabel;
    EnterPassLayout: TLayout;
    RepeatPassLabel: TLabel;
    EnterPassLabel: TLabel;
    EnterPassEdit: TEdit;
    RepeatPassEdit: TEdit;
    GoRegRectangle: TRectangle;
    EnterPassErrorLabel: TLabel;
    RepeatPassErrorLabel: TLabel;
    RegColorAnimation: TColorAnimation;
    GoRegLabel: TLabel;
    TextColorAnimation: TColorAnimation;
    LogInRectangle: TRectangle;
    logInLabel: TLabel;
    RestoreCryptoConRectangle: TRectangle;
    RestoreCryptoConLabel: TLabel;
    LabNetRadioButton: TRadioButton;
    TestNetRadioButton: TRadioButton;
    MainNetRadioButton: TRadioButton;
    ShowPassLayout: TLayout;
    ShowPassPath: TPath;
    ShowRepeatPassLayout: TLayout;
    ShowRepeatPassPath: TPath;
    procedure GoRegRectangleClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure LogInRectangleClick(Sender: TObject);
    procedure RegColorAnimationFinish(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure RestoreCryptoConRectangleClick(Sender: TObject);
    procedure ShowPassLayoutClick(Sender: TObject);
  private
    GoAnimation: Boolean;
    function CheckPasswords: Boolean;
  public
    { Public declarations }
  end;

var
  RegistrationForm: TRegistrationForm;

implementation

{$R *.fmx}

function TRegistrationForm.CheckPasswords: Boolean;
begin
  Result := (EnterPassEdit.Text.Length >= 6) and (EnterPassEdit.Text = RepeatPassEdit.Text)
end;

procedure TRegistrationForm.EditChange(Sender: TObject);
begin
  EnterPassErrorLabel.Visible := (not EnterPassEdit.Text.IsEmpty) and (EnterPassEdit.Text.Length < 6);
  RepeatPassErrorLabel.Visible := (not RepeatPassEdit.Text.IsEmpty) and (EnterPassEdit.Text <> RepeatPassEdit.Text);
  GoRegRectangle.HitTest := not(EnterPassEdit.Text.IsEmpty or RepeatPassEdit.Text.IsEmpty) and
  not(EnterPassErrorLabel.Visible or RepeatPassErrorLabel.Visible);
  RegColorAnimation.Inverse := not GoRegRectangle.HitTest;
  TextColorAnimation.Inverse := RegColorAnimation.Inverse;
  RegColorAnimation.Enabled := GoRegRectangle.HitTest <> GoAnimation;
  TextColorAnimation.Enabled := RegColorAnimation.Enabled;
  GoAnimation := GoRegRectangle.HitTest;
end;

procedure TRegistrationForm.FormCreate(Sender: TObject);
begin
  GoAnimation := False;
  GoRegRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  GoRegRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  LogInRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  LogInRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
  RestoreCryptoConRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  RestoreCryptoConRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
  ShowPassLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  ShowPassLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  ShowRepeatPassLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  ShowRepeatPassLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
end;

procedure TRegistrationForm.GoRegRectangleClick(Sender: TObject);
begin
  if CheckPasswords then
    AppCore.ShowForm(ord(fVerification), [EnterPassEdit.Text]);
end;

procedure TRegistrationForm.LogInRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fLogin), []);
end;

procedure TRegistrationForm.RegColorAnimationFinish(Sender: TObject);
begin
  if RegColorAnimation.Inverse then
    GoRegRectangle.Fill.Color := RegColorAnimation.StartValue
  else
    GoRegRectangle.Fill.Color := RegColorAnimation.StopValue;
  RegColorAnimation.Enabled := False;
end;

procedure TRegistrationForm.RestoreCryptoConRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRestoreSelection), []);
end;

procedure TRegistrationForm.ShowPassLayoutClick(Sender: TObject);
var
  FEdit: TEdit;
  FEye: TPath;
  Obj: TFMXObject;
begin
  FEdit := (Sender as TLayout).Parent as TEdit;
  Obj := nil;
  for Obj in (Sender as TLayout).Children.ToArray do
    if (Obj is TPath) then
    begin
      FEye := Obj as TPath;
      break;
    end;

  FEdit.Password := not FEdit.Password;
  case FEdit.Password of
    True:
      begin
        FEye.Data.Data := SVG_OPEN_EYE;
        FEye.Width := 24;
        FEye.Height := 18;
      end;
    False:
      begin
        FEye.Data.Data := SVG_CLOSE_EYE;
        FEye.Width := 24;
        FEye.Height := 20;
      end;
  end;
end;

procedure TRegistrationForm.TextColorAnimationFinish(Sender: TObject);
begin
  if TextColorAnimation.Inverse then
  begin
    GoRegRectangle.Cursor := crDefault;
    GoRegLabel.TextSettings.FontColor := TextColorAnimation.StartValue
  end
  else
  begin
    GoRegRectangle.Cursor := crHandPoint;
    GoRegLabel.TextSettings.FontColor := TextColorAnimation.StopValue;
  end;
  TextColorAnimation.Enabled := False;
end;

end.
