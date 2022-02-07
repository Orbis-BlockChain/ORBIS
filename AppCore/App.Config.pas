unit App.Config;

interface

uses
  App.Types,
  App.Meta,
  App.Paths,
  System.Classes,
  System.TypInfo,
  System.Generics.Collections,
  System.JSON.Builders,
  System.JSON.writers,
  System.JSON.Readers,
  System.IOUtils,
  System.JSON.Types,
  System.SysUtils
  {$IFDEF GUII}
  ,Fmx.Platform
  {$ENDIF}
  ;

const
  DefaultMainNetIPs: TArray<string> = ['185.213.211.97'];
  PatchTestNetIP = '23.106.234.133';
  //DefaultTestNetIPs: TArray<string> = ['23.106.234.133'];
  DefaultTestNetIPs: TArray<string> = ['45.147.199.110'];
  DefaultLabNetIPs: TArray<string> = ['45.147.199.91'];
  DefaultMainNetPorts: TArray<string> = ['30200', '30200', '20200'];
  DefaultTestNetPorts: TArray<string> = ['30100', '30100', '20100'];
  DefaultLabNetPorts: TArray<string> = ['30000', '30000', '20000'];

type
  TConfig = class
  private
    FTypeNet: TNET;
    FConnectTo: TArray<string>;
    FApprovedConnections: TArray<string>;
    FServer: boolean;
    FAPIName: string;
    FAPIKey: string;
    FNodeState: TNodeState;
    FWalletName: string;
    FWalletPassword: string;
    FServerPort: word;
    FClientPort: word;
    FWebServerPort: word;
    FStaticIP: string;
    procedure SetDefaultParams;
    function TryReadConfig: boolean;
    procedure InitConfig;
    function GetLanguage: App.Meta.TLanguages;
    procedure CheckPaths;
  public

    property TypeNet: TNET read FTypeNet;
    property ConnectTo: TArray<string> read FConnectTo;
    property ApprovedConnections: TArray<string> read FApprovedConnections;
    property Server: boolean read FServer;
    property APIName: string read FAPIName;
    property APIKey: string read FAPIKey;
    property NodeState: TNodeState read FNodeState write FNodeState;
    property WalletName: string read FWalletName;
    property WalletPassword: string read FWalletPassword;
    property ServerPort: word read FServerPort;
    property ClientPort: word read FClientPort;
    property WebServerPort: word read FWebServerPort;
    property StaticIP: string read FStaticIP;
    property Language: App.Meta.TLanguages read GetLanguage;
    procedure SetTestNet;
    function ConfigDirectory: string;
    function DoConfigurate: boolean;
    function SaveConfigNet(snet: string): boolean;
    function DoChangeConfigurate(TagNet: NativeInt): boolean;
    function NodeStateAsStr: string;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TConfig }

function TConfig.DoChangeConfigurate(TagNet: NativeInt): boolean;
var
  OldFTypeNet: TNET;
  OldPaths: IBasePaths;

  OldFNodeState: TNodeState;
  OldFWalletName: string;
  OldFWalletPassword: string;
  OldFServerPort: word;
  OldFClientPort: word;
  OldFWebServerPort: word;

  OldFConnectTo: TArray<string>;
  OldFApprovedConnections: TArray<string>;
  OldFServer: boolean;
  OldFAPIName: string;
  OldFAPIKey: string;
  OldFStaticIP: string;
