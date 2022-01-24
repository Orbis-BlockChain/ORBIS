unit DGUI.Form.NewTransaction;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  App.IHandlerCore,
  App.Types,
  App.Notifyer,
  App.Globals,
  App.Meta,
  UI.Types,
  UI.Animated,
  UI.GUI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Ani,
  FMX.Objects,
  FMX.Edit,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  System.Math,
  FMX.ListBox,
  FMX.Effects,
  DGUI.Form.Resources;

type
  TTokenBalance = record
    Name: String;
    Balance: Extended;
  end;

  TNewTransactionForm = class(TForm)
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    GoTransRectangle: TRectangle;
    GoTransLabel: TLabel;
    TokenInfoLayout: TLayout;
    PayLabel: TLabel;
    TokenEdit: TEdit;
    ArrowPath: TPath;
    ArrowColorAnimation: TColorAnimation;
    BalanceLabel: TLabel;
    TokenNameLabel: TLabel;
    FeePath: TPath;
    FeeLabel: TLabel;
    AddressLayout: TLayout;
    AddressLabel: TLabel;
    AddressEdit: TEdit;
    TransactionsPath: TPath;
    QRPath: TPath;
    ConnectionStateLabel: TLabel;
    Line: TLine;
    TransactionsLabel: TLabel;
    MyAddressLabel: TLabel;
    TransactionsLayout: TLayout;
    MyAddressLayout: TLayout;
    TokensListBox: TListBox;
    TokensShadowEffect: TShadowEffect;
    ChooseTokenLayout: TLayout;
    Popup: TPopup;
    RelogLayout: TLayout;
    RelogPath: TPath;
    procedure TransactionsLayoutClick(Sender: TObject);
    procedure MyAddressLayoutClick(Sender: TObject);
    procedure GoTransRectangleClick(Sender: TObject);
    procedure TokenEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure TokenEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ArrowColorAnimationFinish(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OnApplyStyleTokenItem(Sender: TObject);
    procedure OnTokenItemResized(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TokensListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ChooseTokenLayoutClick(Sender: TObject);
    procedure TokenEditChangeTracking(Sender: TObject);
    procedure EnterKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure TokensListBoxChange(Sender: TObject);
    procedure ChooseTokenLayoutMouseEnter(Sender: TObject);
    procedure ChooseTokenLayoutMouseLeave(Sender: TObject);
  private
    Tokens: TArray<TTokenBalance>;
    Index: Integer;
    PrevVol: String;
    procedure AddToken(const AName: String; ABalance: Extended);
    procedure SetBalances(AArgs: TArray<string>);
    procedure UpdateBalances;
  public
    procedure ClearFields;
  end;

var
  NewTransactionForm: TNewTransactionForm;

implementation

{$R *.fmx}

procedure TNewTransactionForm.AddToken(const AName: String; ABalance: Extended);
var
  Item: TListBoxItem;
  TB: TTokenBalance;
  Txt: TText;
begin
  TB.Name := AName;
  TB.Balance := ABalance;
  Tokens := Tokens + [TB];

  Item := TListBoxItem.Create(TokensListBox);
  with Item do
  begin
    Name := 'ListItem' + TokensListBox.Items.Count.ToString;
    StyleLookup := 'ListBoxItemTokenStyle';
    Item.Tag := TokensListBox.Items.Count;
    Item.Height := TokensListBox.ItemHeight;
    if not(TokensListBox.Items.Count = 0) then
    begin
      Margins.Top := 4;
      TokensListBox.ListItems[TokensListBox.Items.Count - 1].Margins.Bottom := 4;
    end;

    OnResized := OnTokenItemResized;
    OnApplyStyleLookup := OnApplyStyleTokenItem;
    StyledSettings := [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor,
    TStyledSetting.Other];
    TextSettings.FontColor := $FF8B8CA7;

    TokensListBox.AddObject(Item);
    Item.NeedStyleLookup;
    Item.ApplyStyleLookup;

    Txt := TText(Item.FindStyleResource('text'));
    Txt.Text := AName;

    Txt := TText(Item.FindStyleResource('balancetext'));
    Txt.Text := ABalance.ToString;
  end;
end;

procedure TNewTransactionForm.ArrowColorAnimationFinish(Sender: TObject);
begin
  if ArrowColorAnimation.Inverse then
    ArrowPath.Fill.Color := ArrowColorAnimation.StartValue
  else
    ArrowPath.Fill.Color := ArrowColorAnimation.StopValue;
  ArrowColorAnimation.Inverse := False;
end;

procedure TNewTransactionForm.ChooseTokenLayoutClick(Sender: TObject);
begin
  if TokensListBox.Items.Count > 0 then
  begin
    Popup.IsOpen := not Popup.IsOpen;
    Popup.Height := Min(250, TokensListBox.Items.Count * (TokensListBox.ItemHeight + 8) + 28);
  end;
end;

procedure TNewTransactionForm.ChooseTokenLayoutMouseEnter(Sender: TObject);
begin
  TokenNameLabel.TextSettings.FontColor := CLR_GRAY_SELECTED_TEXT;
  ArrowPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TNewTransactionForm.ChooseTokenLayoutMouseLeave(Sender: TObject);
begin
  TokenNameLabel.TextSettings.FontColor := CLR_GRAY_FREE_TEXT;
  ArrowPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TNewTransactionForm.ClearFields;
begin
  AddressEdit.Text := '';
  TokenEdit.Text := '';
end;

procedure TNewTransactionForm.FormCreate(Sender: TObject);
begin
  Notifyer.Subscribe(UpdateBalances, nOnAcceptTransfers);
  SetLength(Tokens, 0);
  PrevVol := '';
  GoTransRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  GoTransRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  TransactionsLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  TransactionsLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  MyAddressLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  MyAddressLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  RelogLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  RelogLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
end;

procedure TNewTransactionForm.FormDestroy(Sender: TObject);
begin
  SetLength(Tokens, 0);
end;

procedure TNewTransactionForm.FormShow(Sender: TObject);
begin
  Index := 0;
  BalanceLabel.Visible := False;
  TokensListBox.BeginUpdate;
  TokensListBox.Clear;
  TokensListBox.EndUpdate;
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_GET_BALANCES, [], SetBalances);
  if not TokenNameLabel.Text.IsEmpty then
    TokenEdit.SetFocus;
end;

procedure TNewTransactionForm.GoTransRectangleClick(Sender: TObject);
begin
  if TokenEdit.Text.IsEmpty or (StrToFloat(TokenEdit.Text.Replace('.', ',')) = 0) then
    ShowMessage('Количество должно быть больше нуля')
  else if (AddressEdit.Text.IsEmpty) then
    ShowMessage('Адрес получателя пуст')
  else
    AppCore.ShowForm(ord(fApproveTrx), [Trim(TokenNameLabel.Text), AddressEdit.Text, TokenEdit.Text.Replace('.', ',')]);
end;

procedure TNewTransactionForm.MyAddressLayoutClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fMyAddress), [])
end;

