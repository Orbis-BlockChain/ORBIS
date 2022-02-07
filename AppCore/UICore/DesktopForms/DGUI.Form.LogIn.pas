unit DGUI.Form.LogIn;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.StrUtils,
  System.Generics.Collections,
  System.Math,
  App.Notifyer,
  App.Globals,
  Translate.Core,
  App.Types,
  App.Meta,
  App.IHandlerCore,
  UI.Types,
  UI.GUI.Types,
  UI.Animated,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Ani,
  FMX.Edit,
  DGUI.Form.Resources,
  FMX.ComboEdit,
  FMX.ListBox,
  FMX.Effects;

type
  TLogInForm = class(TForm)
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    HeadLabel: TLabel;
    LogInRectangle: TRectangle;
    LogInLabel: TLabel;
    TextColorAnimation: TColorAnimation;
    LogInColorAnimation: TColorAnimation;
    GoRegRectangle: TRectangle;
    GoRegLabel: TLabel;
    EnterPassLayout: TLayout;
    EnterPassLabel: TLabel;
    WalletLabel: TLabel;
    EnterPassEdit: TEdit;
    WalletEdit: TEdit;
    WalletListBox: TListBox;
    WalletShadowEffect: TShadowEffect;
    ArrowPath: TPath;
    ArrowColorAnimation: TColorAnimation;
    Line: TLine;
    Popup: TPopup;
    ResWithKeysRectangle: TRectangle;
    ResWithKeysLabel: TLabel;
    ShowPassLayout: TLayout;
    ShowPassPath: TPath;
    DeleteCryptoRectangle: TRectangle;
    DeleteCryptoLabel: TLabel;
    LangLayout: TLayout;
    LangLabel: TLabel;
    LangPath: TPath;
    LangPopup: TPopup;
    LangListBox: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    LangShadowEffect: TShadowEffect;
    procedure EditChangeTracking(Sender: TObject);
    procedure LogInColorAnimationFinish(Sender: TObject);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LogInRectangleClick(Sender: TObject);
    procedure WalletEditClick(Sender: TObject);
    procedure WalletEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure WalletEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ArrowColorAnimationFinish(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GoRegRectangleClick(Sender: TObject);
    procedure WalletListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ResWithKeysRectangleClick(Sender: TObject);
    procedure ShowPassLayoutClick(Sender: TObject);
    procedure WalletEditMouseEnter(Sender: TObject);
    procedure WalletEditMouseLeave(Sender: TObject);
    procedure ShowPassLayoutMouseEnter(Sender: TObject);
    procedure ShowPassLayoutMouseLeave(Sender: TObject);
    procedure EnterPassEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure DeleteCryptoRectangleClick(Sender: TObject);
    procedure WalletListBoxChange(Sender: TObject);
    procedure LangLayoutClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure LangListBoxChange(Sender: TObject);
    procedure LangListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
  private
    GoAnimation: Boolean;
    procedure SetWallets(AArgs: TArray<string>);
    procedure TryOpenWallet(AArgs: TArray<string>);
    procedure SetText;
    procedure SetLang;
  public
    Handler: IBaseHandler;
    procedure AddWallet(const FAddress: String);
    { Public declarations }
  end;

var
  LogInForm: TLogInForm;

implementation

{$R *.fmx}

procedure TLogInForm.AddWallet(const FAddress: String);
var
  Item: TListBoxItem;
begin
  Item := TListBoxItem.Create(WalletListBox);
  Item.Text := FAddress;
  Item.TextSettings.Font.Family := 'Roboto';
  Item.TextSettings.Font.Size := 19;
  Item.TextSettings.Font.Style := [TFontStyle.fsBold];
  Item.TextSettings.FontColor := $FF8B8CA7;
  Item.StyledSettings := [TStyledSetting.Other];
  Item.Margins.Left := 8;
  Item.Margins.Right := 8;
  if WalletListBox.Items.Count > 0 then
  begin
    WalletListBox.ListItems[WalletListBox.Items.Count - 1].Margins.Bottom := 4;
    Item.Margins.Top := 4;
  end;
  WalletListBox.AddObject(Item);
  Popup.Height := Min(WalletListBox.ItemHeight * 6 + 80, (WalletListBox.Items.Count * WalletListBox.ItemHeight) +
    ((WalletListBox.Items.Count - 1) * 9) + 36);
end;

procedure TLogInForm.ArrowColorAnimationFinish(Sender: TObject);
begin
  if ArrowColorAnimation.Inverse then
    ArrowPath.Fill.Color := ArrowColorAnimation.StartValue
  else
    ArrowPath.Fill.Color := ArrowColorAnimation.StopValue;
  ArrowColorAnimation.Inverse := False;
end;

procedure TLogInForm.DeleteCryptoRectangleClick(Sender: TObject);
var
  MsgDialog: TModalResult;
begin
  MsgDialog := MessageDlg(Trnaslator.GetPhrase(index51, CurrentLanguage), TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0);
  if MsgDialog = mrYes then
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_REMOVE_CC, [trim(WalletEdit.Text)], SetWallets)
  else
    WalletEdit.SetFocus;