begin

  case TNET(TagNet) of
    TNET.MAINNET:
      begin
        FTypeNet := TNET.MAINNET;
        Paths := TMainPaths.Create;

        FNodeState := TNodeState.FullNode;
        FWalletName := '';
        FWalletPassword := '';
        FServerPort := strtoint(DefaultMainNetPorts[0]);
        FClientPort := strtoint(DefaultMainNetPorts[1]);
        FWebServerPort := strtoint(DefaultMainNetPorts[2]);

        FConnectTo := DefaultMainNetIPs;
        FApprovedConnections := [];
        FServer := false;
        FAPIName := 'SomeName';
        FAPIKey := 'SomePassword';
        FStaticIP := '127.0.0.1';

      end;
    TNET.LABNET:
      begin
        FTypeNet := TNET.LABNET;
        Paths := TLabPaths.Create;

        FNodeState := TNodeState.FullNode;
        FWalletName := '';
        FWalletPassword := '';
        FServerPort := strtoint(DefaultLabNetPorts[0]);
        FClientPort := strtoint(DefaultLabNetPorts[1]);
        FWebServerPort := strtoint(DefaultLabNetPorts[2]);

        FConnectTo := DefaultLabNetIPs;
        FApprovedConnections := [];
        FServer := false;
        FAPIName := 'SomeName';
        FAPIKey := 'SomePassword';
        FStaticIP := '127.0.0.1';

      end;
    TNET.TESTNET:
      begin
        FTypeNet := TNET.TESTNET;
        Paths := TTestPaths.Create;

        FNodeState := TNodeState.FullNode;
        FWalletName := '';
        FWalletPassword := '';
        FServerPort := strtoint(DefaultTestNetPorts[0]);
        FClientPort := strtoint(DefaultTestNetPorts[1]);
        FWebServerPort := strtoint(DefaultTestNetPorts[2]);

        FConnectTo := DefaultTestNetIPs;
        FApprovedConnections := [];
        FServer := false;
        FAPIName := 'SomeName';
        FAPIKey := 'SomePassword';
        FStaticIP := '127.0.0.1';

      end;
  end;

  CheckPaths;

  Result := True;

end;

function TConfig.DoConfigurate: boolean;
begin

  try
    if not TDirectory.Exists(ConfigDirectory) then
    begin
      TDirectory.CreateDirectory(ConfigDirectory);
      TFile.Create(TPath.Combine(ConfigDirectory, configName)).Destroy;
      InitConfig;
    end
    else
    begin
      if not TFile.Exists(TPath.Combine(ConfigDirectory, configName)) then
      begin
        TFile.Create(TPath.Combine(ConfigDirectory, configName)).Destroy;
        InitConfig;
      end
      else
      begin
        Result := TryReadConfig;
        if not Result then
          InitConfig;
      end;
    end;
    if not Result then
      Result := TryReadConfig;
    case FTypeNet of
      TNET.MAINNET:
        Paths := TMainPaths.Create;
      TNET.TESTNET:
        Paths := TTestPaths.Create;
      TNET.LABNET:
        Paths := TLabPaths.Create;
    else
      raise Exception.Create('Incorrect config');
    end;
    CheckPaths;

  except
    Result := false;
  end;

end;

{$IFDEF CONSOLEI}
function TConfig.GetLanguage: App.Meta.TLanguages;
begin
  Result := App.Meta.TLanguages.English;
  DecimalSeparator:= FormatSettings.DecimalSeparator;
  if DecimalSeparator = ',' then
    OldDecimalSeparator:= '.'
  else
    OldDecimalSeparator:= ',';
end;
{$ELSE}
function TConfig.GetLanguage: App.Meta.TLanguages;
var
  LocaleSvc: IFMXLocaleService;
  fs: TFormatSettings;
begin
  fs := TFormatSettings.Invariant;
  Result := App.Meta.TLanguages.English;
  if TPlatformServices.Current.SupportsPlatformService(IFMXLocaleService, LocaleSvc) then
    if LocaleSvc.GetCurrentLangID = 'ru' then
      Result := App.Meta.TLanguages.Russian
    else
      Result := App.Meta.TLanguages.English;

  DecimalSeparator:= FormatSettings.DecimalSeparator;
  if DecimalSeparator = ',' then
    OldDecimalSeparator:= '.'
  else
    OldDecimalSeparator:= ',';

end;
{$ENDIF}

function TConfig.ConfigDirectory: string;
begin
  case TOsversion.Platform of
    pfWindows:
    begin
     Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), configName);
{$IFDEF DEBUG}
      Result := TPath.Combine(GetCurrentDir, configName);
{$ENDIF}
    end;
    pfMacOS:
      Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ORBIS'), configName);
    pfiOS:
      ;
    pfAndroid:
      ;
    pfLinux:
      ;
  end;
