unit DGUI.Form.CreateToken;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Hash,
  App.Notifyer,
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
  FMX.Effects;

type
  TCreateTokenForm = class(TForm)
    CapacityEdit: TEdit;
    CapacityLayout: TLayout;
    CapacityText2: TText;
    CapacityText1: TText;
    CapacityText3: TText;
    CapacityLabel: TLabel;
    CostEdit: TEdit;
    ORBCLabel: TLabel;
    CostLabel: TLabel;
    CreateTokenRectangle: TRectangle;
    CreateTokenLabel: TLabel;
    InfoLabel: TLabel;
    MaxEmissionEdit: TEdit;
    MaxEmissionLabel: TLabel;
    SymbolEdit: TEdit;
    SymbolLabel: TLabel;
    TokenNameEdit: TEdit;
    TokenNameLabel: TLabel;
    TopLayout: TLayout;
    HeadLabel: TLabel;
    BackLayout: TLayout;
    BackPath: TPath;
    procedure BackLayoutClick(Sender: TObject);
    procedure CreateTokenRectangleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CapacityEditChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    GoAccept: Boolean;
    SubscribeToken: TBytes;
    procedure GoAnimation;
    procedure GoPaintComponents;
    procedure Return(AArgs: TArray<string>);
    procedure SetData(Args: TArray<string>);
    procedure SetText;
    procedure DoUpdateText;
  public
    procedure CheckBalance(AArgs: TArray<string>);
    { Public declarations }
  end;

var
  CreateTokenForm: TCreateTokenForm;

implementation

{$R *.fmx}

procedure TCreateTokenForm.BackLayoutClick(Sender: TObject);
begin
  BackLayout.Visible := False;
  if GoAccept then
  begin
    GoAccept := False;
    GoAnimation;

    TokenNameEdit.Enabled := True;
    SymbolEdit.Enabled := True;
    SymbolEdit.MaxLength := 4;
    if SymbolEdit.Text.EndsWith('O') then
      SymbolEdit.Text := Copy(SymbolEdit.Text, 1, Length(SymbolEdit.Text) - 1);
    CapacityEdit.Enabled := True;
    MaxEmissionEdit.Enabled := True;
    CostEdit.Enabled := True;
  end;
end;

procedure TCreateTokenForm.Return(AArgs: TArray<string>);
begin
  if AArgs[0] = 'OK' then
    ShowMessage('Congratulations, you have created a ' + TokenNameEdit.Text + ' token with a face value of ' + MaxEmissionEdit.Text)
  else if Length(AArgs) > 1 then
    ShowMessage('Error: ' + AArgs[1])
  else
    ShowMessage('Sorry, your transaction was not completed, please try again later.');

  AppCore.ShowForm(ord(fNewTransaction), []);
  Self.Close;
end;

procedure TCreateTokenForm.SetData(Args: TArray<string>);
begin
  SetText;
end;

procedure TCreateTokenForm.SetText;
begin
  HeadLabel.Text := Trnaslator.GetPhrase(index18, CurrentLanguage);
  TokenNameLabel.Text := Trnaslator.GetPhrase(index90, CurrentLanguage);
  SymbolLabel.Text := Trnaslator.GetPhrase(index91, CurrentLanguage);
  CapacityText1.Text := Trnaslator.GetPhrase(index92, CurrentLanguage);
  CapacityText3.Text := Trnaslator.GetPhrase(index93, CurrentLanguage);
  MaxEmissionLabel.Text := Trnaslator.GetPhrase(index20, CurrentLanguage) + ' ' + Trnaslator.GetPhrase(index120, CurrentLanguage);
  CostLabel.Text := Trnaslator.GetPhrase(index17, CurrentLanguage);
  CreateTokenLabel.Text := Trnaslator.GetPhrase(index3, CurrentLanguage);
  InfoLabel.Text := Trnaslator.GetPhrase(index19, CurrentLanguage);
end;

procedure TCreateTokenForm.CapacityEditChange(Sender: TObject);
begin
  if Trim(CapacityEdit.Text) = '' then
    CapacityEdit.Text := '0';

  MaxEmissionEdit.MaxLength := 18 - CapacityEdit.Text.ToInteger;
