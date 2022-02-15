unit WebServer.Abstractions;

interface

uses
  System.JSON,
  BlockChain.ServiceResult,
  WebServer.HTTPTypes;

type

  IDataSource = interface
    function GenNewCrypto(const Password: String): TJSONObject;
    function GenNewTransaction(const FAddress, FPass, FTo, FToken, FAmount: String; FFee: Double = 0): TJSONObject;
    function CheckTransaction(const FOwnerSign: String): TJSONObject;
    function GenNewToken(const FAddress, FPass, FName, FSymbol: String; FEmission, FCapacity: UInt64): TJSONObject;
    function BuyOM(const FAddress, FPass: String): TJSONObject;
    function CheckOM(const Address: String): TJSONObject;
    function OpenWallet(const Address, Pass: String): TJSONObject;
    function RestoreCryptoContainerKeys(Keys: TStrings; Pass: String): TJSONObject;
    function CheckCryptoContainerKeys(Keys: TStrings): TJSONObject;
    function GetAccBalances(const Address: String): TJSONObject;
    function GetAccData(const Address: String; Tokens: TStrings): TJSONObject;
    function GetAccDataDetails(const Tab, Address: String; Tokens: TStrings;
      const PageID, Count: Integer; TransType: TTransType = All; DateFrom: String = '';
      DateTo: String = ''): TJSONObject;
    function GetTokenListData(const Address: String): TJSONObject;
    function GetGlobalData(const Name: String; const PageID, Count: Integer;
      const SortBy: String = 'blocknum'; const Inverse: Boolean = False): TJSONObject;
    function GetTransData(const Hash: String): TJSONObject;
    function GetTokenInfoData(const Symbol: String): TJSONObject;
    function GetWalletBalance(const Address, Token: String): TJSONObject;
    function GetTokenTransactions(const Tab, Symbol: String; const PageID, Count: Integer): TJSONObject;
    function GetStatisticsData(const Tab: String; DateFrom: String = ''; DateTo: String = '';
      const Step: Int64 = 86400): TJSONObject;
    function GetMiningData: TJSONObject;
    function GetMinedData(const PageID, Count: Integer;
      const SortBy: String = 'datetime'; const Inverse: Boolean = False): TJSONObject;

    function RegNewService(const FAddress, FPass, Name: String): TJSONObject;
    function SetServiceData(const FAddress, FPass, Name: String; Data: TSRData): TJSONObject;
    function GetServiceData(const Name: String): TJSONObject;
    function GetServiceInfo(const Name: String): TJSONObject;
  end;

implementation

end.