end;

constructor TConfig.Create;
begin

end;

destructor TConfig.Destroy;
begin

end;

procedure TConfig.CheckPaths;
begin
  if not TDirectory.Exists(Paths.GetPathBlockChain) then
    TDirectory.CreateDirectory(Paths.GetPathBlockChain);
  if not TDirectory.Exists(Paths.GetPathLog) then
    TDirectory.CreateDirectory(Paths.GetPathLog);
  if not TDirectory.Exists(Paths.GetPathCryptoContainer) then
    TDirectory.CreateDirectory(Paths.GetPathCryptoContainer);
  if not TDirectory.Exists(Paths.GetPathFastIndex) then
    TDirectory.CreateDirectory(Paths.GetPathFastIndex);
end;

procedure TConfig.InitConfig;
var
  configFile: TextFile;
  Builder: TJSONObjectBuilder;
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  IP: string;
begin
  StringBuilder := TStringBuilder.Create;
  StringWriter := TStringWriter.Create(StringBuilder);
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);

  try
    AssignFile(configFile, TPath.Combine(ConfigDirectory, configName));
    Builder.BeginObject.BeginObject('NetConfig').
{$IFDEF MAINNET}
      Add('TypeNet', 'MAINNET').Add('staticIP', '127.0.0.1').BeginArray('ConnectTo').Add(DefaultMainNetIPs[0])
      .EndArray.BeginArray('ApprovedConnections').EndArray.Add('ServerPort', DefaultMainNetPorts[0]).Add('ClientPort', DefaultMainNetPorts[1])
      .Add('WebServerPort', DefaultMainNetPorts[2]).Add('NodeState', 'FullNode').Add('Wallet', '').Add('Pass', '').
{$ENDIF}
{$IFDEF TESTNET}
      Add('TypeNet', 'TESTNET').Add('staticIP', '127.0.0.1').BeginArray('ConnectTo').Add(DefaultTestNetIPs[0])
      .EndArray.BeginArray('ApprovedConnections').EndArray.Add('ServerPort', DefaultTestNetPorts[0]).Add('ClientPort', DefaultTestNetPorts[1])
      .Add('WebServerPort', DefaultTestNetPorts[2]).Add('NodeState', 'FullNode').Add('Wallet', '').Add('Pass', '').
{$ENDIF}
{$IFDEF LABNET}
      Add('TypeNet', 'LABNET').Add('staticIP', '127.0.0.1').BeginArray('ConnectTo').Add(DefaultLabNetIPs[0])
      .EndArray.BeginArray('ApprovedConnections').EndArray.Add('ServerPort', DefaultLabNetPorts[0]).Add('ClientPort', DefaultLabNetPorts[1])
      .Add('WebServerPort', DefaultLabNetPorts[2]).Add('NodeState', 'FullNode').Add('Wallet', '').Add('Pass', '').
{$ENDIF}
      EndObject.BeginObject('APIConfig').Add('Server', false).Add('APIName', 'SomeName').Add('APIKey', 'SomeKey').EndObject.EndObject;

    Rewrite(configFile);
    Write(configFile, StringBuilder.ToString);
    Close(configFile);
  finally
    Builder.Free;
    Writer.Free;
    StringWriter.Free;
    StringBuilder.Free;
//    SetDefaultParams;
  end;
end;

function TConfig.NodeStateAsStr: string;
begin
  Result := GetEnumName(TypeInfo(TNodeState), ord(FNodeState));
end;

function TConfig.SaveConfigNet(snet: string): boolean;
var
  configFile: TextFile;
  Builder: TJSONObjectBuilder;
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  StringBuilder: TStringBuilder;
  IP: string;
  TypeNetS: string;
  ConnectToS: TArray<string>;
  ServerPortS: string;
  ClientPortS: string;
  WebServerPortS: string;
  NodeStateS: string;
