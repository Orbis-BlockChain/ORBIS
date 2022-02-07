unit App.Tools;

interface
uses
{$IFDEF MSWINDOWS}


  Winapi.Windows,
  Winapi.ShellAPI,
  vcl.Forms,
{$ENDIF}
  System.Classes,
  System.Net.HttpClient,
  SYstem.JSON,
  System.SysUtils,
  System.IOUtils;
type
  TTools = class
  private
  public
    procedure Restart;
  end;
function GetMyIP: string;
implementation
{$IFDEF MACOS}

uses
  MacApi.AppKit, MacApi.Foundation, MacApi.CoreFoundation, MacApi.Helpers;
{$ENDIF}
{ TTools }

procedure TTools.Restart;
{$IFDEF MACOS}
var
  path: NSString;
  name: NSString;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ShellExecute(0, 'open', PChar(Application.ExeName), nil, nil, SW_SHOWDEFAULT);
{$ENDIF}
{$IFDEF MACOS}
  name := NSSTR(String(PAnsiChar(UTF8Encode('ORBIS'))));
  path := TNSWorkspace.Wrap(TNSWorkspace.OCClass.sharedWorkspace).fullPathForApplication(name);
  TNSWorkspace.Wrap(TNSWorkspace.OCClass.sharedWorkspace).openFile(path);
{$ENDIF}
end;

function GetMyIP: string;
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
  Result := '';
  try
    client.Get('http://api.myip.com', response);
    JSON.Parse(BytesOf(response.Memory, response.Size), 0);
    JSON.TryGetValue('ip', result);

  finally
    response.Free;
    client.Free;
    JSON.Free;
  end;
end;
end.
