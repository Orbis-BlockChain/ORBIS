unit DGUI.Form.Resources;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs;

type
  TResourcesForm = class(TForm)
    AppStyle: TStyleBook;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  ResourcesForm: TResourcesForm;

implementation

{$R *.fmx}

procedure TResourcesForm.FormShow(Sender: TObject);
begin
  sleep(1);
end;

end.
