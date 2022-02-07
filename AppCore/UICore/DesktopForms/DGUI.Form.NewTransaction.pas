unit DGUI.Form.NewTransaction;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Hash,
  App.IHandlerCore,
  Translate.Core,
  App.Types,
  App.Meta,
  App.Notifyer,
  App.Globals,
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
  DGUI.Form.Resources,
  DGUI.Form.Base;

type
  TTokenBalance = record
    // ћожешь обозвать как тебе хочетс€ и перекинуть в другой модуль
    Name: String; // ј тут заменить на TSymbol, полагаю
    BalanceStr: String;
    Decimal: UInt64;
  end;

  TNewTransactionForm = class(TBaseForm)
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
    ORBCLabel: TLabel;
    ToStartMiningInfoLabel: TLabel;
    MiningInfoLayout: TLayout;
    MiningInfoLabel1: TLabel;
    MiningInfoLabel2: TLabel;
    ORBCAmountLabel: TLabel;
    NoORBCLabel: TLabel;
    CreateTokenLayout: TLayout;
    CreateTokenLabel: TLabel;
    CreateTokenPath: TPath;
    NFTLayout: TLayout;
    NFTLabel: TLabel;
    NFTPath: TPath;
    LangLayout: TLayout;
    LangLabel: TLabel;
    Path1: TPath;
    LangPopup: TPopup;
    LangListBox: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    LangShadowEffect: TShadowEffect;
    ValidatorLayout: TLayout;
    ValidatorInnerLayout: TLayout;
    Layout1: TLayout;
    IPLabel: TLabel;
    CheckBoxNet: TCheckBox;
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
    procedure RelogLayoutClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure NFTLayoutClick(Sender: TObject);
    procedure CreateTokenLayoutClick(Sender: TObject);
    procedure LangLayoutClick(Sender: TObject);
    procedure LangListBoxChange(Sender: TObject);
    procedure LangListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure FormHide(Sender: TObject);
    procedure AddressEditChangeTracking(Sender: TObject);
    procedure AddressEditTyping(Sender: TObject);
    procedure AddressEditExit(Sender: TObject);
    procedure SwitchCheck(AArgs: TArray<string>);
    procedure CheckBoxNetChange(Sender: TObject);
  private
    SubscribeToken: TBytes;
    Tokens: TArray<TTokenBalance>;
    // Ёто нужно дл€ хранени€ и посто€нной подгрузки информации о балансе токенов
    Index: Integer; // во врем€ прокрутки листбокса
    PrevVol: String;
    ChosenOM, BoughtOM, CtrlV: Boolean;
    procedure AddToken(const AName, AValueStr, ADecimal: String);
    procedure SetBalances(AArgs: TArray<string>);
    procedure UpdateBalances;
    procedure ShowOMBuyField(ChosenOM: Boolean);
    procedure SetText;
    procedure SetLang;
    function CheckORBCBalcane: real;
  public
    procedure ClearFields;
    procedure Return(AArgs: TArray<string>);
  end;

var
  NewTransactionForm: TNewTransactionForm;

implementation

{$R *.fmx}

procedure TNewTransactionForm.AddressEditChangeTracking(Sender: TObject);
begin
  if AddressEdit.Text.Length > 64 then
    AddressEdit.Text := Copy(AddressEdit.Text, 1, 64);
end;

procedure TNewTransactionForm.AddressEditExit(Sender: TObject);
begin
  AddressEdit.SelStart := 0;
  AddressEdit.SelLength := 0;
  CtrlV := False;
end;

procedure TNewTransactionForm.AddressEditTyping(Sender: TObject);
begin
  if CtrlV then
  begin
    AddressEdit.SelStart := 0;
    AddressEdit.SelLength := 0;
    CtrlV := False;
  end;
end;

procedure TNewTransactionForm.AddToken(const AName, AValueStr, ADecimal: String);
var
  Item: TListBoxItem;
  TB: TTokenBalance;
  Txt: TText;