procedure TNewTransactionForm.TokenEditChangeTracking(Sender: TObject);
begin
  if (TokenEdit.Text.IndexOf('.') <> TokenEdit.Text.LastIndexOf('.')) or
  ((Length(TokenEdit.Text) = 1) and TokenEdit.Text.StartsWith('.')) then
  begin
    TokenEdit.Text := PrevVol;
    exit;
  end
  else
    PrevVol := TokenEdit.Text;

  if not TokenEdit.Text.IsEmpty then
    if StrToFloat(TokenEdit.Text.Replace('.', ',')) > Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag].Balance
    then
      TokenEdit.Text := Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag].Balance.ToString;
end;

procedure TNewTransactionForm.EnterKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    GoTransRectangleClick(nil);
end;

procedure TNewTransactionForm.TokenEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ArrowColorAnimation.Start;
end;

procedure TNewTransactionForm.TokenEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  ArrowColorAnimation.Inverse := True;
  ArrowColorAnimation.Start;
end;

procedure TNewTransactionForm.UpdateBalances;
begin
  TokensListBox.BeginUpdate;
  TokensListBox.Clear;
  TokensListBox.EndUpdate;
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_GET_BALANCES, [], SetBalances);
end;

procedure TNewTransactionForm.TokensListBoxChange(Sender: TObject);
begin
  TokenNameLabel.Text := TokensListBox.Items[TokensListBox.ItemIndex];
  BalanceLabel.Text := 'Balance ' + Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag].Balance.ToString.Replace
  (',', '.') + ' ' + TokensListBox.Items[TokensListBox.ItemIndex];
  Index := TokensListBox.ItemIndex;
  BalanceLabel.Visible := True;
end;

procedure TNewTransactionForm.TokensListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  Popup.IsOpen := False;
end;

procedure TNewTransactionForm.OnApplyStyleTokenItem(Sender: TObject);
var
  Item: TListBoxItem;
  TB: TTokenBalance;
  Txt: TText;
begin

  Item := Sender as TListBoxItem;
  TB := Tokens[Item.Tag];

  Item.Text := TB.Name;
  TText(Item.FindStyleResource('balancetext')).Text := (TB.Balance.ToString.Replace(',', '.'));

  if Item.FindStyleResource('text', Txt) then
  begin
    Txt.AutoSize := True;
    Txt.AutoSize := False;
  end;
end;

procedure TNewTransactionForm.OnTokenItemResized(Sender: TObject);
var
  Item: TListBoxItem;
  TB: TTokenBalance;
  Txt: TText;
begin
  Item := Sender as TListBoxItem;
  TB := Tokens[Item.Tag];

  if Item.FindStyleResource('text', Txt) then
  begin
    Txt.AutoSize := True;
    Txt.AutoSize := False;
  end;
end;

procedure TNewTransactionForm.SetBalances(AArgs: TArray<string>);
var
  Counter: Integer;
  Symbol: string;
  Value: real;
begin
  Counter := 0;
  TokensListBox.BeginUpdate;
  SetLength(Tokens, 0);
  if Length(AArgs) > 0 then
  begin
    while Counter < Length(AArgs) do
    begin
      Symbol := AArgs[Counter];
      Inc(Counter);
      Value := StrToFloat(AArgs[Counter]);
      Inc(Counter);
      AddToken(Symbol, Value);
    end;
  end
  else
  begin
    AddToken('ORBC', 0);
  end;
  TokensListBox.EndUpdate;
  TokensListBox.ItemIndex := Index;
  BalanceLabel.Text := 'Balance ' + Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag].Balance.ToString.Replace
  (',', '.') + ' ' + TokensListBox.Items[TokensListBox.ItemIndex];
end;

procedure TNewTransactionForm.TransactionsLayoutClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fTransactionHistory), [Tokens[index].Name]);
end;

end.
