unit App.FileLocker;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils;

type
  TFileLocker = class
  private
    Path: string;
    FFIle: TFileStream;
    FileName: string;
  public
    function TryTakeDescriptor: boolean;
    procedure FreeDescriptor;
    constructor Create(const APath: string);
    destructor Destroy; override;
  end;

implementation

{ TFileLocker }

constructor TFileLocker.Create(const APath: string);
begin
  Path := APath;
  FileName := '.lockDescriptor';
end;

destructor TFileLocker.Destroy;
begin
  inherited;
end;

procedure TFileLocker.FreeDescriptor;
begin
  FFile.Free;
end;

function TFileLocker.TryTakeDescriptor: boolean;
var
  FLocFile: file;
begin
  result := true;
  try
    if not TFile.Exists(TPath.Combine(Path, FileName)) then
    begin
      AssignFile(FLocFile, TPath.Combine(Path, FileName));
      Rewrite(FLocFile, 1);
      CloseFile(FLocFile);
    end;
     FFile := TFile.OpenWrite(TPath.Combine(Path, FileName));
  except
    result := false;
  end;
end;

end.