begin
  TB.Name := AName;
  TB.BalanceStr := AValueStr;
  TB.Decimal := StrToUint64(ADecimal);
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
    StyledSettings := [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor, TStyledSetting.Other];
    TextSettings.FontColor := $FF8B8CA7;
    TokensListBox.AddObject(Item);
    Item.NeedStyleLookup;
    Item.ApplyStyleLookup;

    Txt := TText(Item.FindStyleResource('text'));
    Txt.Text := AName;

    Txt := TText(Item.FindStyleResource('balancetext'));
    Txt.Text := AValueStr;

    if (AName = 'OM') and (AValueStr.ToDouble <> 0) then
      BoughtOM := True;
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

procedure TNewTransactionForm.CheckBoxNetChange(Sender: TObject);
begin
  if CheckBoxNet.IsChecked then
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_CHANGE_NET_STATE, ['Validator'], SwitchCheck)
  else
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_DO_CHANGE_NET_STATE, ['FullNode'], SwitchCheck);
end;

function TNewTransactionForm.CheckORBCBalcane: real;
begin
  Result := 0;
  for var Item in Tokens do
    if trim(Item.Name) = 'ORBC' then
    begin
      Result := Item.BalanceStr.ToDouble;
      break;
    end;
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
  CtrlV := False;
end;

procedure TNewTransactionForm.CreateTokenLayoutClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fCreateToken), []);
end;

procedure TNewTransactionForm.FormCreate(Sender: TObject);
begin
  inherited;
  LangListBox.ItemIndex := ord(CurrentLanguage);
  SubscribeToken := THashSha2.GetHashBytes(DateTimeToStr(now));
  Notifyer.Subscribe(UpdateBalances, nOnAcceptTransfers, SubscribeToken);
  SetLength(Tokens, 0);
  PrevVol := '';
  ChosenOM := False;

  GoTransRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  GoTransRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  TransactionsLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  TransactionsLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  MyAddressLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  MyAddressLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  CreateTokenLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  CreateTokenLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  RelogLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  RelogLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  NFTLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  NFTLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  LangLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  LangLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;

  SetNet;
end;

procedure TNewTransactionForm.FormDestroy(Sender: TObject);
begin
  SetLength(Tokens, 0);
  Notifyer.UnSubscribe(SubscribeToken);
end;

procedure TNewTransactionForm.FormHide(Sender: TObject);
begin
  LangPopup.IsOpen := False;
end;

procedure TNewTransactionForm.FormResize(Sender: TObject);
var
  L: TLayout;
begin
  inherited;
  TokenEdit.NeedStyleLookup;
  TokenEdit.ApplyStyleLookup;
  L := TLayout(TokenEdit.FindStyleResource('content'));
  L.Margins.Right := 15;
  L := TLayout(TokenEdit.FindStyleResource('buttons'));
  L.Visible := False;

  AddressEdit.NeedStyleLookup;
  AddressEdit.ApplyStyleLookup;
  L := TLayout(AddressEdit.FindStyleResource('content'));
  L.Margins.Right := 15;
  L := TLayout(AddressEdit.FindStyleResource('buttons'));
  L.Visible := False;
end;

procedure TNewTransactionForm.FormShow(Sender: TObject);
begin
  inherited;
  self.Caption := GetCaption;
  Index := 0;
  BalanceLabel.Visible := False;
  BoughtOM := False;
  TokensListBox.BeginUpdate;
  TokensListBox.Clear;
  TokensListBox.EndUpdate;
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_GET_BALANCES, [], SetBalances);
  if not TokenNameLabel.Text.IsEmpty then
    TokenEdit.SetFocus;
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_CHECK_ACC_BY_MINING, [], Return);
  LangListBox.ItemIndex := LangListBox.Items.IndexOf(LangLabel.Text);
  PayLabel.Text := Trnaslator.GetPhrase(index57, CurrentLanguage);
  TokenEdit.TextPrompt := Trnaslator.GetPhrase(index67, CurrentLanguage);
  FeeLabel.Text := Trnaslator.GetPhrase(index8, CurrentLanguage) + ' 0%';
  AddressLabel.Text := Trnaslator.GetPhrase(index60, CurrentLanguage);
  AddressEdit.TextPrompt := Trnaslator.GetPhrase(index68, CurrentLanguage);
  NoORBCLabel.Text := Trnaslator.GetPhrase(index65, CurrentLanguage);
  ToStartMiningInfoLabel.Text := Trnaslator.GetPhrase(index62, CurrentLanguage);
  MiningInfoLabel1.Text := Trnaslator.GetPhrase(index63, CurrentLanguage);
  MiningInfoLabel2.Text := '';
  GoTransLabel.Text := Trnaslator.GetPhrase(index56, CurrentLanguage);
  TransactionsLabel.Text := Trnaslator.GetPhrase(index61, CurrentLanguage);
  MyAddressLabel.Text := Trnaslator.GetPhrase(index52, CurrentLanguage);
  SetFitLabel(CreateTokenLabel, Trnaslator.GetPhrase(index66, CurrentLanguage));

  LangListBox.ItemIndex := ord(CurrentLanguage);
  SetText;
  // TokensListBox.BeginUpdate;
  // AddToken('ORBC',0.44);
  // AddToken('RTRT',15235);
  // AddToken('OM',0.006464);
  // AddToken('TGU',0.1234);
  // AddToken('COIN',57654);
  // AddToken('TGU',0.1234);
  // AddToken('COIN',57654);
  // TokensListBox.EndUpdate;