end;

procedure TLogInForm.EditChangeTracking(Sender: TObject);
begin
  LogInRectangle.HitTest := not(EnterPassEdit.Text.IsEmpty or WalletEdit.Text.IsEmpty);
  LogInColorAnimation.Inverse := EnterPassEdit.Text.IsEmpty or WalletEdit.Text.IsEmpty;
  TextColorAnimation.Inverse := LogInColorAnimation.Inverse;
  LogInColorAnimation.Enabled := LogInColorAnimation.Inverse <> GoAnimation;
  TextColorAnimation.Enabled := LogInColorAnimation.Enabled;
  GoAnimation := EnterPassEdit.Text.IsEmpty or WalletEdit.Text.IsEmpty;
end;

procedure TLogInForm.EnterPassEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    LogInRectangleClick(nil);
end;

procedure TLogInForm.FormCreate(Sender: TObject);
begin
  SetLang;
  LangListBox.ItemIndex := ord(CurrentLanguage);
  GoAnimation := True;
  LogInRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  LogInRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  GoRegRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  GoRegRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
  ResWithKeysRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  ResWithKeysRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
  DeleteCryptoRectangle.OnMouseEnter := TRectAnimations.AnimRectRedMouseIn;
  DeleteCryptoRectangle.OnMouseLeave := TRectAnimations.AnimRectRedMouseOut;
  LangLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  LangLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
end;

procedure TLogInForm.FormHide(Sender: TObject);
begin
  LangPopup.IsOpen := False;
end;

procedure TLogInForm.FormShow(Sender: TObject);
begin
  Self.Caption := GetCaption;

  AppCore.GetHandler.HandleGUICommand(CMD_CHECK_COUNT_WALLETS, [], SetWallets);
  if not WalletEdit.Text.IsEmpty then
    EnterPassEdit.SetFocus;

  EnterPassEdit.Text := '';
  LangListBox.ItemIndex := LangListBox.Items.IndexOf(LangLabel.Text);

  SetText;
end;

procedure TLogInForm.GoRegRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRegestrattion), []);
end;

procedure TLogInForm.LangLayoutClick(Sender: TObject);
begin
  if (LangListBox.Items.Count > 0) then
    LangPopup.IsOpen := not LangPopup.IsOpen;
end;

procedure TLogInForm.LangListBoxChange(Sender: TObject);
begin
  LangLabel.Text := LangListBox.Items[LangListBox.ItemIndex];
  CurrentLanguage := App.Meta.TLanguages(LangListBox.ItemIndex);
  Notifyer.DoEvent(TEvents.nOnSwitchLang);
  SetText;
end;

procedure TLogInForm.LangListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  LangPopup.IsOpen := False;
end;

