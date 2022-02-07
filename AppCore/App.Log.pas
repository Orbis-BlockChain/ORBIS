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
    cs: TCriticalSection;
    procedure DoLogR(NameProc: string; State: TLogStates; Msg: string);
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

var
  MyClientsLog: TLogs;
  ConnectedClientsLog: TLogs;
  BlockChainLogs: TLogs;
  HTTPLog: TLogs;
  WebServerLog: TLogs;
  ConsensusLog: TLogs;
  WalletCoreLog: TLogs;

implementation

{ TWebServerLogs }

constructor TLogs.Create(AName, APath: String);
begin
  cs := TCriticalSection.Create;
  Init(AName, APath);
  Name := AName;
end;

destructor TLogs.Destroy;
begin
  cs.Free;
end;

procedure TLogs.CreateFolder;
begin
  TDirectory.CreateDirectory(PathName);
end;

procedure TLogs.CreateLogFile;
begin
  AssignFile(LogFile, PathName);
{$IFDEF CONSOLEI}
  if TFile.Exists(PathName) then
    Reset(LogFile)
  else
    Rewrite(LogFile);
{$ENDIF}
{$IFDEF GUII}
  Rewrite(LogFile);
{$ENDIF}
  CloseFile(LogFile);
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

procedure TLogs.DoLogR(NameProc: string; State: TLogStates; Msg: string);
begin
end;

procedure TLogs.DoLog(NameProc: string; State: TLogStates; Msg: string);
var
  Value: string;
begin
  try
    if (length(trim(PathName)) = 0) then
      Exit;
    if not(TFile.Exists(PathName)) then
      Init(Name, Path);
  except
    Exit
  end;
  try
    Value := //'[' + IntToStr(TThread.CurrentThread.ThreadID) + ']'
            Format('[%.*d]',[8,TThread.CurrentThread.ThreadID])
//        + '[' + DateTimeToStr((TTimeZone.Local.ToUniversalTime(now))) + ']'
        + '[' + FormatDateTime('yyyy.mm.dd hh:nn:ss.zzz',TTimeZone.Local.ToUniversalTime(now)) + ']'
        + '[' + NameProc + ']'
        + '[' + GetEnumName(TypeInfo(TLogStates), Ord(State)) + ']'
        + '[' + Msg + ']';
  except
    Exit;
  end;
  try
    cs.Enter;
    Assign(LogFile, PathName);
    Append(LogFile);
    Writeln(LogFile, Value);
    Close(LogFile);
  finally
    cs.Leave;
  end;

end;

procedure TLogs.DoRequest(NameProc, ReqText: String);
begin
  DoLog(NameProc, lsNormal, ReqText);
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
  try
    cs.Enter;
    CreateLogFile;
  finally
    cs.Leave;
  end;
end;

end.
