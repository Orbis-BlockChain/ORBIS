unit Net.IClient;

interface

uses
  System.SysUtils;

type
  IClient = interface
    procedure SetID(ID: UInt64);
    procedure DoLog(AProc,AMsg: string);
    function GetID: UInt64;
    function SendMessage(const AData: TBytes): integer;
    function GetIP: string;
    property IDNode: UInt64 read GetID write SetID;
  end;

implementation

end.
