unit Net.IClient;

interface

uses
  System.SysUtils;

type
  IClient = interface
    procedure SetID(ID: UInt64);
    function GetID: UInt64;
    property IDNode: UInt64 read GetID write SetID;
    function SendMessage(const AData: TBytes): integer;
    function GetIP: string;

  end;

implementation

end.