end;

procedure TCreateTokenForm.CheckBalance(AArgs: TArray<string>);
begin
  if AArgs[0] = 'OK' then

end;

procedure TCreateTokenForm.CreateTokenRectangleClick(Sender: TObject);
begin
  if Length(Trim(TokenNameEdit.Text)) = 0 then
  begin
    ShowMessage(Trnaslator.GetPhrase(index121, CurrentLanguage));
    exit;
  end;

  if Length(Trim(SymbolEdit.Text)) = 0 then
  begin
    ShowMessage(Trnaslator.GetPhrase(index122, CurrentLanguage));
    exit;
  end;

  if Length(Trim(CapacityEdit.Text)) = 0 then
  begin
    ShowMessage(Trnaslator.GetPhrase(index124, CurrentLanguage));
    exit;
  end;

  if Length(Trim(MaxEmissionEdit.Text)) = 0 then
  begin
    ShowMessage(Trnaslator.GetPhrase(index125, CurrentLanguage));
    exit;
  end;

  try
    if (StrToUInt64(MaxEmissionEdit.Text) = 1) and (CapacityEdit.Text.ToInteger = 0) then
    begin
      ShowMessage(Trnaslator.GetPhrase(index123, CurrentLanguage));
      exit;
    end;
  except
    ShowMessage(Trnaslator.GetPhrase(index123, CurrentLanguage));
    exit;
  end;

  if not GoAccept then
  begin
    BackLayout.Visible := True;
    GoAccept := True;
    GoAnimation;
    CreateTokenRectangle.SetFocus;

    TokenNameEdit.Enabled := False;
    SymbolEdit.Enabled := False;
    SymbolEdit.MaxLength := 5;
    SymbolEdit.Text := SymbolEdit.Text + 'O';
    CapacityEdit.Enabled := False;
    MaxEmissionEdit.Enabled := False;
    CostEdit.Enabled := False;

  end
  else
  begin
    AppCore.GetHandler.HandleGUICommand(CMD_GUI_CREATE_TOKEN_WITH_COMMISSION, [Trim(SymbolEdit.Text), Trim(TokenNameEdit.Text), CapacityEdit.Text,
      MaxEmissionEdit.Text], Return);
  end;
end;

procedure TCreateTokenForm.DoUpdateText;
begin
  SetText;
end;

procedure TCreateTokenForm.GoPaintComponents;
begin
  CapacityText1.AutoSize := True;
  CapacityText3.AutoSize := True;
  CapacityText3.AutoSize := False;
  CapacityText1.AutoSize := False;
end;

procedure TCreateTokenForm.GoAnimation;
var
  FStyleName: String;
  FFontSize: Integer;
  FFontStyles: TFontStyles;
  FEditStyledSetting: TStyledSettings;
  FFontColor: TAlphaColor;
