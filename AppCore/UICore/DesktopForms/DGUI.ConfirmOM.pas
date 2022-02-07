unit DGUI.ConfirmOM;

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
  App.Globals,
  UI.Types,
  UI.Animated,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Ani,
  FMX.Objects,
  UI.GUI.Types,
  DGUI.Form.Base;

type
  TConfirmOMForm = class(TBaseForm)
    MyAddressLabel: TLabel;
    AmountLabel: TLabel;
    AmountORBCLabel: TLabel;
    GoConfirmRectangle: TRectangle;
    GoConfirmLabel: TLabel;
    CancelRectangle: TRectangle;
    CancelLabel: TLabel;
    Line: TLine;
    CautionLabel: TLabel;
    Label1: TLabel;
    AmountOMLabel: TLabel;
    procedure GoConfirmRectangleClick(Sender: TObject);
    procedure CancelRectangleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelRectangleMouseEnter(Sender: TObject);
    procedure CancelRectangleMouseLeave(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    typeCoin, valueORBC, valueOM: string;
  public
    procedure SetData(AArgs: TArray<string>);
    procedure Return(AArgs: TArray<string>);
  end;

var
  ConfirmOMForm: TConfirmOMForm;

implementation

{$R *.fmx}

procedure TConfirmOMForm.CancelRectangleMouseEnter(Sender: TObject);
begin
  CancelRectangle.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

procedure TConfirmOMForm.CancelRectangleMouseLeave(Sender: TObject);
begin
  CancelRectangle.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

procedure TConfirmOMForm.FormCreate(Sender: TObject);
begin
  GoConfirmRectangle.OnMouseEnter := TRectAnimations.AnimRectPurpleMouseIn;
  GoConfirmRectangle.OnMouseLeave := TRectAnimations.AnimRectPurpleMouseOut;

  SetNet;
end;

procedure TConfirmOMForm.FormShow(Sender: TObject);
begin
  self.Caption := GetCaption;
  MyAddressLabel.Text := Trnaslator.GetPhrase(index1, CurrentLanguage);
  AmountLabel.Text := Trnaslator.GetPhrase(index2, CurrentLanguage) + ' ' + MainCoin;
  Label1.Text := Trnaslator.GetPhrase(index2, CurrentLanguage) + ' OM';
  CautionLabel.Text := Trnaslator.GetPhrase(index5, CurrentLanguage);
  GoConfirmLabel.Text := Trnaslator.GetPhrase(index3, CurrentLanguage);
  CancelLabel.Text := Trnaslator.GetPhrase(index4, CurrentLanguage);
  AmountORBCLabel.Text := valueORBC + ' ' + typeCoin;
  AmountOMLabel.Text := valueOM + ' OM';
end;

procedure TConfirmOMForm.GoConfirmRectangleClick(Sender: TObject);
begin
  AppCore.GetHandler.HandleGUICommand(CMD_GUI_BUY_OM, [], Return);
end;

procedure TConfirmOMForm.Return(AArgs: TArray<string>);
begin
  if AArgs[0] = 'OK' then
  begin
    ShowMessage(Trnaslator.GetPhrase(index133, CurrentLanguage));
    AppCore.ShowForm(ord(fNewTransaction), [])
  end
  else
  begin
    ShowMessage(Trnaslator.GetPhrase(index134, CurrentLanguage));
    AppCore.ShowForm(ord(fNewTransaction), []);
  end;
end;

procedure TConfirmOMForm.SetData(AArgs: TArray<string>);
begin
  typeCoin := AArgs[0];
  valueORBC := AArgs[1];
  valueOM := AArgs[2];
end;

procedure TConfirmOMForm.CancelRectangleClick(Sender: TObject);
begin
  AppCore.ShowForm(ord(fNewTransaction), []);
end;

end.
