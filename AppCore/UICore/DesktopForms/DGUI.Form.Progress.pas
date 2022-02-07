unit DGUI.Form.Progress;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Hash,
  System.Threading,
  Translate.Core,
  App.Types,
  App.Meta,
  App.Globals,
  App.Notifyer,
  UI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts;

type
  TProgressForm = class(TForm)
    ProgressBar: TProgressBar;
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    InfoLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    SubscribeToken: TBytes;
    percent: integer;
    procedure SetDownload;
    procedure SetUpack;
    procedure SetInstall;
  public

  end;

var
  ProgressForm: TProgressForm;

implementation

{$R *.fmx}

procedure TProgressForm.FormCreate(Sender: TObject);
begin
  Caption := GetCaption;
  SubscribeToken := THashSha2.GetHashBytes(DateTimeToStr(now));
  Notifyer.Subscribe(SetDownload, nOnDowloadUpdate, SubscribeToken);
  Notifyer.Subscribe(SetUpack, nOnSaveUpdatePackage, SubscribeToken);
  Notifyer.Subscribe(SetInstall, nOnStartInstall, SubscribeToken);
end;

procedure TProgressForm.FormDestroy(Sender: TObject);
begin
  Notifyer.UnSubscribe(SubscribeToken);
end;

procedure TProgressForm.FormShow(Sender: TObject);
begin
  ProgressBar.Min := 0;
  ProgressBar.max := 100;
  ProgressBar.Value := 0;
  percent := 10;
  InfoLabel.Text := Trnaslator.GetPhrase(index113, CurrentLanguage);
  TThread.CreateAnonymousThread(
    procedure
    begin
      while not (Application.Terminated)and (ProgressBar.Value < 100) do
      begin
        if ProgressBar.Value < percent then
          ProgressBar.Value := ProgressBar.Value + 1;
        sleep(20);
      end;
    end).Start;
  TTask.Run(
    procedure
    begin
      AppCore.GetHandler.HandleCommand(CMD_DO_START_UPDATE, []);
    end);
end;

procedure TProgressForm.SetDownload;
begin
  percent := 33;
  InfoLabel.Text := Trnaslator.GetPhrase(index86, CurrentLanguage);
end;

procedure TProgressForm.SetInstall;
begin
  percent :=100;
  InfoLabel.Text := Trnaslator.GetPhrase(index88, CurrentLanguage);
end;

procedure TProgressForm.SetUpack;
begin
  percent := 66;
  InfoLabel.Text := Trnaslator.GetPhrase(index87, CurrentLanguage);
end;

end.
