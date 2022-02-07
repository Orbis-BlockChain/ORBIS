unit DGUI.Form.CreatePass;

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
  FMX.Ani,
  FMX.Effects,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  DGUI.Form.Resources;

type
  TCreatePassForm = class(TForm)
    EnterPassLayout: TLayout;
    RepeatPassLabel: TLabel;
    EnterPassLabel: TLabel;
    RepeatPassEdit: TEdit;
    EnterPassEdit: TEdit;
    EnterPassErrorLabel: TLabel;
    RepeatPassErrorLabel: TLabel;
    OkRectangle: TRectangle;
    OkLabel: TLabel;
    TextColorAnimation: TColorAnimation;
    OkColorAnimation: TColorAnimation;
    HeadLabel: TLabel;
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    procedure EditChangeTracking(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure OkColorAnimationFinish(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    GoAnimation: Boolean;
  public
    { Public declarations }
  end;

var
  CreatePassForm: TCreatePassForm;

implementation

{$R *.fmx}

procedure TCreatePassForm.EditChangeTracking(Sender: TObject);
begin
  EnterPassErrorLabel.Visible := (not EnterPassEdit.Text.IsEmpty) and (EnterPassEdit.Text.Length < 6);
  RepeatPassErrorLabel.Visible := (not RepeatPassEdit.Text.IsEmpty) and (EnterPassEdit.Text <> RepeatPassEdit.Text);
  OkRectangle.HitTest := not(EnterPassEdit.Text.IsEmpty or RepeatPassEdit.Text.IsEmpty);
  OkColorAnimation.Inverse := EnterPassEdit.Text.IsEmpty or RepeatPassEdit.Text.IsEmpty;
  TextColorAnimation.Inverse := OkColorAnimation.Inverse;
  OkColorAnimation.Enabled := OkColorAnimation.Inverse <> GoAnimation;
  TextColorAnimation.Enabled := OkColorAnimation.Enabled;
  GoAnimation := EnterPassEdit.Text.IsEmpty or RepeatPassEdit.Text.IsEmpty;
end;

procedure TCreatePassForm.EditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
//    OkRectangleClick(nil);
end;

procedure TCreatePassForm.FormCreate(Sender: TObject);
begin
  GoAnimation := True;
end;

procedure TCreatePassForm.FormHide(Sender: TObject);
begin
  EnterPassEdit.Text := '';
  RepeatPassEdit.Text := '';
end;

procedure TCreatePassForm.FormShow(Sender: TObject);
begin
  HeadLabel.Text := Trnaslator.GetPhrase(index10,CurrentLanguage);
  EnterPassLabel.Text := Trnaslator.GetPhrase(index11,CurrentLanguage);
  RepeatPassLabel.Text := Trnaslator.GetPhrase(index12,CurrentLanguage);
  OkLabel.Text := Trnaslator.GetPhrase(index13,CurrentLanguage);
  Self.Caption := GetCaption;
end;

procedure TCreatePassForm.OkColorAnimationFinish(Sender: TObject);
begin
  if OkColorAnimation.Inverse then
    OkRectangle.Fill.Color := OkColorAnimation.StartValue
  else
    OkRectangle.Fill.Color := OkColorAnimation.StopValue;
  OkColorAnimation.Enabled := False;
end;

procedure TCreatePassForm.TextColorAnimationFinish(Sender: TObject);
begin
  if TextColorAnimation.Inverse then
    OkLabel.TextSettings.FontColor := TextColorAnimation.StartValue
  else
    OkLabel.TextSettings.FontColor := TextColorAnimation.StopValue;
  TextColorAnimation.Enabled := False;
end;

end.
