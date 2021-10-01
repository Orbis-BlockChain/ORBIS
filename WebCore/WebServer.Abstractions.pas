unit WebServer.Abstractions;

interface

uses
  System.JSON,
  WebServer.HTTPTypes;

type

  IDataSource = interface
    function GetAccData(const Address, Net: String; Tokens: TStrings): TJSONObject;
    function GetAccDataDetails(const Tab, Address, Net: String; Tokens: TStrings;
      const PageID, Count: Integer; TransType: TTransType = All; DateFrom: String = '';
      DateTo: String = ''): TJSONObject;
    function GetTokenListData(const Address, Net: String): TJSONObject;
    function GetData(const Name: String; const PageID, Count: Integer; const Net: String): TJSONObject;
  end;

implementation

end.
