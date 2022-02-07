unit DGUI.Form.Verification;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Math,
  System.StrUtils,
  System.SyncObjs,
  Translate.Core,
  App.Meta,
  App.Types,
  App.Globals,
  App.Notifyer,
  App.IHandlerCore,
  UI.Types,
  UI.GUI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Ani,
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  DGUI.Form.Resources,
  UI.Animated;

type
  TVerificationForm = class(TForm)
    EnterPassLayout: TLayout;
    EnterPassEdit: TEdit;
    OkRectangle: TRectangle;
    OkLabel: TLabel;
    TextColorAnimation: TColorAnimation;
    OkColorAnimation: TColorAnimation;
    HeadLabel: TLabel;
    ChangePassRectangle: TRectangle;
    ChangePassLabel: TLabel;
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    PasswordLabel: TLabel;
    EnterPassTextLayout: TLayout;
    EnterPassText: TText;
    EnterPassErrorText: TText;

    procedure ChangePassRectangleClick(Sender: TObject);
    procedure OkRectangleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkColorAnimationFinish(Sender: TObject);
    procedure EnterPassEditChangeTracking(Sender: TObject);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EnterPassEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormHide(Sender: TObject);
  private
    GoAnimation: Boolean;
    ControlKey: string;
    procedure CallBackCreateWallet(AArgs: TArray<string>);
    procedure CallbackForAcceptCC;
    procedure SetAcceptCC(AArgs: TArray<string>);
  public
    Password: string;
    Address: string;
    { Public declarations }
  end;

var
  VerificationForm: TVerificationForm;

implementation

{$R *.fmx}

procedure TVerificationForm.CallBackCreateWallet(AArgs: TArray<string>);
begin
  Address := AArgs[0];

  OkRectangle.Enabled := True;
  ChangePassRectangle.Enabled := True;
  EnterPassLayout.Enabled := True;

  if Length(Trim(Address)) > 0 then
  begin
    AppCore.ShowForm(ord(fWords), [Address]);
  end
  else
  begin
    ShowMessage(aargs[1]);
    AppCore.ShowForm(ord(fRegestrattion), []);
  end;
end;

procedure TVerificationForm.CallbackForAcceptCC;
begin
  Handler.HandleGUICommand(CMD_GUI_CHECK_NEW_WALLET, [Address], SetAcceptCC)
end;

procedure TVerificationForm.ChangePassRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRegestrattion), []);
end;

procedure TVerificationForm.EnterPassEditChangeTracking(Sender: TObject);
begin
  OkRectangle.HitTest := not EnterPassEdit.Text.IsEmpty;
  OkColorAnimation.Inverse := EnterPassEdit.Text.IsEmpty;
  TextColorAnimation.Inverse := OkColorAnimation.Inverse;
  OkColorAnimation.Enabled := OkColorAnimation.Inverse <> GoAnimation;
  TextColorAnimation.Enabled := OkColorAnimation.Enabled;
  GoAnimation := EnterPassEdit.Text.IsEmpty;
end;

procedure TVerificationForm.EnterPassEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    OkRectangleClick(nil);
end;

procedure TVerificationForm.FormCreate(Sender: TObject);
begin
  GoAnimation := True;
  OkRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  OkRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  ChangePassRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  ChangePassRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
end;

procedure TVerificationForm.FormHide(Sender: TObject);
begin
  EnterPassEdit.Text := '';
end;

procedure TVerificationForm.FormShow(Sender: TObject);
begin
  self.Caption := GetCaption;
  ControlKey := IntToStr(RandomRange(100000, 999999));
  PasswordLabel.Text := ControlKey;
  EnterPassEdit.SetFocus;
  HeadLabel.Text := Trnaslator.GetPhrase(index84, CurrentLanguage);
  SetFitText(EnterPassText, Trnaslator.GetPhrase(index82, CurrentLanguage));
  SetFitText(EnterPassErrorText, Trnaslator.GetPhrase(index83, CurrentLanguage));
  OkLabel.Text := Trnaslator.GetPhrase(index13, CurrentLanguage);
  ChangePassLabel.Text := Trnaslator.GetPhrase(index85, CurrentLanguage);
end;

procedure TVerificationForm.OkColorAnimationFinish(Sender: TObject);
begin
  if OkColorAnimation.Inverse then
    OkRectangle.Fill.Color := OkColorAnimation.StartValue
  else
    OkRectangle.Fill.Color := OkColorAnimation.StopValue;
  OkColorAnimation.Enabled := False;
end;

procedure TVerificationForm.OkRectangleClick(Sender: TObject);
begin
  EnterPassErrorText.Visible := not(EnterPassEdit.Text = ControlKey);

  if EnterPassEdit.Text = ControlKey then
  begin
    OkRectangle.Enabled := False;
    ChangePassRectangle.Enabled := False;
    EnterPassLayout.Enabled := False;

    Handler.HandleGUICommand(CMD_GUI_CREATE_WALLET, [Password], CallBackCreateWallet);
  end;
end;

procedure TVerificationForm.SetAcceptCC(AArgs: TArray<string>);
begin
end;

procedure TVerificationForm.TextColorAnimationFinish(Sender: TObject);
begin
  if TextColorAnimation.Inverse then
    OkLabel.TextSettings.FontColor := TextColorAnimation.StartValue
  else
    OkLabel.TextSettings.FontColor := TextColorAnimation.StopValue;
  TextColorAnimation.Enabled := False;
end;

end.
