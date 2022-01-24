unit App.Paths;

interface

uses
  System.SysUtils,
  System.IOUtils;

const
  configExpansion = '.config';
  blockchainExpansion = '.bc';
  logExpansion = '.log';
  cryptoContainerExpansion = '.cc';

  configName = configExpansion;
  chainName = 'Chain' + blockchainExpansion;
  logName = 'Log' + logExpansion;
  cryptoContainerName = cryptoContainerExpansion;

type

  IBasePaths = interface
    function GetPathBlockChain: string;
    function GetPathLog: string;
    function GetPathCryptoContainer: string;
    function GetPathFastIndex: string;
  end;

  TMainPaths = class(TInterfacedObject, IBasePaths)
    function GetPathBlockChain: string;
    function GetPathLog: string;
    function GetPathCryptoContainer: string;
    function GetPathFastIndex: string;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TTestPaths = class(TInterfacedObject, IBasePaths)
    function GetPathBlockChain: string;
    function GetPathLog: string;
    function GetPathCryptoContainer: string;
    function GetPathFastIndex: string;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TLabPaths = class(TInterfacedObject, IBasePaths)
    function GetPathBlockChain: string;
    function GetPathLog: string;
    function GetPathCryptoContainer: string;
    function GetPathFastIndex: string;
    destructor Destroy; override;
  end;

  TPaths = class

  end;

implementation

{$REGION 'TMainPaths'}

function TMainPaths.GetPathBlockChain: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.main-blockchain');
    pfMacOS:
      Result := TPath.Combine(GetCurrentDir, '.main-blockchain');
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TMainPaths.GetPathCryptoContainer: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.main-cryptocontainer');
    pfMacOS:
      ;
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TMainPaths.GetPathFastIndex: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.main-fastindex');
    pfMacOS:
      ;
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TMainPaths.GetPathLog: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.main-log');
    pfMacOS:
      ;
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TMainPaths.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TMainPaths._AddRef: Integer;
begin
  Result := -1;
end;

function TMainPaths._Release: Integer;
begin
  Result := -1;
end;

{$ENDREGION}
{$REGION 'TTestPaths'}

function TTestPaths.GetPathBlockChain: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.test-blockchain');
    pfMacOS:
      ;
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TTestPaths.GetPathCryptoContainer: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.test-cryptocontainer');
    pfMacOS:
      ;
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TTestPaths.GetPathFastIndex: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.test-fastindex');
    pfMacOS:
      ;
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TTestPaths.GetPathLog: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(GetCurrentDir, '.test-log');
    pfMacOS:
      ;
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TTestPaths.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TTestPaths._AddRef: Integer;
begin
  Result := -1;
end;

function TTestPaths._Release: Integer;
begin
  Result := -1;
end;

{$ENDREGION}
{$REGION 'TLabPaths'}

destructor TLabPaths.Destroy;
begin

  inherited;
end;

function TLabPaths.GetPathBlockChain: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-blockchain');
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-blockchain');
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TLabPaths.GetPathCryptoContainer: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-cryptocontainer');
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-cryptocontainer');
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TLabPaths.GetPathFastIndex: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-fastindex');
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-fastindex');
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

function TLabPaths.GetPathLog: string;
begin
  case TOsversion.Platform of
    pfWindows:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-log');
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'ORBIS'), '.lab-log');
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

{$ENDREGION}

end.