begin
  if ((snet = 'MAINNET') or (snet = 'TESTNET') or (snet = 'LABNET') or (snet = 'Validator') or (snet = 'FullNode')) then
  begin

    StringBuilder := TStringBuilder.Create;
    StringWriter := TStringWriter.Create(StringBuilder);
    Writer := TJsonTextWriter.Create(StringWriter);
    Writer.Formatting := TJsonFormatting.Indented;
    Builder := TJSONObjectBuilder.Create(Writer);

    try
      AssignFile(configFile, TPath.Combine(ConfigDirectory, configName));
      if snet = 'MAINNET' then
      begin
        Builder.BeginObject.BeginObject('NetConfig').Add('TypeNet', 'MAINNET').Add('staticIP', '127.0.0.1').BeginArray('ConnectTo')
          .Add(DefaultMainNetIPs[0]).EndArray.BeginArray('ApprovedConnections').EndArray.Add('ServerPort', DefaultMainNetPorts[0])
          .Add('ClientPort', DefaultMainNetPorts[1]).Add('WebServerPort', DefaultMainNetPorts[2]).Add('NodeState', NodeStateAsStr).Add('Wallet', '')
          .Add('Pass', '').EndObject.BeginObject('APIConfig').Add('Server', false).Add('APIName', 'SomeName').Add('APIKey', 'SomeKey')
          .EndObject.EndObject;
      end;

      if snet = 'TESTNET' then
      begin
        Builder.BeginObject.BeginObject('NetConfig').Add('TypeNet', 'TESTNET').Add('staticIP', '127.0.0.1').BeginArray('ConnectTo')
          .Add(DefaultTestNetIPs[0]).EndArray.BeginArray('ApprovedConnections').EndArray.Add('ServerPort', DefaultTestNetPorts[0])
          .Add('ClientPort', DefaultTestNetPorts[1]).Add('WebServerPort', DefaultTestNetPorts[2]).Add('NodeState', NodeStateAsStr).Add('Wallet', '')
          .Add('Pass', '').EndObject.BeginObject('APIConfig').Add('Server', false).Add('APIName', 'SomeName').Add('APIKey', 'SomeKey')
          .EndObject.EndObject;
      end;

      if snet = 'LABNET' then
      begin
        Builder.BeginObject.BeginObject('NetConfig').Add('TypeNet', 'LABNET').Add('staticIP', '127.0.0.1').BeginArray('ConnectTo')
          .Add(DefaultLabNetIPs[0]).EndArray.BeginArray('ApprovedConnections').EndArray.Add('ServerPort', DefaultLabNetPorts[0])
          .Add('ClientPort', DefaultLabNetPorts[1]).Add('WebServerPort', DefaultLabNetPorts[2]).Add('NodeState', NodeStateAsStr).Add('Wallet', '')
          .Add('Pass', '').EndObject.BeginObject('APIConfig').Add('Server', false).Add('APIName', 'SomeName').Add('APIKey', 'SomeKey')
          .EndObject.EndObject;
      end;

      if ((snet = 'Validator') or (snet = 'FullNode')) then
      begin
        NodeStateS := snet;
        TypeNetS := GetEnumName(TypeInfo(TNet),ord(FTypeNet));
        ConnectToS := Self.FConnectTo;
        ServerPortS := Self.FServerPort.ToString;
        ClientPortS := Self.FClientPort.ToString;
        WebServerPortS := Self.FWebServerPort.ToString;

        Builder.BeginObject.BeginObject('NetConfig').Add('TypeNet', TypeNetS).Add('staticIP', StaticIP).BeginArray('ConnectTo').Add(ConnectTo[0])
          .EndArray.BeginArray('ApprovedConnections').EndArray.Add('ServerPort', ServerPortS).Add('ClientPort', ClientPortS)
          .Add('WebServerPort', WebServerPortS).Add('NodeState', NodeStateS).Add('Wallet', WalletName).Add('Pass', WalletPassword).EndObject.BeginObject('APIConfig')
          .Add('Server', false).Add('APIName', 'SomeName').Add('APIKey', 'SomeKey').EndObject.EndObject;
      end;

      Rewrite(configFile);
      Write(configFile, StringBuilder.ToString);
      Close(configFile);
    finally
      Builder.Free;
      Writer.Free;
      StringWriter.Free;
      StringBuilder.Free;
    end;
  end;
