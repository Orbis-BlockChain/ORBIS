unit DGUI.Form.Transactions;

interface

uses
  System.Hash,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Math,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.DateUtils,
  Translate.Core,
  App.Types,
  App.Notifyer,
  App.Globals,
  App.Meta,
  App.IHandlerCore,
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
  FMX.ListBox,
  DGUI.Form.Resources,
  DGUI.Form.Base,
  FMX.Ani,
  FMX.Edit,
  UI.GUI.Types,
  UI.Animated,
  FMX.Effects, FMX.MultiView, FMX.DateTimeCtrls, FMX.Calendar;

type
  TTransHistory = record
    Date, Address, Address2, Token, Volume, Hash: string;
  end;

  TTransactionsForm = class(TBaseForm)
    TransactionsLabel: TLabel;
    Line: TLine;
    TransactionsListBox: TListBox;
    ShowFilterLayout: TLayout;
    OrderLayout: TLayout;
    OrderPath: TPath;
    FilterAnimation: TFloatAnimation;
    FilterPanelLayout: TLayout;
    CurrencyLabel: TLabel;
    TransTypeLabel: TLabel;
    TokenEdit: TEdit;
    CurrencyArrowPath: TPath;
    TransTypeEdit: TEdit;
    TransTypeArrowPath: TPath;
    TLBPopup: TPopup;
    TokensListBox: TListBox;
    TokensShadowEffect: TShadowEffect;
    TTPopup: TPopup;
    TransTypeListBox: TListBox;
    TransTypeShadowEffect: TShadowEffect;
    FilterAnimation2: TFloatAnimation;
    FromDateEdit: TDateEdit;
    ToDateEdit: TDateEdit;
    FromToLine: TLine;
    DateLabel: TLabel;
    SearchLayout: TLayout;
    SearchPath: TPath;
    ShowSearchLayout: TLayout;
    SearchAnimation: TFloatAnimation;
    SearchAnimation2: TFloatAnimation;
    SearchPanelLayout: TLayout;
    SearchLabel: TLabel;
    SearchEdit: TEdit;
    ClearEditLayout: TLayout;
    ClearEditPath: TPath;
    TransNotFoundLabel: TLabel;
    SortByLabel: TLabel;
    SortByEdit: TEdit;
    SortByArrowPath: TPath;
    SortByPopup: TPopup;
    SortByListBox: TListBox;
    SortByShadowEffect: TShadowEffect;
    OrderByEdit: TEdit;
    OrderByArrowPath: TPath;
    OrderByLabel: TLabel;
    OrderByPopup: TPopup;
    OrderByListBox: TListBox;
    OrderShadowEffect: TShadowEffect;
    ClearFromEditPath: TPath;
    ClearFromDateLayout: TLayout;
    ClearToDateLayout: TLayout;
    ClearToDatePath: TPath;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnApplyStyleTransItem(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TokenEditMouseEnter(Sender: TObject);
    procedure TokenEditMouseLeave(Sender: TObject);
    procedure TransTypeEditMouseEnter(Sender: TObject);
    procedure TransTypeEditMouseLeave(Sender: TObject);
    procedure TokenEditClick(Sender: TObject);
    procedure TokensListBoxItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure FormHide(Sender: TObject);
    procedure TransTypeEditClick(Sender: TObject);
    procedure TransTypeListBoxItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure FilterAnimationFinish(Sender: TObject);
    procedure FilterAnimation2Finish(Sender: TObject);
    procedure OrderLayoutClick(Sender: TObject);
    procedure FromDateEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ToDateEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ToDateEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FromDateEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FromDateEditChange(Sender: TObject);
    procedure ToDateEditChange(Sender: TObject);
    procedure SearchLayoutClick(Sender: TObject);
    procedure SearchAnimationFinish(Sender: TObject);
    procedure SearchAnimation2Finish(Sender: TObject);
    procedure SearchEditChangeTracking(Sender: TObject);
    procedure ClearEditLayoutClick(Sender: TObject);
    procedure SortByListBoxItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure SortByEditClick(Sender: TObject);
    procedure SortByEditMouseEnter(Sender: TObject);
    procedure SortByEditMouseLeave(Sender: TObject);
    procedure OrderByEditClick(Sender: TObject);
    procedure OrderByEditMouseEnter(Sender: TObject);
    procedure OrderByEditMouseLeave(Sender: TObject);
    procedure OrderByListBoxItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure ClearFromDateLayoutClick(Sender: TObject);
    procedure ClearToDateLayoutClick(Sender: TObject);
  private
    History: TArray<TTransHistory>;
    SubscribeToken: TBytes;
    CurrentToken: String;
    procedure SetTransfers(args: TArray<string>);
    procedure AcceptCC;
    procedure ItemOnCLick(Sender: TObject);
    procedure SetText;
    procedure DoUpdateText;
    procedure AddString(const AName: String; AListBox: TListBox);
    procedure FillTransList;
    function GetTokenIndexByName(AName: String): Integer;
  public
    Address: string;
    Token: string;
    Handler: IBaseHandler;
    procedure AddTransaction(ADate, AAddress, Address2, AToken, AVolume, AHash: string; ATag: Integer);
  end;

var
  TransactionsForm: TTransactionsForm;

implementation

{$R *.fmx}

procedure TTransactionsForm.AcceptCC;
begin
  if Self.Visible then
    Handler.HandleGUICommand(CMD_GUI_TRANSACTION_HISTORY, ['0'], SetTransfers);
end;

procedure TTransactionsForm.AddString(const AName: String; AListBox: TListBox);
var
  Item: TListBoxItem;
  Txt: TText;
begin
  Item := TListBoxItem.Create(AListBox);
  with Item do
  begin
    Name := 'StrListItem' + AListBox.Items.Count.ToString;
    Item.Tag := AListBox.Items.Count;
    Item.Height := AListBox.ItemHeight;
    StyledSettings := [];
    TextSettings.FontColor := $FF8B8CA7;
    TextSettings.Font.Size := 14;
    TextSettings.Font.Family := 'Roboto';
    StyleLookup := 'TransHistoryListBoxItemstyle';
    Item.NeedStyleLookup;
    Item.ApplyStyleLookup;
    AListBox.AddObject(Item);

    Item.Text := Trim(AName);
  end;
end;

procedure TTransactionsForm.AddTransaction(ADate, AAddress, Address2, AToken, AVolume, AHash: string; ATag: Integer);
var
  Item: TListBoxItem;
  Txt: TText;
  FS: TFormatSettings;
begin
  FS.DateSeparator := '.';
  FS.TimeSeparator := ':';
  FS.ShortDateFormat := 'dd.mm.yy/hh:mm:ss';

  Item := TListBoxItem.Create(TransactionsListBox);
  with Item do
  begin
    Name := 'ListItem' + TransactionsListBox.Items.Count.ToString;
    Item.StyleLookup := 'TransInfoListBoxItemStyle';
    Item.Tag := ATag;
    Item.Height := TransactionsListBox.ItemHeight;

    Item.OnApplyStyleLookup := OnApplyStyleTransItem;
    StyledSettings := [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor,
    TStyledSetting.Other];
    TextSettings.FontColor := $FF525A64;

    TransactionsListBox.AddObject(Item);
    Item.NeedStyleLookup;
    Item.ApplyStyleLookup;
    OnClick := ItemOnCLick;
  end;
end;

procedure TTransactionsForm.ClearEditLayoutClick(Sender: TObject);
begin
  inherited;
  SearchEdit.Text := '';
end;

procedure TTransactionsForm.ClearFromDateLayoutClick(Sender: TObject);
begin
  inherited;
  FromDateEdit.Text := '__.__.____';
  FromDateEdit.OnChange(nil);
end;

procedure TTransactionsForm.ClearToDateLayoutClick(Sender: TObject);
begin
  inherited;
  ToDateEdit.Text := '__.__.____';
  ToDateEdit.OnChange(nil);
end;

procedure TTransactionsForm.DoUpdateText;
begin
  SetNet;
  SetText;
end;

procedure TTransactionsForm.OnApplyStyleTransItem(Sender: TObject);
var
  Item: TListBoxItem;
  TH: TTransHistory;
  Txt: TText;
  Lbl: TLabel;
  Pth: TPath;
begin
  Item := Sender as TListBoxItem;
  TH := History[Item.Tag];
  if Item.FindStyleResource('DateTimeLabel',Lbl) then
    Lbl.Text := TH.Date;
  Item.Text := TH.Address;
  if Item.FindStyleResource('VolumeText',Txt) then
    if (TH.Volume.ToExtended > 0) then
      Txt.Text := '+' + TH.Volume.Replace(OldDecimalSeparator, DecimalSeparator) + ' ' + TH.Token
    else
      Txt.Text := TH.Volume.Replace(OldDecimalSeparator, DecimalSeparator) + ' ' + TH.Token;
  if (TH.Volume.ToExtended < 0) then
  begin
    if Item.FindStyleResource('ImagePath',Pth) then
    begin
      Pth.Data.Data := SVG_OUTGOING_TRANS;
      Pth.Fill.Color := $FFEB5E6C;
    end;
    if Item.FindStyleResource('VolumeText',Txt) then
      Txt.TextSettings.FontColor := $FFEB5E6C;
  end;
end;

procedure TTransactionsForm.OrderByEditClick(Sender: TObject);
begin
  inherited;
  if OrderByListBox.Items.Count > 0 then
    OrderByPopup.IsOpen := not OrderByPopup.IsOpen;
end;

procedure TTransactionsForm.OrderByEditMouseEnter(Sender: TObject);
begin
  inherited;
  OrderByArrowPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TTransactionsForm.OrderByEditMouseLeave(Sender: TObject);
begin
  inherited;
  OrderByArrowPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TTransactionsForm.OrderLayoutClick(Sender: TObject);
begin
  inherited;
  ShowFilterLayout.Visible := True;
  FilterAnimation.StopAtCurrent;
  FilterAnimation2.StopAtCurrent;
  FilterAnimation.Enabled := True;
  FilterAnimation2.Enabled := True;

  if SearchPath.Tag = 1 then
    SearchLayout.OnClick(nil);

  if OrderPath.Tag = 0 then
  begin
    OrderPath.Tag := 1;
    OrderPath.Data.Data := SVG_CLOSE;
  end else
  begin
    OrderPath.Tag := 0;
    OrderPath.Data.Data := SVG_OPEN_FILTER;
  end;
end;

procedure TTransactionsForm.OrderByListBoxItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  inherited;
  OrderByEdit.Text := OrderByListBox.Items[OrderByListBox.ItemIndex];
  OrderByPopup.IsOpen := False;

  SearchEdit.Text := '';

  if Self.Visible then
    Handler.HandleGUICommand(CMD_GUI_TRANSACTION_HISTORY, ['0'], SetTransfers);
end;

procedure TTransactionsForm.SearchAnimation2Finish(Sender: TObject);
begin
  inherited;
  SearchAnimation2.Enabled := False;
  SearchAnimation2.Inverse := not SearchAnimation2.Inverse;
  ShowSearchLayout.Visible := SearchAnimation2.Inverse;
end;

procedure TTransactionsForm.SearchAnimationFinish(Sender: TObject);
begin
  inherited;
  SearchAnimation.Enabled := False;
  SearchAnimation.Inverse := not SearchAnimation.Inverse;
end;

procedure TTransactionsForm.SearchEditChangeTracking(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  TransactionsListBox.BeginUpdate;
  try
    TransactionsListBox.Clear;
    if not SearchEdit.Text.IsEmpty then
    begin
      for i := 0 to Length(History) - 1 do
        if Trim(History[i].Hash) = SearchEdit.Text then
        begin
          AddTransaction(History[i].Date, History[i].Address, History[i].Address2,
              History[i].Token, History[i].Volume, History[i].Hash, i);
          break;
        end;
    end else
      FillTransList;
    TransNotFoundLabel.Visible := TransactionsListBox.Items.Count = 0;
  finally
    TransactionsListBox.EndUpdate;
  end;
end;

procedure TTransactionsForm.SearchLayoutClick(Sender: TObject);
begin
  inherited;

  ShowSearchLayout.Visible := True;
  SearchAnimation.StopAtCurrent;
  SearchAnimation2.StopAtCurrent;
  SearchAnimation.Enabled := True;
  SearchAnimation2.Enabled := True;

  if OrderPath.Tag = 1 then
    OrderLayout.OnClick(nil);

  if SearchPath.Tag = 0 then
  begin
    SearchPath.Tag := 1;
    SearchPath.Data.Data := SVG_CLOSE;
    SearchEdit.SetFocus;
  end else
  begin
    SearchPath.Tag := 0;
    SearchPath.Data.Data := SVG_OPEN_SEARCH;
  end;
end;

procedure TTransactionsForm.SetText;
begin
  TransactionsLabel.Text := Trnaslator.GetPhrase(index115, CurrentLanguage);
  TokensListBox.Items[0] := Trnaslator.GetPhrase(index135, CurrentLanguage);
  TransTypeListBox.Items[0] := Trnaslator.GetPhrase(index135, CurrentLanguage);
  TransTypeListBox.Items[1] := Trnaslator.GetPhrase(index136, CurrentLanguage);
  TransTypeListBox.Items[2] := Trnaslator.GetPhrase(index137, CurrentLanguage);
  SortByListBox.Items[0] := Trnaslator.GetPhrase(index139, CurrentLanguage);
  SortByListBox.Items[1] := Trnaslator.GetPhrase(index91, CurrentLanguage);
  SortByListBox.Items[2] := Trnaslator.GetPhrase(index81, CurrentLanguage);
  OrderByListBox.Items[0] := Trnaslator.GetPhrase(index144, CurrentLanguage);
  OrderByListBox.Items[1] := Trnaslator.GetPhrase(index145, CurrentLanguage);

  TransNotFoundLabel.Text := Trnaslator.GetPhrase(index142, CurrentLanguage);
  SearchLabel.Text := Trnaslator.GetPhrase(index140, CurrentLanguage);
  TokenEdit.Text := Trim(TokensListBox.Items[TokensListBox.ItemIndex]);
  TransTypeEdit.Text := TransTypeListBox.Items[TransTypeListBox.ItemIndex];
  SortByEdit.Text := SortByListBox.Items[TransTypeListBox.ItemIndex];
  OrderByEdit.Text := OrderByListBox.Items[OrderByListBox.ItemIndex];
  CurrencyLabel.Text := Trnaslator.GetPhrase(index138, CurrentLanguage);
  TransTypeLabel.Text := Trnaslator.GetPhrase(index77, CurrentLanguage);
  DateLabel.Text := Trnaslator.GetPhrase(index139, CurrentLanguage);
  SortByLabel.Text := Trnaslator.GetPhrase(index143, CurrentLanguage);
  OrderByLabel.Text := Trnaslator.GetPhrase(index146, CurrentLanguage);
end;

procedure TTransactionsForm.SetTransfers(args: TArray<string>);
var
  Counter, i: integer;
  TH: TTransHistory;
  LBI: TListBoxItem;
begin
  History := [];
  TransactionsListBox.Clear;

  TokensListBox.BeginUpdate;
  try
    for i := 1 to TokensListBox.Items.Count - 1 do
    begin
      LBI := TokensListBox.ItemByIndex(1);
      LBI.Parent := nil;
      LBI.Free;
    end;
  finally
    TokensListBox.EndUpdate;
  end;

  TransactionsListBox.BeginUpdate;
  try
    Counter := Length(args) - 1;
    while Counter >= 0 do
    begin
      var
      Hash := args[Counter];
      dec(Counter);
      var
      UnixTime := args[Counter];
      dec(Counter);
      var
      Token := args[Counter];
      dec(Counter);
      var
      Amount := args[Counter].Replace(OldDecimalSeparator, DecimalSeparator);
      dec(Counter);
      var
      DirectTo := args[Counter];
      dec(Counter);
      var
      DirectFrom := args[Counter];
      dec(Counter);

      if (TokensListBox.Items.IndexOf(Trim(Token)) = -1) then
        AddString(Token,TokensListBox);

      TH.Date := UnixTime;
      TH.Token := Token;
      TH.Volume := Amount.Replace(OldDecimalSeparator,DecimalSeparator);
      TH.Hash := Hash;

      if StrToFloat(Amount) > 0 then
      begin
        TH.Address := DirectFrom;
        TH.Address2 := DirectTo;
      end else
      begin
        TH.Address := DirectTo;
        TH.Address2 := DirectFrom;
      end;

      History := History + [TH];
    end;
    TokensListBox.ItemIndex := GetTokenIndexByName(CurrentToken);

    case SortByListBox.ItemIndex of
      0: TArray.Sort<TTransHistory>(History, TComparer<TTransHistory>.Construct(
         function(const Left,Right: TTransHistory): Integer
         begin
           Result := CompareValue(DateTimeToUnix(StrToDateTime(Left.Date)), DateTimeToUnix(StrToDateTime(Right.Date)));
           if OrderByListBox.ItemIndex = 0 then
             Result := -1 * Result;
         end));

      1: TArray.Sort<TTransHistory>(History, TComparer<TTransHistory>.Construct(
         function(const Left,Right: TTransHistory): Integer
         begin
           Result := -CompareText(Trim(Left.Token), Trim(Right.Token));
           if OrderByListBox.ItemIndex = 0 then
             Result := -1 * Result;
         end));

      2: TArray.Sort<TTransHistory>(History, TComparer<TTransHistory>.Construct(
         function(const Left,Right: TTransHistory): Integer
         begin
           Result := CompareValue(StrToFloat(Left.Volume), StrToFloat(Right.Volume));
           if OrderByListBox.ItemIndex = 0 then
             Result := -1 * Result;
         end));
    end;

    FillTransList;
  finally
    TransactionsListBox.EndUpdate;
  end;
end;

procedure TTransactionsForm.SortByEditClick(Sender: TObject);
begin
  inherited;
  if SortByListBox.Items.Count > 0 then
    SortByPopup.IsOpen := not SortByPopup.IsOpen;
end;

procedure TTransactionsForm.SortByEditMouseEnter(Sender: TObject);
begin
  inherited;
  SortByArrowPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TTransactionsForm.SortByEditMouseLeave(Sender: TObject);
begin
  inherited;
  SortByArrowPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TTransactionsForm.SortByListBoxItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  inherited;
  SortByEdit.Text := SortByListBox.Items[SortByListBox.ItemIndex];
  SortByPopup.IsOpen := False;

  SearchEdit.Text := '';

  if Self.Visible then
    Handler.HandleGUICommand(CMD_GUI_TRANSACTION_HISTORY, ['0'], SetTransfers);
end;

procedure TTransactionsForm.ToDateEditChange(Sender: TObject);
begin
  inherited;
  if FromDateEdit.Text <> '__.__.____' then
  begin
    if DateTimeToUnix(ToDateEdit.DateTime) < DateTimeToUnix(FromDateEdit.DateTime) then
      ToDateEdit.DateTime := FromDateEdit.DateTime;
  end;
  SearchEdit.Text := '';

  try
    TransactionsListBox.BeginUpdate;
    TransactionsListBox.Clear;
    FillTransList;
  finally
    TransactionsListBox.EndUpdate;
  end;
end;

procedure TTransactionsForm.ToDateEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    ToDateEdit.OnExit(nil);
end;

procedure TTransactionsForm.ToDateEditMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if not ToDateEdit.IsPickerOpened then
    ToDateEdit.OpenPicker;
end;

procedure TTransactionsForm.TokenEditClick(Sender: TObject);
begin
  inherited;
  if TokensListBox.Items.Count > 0 then
  begin
    TLBPopup.Height := Min(366, TokensListBox.Items.Count * TokensListBox.ItemHeight + 16);
    TLBPopup.IsOpen := not TLBPopup.IsOpen;
  end;
end;

procedure TTransactionsForm.TokenEditMouseEnter(Sender: TObject);
begin
  inherited;
  CurrencyArrowPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TTransactionsForm.TokenEditMouseLeave(Sender: TObject);
begin
  inherited;
  CurrencyArrowPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TTransactionsForm.TokensListBoxItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  inherited;
  CurrentToken := Trim(TokensListBox.Items[TokensListBox.ItemIndex]);
  TokenEdit.Text := Trim(TokensListBox.Items[TokensListBox.ItemIndex]);
  TLBPopup.IsOpen := False;

  SearchEdit.Text := '';

  if Self.Visible then
    Handler.HandleGUICommand(CMD_GUI_TRANSACTION_HISTORY, ['0'], SetTransfers);
end;

procedure TTransactionsForm.TransTypeEditClick(Sender: TObject);
begin
  inherited;
  if TransTypeListBox.Items.Count > 0 then
    TTPopup.IsOpen := not TTPopup.IsOpen;
end;

procedure TTransactionsForm.TransTypeEditMouseEnter(Sender: TObject);
begin
  inherited;
  TransTypeArrowPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TTransactionsForm.TransTypeEditMouseLeave(Sender: TObject);
begin
  inherited;
  TransTypeArrowPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TTransactionsForm.TransTypeListBoxItemClick(
  const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  inherited;
  TransTypeEdit.Text := TransTypeListBox.Items[TransTypeListBox.ItemIndex];
  TTPopup.IsOpen := False;

  SearchEdit.Text := '';

  if Self.Visible then
    Handler.HandleGUICommand(CMD_GUI_TRANSACTION_HISTORY, ['0'], SetTransfers);
end;

procedure TTransactionsForm.FillTransList;
var
  i: UInt64;
  FDate,FromDate,ToDate: Int64;
  Passed: Boolean;
begin

  if FromDateEdit.Text = '__.__.____' then
    FromDate := 0
  else
    FromDate := DateTimeToUnix(StrToDateTime(FromDateEdit.Text));
  if ToDateEdit.Text = '__.__.____' then
    ToDate := DateTimeToUnix(IncSecond(Now))
  else
    ToDate := DateTimeToUnix(IncSecond(IncDay(StrToDateTime(ToDateEdit.Text)),-1));

  if Length(History) > 0 then
  for i := 0 to Length(History) - 1 do
  begin
    Passed := False;
    if (TokensListBox.ItemIndex = 0) or (Trim(TokenEdit.Text).ToUpper = Trim(History[i].Token).ToUpper) then
    begin
      case TransTypeListBox.ItemIndex of
        0: begin
             Passed := True;
           end;
        1: begin
             Passed := (Trim(History[i].Volume).ToExtended > 0);
           end;
        2: begin
             Passed := (Trim(History[i].Volume).ToExtended < 0);
           end;
      end;
    end;

    if Passed then
    begin
      FDate := DateTimeToUnix(StrToDateTime(History[i].Date));

      if (FDate >= FromDate) and (ToDate >= FDate) then
        AddTransaction(History[i].Date, History[i].Address, History[i].Address2,
               History[i].Token, History[i].Volume, History[i].Hash, i);
    end;
  end;
  TransNotFoundLabel.Visible := TransactionsListBox.Items.Count = 0;
end;

procedure TTransactionsForm.FilterAnimation2Finish(Sender: TObject);
begin
  inherited;
  FilterAnimation2.Enabled := False;
  FilterAnimation2.Inverse := not FilterAnimation2.Inverse;
  ShowFilterLayout.Visible := FilterAnimation2.Inverse;
end;

procedure TTransactionsForm.FilterAnimationFinish(Sender: TObject);
begin
  inherited;
  FilterAnimation.Enabled := False;
  FilterAnimation.Inverse := not FilterAnimation.Inverse;
end;

procedure TTransactionsForm.FormCreate(Sender: TObject);
begin
  SubscribeToken := THashSha2.GetHashBytes(DateTimeToStr(now));
  Notifyer.Subscribe(AcceptCC, nOnAcceptTransfers,SubscribeToken);
  Notifyer.Subscribe(DoUpdateText, nOnSwitchLang,SubscribeToken);
  SetLength(History, 0);
  SetNet;

  TokensListBox.Clear;
  TransTypeListBox.Clear;
  AddString(Trnaslator.GetPhrase(index135, CurrentLanguage), TokensListBox);
  AddString(Trnaslator.GetPhrase(index135, CurrentLanguage), TransTypeListBox);
  AddString(Trnaslator.GetPhrase(index136, CurrentLanguage), TransTypeListBox);
  AddString(Trnaslator.GetPhrase(index137, CurrentLanguage), TransTypeListBox);
  AddString(Trnaslator.GetPhrase(index139, CurrentLanguage), SortByListBox);
  AddString(Trnaslator.GetPhrase(index91, CurrentLanguage), SortByListBox);
  AddString(Trnaslator.GetPhrase(index81, CurrentLanguage), SortByListBox);
  AddString(Trnaslator.GetPhrase(index144, CurrentLanguage), OrderByListBox);
  AddString(Trnaslator.GetPhrase(index145, CurrentLanguage), OrderByListBox);
  TokensListBox.ItemIndex := 0;
  TransTypeListBox.ItemIndex := 0;
  SortByListBox.ItemIndex := 0;
  OrderByListBox.ItemIndex := 0;
  TransTypeEdit.Text := Trim(TransTypeListBox.Items[TransTypeListBox.ItemIndex]);
  TokenEdit.Text := Trim(TokensListBox.Items[TokensListBox.ItemIndex]);
  SortByEdit.Text := Trim(SortByListBox.Items[SortByListBox.ItemIndex]);
  OrderByEdit.Text := Trim(OrderByListBox.Items[OrderByListBox.ItemIndex]);
  CurrentToken := Trnaslator.GetPhrase(index135, CurrentLanguage);

  SearchLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  SearchLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  ClearEditLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  ClearEditLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  OrderLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  OrderLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  ClearFromDateLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  ClearFromDateLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  ClearToDateLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  ClearToDateLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;

end;

procedure TTransactionsForm.FormDestroy(Sender: TObject);
begin
  SetLength(History, 0);
  Notifyer.UnSubscribe(SubscribeToken);
end;

procedure TTransactionsForm.FormHide(Sender: TObject);
begin
  inherited;
  TLBPopup.IsOpen := False;
  TTPopup.IsOpen := False;
  SortByPopup.IsOpen := False;
  OrderByPopup.IsOpen := False;
  if ShowFilterLayout.Visible then
    OrderLayout.OnClick(nil);
  if ShowSearchLayout.Visible then
  begin
    SearchEdit.Text := '';
    SearchLayout.OnClick(nil);
  end;

  SearchEdit.Text := '';
  TokensListBox.ItemIndex := 0;
  TokenEdit.Text := TokensListBox.Items[TokensListBox.ItemIndex];
  TransTypeListBox.ItemIndex := 0;
  TransTypeEdit.Text := TransTypeListBox.Items[TransTypeListBox.ItemIndex];
  SortByListBox.ItemIndex := 0;
  SortByEdit.Text := SortByListBox.Items[SortByListBox.ItemIndex];
  OrderByListBox.ItemIndex := 0;
  OrderByEdit.Text := OrderByListBox.Items[OrderByListBox.ItemIndex];
  FromDateEdit.Text := '__.__.____';
  ToDateEdit.Text := '__.__.____';
  CurrentToken := '';
end;

procedure TTransactionsForm.FormShow(Sender: TObject);
begin
  self.Caption := GetCaption;
  SetText;
  SetNet;
  Handler.HandleGUICommand(CMD_GUI_TRANSACTION_HISTORY, ['0'], SetTransfers);
end;

procedure TTransactionsForm.FromDateEditChange(Sender: TObject);
begin
  inherited;
  if ToDateEdit.Text <> '__.__.____' then
  begin
    if DateTimeToUnix(FromDateEdit.DateTime) > DateTimeToUnix(ToDateEdit.DateTime) then
      FromDateEdit.DateTime := ToDateEdit.DateTime;
  end;

  SearchEdit.Text := '';

  try
    TransactionsListBox.BeginUpdate;
    TransactionsListBox.Clear;
    FillTransList;
  finally
    TransactionsListBox.EndUpdate;
  end;
end;

procedure TTransactionsForm.FromDateEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    FromDateEdit.OnExit(nil);
end;

procedure TTransactionsForm.FromDateEditMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if not FromDateEdit.IsPickerOpened then
    FromDateEdit.OpenPicker;
end;

function TTransactionsForm.GetTokenIndexByName(AName: String): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to TokensListBox.Items.Count - 1 do
    if TokensListBox.Items[i] = Trim(AName).ToUpper then
    begin
      Result := i;
      exit;
    end;
end;

procedure TTransactionsForm.ItemOnCLick(Sender: TObject);
begin
  var
  Item := Sender as TListBoxItem;
  var
  TH := History[Item.Tag];
  AppCore.ShowForm(ord(fTransaction), [TH.Date, TH.Address, TH.Address2, TH.Token, TH.Volume, TH.Hash])
end;

end.
