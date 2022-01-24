unit Updater.Core;

interface

uses
  App.Globals,
  App.Types,
  App.Meta,
  App.Notifyer,
  System.Net.HttpClient,
  System.Threading,
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  System.IOUtils,
  System.Generics.Collections,
  System.StrUtils,
  System.JSON,
  System.Zip;

const
  URL_VERSION = 'https://orbistest.net/versions';
{$IFDEF MSWINDOWS}
  TypeOS = 'windows';
{$ENDIF}
{$IFDEF MACOS}
  TypeOS = 'macos';
{$ENDIF}
{$IFDEF LINUX}
  TypeOS = 'linux';
{$ENDIF}
{$IFDEF GUII}
  TypeNode = TypeOS + '-gui';
{$ENDIF}
{$IFDEF CONSOLEI}
  TypeNode = TypeOS + '-console';
{$ENDIF}

type

  TUpdaterCore = class
  private
    Error: string;
    CurrentVersion: TBytes;
    TimeCheck: integer;
    AVersion: TBytes;
    NameUpdatePack: string;
    HashUpdatePack: string;
    LinkUpdatePack: string;
    SizeUpdatePack: Int64;
    CancelUpdate: boolean;
    NeedDestroy: TEvent;
    TimerEvent: TEvent;
    procedure DoInstall(const AFilePath: string);
    procedure SaveFile(const AFilePath: string; AData: TMemoryStream);
    procedure removeTrash(const ACurrentVersion: TBytes);
    function UnpackFile(const AFilePath: string): string;

  public
    function isNeedUpdate(ACurrentVersion: TBytes; var ANewVersion: TBytes): boolean;
    procedure DoUpdate;
    function needTreminte(var ErrorCode: integer; var ErrorMessage: string): boolean;
    procedure StartAutoUpdate;
    constructor Create(ACurrentVersion: TBytes; AAutoCheck: boolean = true; ATimeCheck: integer = 10000);
    destructor Destroy; override;
  end;

implementation

{$IFDEF MSWINDOWS}

uses
  Winapi.Windows, Winapi.ActiveX, Winapi.ShlObj, Winapi.ShellAPI,
  Winapi.KnownFolders, System.Win.ComObj;
{$ENDIF}
{$IFDEF MACOS}

uses
  MacApi.AppKit, MacApi.Foundation, MacApi.CoreFoundation, MacApi.Helpers;
{$ENDIF}
{ TUpdaterCore }

function TUpdaterCore.needTreminte(var ErrorCode: integer; var ErrorMessage: string): boolean;
var
  NewVersion: TBytes;
begin
  Result := False;
  ErrorCode := -1;
  try
    if isNeedUpdate(CurrentVersion, NewVersion) then
      Result := true
    else
      removeTrash(CurrentVersion);
  except
    on e: exception do
    begin
      ErrorCode := 0;
      ErrorMessage := Error;
      Result := true;
    end;
  end;
end;

constructor TUpdaterCore.Create(ACurrentVersion: TBytes; AAutoCheck: boolean = true; ATimeCheck: integer = 10000);
begin
  CurrentVersion := ACurrentVersion;
  TimeCheck := ATimeCheck;
  NeedDestroy := TEvent.Create;
  TimerEvent := TEvent.Create;
  CancelUpdate := true;
end;

destructor TUpdaterCore.Destroy;
begin
  if CancelUpdate then
  begin
    TimerEvent.Free;
    NeedDestroy.Free;
  end
  else
  begin
    CancelUpdate := true;
    TimerEvent.SetEvent;
    NeedDestroy.WaitFor(600000);
    NeedDestroy.Free;
  end;

  inherited;
end;

procedure TUpdaterCore.DoInstall(const AFilePath: string);
begin
  case TOSVersion.Platform of
    pfWindows:
      begin
{$IFDEF MSWINDOWS}
        ShellExecute(0, 'open', PChar(AFilePath), nil, nil, SW_SHOWDEFAULT);
{$ENDIF}
      end;
    pfMacOS:
      begin
{$IFDEF MACOS}
        TNSWorkspace.Wrap(TNSWorkspace.OCClass.sharedWorkspace).openFile(NSStr(AFilePath));
{$ENDIF}
      end;
  end;
end;

procedure TUpdaterCore.DoUpdate;
var
  client: THTTPClient;
  UpdatePack: TMemoryStream;
  FileName, FilePath: string;
  counterProgressBar: integer;
  cancelationToken: boolean;
  EndDownload: TEvent;
