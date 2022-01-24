unit DGUI.Form.Base;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  Translate.Core,
  App.Types,
  App.Meta,
  UI.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.Objects;

type
  TBaseForm = class(TForm)
    NetText1: TText;
    NetLayout: TLayout;
    InnerNetLayout: TLayout;
    NetText2: TText;
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetNet;
  end;

var
  BaseForm: TBaseForm;

implementation

{$R *.fmx}

procedure TBaseForm.FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  with Self do
  begin
    NetText1.AutoSize := True;
    NetText1.AutoSize := False;
    NetText2.AutoSize := True;
    NetText2.AutoSize := False;
    InnerNetLayout.Width := NetText1.Width + NetText2.Width;
  end;
end;

procedure TBaseForm.FormShow(Sender: TObject);
begin
  Self.Caption := GetCaption;
end;

procedure TBaseForm.SetNet;
begin
  NetText1.Text :=  Trnaslator.GetPhrase(index9,CurrentLanguage);
  case NetState of
    MAINNET:
      begin
        NetText2.Text := 'MAINNET';
        NetText2.TextSettings.FontColor := $FF9B51E0;
      end;
    TESTNET:
      begin
        NetText2.Text := 'TESTNET';
        NetText2.TextSettings.FontColor := $FFEB5E6C;
      end;
    LABNET:
      begin
        NetText2.Text := 'LABNET';
        NetText2.TextSettings.FontColor := $FFEB5E6C;
      end;
  else
    begin
      NetText1.Text := '';
      NetText1.Width := 0;
      NetText2.Text := Trnaslator.GetPhrase(index89,CurrentLanguage);
      NetText2.TextSettings.FontColor := $FFEB5E6C;
    end;
  end;
  Self.FormPaint(Self, nil, TRectF.Create(0, 0, 0, 0));
end;

end.