end;

procedure TNewTransactionForm.GoTransRectangleClick(Sender: TObject);
begin
  if not ChosenOM then
  begin
    if TokenEdit.Text.IsEmpty or (StrToFloat(TokenEdit.Text.Replace(OldDecimalSeparator, DecimalSeparator)) = 0) then
      ShowMessage(Trnaslator.GetPhrase(index111, CurrentLanguage))
    else if (AddressEdit.Text.IsEmpty) then
      ShowMessage(Trnaslator.GetPhrase(index112, CurrentLanguage))
    else
      AppCore.ShowForm(ord(fApproveTrx), [trim(TokenNameLabel.Text), AddressEdit.Text, TokenEdit.Text.Replace(OldDecimalSeparator,
        DecimalSeparator)]);
  end
  else
  begin
    AppCore.ShowForm(ord(fApproveOM), [trim('ORBC'), AddressEdit.Text.Replace(OldDecimalSeparator, DecimalSeparator),
      TokenEdit.Text.Replace(OldDecimalSeparator, DecimalSeparator)]);
  end;
end;

procedure TNewTransactionForm.LangLayoutClick(Sender: TObject);
begin
  if (LangListBox.Items.Count > 0) then
    LangPopup.IsOpen := not LangPopup.IsOpen;
end;

procedure TNewTransactionForm.LangListBoxChange(Sender: TObject);
begin
  LangLabel.Text := LangListBox.Items[LangListBox.ItemIndex];
  CurrentLanguage := App.Meta.TLanguages(LangListBox.ItemIndex);
  Notifyer.DoEvent(TEvents.nOnSwitchLang);
  SetText;
  SetNet;
end;

procedure TNewTransactionForm.LangListBoxItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  LangPopup.IsOpen := False;
end;

procedure TNewTransactionForm.MyAddressLayoutClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fMyAddress), []);
end;

procedure TNewTransactionForm.NFTLayoutClick(Sender: TObject);
begin
  // NFT
end;

procedure TNewTransactionForm.TokenEditChangeTracking(Sender: TObject);
var
  x,y,z: Integer;
begin
  if Pos('.', TokenEdit.Text) <> 0 then
    TokenEdit.MaxLength := 19
  else
    TokenEdit.MaxLength := 18;

  if TokenNameLabel.Text = 'OM' then
  begin
    if Tokens[Length(Tokens) - 1].BalanceStr.ToDouble = 1 then
      TokenEdit.Text := '0'
    else
      TokenEdit.Text := '1';
  end
  else
  begin
    if (TokenEdit.Text.IndexOf('.') <> TokenEdit.Text.LastIndexOf('.')) or ((Length(TokenEdit.Text) = 1) and TokenEdit.Text.StartsWith('.')) then
    begin
      TokenEdit.Text := PrevVol;
      exit;
    end
    else
    begin
      x := TokenEdit.Text.IndexOf('.');
      y := Length(TokenEdit.Text) - 2;
      z := Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag].Decimal;
      if (x <> - 1) then
        if (z > 0) then
        begin
          if (x > (y - z)) then
            PrevVol := TokenEdit.Text
          else
          begin
            TokenEdit.Text := PrevVol;
            exit;
          end;
        end else
          TokenEdit.Text := Copy(TokenEdit.Text, 2, Length(TokenEdit.Text));
