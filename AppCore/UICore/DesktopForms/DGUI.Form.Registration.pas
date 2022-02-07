unit DGUI.Form.Registration;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  App.Notifyer,
  App.Globals,
  Translate.Core,
  App.Types,
  App.Meta,
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
  DGUI.Form.Resources,
  FMX.Effects,
  FMX.ListBox,
  App.Config;

type
  TRegistrationForm = class(TForm)
    OrbisLogoPath1: TPath;
    OrbisLogoPath2: TPath;
    OrbisLogoPath3: TPath;
    LogoLayout: TLayout;
    HeadLabel: TLabel;
    EnterPassLayout: TLayout;
    EnterPassEdit: TEdit;
    RepeatPassEdit: TEdit;
    GoRegRectangle: TRectangle;
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
    LangLayout: TLayout;
    LangLabel: TLabel;
    ArrowPath: TPath;
    LangPopup: TPopup;
    LangListBox: TListBox;
    LangShadowEffect: TShadowEffect;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    PasswordLayout: TLayout;
    EnterPassText: TText;
    EnterPassErrorText: TText;
    RepeatPasswordLayout: TLayout;
    RepeatPassErrorText: TText;
    RepeatPassText: TText;
    procedure GoRegRectangleClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure LogInRectangleClick(Sender: TObject);
    procedure RegColorAnimationFinish(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure RestoreCryptoConRectangleClick(Sender: TObject);
    procedure ShowPassLayoutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EnterPassEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormHide(Sender: TObject);
    procedure LangLayoutClick(Sender: TObject);
    procedure LangListBoxChange(Sender: TObject);
    procedure LangListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure SetText;
    procedure SetLang;
    procedure LabNetRadioButtonClick(Sender: TObject);
    procedure TestNetRadioButtonClick(Sender: TObject);
    procedure MainNetRadioButtonClick(Sender: TObject);
  private
    GoAnimation: Boolean;
    function CheckPasswords: Boolean;
    procedure DoChangeNetCallBack(ARgs: TArray<string>);
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

procedure TRegistrationForm.DoChangeNetCallBack(ARgs: TArray<string>);
begin
  if ARgs.Length <= 0 then
    exit;
  if ARgs[0] = 'OK' then
  begin
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_CHANGE_NET, [], nil);
  end;
end;

procedure TRegistrationForm.EditChange(Sender: TObject);
begin
  EnterPassErrorText.Visible := (not EnterPassEdit.Text.IsEmpty) and (EnterPassEdit.Text.Length < 6);
  RepeatPassErrorText.Visible := (not RepeatPassEdit.Text.IsEmpty) and (EnterPassEdit.Text <> RepeatPassEdit.Text);
  GoRegRectangle.HitTest := not(EnterPassEdit.Text.IsEmpty or RepeatPassEdit.Text.IsEmpty) and
    not(EnterPassErrorText.Visible or RepeatPassErrorText.Visible);
  RegColorAnimation.Inverse := not GoRegRectangle.HitTest;
  TextColorAnimation.Inverse := RegColorAnimation.Inverse;
  RegColorAnimation.Enabled := GoRegRectangle.HitTest <> GoAnimation;
  TextColorAnimation.Enabled := RegColorAnimation.Enabled;
  GoAnimation := GoRegRectangle.HitTest;
end;

procedure TRegistrationForm.EnterPassEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkReturn) and GoRegRectangle.HitTest then
    GoRegRectangleClick(nil);
end;

procedure TRegistrationForm.FormCreate(Sender: TObject);
begin
  LangListBox.ItemIndex := ord(CurrentLanguage);
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
  LangLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  LangLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
end;

procedure TRegistrationForm.FormHide(Sender: TObject);
begin
  EnterPassEdit.Text := '';
  RepeatPassEdit.Text := '';
  LangPopup.IsOpen := False;
end;

procedure TRegistrationForm.FormShow(Sender: TObject);
begin
  Self.Caption := GetCaption;
  Self.EnterPassEdit.SetFocus;
  LangListBox.ItemIndex := LangListBox.Items.IndexOf(LangLabel.Text);
  SetText;
  case NetState of
    MAINNET:
      MainNetRadioButton.IsChecked := true;
    TESTNET:
      TestNetRadioButton.IsChecked := true;
    LABNET:
      LabNetRadioButton.IsChecked := true;
  end;
end;

procedure TRegistrationForm.GoRegRectangleClick(Sender: TObject);
begin
  if CheckPasswords then
  begin
    AppCore.ShowForm(ord(fVerification), [EnterPassEdit.Text]);
  end;
end;

procedure TRegistrationForm.LabNetRadioButtonClick(Sender: TObject);
begin
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_SAVE_CONFIG, ['LABNET'], nil);
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_RESTART, ['LABNET'], nil);
end;

procedure TRegistrationForm.LangLayoutClick(Sender: TObject);
begin
  if (LangListBox.Items.Count > 0) then
    LangPopup.IsOpen := not LangPopup.IsOpen;
end;

procedure TRegistrationForm.LangListBoxChange(Sender: TObject);
begin
  LangLabel.Text := LangListBox.Items[LangListBox.ItemIndex];
  CurrentLanguage := App.Meta.TLanguages(LangListBox.ItemIndex);
  Notifyer.DoEvent(TEvents.nOnSwitchLang);
  SetText;
end;

procedure TRegistrationForm.LangListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  LangPopup.IsOpen := False;
end;

procedure TRegistrationForm.LogInRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fLogin), []);
end;

procedure TRegistrationForm.MainNetRadioButtonClick(Sender: TObject);
begin
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_SAVE_CONFIG, ['MAINNET'], nil);
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_RESTART, ['MAINNET'], nil);
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

procedure TRegistrationForm.SetLang;
begin
  LangListBox.ItemIndex := ord(CurrentLanguage);
end;

procedure TRegistrationForm.SetText;
begin
  HeadLabel.Text := Trnaslator.GetPhrase(index47, CurrentLanguage);

  SetFitText(EnterPassText, Trnaslator.GetPhrase(index11, CurrentLanguage));
  SetFitText(EnterPassErrorText, Trnaslator.GetPhrase(index14, CurrentLanguage));

  SetFitText(RepeatPassText, Trnaslator.GetPhrase(index12, CurrentLanguage));
  SetFitText(RepeatPassErrorText, Trnaslator.GetPhrase(index15, CurrentLanguage));

  GoRegLabel.Text := Trnaslator.GetPhrase(index47, CurrentLanguage);
  logInLabel.Text := Trnaslator.GetPhrase(index46, CurrentLanguage);

  RestoreCryptoConLabel.Text := Trnaslator.GetPhrase(index114, CurrentLanguage);
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
    true:
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

procedure TRegistrationForm.TestNetRadioButtonClick(Sender: TObject);
begin
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_SAVE_CONFIG, ['TESTNET'], nil);
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_RESTART, ['TESTNET'], nil);
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
