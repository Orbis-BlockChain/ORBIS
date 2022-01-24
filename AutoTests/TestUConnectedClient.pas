unit TestUConnectedClient;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework,
  System.Generics.Collections,
  System.SysUtils,
  System.Threading,
  Net.ConnectedClient,
  System.Types,
  System.Net.Socket,
  System.Classes,
  Net.Core;

type
  TestTConnectedClient = class(TTestCase)
  strict private
    FNetCore: TNetCore;
    FConnectedClient: TConnectedClient;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnected;
    procedure TestCallBack;
    procedure TestStartReceive;
    procedure TestSendMessage;
  end;

implementation

procedure TestTConnectedClient.SetUp;
begin
  FNetCore := TNetCore.Create(nil);
end;

procedure TestTConnectedClient.TearDown;
begin
  FConnectedClient.Free;
  FConnectedClient := nil;
end;

procedure TestTConnectedClient.TestConnected;
var
  ReturnValue: Boolean;
begin
//  ReturnValue := FConnectedClient.Connected;

  CheckTrue(ReturnValue);
end;

procedure TestTConnectedClient.TestCallBack;
begin
  FConnectedClient.CallBack(nil);
  // TODO: Validate method results
end;

procedure TestTConnectedClient.TestStartReceive;
begin
  FConnectedClient.StartReceive;
  // TODO: Validate method results
end;

procedure TestTConnectedClient.TestSendMessage;
var
  AData: TArray<System.Byte>;
begin
  // TODO: Setup method call parameters
  FConnectedClient.SendMessage(AData);
  // TODO: Validate method results
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTConnectedClient.Suite);
end.