//      PrevVol := TokenEdit.Text;
    end;

    if not TokenEdit.Text.IsEmpty then
      if StrToFloat(TokenEdit.Text.Replace(OldDecimalSeparator, DecimalSeparator)) > Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag].BalanceStr.ToDouble
      then
        TokenEdit.Text := Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag].BalanceStr.Replace(',', '.');

    if (Length(TokenEdit.Text) > 1) and (TokenEdit.Text.StartsWith('0')) then
      if (TokenEdit.Text[2] = '0') or (not(TokenEdit.Text[2] = '.')) then
        TokenEdit.Text := Copy(TokenEdit.Text, 2, Length(TokenEdit.Text));

//    if TokenEdit.Text.IndexOf('.') <> -1 then
//    begin


//    end;
  end;
end;

procedure TNewTransactionForm.EnterKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    GoTransRectangleClick(nil);
  CtrlV := ((ssCtrl in Shift) and (Key = vkV))
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
  BalanceLabel.Text := Trnaslator.GetPhrase(index58, CurrentLanguage) + ' ' + Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag]
    .BalanceStr.Replace(',', '.') + ' ' + TokensListBox.Items[TokensListBox.ItemIndex];
  Index := TokensListBox.ItemIndex;
  BalanceLabel.Visible := True;

  ChosenOM := TokenNameLabel.Text = 'OM';
  ShowOMBuyField(ChosenOM);
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
  TText(Item.FindStyleResource('balancetext')).Text := (TB.BalanceStr.Replace(',', '.'));
  //
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

procedure TNewTransactionForm.RelogLayoutClick(Sender: TObject);
begin
  //
  AppCore.ShowForm(ord(fLogin), []);
  //
end;

procedure TNewTransactionForm.Return(AArgs: TArray<string>);
begin
  // if AArgs[1] = 'Validator' then
  // ValidSwitch.IsChecked := True
  // else
  // ValidSwitch.IsChecked := False;
  // if AArgs[0] = 'OK' then
  // ValidSwitch.Enabled := True
  // else
  // ValidSwitch.Enabled := False;
end;

procedure TNewTransactionForm.ShowOMBuyField(ChosenOM: Boolean);
begin
  self.BeginUpdate;
  if ChosenOM then
  begin
    AddressEdit.FilterChar := '';

    if not BoughtOM then
    begin
      AddressLabel.Text := Trnaslator.GetPhrase(index2, CurrentLanguage);
      AddressEdit.TextPrompt := '';
      AddressEdit.TextSettings.HorzAlign := TTextAlign.Trailing;
      TokenEdit.Text := '1';
      AddressEdit.Text := '10000';
      GoTransRectangle.SetFocus;
    end
    else
    begin

    end;

    if (CheckORBCBalcane < 10000) then
    begin
      NoORBCLabel.Visible := True;
      GoTransRectangle.Enabled := False;
    end
    else
    begin
      NoORBCLabel.Visible := False;
      GoTransRectangle.Enabled := True;
    end;

    if (NoORBCLabel.Visible) and (Tokens[Length(Tokens) - 1].BalanceStr.ToDouble = 1) then
      NoORBCLabel.Visible := False;

    AddressEdit.ResetFocus;
  end
  else
  begin
    AddressEdit.FilterChar := '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    AddressLabel.Text := Trnaslator.GetPhrase(index60, CurrentLanguage);
    AddressEdit.TextPrompt := Trnaslator.GetPhrase(index68, CurrentLanguage);
    AddressEdit.TextSettings.HorzAlign := TTextAlign.Leading;
    AddressEdit.Text := '';
    TokenEdit.Text := '';
    GoTransRectangle.Enabled := True;
    NoORBCLabel.Visible := False;
  end;
  TokenEdit.ReadOnly := ChosenOM and BoughtOM;
  ORBCLabel.Visible := ChosenOM and not BoughtOM;
  FeePath.Visible := not ChosenOM;
  FeeLabel.Visible := FeePath.Visible;
  ToStartMiningInfoLabel.Visible := ORBCLabel.Visible;
  AddressEdit.HitTest := not ORBCLabel.Visible;

  MiningInfoLayout.Visible := ChosenOM and BoughtOM;
  AddressLayout.Visible := not MiningInfoLayout.Visible;
  GoTransRectangle.Visible := AddressLayout.Visible;
  self.EndUpdate;