begin
  Self.BeginUpdate;
  case GoAccept of
    True:
      begin
        CapacityText3.Visible := not GoAccept;
        CapacityText2.Visible := not GoAccept;
        CapacityText1.Visible := not GoAccept;
        CapacityLabel.Visible := GoAccept;
        TokenNameLabel.Text := Trnaslator.GetPhrase(index90, CurrentLanguage);
        SymbolLabel.Text := Trnaslator.GetPhrase(index91, CurrentLanguage);
        MaxEmissionLabel.Text := Trnaslator.GetPhrase(index20, CurrentLanguage) + ' ' + Trnaslator.GetPhrase(index120, CurrentLanguage);
        CostLabel.Text := Trnaslator.GetPhrase(index17, CurrentLanguage);
        CreateTokenLabel.Text := Trnaslator.GetPhrase(index3, CurrentLanguage);
        CostEdit.FilterChar := '0123456789';
        CostEdit.Text := CostEdit.Text + ' ORBC';

        FStyleName := 'transparentedit';
        FEditStyledSetting := [TStyledSetting.Style, TStyledSetting.FontColor];
        FFontSize := 23;
        FFontStyles := [TFontStyle.fsBold];
        FFontColor := $FF6C757D;
      end;
    False:
      begin
        CapacityLabel.Visible := GoAccept;
        CapacityText1.Visible := not GoAccept;
        CapacityText2.Visible := not GoAccept;
        CapacityText3.Visible := not GoAccept;
        GoPaintComponents;
        TokenNameLabel.Text := Trnaslator.GetPhrase(index22, CurrentLanguage);
        SymbolLabel.Text := Trnaslator.GetPhrase(index21, CurrentLanguage);
        MaxEmissionLabel.Text := Trnaslator.GetPhrase(index20, CurrentLanguage) + ' ' + Trnaslator.GetPhrase(index120, CurrentLanguage);
        CostLabel.Text := Trnaslator.GetPhrase(index17, CurrentLanguage);
        CreateTokenLabel.Text := Trnaslator.GetPhrase(index18, CurrentLanguage);
        CostEdit.FilterChar := '0123456789';

        FStyleName := 'EditWalletStyle';
        FEditStyledSetting := [TStyledSetting.Style];
        FFontSize := 14;
        FFontStyles := [];
        FFontColor := $FF525A64;
      end;
  end;

  with TokenNameEdit do
  begin
    StyleLookup := FStyleName;
    StyledSettings := FEditStyledSetting;
    HitTest := not GoAccept;
    TextSettings.Font.Size := FFontSize;
    TextSettings.Font.Style := FFontStyles;
    TextSettings.FontColor := FFontColor;
  end;
  with SymbolEdit do
  begin
    StyleLookup := FStyleName;
    StyledSettings := FEditStyledSetting;
    HitTest := not GoAccept;
    TextSettings.Font.Size := FFontSize;
    TextSettings.Font.Style := FFontStyles;
    TextSettings.FontColor := FFontColor;
  end;
  with CapacityEdit do
  begin
    StyleLookup := FStyleName;
    StyledSettings := FEditStyledSetting;
    HitTest := not GoAccept;
    TextSettings.Font.Size := FFontSize;
    TextSettings.Font.Style := FFontStyles;
    TextSettings.FontColor := FFontColor;
  end;
  with MaxEmissionEdit do
  begin
    StyleLookup := FStyleName;
    StyledSettings := FEditStyledSetting;
    HitTest := not GoAccept;
    TextSettings.Font.Size := FFontSize;
    TextSettings.Font.Style := FFontStyles;
    TextSettings.FontColor := FFontColor;
  end;
  with CostEdit do
  begin
    StyleLookup := FStyleName;
    StyledSettings := FEditStyledSetting;
    HitTest := not GoAccept;
    TextSettings.Font.Size := FFontSize;
    TextSettings.Font.Style := FFontStyles;
    TextSettings.FontColor := FFontColor;
  end;

  ORBCLabel.Visible := not GoAccept;
  Self.EndUpdate;
end;

procedure TCreateTokenForm.FormCreate(Sender: TObject);
begin
  GoAccept := False;
  GoPaintComponents;
  BackLayout.OnMouseEnter := TRectAnimations.AnimPathGrayMouseIn;
  BackLayout.OnMouseLeave := TRectAnimations.AnimPathGrayMouseOut;
  CreateTokenRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  CreateTokenRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  Notifyer.Subscribe(DoUpdateText, nOnSwitchLang, SubscribeToken);
end;

procedure TCreateTokenForm.FormDestroy(Sender: TObject);
begin
  Notifyer.UnSubscribe(SubscribeToken);
end;

procedure TCreateTokenForm.FormShow(Sender: TObject);
begin
  Caption := GetCaption;
  TokenNameEdit.Text := '';
  SymbolEdit.Text := '';
  CapacityEdit.Text := '';
  MaxEmissionEdit.Text := '';
  GoAccept := False;
  GoAnimation;
  SymbolEdit.MaxLength := 4;

  TokenNameEdit.Enabled := True;
  SymbolEdit.Enabled := True;
  CapacityEdit.Enabled := True;
  MaxEmissionEdit.Enabled := True;
  CostEdit.Enabled := True;

  SetText;
end;

end.
