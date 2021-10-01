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
  App.Globals,
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
    procedure EnterPassEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure WalletListBoxChange(Sender: TObject);
    procedure WalletListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ResWithKeysRectangleClick(Sender: TObject);
    procedure ShowPassLayoutClick(Sender: TObject);
    procedure WalletEditMouseEnter(Sender: TObject);
    procedure WalletEditMouseLeave(Sender: TObject);
    procedure ShowPassLayoutMouseEnter(Sender: TObject);
    procedure ShowPassLayoutMouseLeave(Sender: TObject);
  private
    GoAnimation: Boolean;
    procedure SetWallets(AArgs: TArray<string>);
    procedure TryOpenWallet(AArgs: TArray<string>);
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
  Popup.Height := Min(WalletListBox.ItemHeight * 3 + 54, (WalletListBox.Items.Count * WalletListBox.ItemHeight) +
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
  GoAnimation := True;
  LogInRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  LogInRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  GoRegRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  GoRegRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
  ResWithKeysRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  ResWithKeysRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;
end;

procedure TLogInForm.FormShow(Sender: TObject);
begin
  WalletListBox.Clear;
  AppCore.GetHandler.HandleGUICommand(CMD_CHECK_COUNT_WALLETS, [], SetWallets);
  if not WalletEdit.Text.IsEmpty then
    EnterPassEdit.SetFocus;
end;

procedure TLogInForm.GoRegRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRegestrattion), []);
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
  if (Length(Trim(WalletEdit.Text)) > 0) and (Length(Trim(EnterPassEdit.Text)) > 0) then
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_OPEN_WALLET, [WalletEdit.Text, EnterPassEdit.Text], TryOpenWallet);
end;

procedure TLogInForm.ResWithKeysRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRestoreSelection), []);
end;

procedure TLogInForm.SetWallets(AArgs: TArray<string>);
var
  buf: TArray<string>;
begin
  if Length(Trim(AArgs[0])) > 0 then
    buf := SplitString(AArgs[0], #13#10);
  for var Item in buf do
    if Length(Trim(Item)) > 0 then
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
    AppCore.ShowForm(ord(fNewTransaction), [])
  else
    ShowMessage('Bad Login or Password. Try Again.');
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