end;

procedure TConfig.SetDefaultParams;
begin
  FNodeState := TNodeState.FullNode;
  FWalletName := '';
  FWalletPassword := '';
  FServerPort := 30100;
  FClientPort := 30100;
  FWebServerPort := 20100;

  FTypeNet := TNET.TESTNET;
  FConnectTo := DefaultTESTNetIPs;
  FApprovedConnections := [];
  FServer := false;
  FAPIName := 'SomeName';
  FAPIKey := 'SomePassword';
  FStaticIP := '127.0.0.1';
end;

procedure TConfig.SetTestNet;
begin

end;

function TConfig.TryReadConfig: boolean;
var
  configFile: TextFile;
  JSON: TJSONIterator;
  Reader: TJsonTextReader;
  TextReader: TStringReader;
  cJsonStr, buf: string;
begin
  // SetDefaultParams
  try
    cJsonStr := '';
    AssignFile(configFile, TPath.Combine(ConfigDirectory, configName));
    Reset(configFile);
    while not Eof(configFile) do
    begin
      ReadLn(configFile, buf);
      cJsonStr := cJsonStr + buf;
    end;
    Close(configFile);
  except
    Result := false;
  end;

  try
    TextReader := TStringReader.Create(cJsonStr);
    Reader := TJsonTextReader.Create(TextReader);
    JSON := TJSONIterator.Create(Reader);
    JSON.Next('NetConfig');
    JSON.Recurse;
    JSON.Next;

    var
      NetState: string := JSON.AsString;

    FTypeNet := TNET(GetEnumValue(TypeInfo(TNET), NetState));

    JSON.Next('StaticIP');
    FStaticIP := JSON.AsString;

    JSON.Next('ConnectTo');
    if JSON.&type = TJsonToken.StartArray then
    begin
      JSON.Recurse;
      while JSON.Next do
        begin
          var tmp:=JSON.AsString;
          if tmp = PatchTestNetIP then tmp := DefaultTestNetIPs[0];
          FConnectTo := FConnectTo + [tmp];
        end;
      JSON.Return;
    end;

    if Length(FConnectTo) = 0 then
      FConnectTo := DefaultLabNetIPs;

    JSON.Next('ApprovedConnections');
    if JSON.&type = TJsonToken.StartArray then
    begin
      JSON.Recurse;
      while JSON.Next do
        FApprovedConnections := FApprovedConnections + [JSON.AsString];
      JSON.Return;
    end;

    JSON.Next('ServerPort');

    var
    LServerPort := JSON.AsString;

    FServerPort := strtoint(LServerPort);

    JSON.Next('ClientPort');

    var
    LClientPort := JSON.AsString;

    FClientPort := strtoint(LClientPort);

    JSON.Next('WebServerPort');

    var
    LWebServerPort := JSON.AsString;

    FWebServerPort := strtoint(LWebServerPort);

    JSON.Next('NodeState');

    var
    LNodeState := JSON.AsString;

    FNodeState := TNodeState(GetEnumValue(TypeInfo(TNodeState), LNodeState));
    LNodeState := '';

    JSON.Next('Wallet');

    FWalletName := JSON.AsString;

    JSON.Next('Pass');

    FWalletPassword := JSON.AsString;

    JSON.Return;

    JSON.Find('APIConfig');

    JSON.Recurse;
    JSON.Next;
    FServer := JSON.AsBoolean;

    JSON.Next;
    FAPIName := JSON.AsString;

    JSON.Next;
    FAPIKey := JSON.AsString;
    JSON.Return;

    Result := True;
  except
    SetDefaultParams;
  end;

  JSON.Destroy;
  Reader.Destroy;
  TextReader.Destroy;
end;

end.
