unit DGUI.Form.Waiting;

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
  UI.Types;

type
  TWaitingForm = class(TForm)
    InfoLabel: TLabel;
    Line: TLine;
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    ProgressArc: TArc;
    ProgressLabel: TLabel;
    ProgressLayout: TLayout;
    ArcFloatAnimation: TFloatAnimation;
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
  WaitingForm: TWaitingForm;
  MyThread: TWaitingThread;

implementation

{$R *.fmx}

procedure TWaitingForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ArcFloatAnimation.Enabled := False;
end;

procedure TWaitingForm.FormCreate(Sender: TObject);
begin
  Splash := TSplashFrame.Create(self);
  Splash.Parent := self;
end;

procedure TWaitingForm.FormDestroy(Sender: TObject);
begin
  Splash.Free;
  Notifyer.UnSubscribe(SubscribeToken);
end;

procedure TWaitingForm.FormShow(Sender: TObject);
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

function TWaitingForm.GetAngle(const APercent: UInt64): UInt64;
begin
  Result := Trunc(359 * APercent * 0.01);
end;

procedure TWaitingForm.GoProgress(const APercent: UInt64; const AInfoText: String);
begin
  MyThread.PPercent := APercent;
  MyThread.PText := AInfoText;
end;

procedure TWaitingForm.PaintProgress;
begin
  if not Application.Terminated then
  begin

    if not(MyThread.PText = '') then
      InfoLabel.Text := MyThread.PText;
    ProgressLabel.Text := MyThread.FCurrentValue.AsString + '%';

    ProgressArc.EndAngle := GetAngle(MyThread.FCurrentValue);
  end;
end;

procedure TWaitingForm.Set20;
begin
  GoProgress(20, Trnaslator.GetPhrase(index116, CurrentLanguage));
end;

procedure TWaitingForm.Set40;
begin
  GoProgress(40, Trnaslator.GetPhrase(index117, CurrentLanguage));
end;

procedure TWaitingForm.Set60;
begin
  GoProgress(60, Trnaslator.GetPhrase(index118, CurrentLanguage));
end;

procedure TWaitingForm.Set100;
begin
  GoProgress(100, Trnaslator.GetPhrase(index119, CurrentLanguage));
end;

procedure TWaitingForm.StartWork(AObject: TObject);
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
    sleep(1);
    if FCurrentValue >= 100 then
    begin
      Terminate;
    end;
    if FCurrentValue < Percent then
      inc(FCurrentValue);
    Synchronize(WaitingForm.PaintProgress);
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
