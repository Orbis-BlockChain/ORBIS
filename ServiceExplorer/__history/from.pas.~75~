unit from;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,
  System.Generics.Collections,
  App.Paths,
  App.Types,
  BlockChain.Core,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs, System.Rtti,
  FMX.Grid.Style,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Grid,
  FMX.Objects,
  FMX.Menus, FMX.ListBox, FMX.StdCtrls;

type
  TCurrnetPaths = class(TInterfacedObject, IBasePaths)
  public
    RootPath: string;
    function GetPathBlockChain: string;
    function GetPathLog: string;
    function GetPathCryptoContainer: string;
    function GetPathFastIndex: string;
    procedure SetRootPath(APath:string);
//    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
//    function _AddRef: Integer; stdcall;
//    function _Release: Integer; stdcall;

  end;

  TForm1 = class(TForm)
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    ComboBox1: TComboBox;
    StringGrid1: TStringGrid;
    Button_choise_path: TButton;
    ComboBox2: TComboBox;
    Button2: TButton;
    procedure MenuItem3Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button_1Click(Sender: TObject);
    procedure Button_choise_pathClick(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    bc: TBlockChainCore;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  GlobalPath: string;
  TypeNet: string;
implementation

{$R *.fmx}

procedure TForm1.Button2Click(Sender: TObject);
begin
  ComboBox1Change(nil);
end;

procedure TForm1.Button_1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
     GlobalPath :=   ExtractFilePath(OpenDialog1.FileName) ;
  end;
end;

procedure TForm1.Button_choise_pathClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
     GlobalPath :=   ExtractFilePath(OpenDialog1.FileName) ;
     bc := TBlockChainCore.Create;
     ComboBox1.Items.AddStrings(bc.Inquiries.GetChains);
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  DataSource: TArray<TArray<TPair<string, string>>>;
  sn:string;
begin
  bc := TBlockChainCore.Create;
  if ComboBox1.Count = 0 then
  ComboBox1.Items.AddStrings(bc.Inquiries.GetChains);
  stringgrid1.ClearColumns;
  StringGrid1.RowCount :=0;
  if (combobox1.ItemIndex>=0) {and (combobox1.ItemIndex in [0,1,2,3,8])} then
  begin
    DataSource := bc.Inquiries.GetDataFromChain(combobox1.ItemIndex);
    for var i:integer := 0 to Length(DataSource[0]) - 1 do
      stringgrid1.AddObject(TColumn.Create(stringgrid1));
    for var i:integer := 0 to Length(DataSource[0]) - 1 do
      stringgrid1.Columns[i].Header := DataSource[0][i].Key;


    for var i: integer := 0 to Length(DataSource) - 1 do
    begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      for var j: integer := 0 to Length(DataSource[i]) - 1 do
      begin
          sn:=DataSource[i][j].Value;
       if DataSource[0][j].Key = 'Amount' then
        begin
        if ansipos('E',sn)>0 then stringgrid1.Cells[j,i] := FloatEToString(StrToFloat(sn)) //FormatFloat('###0.########',StrToFloat(sn))
                              else stringgrid1.Cells[j,i] := sn;
        end
       else stringgrid1.Cells[j,i] := sn;
      end;
    end;
  end;

end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  TypeNet := ComboBox2.Items[ComboBox2.ItemIndex];
  ComboBox1Change(nil);
  if ComboBox1.Count>0 then
    ComboBox1.ItemIndex := 0;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  DataSource: TArray<TArray<TPair<string, string>>>;
  lpaths: TCurrnetPaths;
  Chains: TArray<string>;
begin
  GlobalPath := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath, 'ORBIS');
  Paths := TCurrnetPaths.Create;
  TypeNet := 'test';
  try
    ComboBox1Change(nil);
  //  combobox1.ItemIndex := 0;
  except
    on e: EXception do
      ShowMessage('ERROR: ' + e.Message);
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key = vkControl and vk1 then
    Button_choise_path.Visible:= True;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
var
  lpaths: TCurrnetPaths;
  Chains: TArray<string>;
begin

end;

{ TCurrnetPaths }

function TCurrnetPaths.GetPathBlockChain: string;
begin

  Result := System.IOUtils.TPath.Combine(GlobalPath, '.'+TypeNet+'-blockchain');
end;

function TCurrnetPaths.GetPathCryptoContainer: string;
begin
  Result := System.IOUtils.TPath.Combine(GlobalPath, '.'+TypeNet+'-cryptocontainer');
end;

function TCurrnetPaths.GetPathFastIndex: string;
begin
  Result := System.IOUtils.TPath.Combine(GlobalPath, '.'+TypeNet+'-fastindex');
end;

function TCurrnetPaths.GetPathLog: string;
begin
  Result := System.IOUtils.TPath.Combine(GlobalPath, '.'+TypeNet+'-log');
end;

procedure TCurrnetPaths.SetRootPath(APath:string);
begin
  RootPath := APath;
end;

end.
