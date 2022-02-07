unit App.Abstractions;

interface

uses
    App.IHandlerCore,
    System.SysUtils,
    System.Classes;

type
    IAppCore = interface
        procedure DoRun;
        procedure ShowForm(AType: Byte; AArgs: TArray<string>);
        function GetHandler: IBaseHandler;
    end;

implementation

end.
