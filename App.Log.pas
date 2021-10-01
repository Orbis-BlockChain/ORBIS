unit App.Log;

interface

uses
  App.Paths,
  System.TypInfo,
  System.DateUtils,
  System.Classes,
  System.IOUtils,
  System.SyncObjs,
  System.SysUtils;

type
  TLogStates = (lsStart, lsEnd, lsError, lsAllert, lsNormal);

  TLogs = class
  private
    Path: string;
    PathName: string;
    Name: String;
    LogFile: TextFile;
    CriticalSection: TCriticalSection;
    procedure DoLog(NameProc: string; State: TLogStates; Msg: string);
    procedure Init(AName, APath: string);
    procedure CreateLogFile;
    procedure CreateFolder;
  public
    constructor Create(AName, APath: string);
    procedure DoStartProcedure(NameProcedure: String = '');
    procedure DoEndProcedure(NameProcedure: String = '');
    procedure DoRequest(NameProc: String; ReqText: String);
    procedure DoError(NameProc: string; Msg: string);
    procedure DoAlert(NameProc: string; Msg: string);
    property LogsPath: String read PathName;
    destructor Destroy; override;
  end;

implementation

{ TWebServerLogs }

constructor TLogs.Create(AName, APath: String);
begin
  Init(AName, APath);
  Name := AName;
  CriticalSection := TCriticalSection.Create;
end;

destructor TLogs.Destroy;
begin
  CriticalSection.Release;
  CriticalSection.Destroy;
end;

procedure TLogs.CreateFolder;
begin
  TDirectory.CreateDirectory(PathName);
end;

procedure TLogs.CreateLogFile;
begin
  Assign(LogFile, PathName);
  Rewrite(LogFile);
  Close(LogFile);
end;

procedure TLogs.DoAlert(NameProc, Msg: string);
begin
  DoLog(NameProc, lsAllert, 'Allert Message: ' + Msg);
end;

procedure TLogs.DoEndProcedure(NameProcedure: String);
begin
  DoLog(NameProcedure, lsEnd, 'End procedure');
end;

procedure TLogs.DoError(NameProc, Msg: string);
begin
  DoLog(NameProc, lsError, 'Error: ' + UpperCase(Msg));
end;

procedure TLogs.DoLog(NameProc: string; State: TLogStates; Msg: string);
var
  Value: string;
begin
  Value := '[' + IntToStr(TThread.CurrentThread.ThreadID) + ']' + '[' + DateTimeToStr(Now) + ']' + '[' + NameProc + ']' + '['
  + GetEnumName(TypeInfo(TLogStates), Ord(State)) + ']' + '[' + Msg + ']';

  if not(TFile.Exists(PathName)) then
    Init(Name, Path);

end;

procedure TLogs.DoRequest(NameProc, ReqText: String);
begin
  DoLog(NameProc, lsStart, ReqText);
end;

procedure TLogs.DoStartProcedure(NameProcedure: String);
begin
  DoLog(NameProcedure, lsStart, 'Start Procedure');
end;

procedure TLogs.Init(AName, APath: string);
begin
  Path := APath;
  PathName := TPath.Combine(Path, AName) + logExpansion;
  if not TDirectory.Exists(Path) then
    CreateFolder;

  if TFile.Exists(PathName) then
  begin
    Assign(LogFile, PathName);
    Reset(LogFile);
    if FileSize(LogFile) > 165000 then
    begin
      Close(LogFile);
      CreateLogFile;
    end
    else
      Close(LogFile);
  end
  else
    CreateLogFile;
end;

end.
