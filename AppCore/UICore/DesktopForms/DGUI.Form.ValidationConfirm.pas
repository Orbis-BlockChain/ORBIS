unit DGUI.Form.ValidationConfirm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Threading,
  System.Hash,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.Ani,
  DGUI.Frame.Splash,
  App.Notifyer,
  Translate.Core,
  App.Meta,
  App.Types,
  App.Globals,
  UI.Types,
  UI.Animated,
  DGUI.Form.Base;

type
  TValidationConfirmForm = class(TBaseForm)
    InfoLabel: TLabel;
    Line: TLine;
    ProgressArc: TArc;
    ProgressLabel: TLabel;
    ProgressLayout: TLayout;
    ArcFloatAnimation: TFloatAnimation;
    InfoText1: TText;
    InfoText2: TText;
    CancelRectangle: TRectangle;
    CancelLabel: TLabel;
    OkRectangle: TRectangle;
    OkLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Splash: TSplashFrame;
    SubscribeToken: TBytes;
    function GetAngle(const APercent: UInt64): UInt64;
    procedure Set20;
    procedure Set40;
    procedure Set60;
    procedure Set100;
    procedure StartWork(AObject: TObject);

  public
    procedure GoProgress(const APercent: UInt64; const AInfoText: String = '');
    procedure PaintProgress;
  end;

  TWaitingThread = class(TThread)
  private
    FCurrentValue: UInt64;
    PPercent: UInt64;
    PText: String;
    procedure NextForm(Args: TArray<string>);
  public
    property Percent: UInt64 read PPercent write PPercent;
    property Text: String read PText write PText;
  protected
    procedure Execute; override;
  end;

var
  ValidationConfirmForm: TValidationConfirmForm;
  MyThread: TWaitingThread;

implementation

{$R *.fmx}

procedure TValidationConfirmForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ArcFloatAnimation.Enabled := False;
end;

procedure TValidationConfirmForm.FormCreate(Sender: TObject);
begin
  Splash := TSplashFrame.Create(self);
  Splash.Parent := self;

  OkRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  OkRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;
  CancelRectangle.OnMouseEnter := TRectAnimations.AnimRectGrayMouseIn;
  CancelRectangle.OnMouseLeave := TRectAnimations.AnimRectGrayMouseOut;

  SetNet;
end;

procedure TValidationConfirmForm.FormDestroy(Sender: TObject);
begin
  Splash.Free;
  Notifyer.UnSubscribe(SubscribeToken);
end;

procedure TValidationConfirmForm.FormShow(Sender: TObject);
begin
  self.Caption := GetCaption;
  Splash.FloatAnimation1.OnFinish := StartWork;
  Splash.FloatAnimation1.Start;

  ProgressArc.StartAngle := 0;
  ProgressArc.EndAngle := 0;
  ArcFloatAnimation.Enabled := True;

  MyThread := TWaitingThread.Create(False);
  MyThread.PPercent := 0;
  MyThread.PText := '';
  MyThread.FreeOnTerminate := True;
end;

function TValidationConfirmForm.GetAngle(const APercent: UInt64): UInt64;
begin
  Result := Trunc(359 * APercent * 0.01);
end;

procedure TValidationConfirmForm.GoProgress(const APercent: UInt64; const AInfoText: String);
begin
  MyThread.PPercent := APercent;
  MyThread.PText := AInfoText;
end;

procedure TValidationConfirmForm.PaintProgress;
begin
  if not Application.Terminated then
  begin

    if not(MyThread.PText = '') then // Если текст пуст, то надпись не меняется
      InfoLabel.Text := MyThread.PText;
    ProgressLabel.Text := MyThread.FCurrentValue.AsString + '%';

    ProgressArc.EndAngle := GetAngle(MyThread.FCurrentValue);
  end;
end;

procedure TValidationConfirmForm.Set20;
begin
  GoProgress(20, Trnaslator.GetPhrase(index116, CurrentLanguage));
end;

procedure TValidationConfirmForm.Set40;
begin
  GoProgress(40, Trnaslator.GetPhrase(index117, CurrentLanguage));
end;

procedure TValidationConfirmForm.Set60;
begin
  GoProgress(60, Trnaslator.GetPhrase(index118, CurrentLanguage));
end;

procedure TValidationConfirmForm.Set100;
begin
  GoProgress(100, Trnaslator.GetPhrase(index119, CurrentLanguage));
end;

procedure TValidationConfirmForm.StartWork(AObject: TObject);
begin
  SubscribeToken := THashSha2.GetHashBytes(DateTimeToStr(now));
  Notifyer.Subscribe(Set20, nOnOkAuth,SubscribeToken);
  Notifyer.Subscribe(Set40, nOnGoodVersion,SubscribeToken);
  Notifyer.Subscribe(Set60, nOnStartDownalodBlocks,SubscribeToken);
  Notifyer.Subscribe(Set100, nOnEndDownloadBlocks,SubscribeToken);

  handler.HandleCommand(CMD_START, []);
end;

{ TWaitingThread }

procedure TWaitingThread.Execute;
begin
  inherited;
  FCurrentValue := 0;
  while (not Terminated) and (not Application.Terminated) do
  begin
    // sleep(20);
    sleep(1);
    if FCurrentValue >= 100 then
    begin
      Terminate;
    end;
    if FCurrentValue < Percent then
      inc(FCurrentValue);
    Synchronize(ValidationConfirmForm.PaintProgress);
  end;
  if (not Application.Terminated) then
    handler.HandleGUICommand(CMD_CHECK_COUNT_WALLETS, [], NextForm);

end;

procedure TWaitingThread.NextForm(Args: TArray<string>);
var
  Form: TDesktopForms;
begin
  if length(Args[0]) = 0 then
    Form := fRegestrattion
  else
    Form := fLogin;

  TThread.Synchronize(nil,
    procedure
    begin
      AppCore.ShowForm(1, [])
    end);
end;

end.
