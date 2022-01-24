unit BlockChain.FastIndex.Service;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.IOUtils,
  App.Types,
  BlockChain.Types,
  BlockChain.FileHandler;

type
  TServiceIndex = record
    ServiceID: UInt64;
    ServiceName: TName;
    class operator Implicit(Buf: TServiceIndex): TBytes;
    class operator Implicit(Buf: TBytes): TServiceIndex;
  end;

  TFastIndexService = class
  private
    FPath: string;
    FName: string;
    ChainFile: TChainFile;
    Services: TArray<TServiceIndex>;
  public
    function GetID(AName: TName): UInt64;
    function GetName(AID: UInt64): TName;
    procedure SetData(AID: UInt64; AName: TName);
    constructor Create(AName: string);
    destructor Destroy; override;
  end;

implementation

{ TFastIndexAccount }

constructor TFastIndexService.Create(AName: string);
begin
  FName := AName;
  FPath := TPath.Combine(Paths.GetPathFastIndex, FName);
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 3;
  var
  SI := Header + Default (TServiceIndex);
  ChainFile := TChainFile.Create(FPath, SI);
  for var i := 1 to ChainFile.GetLastBlockNumber do
  begin
    var
      Buf: TBytes;
    ChainFile.TryRead(i, Buf);
    Buf := Copy(Buf, SizeOf(THeader), Length(Buf) - SizeOf(THeader));
    SI := Buf;
    Services := Services + [SI];
  end;

end;

destructor TFastIndexService.Destroy;
begin
  ChainFile.Free;
end;

function TFastIndexService.GetID(AName: TName): UInt64;
begin
  Result := 0;
  if AName <> '' then
    for var item in Services do
    begin
      if item.ServiceName = AName then
      begin
        Result := item.ServiceID;
        break;
      end;
    end;
end;

function TFastIndexService.GetName(AID: UInt64): TName;
begin
  Result := Default (TName);
  if AID-1 <= Length(Services) then
    Result := Services[AID-1].ServiceName;
end;

procedure TFastIndexService.SetData(AID: UInt64; AName: TName);
begin
  var
    SI: TServiceIndex;
  SI.ServiceID := AID;
  SI.ServiceName := AName;
  var
    Header: THeader := Default (THeader);
  Header.TypeBlock := 9;
  Header.VersionData := 3;
  var
    Buf: TBytes := SI;
  if ChainFile.TryWrite(Header + Buf, Header) then
    Services := Services + [SI];
end;

{ TAccountIndex }

class operator TServiceIndex.Implicit(Buf: TBytes): TServiceIndex;
begin
  Move(Buf[0], Result, SizeOf(TServiceIndex));
end;

class operator TServiceIndex.Implicit(Buf: TServiceIndex): TBytes;
begin
  SetLength(Result, SizeOf(TServiceIndex));
  Move(Buf, Result[0], SizeOf(TServiceIndex));
end;

end.
