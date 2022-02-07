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
  end;

  TTestPaths = class(TInterfacedObject, IBasePaths)
    function GetPathBlockChain: string;
    function GetPathLog: string;
    function GetPathCryptoContainer: string;
    function GetPathFastIndex: string;
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-blockchain');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.main-blockchain');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-blockchain');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-cryptocontainer');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.main-cryptocontainer');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-cryptocontainer');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-fastindex');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.main-fastindex');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-fastindex');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-log');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.main-log');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.main-log');
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

{$ENDREGION}
{$REGION 'TTestPaths'}

function TTestPaths.GetPathBlockChain: string;
begin
  case TOsversion.Platform of
    pfWindows:
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-blockchain');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.test-blockchain');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-blockchain');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-cryptocontainer');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.test-cryptocontainer');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-cryptocontainer');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-fastindex');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.test-fastindex');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-fastindex');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-log');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.test-log');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.test-log');
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-blockchain');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.lab-blockchain');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-blockchain');
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
      begin

        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-cryptocontainer');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.lab-cryptocontainer');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-cryptocontainer');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-fastindex');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.lab-fastindex');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-fastindex');
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
      begin
        Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-log');
{$IFDEF DEBUG}
        Result := TPath.Combine(GetCurrentDir, '.lab-log');
{$ENDIF}
      end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), '.lab-log');
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
