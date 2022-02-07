unit DGUI.Form.RegCryptocontainer;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  Translate.Core,
  App.Types,
  App.Meta,
  UI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Effects,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Ani,
  FMX.Edit,
  UI.Animated,
  UI.GUI.Types,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  DGUI.Form.Resources;

type
  TRegCryptocontainerForm = class(TForm)
    EnterPassLayout: TLayout;
    RepeatPassLabel: TLabel;
    EnterPassLabel: TLabel;
    RepeatPassEdit: TEdit;
    EnterPassEdit: TEdit;
    LogInRectangle: TRectangle;
    LogInLabel: TLabel;
    HeadLabel: TLabel;
    GoRegRectangle: TRectangle;
    GoRegLabel: TLabel;
    TextColorAnimation: TColorAnimation;
    RegColorAnimation: TColorAnimation;
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    EnterPassErrorLabel: TLabel;
    RepeatPassErrorLabel: TLabel;
    ShowPassLayout: TLayout;
    ShowPassPath: TPath;
    ShowRepeatLayout: TLayout;
    ShowRepeatPath: TPath;
    procedure FormCreate(Sender: TObject);
    procedure EditChangeTracking(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure RegColorAnimationFinish(Sender: TObject);
    procedure ShowPassLayoutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    GoAnimation: Boolean;
    function CheckPasswords: Boolean;
  public
    { Public declarations }
  end;

var
  RegCryptocontainerForm: TRegCryptocontainerForm;

implementation

{$R *.fmx}

function TRegCryptocontainerForm.CheckPasswords: Boolean;
begin
  Result := (EnterPassEdit.Text.Length >= 6) and (EnterPassEdit.Text = RepeatPassEdit.Text)
end;

procedure TRegCryptocontainerForm.EditChangeTracking(Sender: TObject);
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

procedure TRegCryptocontainerForm.EditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
//    LogInRectangleClick(nil);
end;

procedure TRegCryptocontainerForm.FormCreate(Sender: TObject);
begin
  GoAnimation := False;
  GoRegRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  GoRegRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  LogInRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  LogInRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
  ShowPassLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  ShowPassLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  ShowRepeatLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  ShowRepeatLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
end;

procedure TRegCryptocontainerForm.FormShow(Sender: TObject);
begin
  self.Caption := GetCaption;
  HeadLabel.Text := Trnaslator.GetPhrase(index72, CurrentLanguage);
  EnterPassLabel.Text := Trnaslator.GetPhrase(index70, CurrentLanguage);
  EnterPassErrorLabel.Text := Trnaslator.GetPhrase(index14, CurrentLanguage);
  RepeatPassLabel.Text := Trnaslator.GetPhrase(index69, CurrentLanguage);
  RepeatPassErrorLabel.Text := Trnaslator.GetPhrase(index15, CurrentLanguage);
  GoRegLabel.Text := Trnaslator.GetPhrase(index47, CurrentLanguage);
  LogInLabel.Text := Trnaslator.GetPhrase(index46, CurrentLanguage);
end;

procedure TRegCryptocontainerForm.RegColorAnimationFinish(Sender: TObject);
begin
  if RegColorAnimation.Inverse then
    GoRegRectangle.Fill.Color := RegColorAnimation.StartValue
  else
    GoRegRectangle.Fill.Color := RegColorAnimation.StopValue;
  RegColorAnimation.Enabled := False;
end;

procedure TRegCryptocontainerForm.ShowPassLayoutClick(Sender: TObject);
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

procedure TRegCryptocontainerForm.TextColorAnimationFinish(Sender: TObject);
begin
  if TextColorAnimation.Inverse then
    GoRegLabel.TextSettings.FontColor := TextColorAnimation.StartValue
  else
    GoRegLabel.TextSettings.FontColor := TextColorAnimation.StopValue;
  TextColorAnimation.Enabled := False;
end;

end.
