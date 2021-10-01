unit DGUI.Form.EnterCryptoKeys;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  App.Globals,
  App.Meta,
  UI.Types,
  UI.GUI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.Layouts,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  DGUI.Form.Resources, FMX.Ani, FMX.Edit;

type
  TEnterWords = class(TForm)
    EnterKeysLabel: TLabel;
    HeadLabel: TLabel;
    KeysMemo: TMemo;
    Line: TLine;
    OKRectangle: TRectangle;
    OKLabel: TLabel;
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    BackRectangle: TRectangle;
    BackLabel: TLabel;
    KeysErrorLabel: TLabel;
    OkColorAnimation: TColorAnimation;
    TextColorAnimation: TColorAnimation;
    EnterPassEdit: TEdit;
    ShowPassLayout: TLayout;
    ShowPassPath: TPath;
    Label1: TLabel;
    Label2: TLabel;
    procedure BackRectangleClick(Sender: TObject);
    procedure OKRectangleClick(Sender: TObject);
    procedure KeysMemoChangeTracking(Sender: TObject);
    procedure TextColorAnimationFinish(Sender: TObject);
    procedure OkColorAnimationFinish(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShowPassLayoutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EnterPassEditKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    GoAnimation: Boolean;
    procedure Callback(AArgs: TArray<string>);
  public
    { Public declarations }
  end;

var
  EnterWords: TEnterWords;

implementation

{$R *.fmx}

procedure TEnterWords.BackRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fRestoreSelection), []);
end;

procedure TEnterWords.Callback(AArgs: TArray<string>);
begin
  if AArgs[0] = 'OK' then
    AppCore.ShowForm(ord(fLogin), [])
  else
    KeysErrorLabel.Visible := True;
end;

procedure TEnterWords.EnterPassEditKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if EnterPassEdit.Text.Length < 6 then
    Label2.Visible := True
  else
    Label2.Visible := False;
end;

procedure TEnterWords.FormCreate(Sender: TObject);
begin
  GoAnimation := True;
end;

procedure TEnterWords.FormShow(Sender: TObject);
begin
  Label2.Visible := False;
  KeysMemo.Lines.Clear;
  EnterPassEdit.Text := '';
end;

procedure TEnterWords.KeysMemoChangeTracking(Sender: TObject);
begin
  OKRectangle.HitTest := not KeysMemo.Text.IsEmpty;
  OkColorAnimation.Inverse := KeysMemo.Text.IsEmpty;
  TextColorAnimation.Inverse := OkColorAnimation.Inverse;
  OkColorAnimation.Enabled := OkColorAnimation.Inverse <> GoAnimation;
  TextColorAnimation.Enabled := OkColorAnimation.Enabled;
  GoAnimation := KeysMemo.Text.IsEmpty;
  KeysErrorLabel.Visible := False;
end;

procedure TEnterWords.OkColorAnimationFinish(Sender: TObject);
begin
  if OkColorAnimation.Inverse then
    OKRectangle.Fill.Color := OkColorAnimation.StartValue
  else
    OKRectangle.Fill.Color := OkColorAnimation.StopValue;
  OkColorAnimation.Enabled := False;
end;

procedure TEnterWords.OKRectangleClick(Sender: TObject);
begin
  if EnterPassEdit.Text.Length >= 6 then
    Handler.HandleGUICommand(CMD_GUI_SET_WORDS, [KeysMemo.Text, EnterPassEdit.Text], Callback);
end;

procedure TEnterWords.ShowPassLayoutClick(Sender: TObject);
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

procedure TEnterWords.TextColorAnimationFinish(Sender: TObject);
begin
  if TextColorAnimation.Inverse then
    OKLabel.TextSettings.FontColor := TextColorAnimation.StartValue
  else
    OKLabel.TextSettings.FontColor := TextColorAnimation.StopValue;
  TextColorAnimation.Enabled := False;
end;

end.