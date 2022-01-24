unit DGUI.Form.TransactionInfo;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Types, System.UITypes,
  System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TTransactionInfoForm = class(TForm)
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
  private
    { Private declarations }
  public
    procedure SetData(Args: TArray<string>);
  end;

var
  TransactionInfoForm: TTransactionInfoForm;

implementation

{$R *.fmx}
{ TTransactionInfoForm }

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
    TransInfoLabel.Text := '- ' + FloatToStr(StrToFloat(Args[4]) * -1) + ' ' + Args[3];
    FromValueLabel.Text := Args[2];
    ToValueLabel.Text := Args[1];
    VolumeValueLabel.Text := FloatToStr(StrToFloat(Args[4]) * -1) + ' ' + Args[3];
    TransInfoLabel.TextSettings.FontColor := $FFEB5E6C;
  end;
  HashValueLabel.Text := Args[5];
end;

end.
