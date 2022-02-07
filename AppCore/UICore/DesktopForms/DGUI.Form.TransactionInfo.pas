unit DGUI.Form.TransactionInfo;

interface

uses
  System.Hash,
  System.SysUtils,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  Translate.Core,
  App.Notifyer,
  App.Types,
  App.Meta,
  Ui.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Platform,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  DGUI.Form.Base,
  DGUI.Toast.Windows,
  FMX.Layouts;

type
  TTransactionInfoForm = class(TBaseForm)
    Line: TLine;
    TransactionInfoLabel: TLabel;
    DateTimeLabel: TLabel;
    TransInfoLabel: TLabel;
    FromLabel: TLabel;
    FromValueLabel: TLabel;
    ToLabel: TLabel;
    ToValueLabel: TLabel;
    HashLabel: TLabel;
    HashValueLabel: TLabel;
    Line1: TLine;
    VolumeLabel: TLabel;
    VolumeValueLabel: TLabel;
    Line2: TLine;
    Line3: TLine;
    ComissionLabel: TLabel;
    ComissionValueLabel: TLabel;
    Layout1: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AddressLabelClick(Sender: TObject);
    procedure HashValueLabelClick(Sender: TObject);
  private
    { Private declarations }
    SubscribeToken: TBytes;
    procedure SetText;
    procedure DoUpdateText;
  public
    procedure SetData(Args: TArray<string>);
  end;

var
  TransactionInfoForm: TTransactionInfoForm;

implementation

{$R *.fmx}
{ TTransactionInfoForm }

procedure TTransactionInfoForm.DoUpdateText;
begin
  SetText;
  SetNet;
end;

procedure TTransactionInfoForm.FormCreate(Sender: TObject);
begin
  SubscribeToken := THashSha2.GetHashBytes(DateTimeToStr(now));
  Notifyer.Subscribe(DoUpdateText, nOnSwitchLang,SubscribeToken);
  SetNet;
end;

procedure TTransactionInfoForm.FormDestroy(Sender: TObject);
begin
  inherited;
  Notifyer.UnSubscribe(SubscribeToken);
end;

procedure TTransactionInfoForm.FormShow(Sender: TObject);
begin
  inherited;
  self.Caption := GetCaption;
  SetText;
  SetNet;
end;

procedure TTransactionInfoForm.HashValueLabelClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
  begin
    Service.SetClipboard((Sender as TLabel).Text);
    ShowWinToast(Trnaslator.GetPhrase(index141, CurrentLanguage));
  end;
end;

procedure TTransactionInfoForm.AddressLabelClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
  begin
    Service.SetClipboard((Sender as TLabel).Text);
    ShowWinToast(Trnaslator.GetPhrase(index110, CurrentLanguage));
  end;
end;

procedure TTransactionInfoForm.SetData(Args: TArray<string>);
begin
  DateTimeLabel.Text := Args[0];
  if StrToFloat(Args[4]) > 0 then
  begin
    TransInfoLabel.Text := '+ ' + Args[4] + ' ' + Args[3];
    FromValueLabel.Text := Args[1];
    ToValueLabel.Text := Args[2];
    VolumeValueLabel.Text := Args[4] + ' ' + Args[3];
    TransInfoLabel.TextSettings.FontColor := $FF41BE06;
  end
  else
  begin
    TransInfoLabel.Text := '- ' + FloatEToString(StrToFloat(Args[4]) * -1) + ' ' + Args[3];
    FromValueLabel.Text := Args[2];
    ToValueLabel.Text := Args[1];
    VolumeValueLabel.Text := FloatEToString(StrToFloat(Args[4]) * -1) + ' ' + Args[3];
    TransInfoLabel.TextSettings.FontColor := $FFEB5E6C;
  end;
  HashValueLabel.Text := Args[5];
end;

procedure TTransactionInfoForm.SetText;
begin
  TransactionInfoLabel.Text := Trnaslator.GetPhrase(index77, CurrentLanguage);
  FromLabel.Text := Trnaslator.GetPhrase(index78, CurrentLanguage);
  ToLabel.Text := Trnaslator.GetPhrase(index79, CurrentLanguage);
  HashLabel.Text := Trnaslator.GetPhrase(index80, CurrentLanguage);
  VolumeLabel.Text := Trnaslator.GetPhrase(index81, CurrentLanguage);
  ComissionLabel.Text := Trnaslator.GetPhrase(index8, CurrentLanguage);
end;

end.