begin
  client := THTTPClient.Create;
  UpdatePack := TMemoryStream.Create;
  try
    FileName := IntToStr(AVersion[0]) + '.' + IntToStr(AVersion[1]) + '.' + IntToStr(AVersion[2]) + '.zip';

    UpdatePack.Clear;
    counterProgressBar := 0;
    cancelationToken := False;
    try
      client.Get(LinkUpdatePack, UpdatePack);
      Notifyer.DoEvent(nOnDowloadUpdate);
    except
      cancelationToken := true;
    end;

    if not cancelationToken then
    begin
      FilePath := TPath.Combine(TPath.GetDownloadsPath, FileName);
      SaveFile(FilePath, UpdatePack);
      Notifyer.DoEvent(nOnSaveUpdatePackage);
      DoInstall(UnpackFile(FilePath));
      Notifyer.DoEvent(nOnStartInstall);
    end;

  finally
    client.Free;
    UpdatePack.Free;

    if cancelationToken then
      raise exception.Create('Error: Bad connect ot update server!')
    else
      Appcore.GetHandler.HandleCommand(CMD_DO_END_UPDATE, []);
  end;
end;

function TUpdaterCore.isNeedUpdate(ACurrentVersion: TBytes; var ANewVersion: TBytes): boolean;
var
  client: THTTPClient;
  response: TMemoryStream;
  JSON, JSONUpdaterPack: TJSONObject;
  name: string;
  version: string;
  Size: Int64;
  link: string;
  hash: string;
begin
  client := THTTPClient.Create;
  response := TMemoryStream.Create;
  JSON := TJSONObject.Create;
  Result := False;
  try
    client.Get(URL_VERSION, response);
    JSON.Parse(BytesOf(response.Memory, response.Size), 0);

    if JSON.TryGetValue(TypeNode, JSONUpdaterPack) then
    begin
      JSONUpdaterPack.TryGetValue('name', name);
      JSONUpdaterPack.TryGetValue('version', version);
      JSONUpdaterPack.TryGetValue('size', Size);
      JSONUpdaterPack.TryGetValue('link', link);
      JSONUpdaterPack.TryGetValue('hash', hash);
    end;

    var
      VersionArray: TArray<string>;
    VersionArray := SplitString(version, '.');
    ANewVersion := [];
    for var i := 0 to Length(VersionArray) - 1 do
      ANewVersion := ANewVersion + [strToInt(VersionArray[i])];

    if (ACurrentVersion[0] < ANewVersion[0]) or ((ACurrentVersion[0] <= ANewVersion[0]) and (ACurrentVersion[1] < ANewVersion[1])) or
      ((ACurrentVersion[0] <= ANewVersion[0]) and (ACurrentVersion[1] <= ANewVersion[1]) and (ACurrentVersion[2] < ANewVersion[2])) then
      Result := true;
    if Result then
    begin
      HashUpdatePack := hash;
      SizeUpdatePack := Size;
      LinkUpdatePack := link;
      AVersion := ANewVersion;
    end;

  except
    on e: Exception do
    begin
      Error := e.Message;
    end;
  end;
  response.Free;
  client.Free;
  JSON.Free;
end;

procedure TUpdaterCore.removeTrash(const ACurrentVersion: TBytes);
var
  FileName, FilePath: string;
begin
  FileName := IntToStr(ACurrentVersion[0]) + '.' + IntToStr(ACurrentVersion[1]) + '.' + IntToStr(ACurrentVersion[2]) + '.zip';

  FilePath := TPath.Combine(TPath.GetDownloadsPath, FileName);

  if TFile.Exists(FilePath) then
    TFile.Delete(FilePath);
end;

procedure TUpdaterCore.SaveFile(const AFilePath: string; AData: TMemoryStream);
var
  FileaHeandler: TFileStream;
begin
  if TFile.Exists(AFilePath) then
    TFile.Delete(AFilePath);

  FileaHeandler := TFile.Create(AFilePath);
  try
    FileaHeandler.Write(BytesOf(AData.Memory, AData.Size), AData.Size);
  finally
    FileaHeandler.Free;
  end;
end;

procedure TUpdaterCore.StartAutoUpdate;
begin
  CancelUpdate := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.CurrentThread.FreeOnTerminate := true;
      var
        NewVersion: TBytes;

      try
        while not(CancelUpdate) do
        begin
          try
            if isNeedUpdate(CurrentVersion, NewVersion) then
            begin
              DoUpdate;
              break;
            end;
          except
            TThread.CurrentThread.Terminate;
            break;
          end;

          TimerEvent.WaitFor(TimeCheck);
        end;
      finally
        TimerEvent.Free;
        NeedDestroy.SetEvent;
      end;
    end).Start;
end;

function TUpdaterCore.UnpackFile(const AFilePath: string): string;
var
  extractedName: string;
begin
  extractedName := '';
  var
  ZipFile := TZipFile.Create;
  try
    ZipFile.Open(AFilePath, TZipMode.zmRead);
    for var FileName in ZipFile.FileNames do
    begin
      ZipFile.Extract(FileName, TPath.GetDownloadsPath);
      extractedName := TPath.Combine(TPath.GetDownloadsPath, FileName);
    end;
  finally
    ZipFile.Free;
  end;
  Result := extractedName;
end;

end.
