unit DGUI.Form.FileCryptocontainer;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  App.Globals,
  Translate.Core,
  App.Types,
  App.Meta,
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
  FMX.Edit,
  UI.Animated,
  DGUI.Form.Resources,
  FMX.Ani,
  UI.GUI.Types;

type
  TFileCryptocontainerForm = class(TForm)
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    HeadLabel: TLabel;
    Line: TLine;
    BackRectangle: TRectangle;
    BackLabel: TLabel;
    LoadFileRectangle: TRectangle;
    LoadFileLabel: TLabel;
    PasswordEdit: TEdit;
    OkRectangle: TRectangle;
    OkColorAnimation: TColorAnimation;
    OkLabel: TLabel;
    TextColorAnimation: TColorAnimation;
    LoadFileDialog: TOpenDialog;
    ChosenFileHeaderLabel: TLabel;
    ChosenFileNameLabel: TLabel;
    ChooseAnotherLabel: TLabel;
    PasswordLayout: TLayout;
    PasswordText: TText;
    PasswordErrorText: TText;
    procedure BackRectangleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PasswordEditChangeTracking(Sender: TObject);
    procedure LoadFileRectangleClick(Sender: TObject);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure OkColorAnimationFinish(Sender: TObject);
    procedure OkRectangleClick(Sender: TObject);
    procedure LabelMouseEnter(Sender: TObject);
    procedure ChooseAnotherLabelMouseLeave(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    GoAnimation: Boolean;
    procedure Callback(AArgs: TArray<string>);
  public
    { Public declarations }
  end;

var
  FileCryptocontainerForm: TFileCryptocontainerForm;

implementation

{$R *.fmx}

procedure TFileCryptocontainerForm.BackRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRestoreSelection), []);
end;

procedure TFileCryptocontainerForm.LabelMouseEnter(Sender: TObject);
begin
  (Sender as TLabel).TextSettings.FontColor := CLR_GRAY_SELECTED_TEXT;
end;

procedure TFileCryptocontainerForm.Callback(AArgs: TArray<string>);
begin
  if AArgs[0] = 'OK' then
  begin
    AppCore.ShowForm(ord(fLogin), []);
  end
  else
    PasswordErrorText.Visible := True;
end;

procedure TFileCryptocontainerForm.ChooseAnotherLabelMouseLeave(Sender: TObject);
begin
  (Sender as TLabel).TextSettings.FontColor := CLR_GRAY_FREE_TEXT;
end;

procedure TFileCryptocontainerForm.FormCreate(Sender: TObject);
begin
  LoadFileDialog.FileName := '';
  GoAnimation := True;
  LoadFileRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  LoadFileRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  OkRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  OkRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  BackRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  BackRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
end;

procedure TFileCryptocontainerForm.FormShow(Sender: TObject);
begin
  self.Caption := GetCaption;
  HeadLabel.Text := Trnaslator.GetPhrase(index28, CurrentLanguage);
  LoadFileLabel.Text :=  Trnaslator.GetPhrase(index29, CurrentLanguage);
  SetFitText(PasswordText, Trnaslator.GetPhrase(index30, CurrentLanguage));
  SetFitText(PasswordErrorText, Trnaslator.GetPhrase(index33, CurrentLanguage));
  OkLabel.Text := Trnaslator.GetPhrase(index13, CurrentLanguage);
  BackLabel.Text := Trnaslator.GetPhrase(index25, CurrentLanguage);
end;

procedure TFileCryptocontainerForm.LoadFileRectangleClick(Sender: TObject);
begin
  if LoadFileDialog.Execute then
  begin
    PasswordEditChangeTracking(nil);
    LoadFileRectangle.Visible := False;
    ChosenFileHeaderLabel.Visible := True;
    ChosenFileNameLabel.Text := ExtractFileName(LoadFileDialog.FileName);
    ChosenFileNameLabel.Visible := True;
    ChooseAnotherLabel.Visible := True;
  end;
end;

procedure TFileCryptocontainerForm.OkColorAnimationFinish(Sender: TObject);
begin
  if OkColorAnimation.Inverse then
    OkRectangle.Fill.Color := OkColorAnimation.StartValue
  else
    OkRectangle.Fill.Color := OkColorAnimation.StopValue;
  OkColorAnimation.Enabled := False;
end;

procedure TFileCryptocontainerForm.OkRectangleClick(Sender: TObject);
begin
  if LoadFileDialog.FileName <> '' then
    handler.HandleGUICommand(CMD_GUI_SET_CC, [LoadFileDialog.FileName, PasswordEdit.Text], Callback);
end;

procedure TFileCryptocontainerForm.PasswordEditChangeTracking(Sender: TObject);
begin
  OkRectangle.HitTest := not((LoadFileDialog.FileName = '') or (PasswordEdit.Text.IsEmpty));
  OkColorAnimation.Inverse := (LoadFileDialog.FileName = '') or PasswordEdit.Text.IsEmpty;
  TextColorAnimation.Inverse := OkColorAnimation.Inverse;
  OkColorAnimation.Enabled := OkColorAnimation.Inverse <> GoAnimation;
  TextColorAnimation.Enabled := OkColorAnimation.Enabled;
  GoAnimation := (LoadFileDialog.FileName = '') or PasswordEdit.Text.IsEmpty;
  PasswordErrorText.Visible := False;
end;

procedure TFileCryptocontainerForm.TextColorAnimationFinish(Sender: TObject);
begin
  if TextColorAnimation.Inverse then
  begin
    OkLabel.TextSettings.FontColor := TextColorAnimation.StartValue;
  end
  else
  begin
    OkLabel.TextSettings.FontColor := TextColorAnimation.StopValue;
  end;
  TextColorAnimation.Enabled := False;
end;

end.