end;

procedure TNewTransactionForm.SwitchCheck(AArgs: TArray<string>);
begin
  CheckBoxNet.Text := AArgs[1];
  if AArgs[0] = 'BAD' then
  begin
    if CheckBoxNet.IsChecked then
      CheckBoxNet.IsChecked := False;
    ShowMessage(AArgs[2]);
  end;

end;

procedure TNewTransactionForm.SetBalances(AArgs: TArray<string>);
var
  Counter: Integer;
  Symbol, ValueStr, DecimalStr: string;
  Value: real;
begin
  Counter := 0;
  TokensListBox.BeginUpdate;
  SetLength(Tokens, 0);
  if Length(AArgs) > 0 then
  begin
    while Counter < Length(AArgs) do
    begin
      Symbol := Trim(AArgs[Counter]);
      Inc(Counter);
      ValueStr := StringReplace(AArgs[Counter], OldDecimalSeparator, DecimalSeparator, [rfReplaceAll]);
      Inc(Counter);
      DecimalStr := AArgs[Counter];
      Inc(Counter);
      AddToken(Symbol, ValueStr, DecimalStr);
    end;
  end;
  // ќм всегда должен быть в списке, даже если баланс его равен нулю
  TokensListBox.EndUpdate;
  TokensListBox.ItemIndex := Index;
  BalanceLabel.Text := Trnaslator.GetPhrase(index58, CurrentLanguage) + ' ' + Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag]
    .BalanceStr.Replace(',', '.') + ' ' + TokensListBox.Items[TokensListBox.ItemIndex];
  // if self.Visible then
  // TThread.Synchronize(nil,procedure begin ShowMessage('Receive Balances'); end);
end;

procedure TNewTransactionForm.SetLang;
begin
  LangListBox.ItemIndex := ord(CurrentLanguage);
end;

procedure TNewTransactionForm.SetText;
begin
  PayLabel.Text := Trnaslator.GetPhrase(index57, CurrentLanguage);
  TokenEdit.TextPrompt := Trnaslator.GetPhrase(index67, CurrentLanguage);
  FeeLabel.Text := Trnaslator.GetPhrase(index8, CurrentLanguage) + ' 0%';
  AddressLabel.Text := Trnaslator.GetPhrase(index60, CurrentLanguage);
  AddressEdit.TextPrompt := Trnaslator.GetPhrase(index68, CurrentLanguage);
  NoORBCLabel.Text := Trnaslator.GetPhrase(index65, CurrentLanguage);
  ToStartMiningInfoLabel.Text := Trnaslator.GetPhrase(index62, CurrentLanguage);
  MiningInfoLabel1.Text := Trnaslator.GetPhrase(index63, CurrentLanguage);
  MiningInfoLabel2.Text := '';
  GoTransLabel.Text := Trnaslator.GetPhrase(index56, CurrentLanguage);
  TransactionsLabel.Text := Trnaslator.GetPhrase(index61, CurrentLanguage);
  MyAddressLabel.Text := Trnaslator.GetPhrase(index52, CurrentLanguage);
  CreateTokenLabel.Text := Trnaslator.GetPhrase(index66, CurrentLanguage);
  if NodeState = FullNode then
    CheckBoxNet.Text := Trnaslator.GetPhrase(index131, CurrentLanguage);

  if NodeState = Validator then
    CheckBoxNet.Text := Trnaslator.GetPhrase(index132, CurrentLanguage);

  MiningInfoLabel1.Text := Trnaslator.GetPhrase(index127, CurrentLanguage);;

  if TokensListBox.Count > 0 then
    BalanceLabel.Text := Trnaslator.GetPhrase(index58, CurrentLanguage) + ' ' + Tokens[TokensListBox.ListItems[TokensListBox.ItemIndex].Tag]
      .BalanceStr.Replace(',', '.') + ' ' + TokensListBox.Items[TokensListBox.ItemIndex];
end;

procedure TNewTransactionForm.TransactionsLayoutClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fTransactionHistory), [Tokens[index].Name]);
end;

end.