procedure TLogInForm.LogInColorAnimationFinish(Sender: TObject);
begin
  if LogInColorAnimation.Inverse then
    GoRegRectangle.Fill.Color := LogInColorAnimation.StartValue
  else
    GoRegRectangle.Fill.Color := LogInColorAnimation.StopValue;
  LogInColorAnimation.Enabled := False;
end;

procedure TLogInForm.LogInRectangleClick(Sender: TObject);
begin
  if (Length(trim(WalletEdit.Text)) > 0) and (Length(trim(EnterPassEdit.Text)) > 0) then
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_OPEN_WALLET, [WalletEdit.Text, EnterPassEdit.Text], TryOpenWallet);
end;

procedure TLogInForm.ResWithKeysRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRestoreSelection), []);
end;

procedure TLogInForm.SetLang;
begin
  LangListBox.ItemIndex := ord(CurrentLanguage);
end;

procedure TLogInForm.SetText;
begin
  HeadLabel.Text := Trnaslator.GetPhrase(index46, CurrentLanguage);
  WalletLabel.Text := Trnaslator.GetPhrase(index49, CurrentLanguage);
  EnterPassLabel.Text := Trnaslator.GetPhrase(index48, CurrentLanguage);
  LogInLabel.Text := Trnaslator.GetPhrase(index46, CurrentLanguage);
  GoRegLabel.Text := Trnaslator.GetPhrase(index47, CurrentLanguage);
  DeleteCryptoLabel.Text := Trnaslator.GetPhrase(index51, CurrentLanguage);
end;

procedure TLogInForm.SetWallets(AArgs: TArray<string>);
var
  buf: TArray<string>;
begin
  WalletEdit.Text := '';
  WalletListBox.Clear;
  if Length(trim(AArgs[0])) > 0 then
    buf := SplitString(AArgs[0], #13#10);
  for var Item in buf do
    if Length(trim(Item)) > 0 then
    begin
      AddWallet(Item);
      WalletListBox.ItemIndex := 0;
    end;
end;

procedure TLogInForm.ShowPassLayoutClick(Sender: TObject);
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

procedure TLogInForm.ShowPassLayoutMouseEnter(Sender: TObject);
begin
  ShowPassPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TLogInForm.ShowPassLayoutMouseLeave(Sender: TObject);
begin
  ShowPassPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TLogInForm.TryOpenWallet(AArgs: TArray<string>);
begin
  if AArgs[0] = 'OK' then
  begin
    AppCore.ShowForm(ord(fNewTransaction), []);
  end
  else
    ShowMessage(AArgs[1]);
end;

procedure TLogInForm.TextColorAnimationFinish(Sender: TObject);
begin
  if TextColorAnimation.Inverse then
    LogInLabel.TextSettings.FontColor := TextColorAnimation.StartValue
  else
    LogInLabel.TextSettings.FontColor := TextColorAnimation.StopValue;
  TextColorAnimation.Enabled := False;
end;

procedure TLogInForm.WalletEditClick(Sender: TObject);
begin
  if (WalletListBox.Items.Count > 0) then
    Popup.IsOpen := not Popup.IsOpen;
  WalletEdit.SelStart := 0;
  WalletEdit.SelLength := 0;
end;

procedure TLogInForm.WalletEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ArrowColorAnimation.Start;
end;

procedure TLogInForm.WalletEditMouseEnter(Sender: TObject);
begin
  WalletEdit.TextSettings.FontColor := CLR_GRAY_SELECTED_TEXT;
  ArrowPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TLogInForm.WalletEditMouseLeave(Sender: TObject);
begin
  WalletEdit.TextSettings.FontColor := CLR_GRAY_FREE_TEXT;
  ArrowPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TLogInForm.WalletEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ArrowColorAnimation.Inverse := True;
  ArrowColorAnimation.Start;
end;

procedure TLogInForm.WalletListBoxChange(Sender: TObject);
begin
  WalletEdit.Text := WalletListBox.Items[WalletListBox.ItemIndex];
end;

procedure TLogInForm.WalletListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  Popup.IsOpen := False;
end;

end.
