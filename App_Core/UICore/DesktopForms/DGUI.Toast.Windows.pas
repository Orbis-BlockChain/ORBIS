unit DGUI.Toast.Windows;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Ani,
  FMX.Objects, FMX.Effects;

type
  TToastForm = class(TForm)
    Rectangle1: TRectangle;
    Text1: TText;
    FloatAnimation1: TFloatAnimation;
    Timer1: TTimer;
    ShadowEffect1: TShadowEffect;
    FloatAnimation2: TFloatAnimation;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormShow(Sender: TObject);
    procedure FloatAnimation1Finish(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure StartShow;
    procedure StartHide;
  public
    procedure ShowToast(const Text: string);
  end;

procedure ShowWinToast(const Text: string);

implementation

{$R *.fmx}

var
  ToastForm: TToastForm;

procedure ShowWinToast(const Text: string);
begin
  if not Assigned(ToastForm) then
    ToastForm := TToastForm.Create(Application);
  ToastForm.ShowToast(Text);
end;

procedure TToastForm.FormShow(Sender: TObject);
begin

  StartShow;
end;

procedure TToastForm.ShowToast(const Text: string);
var
  ParentForm: TCommonCustomForm;
  ParentRect, ToastRect: TRect;
begin
  FloatAnimation1.Stop;
  Text1.Text := Text;
  ParentForm := Screen.ActiveForm;
  if not Assigned(ParentForm) then
    ParentForm := Application.MainForm;
  if Assigned(ParentForm) then
  begin
    ParentRect := ParentForm.Bounds;
    SetParent(ParentForm);
  end
  else
    ParentRect := TRect(Screen.WorkAreaRect);

  Text1.AutoSize := True;
  Text1.AutoSize := False;
  ToastRect := TRect.Create(TPoint.Zero, Round(Text1.Width) + 45,
    Round(Text1.Height) + 30);
  SetBounds((ParentRect.Left - (ToastRect.Width - ParentRect.Width) div 2) - 2,
    ParentRect.Top + 158, ToastRect.Width, ToastRect.Height);
  Rectangle1.Opacity := 0;
  Rectangle1.XRadius := Trunc(ToastRect.Height / 2);
  Rectangle1.YRadius := Trunc(ToastRect.Height / 2);
  Show;
end;

procedure TToastForm.StartShow;
begin
  FloatAnimation1.Inverse := False;
  FloatAnimation1.Start;
  FloatAnimation2.Inverse := False;
  FloatAnimation2.Start;
  Timer1.Enabled := True;
end;

procedure TToastForm.Timer1Timer(Sender: TObject);
begin
  StartHide;
end;

procedure TToastForm.StartHide;
begin
  Timer1.Enabled := False;
  FloatAnimation1.Inverse := True;
  FloatAnimation2.Inverse := True;
  FloatAnimation1.Start;
  FloatAnimation2.Start;
end;

procedure TToastForm.FloatAnimation1Finish(Sender: TObject);
begin
  if FloatAnimation2.Inverse then
    Close;
end;

procedure TToastForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not FloatAnimation1.Inverse or FloatAnimation1.Running then
  begin
    Action := TCloseAction.caNone;
    StartHide;
  end;
end;

procedure TToastForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  StartHide;
end;

end.
