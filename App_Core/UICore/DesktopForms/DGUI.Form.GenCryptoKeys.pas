unit DGUI.Form.GenCryptoKeys;

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
  DGUI.Form.Resources,
  UI.Animated,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Ani,
  WebServer.HTTPTypes,
  FMX.TabControl;

type
  TGenCryptoKeysForm = class(TForm)
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    HeadLabel: TLabel;
    KeysMemo: TMemo;
    EnterPassLabel: TLabel;
    LogInRectangle: TRectangle;
    LogInLabel: TLabel;
    Line: TLine;
    BackRectangle: TRectangle;
    BackLabel: TLabel;
    CanNextTimer: TTimer;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    HeadLabel1: TLabel;
    InfoLabel: TLabel;
    IAgreeCheckBox1: TCheckBox;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Path1: TPath;
    TabItem3: TTabItem;
    LogInRectangle2: TRectangle;
    LogInLabel2: TLabel;
    Path2: TPath;
    Label3: TLabel;
    Path4: TPath;
    Label4: TLabel;
    Path3: TPath;
    Label5: TLabel;
    IAgreeCheckBox2: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure LogInRectangleClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BackRectangleClick(Sender: TObject);
    procedure KeysMemoChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure CanNextTimerTimer(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure IAgreeCheckBox1Change(Sender: TObject);
    procedure IAgreeCheckBox2Change(Sender: TObject);
    procedure LogInRectangle2Click(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
  private
    KeysCopied: Boolean;
    Words: String;
    procedure SetWords(AArray: TArray<string>);
    procedure ChangeFormInfo;
  public
    procedure SetData(AArray: TArray<string>);
  end;

var
  GenCryptoKeysForm: TGenCryptoKeysForm;

implementation

{$R *.fmx}

procedure TGenCryptoKeysForm.BackRectangleClick(Sender: TObject);
begin
  case TabControl.TabIndex of
    1:
      begin
        if not KeysCopied then
        begin
          TabControl.TabIndex := 0;
          IAgreeCheckBox1.IsChecked := False;
          BackRectangle.Visible := False;
        end
        else
        begin
          KeysCopied := False;
          ChangeFormInfo;
        end;
      end;
    2:
      begin
        KeysCopied := False;
        ChangeFormInfo;
        IAgreeCheckBox2.IsChecked := False;
        TabControl.TabIndex := 1;
      end;
  end;
end;

procedure TGenCryptoKeysForm.CanNextTimerTimer(Sender: TObject);
begin
  LogInRectangle.HitTest := True;
  CanNextTimer.Enabled := False;
end;

procedure TGenCryptoKeysForm.ChangeFormInfo;
begin
  if KeysCopied then
  begin
    HeadLabel.Text := Trnaslator.GetPhrase(index94, CurrentLanguage);
    EnterPassLabel.Text := Trnaslator.GetPhrase(index95, CurrentLanguage);
    KeysMemo.Lines.Clear;
    KeysMemo.SetFocus;
  end
  else
  begin
    HeadLabel.Text := Trnaslator.GetPhrase(index96, CurrentLanguage);
    EnterPassLabel.Text := Trnaslator.GetPhrase(index97, CurrentLanguage);
    KeysMemo.Lines.Clear;
    KeysMemo.Lines.Add(Words);
  end;
  KeysMemo.ReadOnly := not KeysCopied;
end;

procedure TGenCryptoKeysForm.IAgreeCheckBox2Change(Sender: TObject);
begin
  LogInRectangle2.Enabled := IAgreeCheckBox2.IsChecked;
end;

procedure TGenCryptoKeysForm.FormCreate(Sender: TObject);
begin
  Rectangle1.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  Rectangle1.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  LogInRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  LogInRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  LogInRectangle2.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  LogInRectangle2.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  KeysCopied := False;
end;

procedure TGenCryptoKeysForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    LogInRectangleClick(nil);
end;

procedure TGenCryptoKeysForm.FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  CanNextTimer.Enabled := True;
end;

procedure TGenCryptoKeysForm.FormShow(Sender: TObject);
begin
  self.Caption := GetCaption;
  Handler.HandleGUICommand(CMD_GUI_GET_WORDS, [], SetWords);
  KeysCopied := False;
  ChangeFormInfo;
  LogInRectangle.HitTest := False;
  IAgreeCheckBox1.IsChecked := False;
  IAgreeCheckBox2.IsChecked := False;
  TabControl.TabIndex := 0;

  HeadLabel1.Text := Trnaslator.GetPhrase(index99, CurrentLanguage);
  infolabel.Text := Trnaslator.GetPhrase(index100, CurrentLanguage);
  IAgreeCheckBox1.Text := Trnaslator.GetPhrase(index101, CurrentLanguage);
  Label1.Text := Trnaslator.GetPhrase(index37, CurrentLanguage);
  HeadLabel.Text := Trnaslator.GetPhrase(index102, CurrentLanguage);
  EnterPassLabel.Text := Trnaslator.GetPhrase(index103, CurrentLanguage);
  LogInLabel.Text := Trnaslator.GetPhrase(index40, CurrentLanguage);
  BackLabel.Text := Trnaslator.GetPhrase(index25, CurrentLanguage);
  Label3.Text := Trnaslator.GetPhrase(index104, CurrentLanguage);
  Label4.Text := Trnaslator.GetPhrase(index105, CurrentLanguage);
  Label5.Text := Trnaslator.GetPhrase(index106, CurrentLanguage);
  IAgreeCheckBox2.Text := Trnaslator.GetPhrase(index107, CurrentLanguage);
  LogInLabel2.Text := Trnaslator.GetPhrase(index41, CurrentLanguage);
end;

procedure TGenCryptoKeysForm.IAgreeCheckBox1Change(Sender: TObject);
begin
  Rectangle1.Enabled := IAgreeCheckBox1.IsChecked;
end;

procedure TGenCryptoKeysForm.KeysMemoChange(Sender: TObject);
var
  FWords: TStrings;
begin
  FWords := Parse(Trim(KeysMemo.Text), ' ');
  LogInRectangle.Enabled := Length(FWords) = 47;
end;

procedure TGenCryptoKeysForm.LogInRectangleClick(Sender: TObject);
begin
  if KeysCopied then
  begin
    if KeysMemo.Text <> Words then
      ShowMessage(Trnaslator.GetPhrase(index98, CurrentLanguage))
    else
      TabControl.TabIndex := 2;
  end
  else
  begin
    KeysCopied := True;
    ChangeFormInfo;
  end;
end;

procedure TGenCryptoKeysForm.Rectangle1Click(Sender: TObject);
begin
  TabControl.TabIndex := 1;
end;

procedure TGenCryptoKeysForm.LogInRectangle2Click(Sender: TObject);
begin
  AppCore.ShowForm(ord(fLogin), []);
end;

procedure TGenCryptoKeysForm.SetData(AArray: TArray<string>);
begin
  //
end;

procedure TGenCryptoKeysForm.SetWords(AArray: TArray<string>);
begin
  Words := Trim(AArray[0]).ToUpper;
  ChangeFormInfo;
end;

procedure TGenCryptoKeysForm.TabControlChange(Sender: TObject);
begin
  BackRectangle.Visible := not(TabControl.TabIndex = 0);
end;

end.
