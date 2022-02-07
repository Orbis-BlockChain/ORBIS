unit Consensus.Types;

interface

uses
  System.SysUtils
  ,System.Classes
  ,System.Hash

  ,System.Generics.Collections

  ,System.SyncObjs
//  ,App.Types
  ,Net.Client

  ,RSA.main
  ,System.DateUtils
  ;

const
  {FormatDateTime}
  FormatDateTimeRU = 'dd.mm.yy hh:nn:ss.zzz';
  FormatDateTimeEU = 'yy.mm.dd hh:nn:ss.zzz';
  FormatTimeFull = 'hh:nn:ss.zzz';

  sPrk = '0x0002000048000000100000001000000069283085c563b1ed04d147f7f82bbd71bf4ad957dd01f67d7697b719e632d48fd7b58db732e3bcb8d9cbb0cb6c2895bded9e4c4f29af6da65aa5fea4287a8d2b48000000'
       + '10000000100000008be5381dbca1cadc951755359a1eef3f3740855700acefa11c598170e3fd024fe42309257797287be68720dd9dc5b8d3f36988df701f49c491c3a9181bfc081d0c000000010000000100000003'
       + '00000028000000080000000800000095ca79466104785424c5c99b31115aee4141111dd2412ba2980c7917b3f393e92800000008000000080000008505e112ca6c09ce7f687e0be06c7ca32a2980b70a3ee3e83285'
       + '7cd95dc2bb2f4800000010000000100000005058d52b9af22fcb60a3ff4fe7ade6df52e047830082e7f2aa05c228d57c8476d6b58db732e3bcb8d9cbb0cb6c2895bded9e4c4f29af6da65aa5fea4287a8d2b280000'
       + '00080000001000000063dcfb2e96adfae2c2d8db67760b3cf42bd660138cd61c6c10b350baccf7b79b2800000008000000080000000359eb6131f3b0deff9aa90740f352c2711b002507d4ec45770353e69381d21f'
       ;
  sPbK = '0x0002000048000000100000001000000069283085c563b1ed04d147f7f82bbd71bf4ad957dd01f67d7697b719e632d48fd7b58db732e3bcb8d9cbb0cb6c2895bded9e4c4f29af6da65aa5fea4287a8d2b0c000000010000000100000003000000';

  MAX = UInt64.MaxValue;
type

///===================================================================
///
  TVInf = record
  const
    sNope = 00;
    sOK   = 01;
    sNO   = 02;
  public
    ID: UInt64;
    Step: array [1..6] of Byte;

    procedure Clear;
  end;

  TQuorumList = record
    IDMainNode: UInt64;
    IDIter: Integer;
    CurrentStep: Integer;
    LastTmCheck: TDateTime;
    Quorum: array of TVInf;

    procedure Init(AIDMainNode: UInt64; AIDIter: Integer; ACurrentStep: Integer);
    procedure Add(AValInf: TVInf);
    procedure SetIDStep(AIDStep: Integer; AID: UInt64; AState: Byte);
    function CheckStep(AIDStep: Integer): Boolean;

    procedure Clear;
  end;
///
///===================================================================


  TUint64Helper = record helper for UInt64
  public
    const
      MaxValue = 18446744073709551615;
      MinValue = 0;
    function ToBytes: TBytes;
    function ToString: string;
    procedure SetBytes(AData: TBytes);
  end;


  TArrayOfUInt64 = record
  type
    tData = UInt64;
    arrUint64 = array of tData;
  private
    function GetSize(): Word;
    procedure SetSize(ASize: Word);
  public
    FSize: Word;
    IDOrator: UInt64;
    IDIter: UInt64;
    Count: Word;
    Data: arrUint64;

    class function Empty: TArrayOfUInt64; static;

    class operator Equal(const AData1, AData2: TArrayOfUInt64): Boolean;
    class operator NotEqual(const AData1, AData2: TArrayOfUInt64): Boolean;

    class operator Implicit(const AData: TBytes): TArrayOfUInt64;
    class operator Implicit(var AData: TArrayOfUInt64): TBytes;
    class operator Implicit(const AData: TArrayOfUInt64): string;

//    property Size: Word read GetSize write SetSize;

    function add(AData: tData): Integer;
    function Exists(AData: tData): Boolean;
    function Len: Integer;
    function MinLen: Integer;
    function IsEmpty: Boolean;
    function ToString: string;
    function ToBytes: TBytes;
    procedure Clear;
  end;

  TText = record
    DataSize: Word;
    Data: TBytes;
    class operator Equal(const AData1, AData2: TText): Boolean;
    class operator NotEqual(const AData1, AData2: TText): Boolean;

    class operator Implicit(const AData: string): TText;
    class operator Implicit(const AData: TText): string;
    class operator Implicit(const AData: TText): TBytes;
    class operator Implicit(const AData: TBytes): TText;

    procedure Clear;
    function Len:Integer;
    function ToString: string;
    function ToBytes: TBytes;
  end;

  THash32 = record
  const
    HASH_LEN = 32;
  private
    function ByteToHex(InByte:byte):string;
    function BytesToHex(const dat: TBytes):string;
    function BytesToHexStr(const AData: TBytes): string;
    function GetHash(AData: TBytes):TBytes;
  public
    Size: Byte;
    Data: TBytes;

    class function Empty: THash32; static;

    class operator Equal(const AData1, AData2: THash32): Boolean;
    class operator NotEqual(const AData1, AData2: THash32): Boolean;

    class operator Implicit(const AData: THash32): TBytes;
    class operator Implicit(const AData: TBytes): THash32;
    class operator Implicit(const AData: THash32): string;

    procedure SetHash(AData: TBytes); // calculate hash

    function ToBytes: TBytes;
    function ToString: string;
    function Len: Byte;
    function MinLen: Byte;
    function IsEmpty: Boolean;
    procedure Clear;
  end;

  TUnixTime = record
    Data: Int64;

    class function Empty: TUnixTime; static;

    class operator Equal(const AData1, AData2: TUnixTime): Boolean;
    class operator NotEqual(const AData1, AData2: TUnixTime): Boolean;

    class operator Implicit(const AData: TUnixTime): TDateTime;
    class operator Implicit(const AData: TDateTime): TUnixTime;
    class operator Implicit(const AData: Int64): TUnixTime;
    class operator Implicit(const AData: TUnixTime): Int64;
    class operator Implicit(const AData: TUnixTime): string;

    function ToString: string;
    function ToTDateTime: TDateTime;
    function Len: Byte;
    function IsEmpty: Boolean;
    procedure Clear;
  end;



  TNodeState = record
  private
    function BooleanToStr(AData: Boolean): string;
  public
    Size: Word;
    IDNode: UInt64;
    Enable: Boolean;
    IDLastBlock: UInt64;
//    UnixTime: TUnixTime;
    UnixTime: Int64;
    HashLastBlock: THash32;

    class function Empty: TNodeState; static;

    class operator Equal(const AData1, AData2: TNodeState): Boolean;
    class operator NotEqual(const AData1, AData2: TNodeState): Boolean;

    class operator Implicit(const AData: TNodeState): TBytes;
    class operator Implicit(const AData: TBytes): TNodeState;
    class operator Implicit(const AData: TNodeState): string;

    procedure SetState(AIDNode: UInt64; AEnable: Boolean;
                        AIDLastBlock: UInt64; AHashLastBlock: THash32);

    function ToBytes: TBytes;
    function ToString: string;
    function MinLen: Byte;
    function Len: Byte;
    function IsEmpty: Boolean;
    procedure Clear;
  end;

  TNetAddr = record
  const
    LenIPv4 = 4;
    msgErrCheckRecord = 'Error record TNetAddr';
  public
    IPv4: array [0..Pred(LenIPv4)] of Byte;
    Port: Word;

    class function Empty: TNetAddr; static;
    class function CheckRecord: Boolean; static;

    class operator Equal(const AData1, AData2: TNetAddr): Boolean;
    class operator NotEqual(const AData1, AData2: TNetAddr): Boolean;

    class operator Implicit(const S: string): TNetAddr;
    class operator Implicit(const AData: TNetAddr): TBytes;
    class operator Implicit(const AData: TNetAddr): string;
    class operator Implicit(const AData: TBytes): TNetAddr;
    procedure Clear;
    function Len: Integer;
    function IsLocalHost: Boolean;
    function ToString: string;
    function ToIPv4: string;
    function ToPort: Word;
    function ToBytes: TBytes;
    function IsEmpty: Boolean;
  end;
{
  TPubKey = record
//    PubKey: Tbytes;
    PubKey: TPublicKey;

    class function Empty: TPubKey; static;

    class operator Equal(const AData1, AData2: TPubKey): Boolean;
    class operator NotEqual(const AData1, AData2: TPubKey): Boolean;

    class operator Implicit(const AData: TPubKey): TBytes;
    class operator Implicit(const AData: TBytes): TPubKey;
    class operator Implicit(const AData: string): TPubKey;
    class operator Implicit(const AData: TPubKey): string;

    procedure Clear;
    procedure GetPbK(APrivateKey: TPrivateKey);
    function Len: Integer;
    function ToString: string;
    function ToBytes: TBytes;
  end;
}
  TPubKey2 = record
    Data: Tbytes;
//    PubKey: TPublicKey;

    class function Empty: TPubKey2; static;

    class operator Equal(const AData1, AData2: TPubKey2): Boolean;
    class operator NotEqual(const AData1, AData2: TPubKey2): Boolean;

    class operator Implicit(const AData: TPubKey2): TBytes;
    class operator Implicit(const AData: TBytes): TPubKey2;

    class operator Implicit(const AData: TPubKey2): TPublicKey;
    class operator Implicit(const AData: TPublicKey): TPubKey2;

    class operator Implicit(const AData: string): TPubKey2;
    class operator Implicit(const AData: TPubKey2): string;

    procedure Clear;
    procedure GetPbK(APrivateKey: TPrivateKey);
    function Len: Integer;
    function IsEmpty: Boolean;
    function ToString: string;
    function ToBytes: TBytes;
    function ToPbK: TPublicKey;
  end;
  TPubKey = TPubKey2;

  TPrivKey = record
  const
    SizeKey = 0 or 128 or 256 or 512 or 1024 or 2048 or 4096;
  type
    TSizeKey = Word;
  public
    PrivKey: TPrivateKey;

    class function Empty: TPrivKey; static;

    class operator Equal(const AData1, AData2: TPrivKey): Boolean;
    class operator NotEqual(const AData1, AData2: TPrivKey): Boolean;

    class operator Implicit(const AData: TPrivKey): TBytes;
    class operator Implicit(const AData: TBytes): TPrivKey;
    class operator Implicit(const AData: string): TPrivKey;
    class operator Implicit(const AData: TPrivKey): string;

    procedure Clear;
    procedure GenPrK(ASizeKey: TSizeKey);
    function Len: Integer;
    function ToString: string;
    function ToBytes: TBytes;
  end;

  TSign = record
    Size: Word;
    IDKey: UInt64;
    KeySize: Word;
    Data: TBytes;

    class function Empty: TSign; static;

    class operator Equal(const AData1, AData2: TSign): Boolean;
    class operator NotEqual(const AData1, AData2: TSign): Boolean;

    class operator Implicit(const AData: TSign): TBytes;
    class operator Implicit(const AData: TBytes): TSign;
    class operator Implicit(const AData: string): TSign;
    class operator Implicit(const AData: TSign): string;

    procedure SetSign(const AData: TBytes; const AIDKey: UInt64 ;const APrivateKey: TPrivKey);
    function CheckSign(const AData: TBytes; APubKey: TPubKey): Boolean;
    function GetData(APubKey: TPubKey): TBytes;

    function Len: Integer;
    function MinLen: Integer;
    function IsEmpty: Boolean;
    function ToString: string;
    function ToBytes: TBytes;
    procedure Clear;
  end;

  TCheckSumm = record
  const
    csLEN = 2;
  public
    Data: array [0..Pred(csLEN)] of Byte;

    class operator Implicit(const AData: TCheckSumm): string;

    class operator Equal(const AData1, AData2: TCheckSumm): Boolean;
    class operator NotEqual(const AData1, AData2: TCheckSumm): Boolean;

    procedure SetCheckSumm(AData: TBytes);
    function ToString: string;
    function Len: Integer;
    procedure Clear;
  end;

  TNetPacket = record
  const
    // tp - types packet
    tpNope                = 00;

    tpNodeConnect         = 01;
    tpNodeReconnect       = 02;
    tpNodeEnable          = 03;
    tpGetNodeEnable       = 04;
    tpGetDefNodeInfo      = 05;
    tpDefNodeInfo         = 06;
    tpGetNodeInfo         = 07;
    tpNodeInfo            = 08;
    tpNodeInfoID          = 09;
    tpGetOratorInfo       = 10;
    tpOratorInfo          = 11;
    tpNewOratorInfo       = 12;

    tpGetIDIteration      = 20;
    tpIDIteration         = 21;
    tpGetIterationInfo    = 22;
    tpIterationInfo       = 23;
    tpNextIteration       = 24;

    tpGetValList          = 40;
    tpValList             = 41;
    tpGetEnableValList    = 42;
    tpEnableValList       = 43;

    tpGetTransaction      = 51;
    tpTransaction         = 52;
    tpGetBlock            = 53;
    tpBlock               = 54;

    tpGetDownload         = 60;
    tpDownload            = 61;

    tpPing                = 100;
    tpCheckTx             = 101;
    tpCheckRx             = 102;
  public
    Size: Integer;
    IDIter: UInt64;
    PacketType: Word;
//    PacketType: TPacketType;
    DataSize: Cardinal;
    Data: TBytes;
    CheckSumm: TCheckSumm;
    Sign: TSign;

  private
    function RData(): TBytes;
  public
    class operator Equal(const AData1, AData2: TNetPacket): Boolean;
    class operator NotEqual(const AData1, AData2: TNetPacket): Boolean;

    class operator Implicit(var AData: TNetPacket): TBytes;
    class operator Implicit(const AData: TBytes): TNetPacket;
    class operator Implicit(const AData: TNetPacket): string;

//    procedure SetPacket(APacketType: TPacketType; AData: TBytes);
    procedure SetPacket(const APacketType: Word; const AData: TBytes);
    procedure SetSignPacket(const APacketType: Word; const AData: TBytes; AIDPrK: UInt64; const APrK: TPrivKey);
    procedure SignPacket(AIDPrK: UInt64; const APrK: TPrivKey);
    function CheckSignPacket(APbK: TPubKey): Boolean;

    function ToString: string;
    function ToBytes: TBytes;
    function LenData: Integer;
    function Len: Integer;
    function MinLen: Word;
    function IsEmpty: Boolean;
    function IDSign: UInt64;
    procedure Clear;
  end;

  TNodeInf = record
    ID: UInt64;
//    IDOM: UINT64;
    NetAddr: TNetAddr;
    TimeStamp: TDateTime;
    IDIteration: UInt64;
    TimeReceive: TDateTime;
//    Sign: TBytes;
    Sign: TSign;

    class function Empty: TNodeInf; static;

    class operator Equal(const AData1, AData2: TNodeInf): Boolean;
    class operator NotEqual(const AData1, AData2: TNodeInf): Boolean;

    class operator Implicit(const AData: TNodeInf): TBytes;
    class operator Implicit(var AData: TBytes): TNodeInf;
    class operator Implicit(const AData: TNodeInf): String;

    procedure SetSign(const AIDKey: UInt64; const APrK: TPrivKey);
    function CheckSign(const APbK: TPubKey): Boolean;

    function ToString: string;
    function ToBytes: TBytes;
    function Len: Integer;
    function IsLocalHost: Boolean;
    function IsEmpty: Boolean;
    procedure Clear;
  private
    function Data(): TBytes;
  end;

  TListIDVal = TArrayOfUInt64;

  TIteration = packed record
    Size: Cardinal;
    ID: UInt64; // future ID in main chain
    TXCount: Integer;
//    TXList: TBytes;
    IDCurrentBlock: UInt64; // current ID in main chain
    IDFirstBlock: UInt64;
    IDLastBlock: UInt64;
    HashCurrentBlock: THash32; // current block in BC
    HashFirstBlock: THash32; // first block in iteration
    HashLastBlock: THash32; // last block in iteration
    CountVal: Integer; // count validators
    CountValOnLine: Integer; // count online validators
//    ListIDValOnline: array of Int64;
    ListIDValOnline: TListIDVal; //
    ListIDValOn: TListIDVal;
    Sign: TSign;

    class function Empty: TIteration; static;

    class operator Equal(const AData1, AData2: TIteration): Boolean;
    class operator NotEqual(const AData1, AData2: TIteration): Boolean;

    class operator Implicit(var AData: TIteration): TBytes;
    class operator Implicit(var AData: TBytes): TIteration;
    class operator Implicit(var AData: TIteration): string;

  private
    function Data(): TBytes;
  public
    procedure SetData(AID: UInt64;
                      ATXCount: Integer;
                  //    TXList: TBytes;
                      AIDCurrentBlock: UInt64;
                      AIDFirstBlock: UInt64;
                      AIDLastBlock: UInt64;
                      AHashCurrentBlock: THash32;
                      AHashFirstBlock: THash32;
                      AHashLastBlock: THash32;
                      ACountVal: Integer;
                      ACountValOnLine: Integer;
                      AListIDValOnline: TListIDVal;
                      AListIDValOn: TListIDVal
                    );

    procedure SetSign(const AIDKey: UInt64; const APrK: TPrivKey);
    function CheckSign(const APbK: TPubKey): Boolean;

    function ToString: string;
    function ToBytes: TBytes;
    function ToHash: THash32;
    function IDSign: UInt64;
    function Len: Integer;
    function MinLen: Word;
    function IsEmpty: Boolean;
    procedure CheckSize;
    procedure Clear;
  end;

  TDinamicEvent = record
  type
    teType = Word;
  const
//    teNope = teType.MinValue or teType.MaxValue or 0;
    teNope = 00;
    teBool = 01;
    teText = 02;
    teBytes = 03;

  public
    Size: Cardinal;
    ID: Integer;
    TypeEvent: teType;
    TimeStamp: TDateTime; // TTimestamp...
    Data: TBytes;
    class function Empty: TDinamicEvent; static;

    class operator Equal(const AData1, AData2: TDinamicEvent): Boolean;
    class operator NotEqual(const AData1, AData2: TDinamicEvent): Boolean;

    class operator Implicit(const AData: TDinamicEvent): TBytes;
    class operator Implicit(const AData: TBytes): TDinamicEvent;

    class operator Implicit(const AData: TDinamicEvent): Boolean;
    class operator Implicit(const AData: Boolean): TDinamicEvent;

    class operator Implicit(const AData: TDinamicEvent): string;
    class operator Implicit(const AData: string): TDinamicEvent;

    procedure SetEvent(AID: Integer; ATypeEvent: teType; AData: TBytes);
    procedure Clear;
    function Len: Integer;
    function MinLen: Integer;
    function IsEmpty: Boolean;
    function ToString: string;
    function ToBytes: TBytes;
  end;
  TEvent = TDinamicEvent;

  TValInf = TNodeInf;
  TOratorInf = TNodeInf;

  TValidator = record
  const
    chTxRx_Nope = 00;
    chTxRx_GOOD = 01;
    chRxTx_BAD  = 02;
  private
  public
    ValInf: TValInf;
//    Num: Cardinal;
//    ID: UInt64;
//    IDOM: UINT64;
//    NetAddr: String;
    PbK: TPubKey;
    Online: Boolean;
    Enable: Boolean;
    Orator: Boolean;
    Client: TClient;
    CheckTxRx: Byte;
    TmTx: TDateTime;
    TmRx: TDateTime;
    CheckOnlineTime: TDateTime;
    Iteration: TIteration;

    class function Empty: TValidator; static;

    class operator Implicit(const AData: TValidator): Pointer;

    class operator Equal(const AData1, AData2: TValidator): Boolean;
    class operator NotEqual(const AData1, AData2: TValidator): Boolean;

  private
    procedure SetEnable(AData: Boolean);
    function GetEnable: Boolean;

    procedure SetPbK(AData: TPubKey);
    function GetPbK: TPubKey;

    procedure SetID(AData: UInt64);
    function GetID: UInt64;
  public
    property pEnable: Boolean read GetEnable write SetEnable;
    property pPbK: TPubKey read GetPbK write SetPbK;
    property ID: UInt64 read GetID write SetID;

    procedure Clear;
    function IsEmpty: Boolean;
  end;

//  PValidator = ^TValidator;

  TEventReconnect = procedure (Sender: TObject; AClient: Tclient) of object;
  TListVal = class(TList<TValidator>)
  const
    CHECK_CONNECT_TIMEOUT = 60000;
    RECONNECT_TIMEOUT = 30000;
  private
    FCS: TCriticalSection;
    FNodeID: UInt64;
    FCount: Integer;
    FCountOnline: Integer;
    FCountOn: Integer;
    FActive: Boolean;

    FEventDisconnect: TEventDisconnect;

    FEventReconnect: TEventReconnect;
    function GetCount: Integer;
    function GetCountOnline: Integer;
    procedure SetCountOnline(AData: integer);
    function GetItem(AIndex: Integer): TValidator; inline;
    procedure SetItem(AIndex: Integer; const Value: TValidator); inline;
    procedure DoReconnect();
    procedure DoOnReconnect(AClient: TClient);

    procedure DoOnDisconnect(AClient: TClient);
    function DoCheckOnline: Integer;
  public
    constructor Create(ANodeID: UInt64);
    destructor Destroy; override;

    function IndexOf(const Value: TValidator): Integer;
    function IndexOfID(const AID: UInt64): Integer;
    function ValidatorOfID(const AID: UInt64): TValidator;
    function PbKOfID(const AID: UInt64): TPubKey;
    property Items[Index: Integer]: TValidator read GetItem write SetItem; default;
    function Add(AData: TValidator): Integer;
    function Remove(AData: TValidator): Integer;
    function Update(AData: TValidator): Integer;
    function Delete(AIndex: Integer): Integer;
    procedure Move(CurIndex, NewIndex: Integer);

    property Count: Integer read GetCount;
    property CountOnline: Integer read GetCountOnline write SetCountOnline;
    procedure Reconnect();

    function SendData(AData: TBytes): Integer;
    function SendDataToID(AID: UInt64; AData: TBytes): Integer;

    procedure CheckTimeReceive(AID: UInt64);
    procedure CheckTx(AID: UInt64); // transmit
    procedure CheckRx(AID: UInt64); // receive
    function CheckOnline(): Integer;
    function CheckAddr(): Integer;
    {events}
    property OnDisconnect: TEventDisconnect read FEventDisconnect write FEventDisconnect;
    property OnReconnect: TEventReconnect read FEventReconnect write FEventReconnect;
  end;

  TTXData = record
    IDNode: UInt64;
    IDIter: UInt64;
    CntTX: Integer;
    TX: TBytes;
    Check: Boolean;

    class function Empty: TTXData; static;

    procedure SetData(AIDNode: UInt64;AIDIter: UInt64;ATX: TBytes);

    function Len: Integer;
    procedure Clear;
  end;

  TArrayTXData = record
    IDNode: UInt64;
    IDIter: UInt64;
    CntNode: Integer;
    CntCheck: Integer;
    TimeStamp: TDateTime;
    CurrentHash: THash32;

    Data: array of TTXData;

    Hash: THash32;
    Sign: TSign;
  private
    function GetItemID(AIndex: UInt64): TTXData; inline;
  public

    class function Empty: TTXData; static;

    property ItemsOfID[AIndex: UInt64]: TTXData read GetItemID;
//    function ItemsOfID(AIndex: UInt64): TTXData;

    procedure Init(AIDNode: UInt64; AIDIter: UInt64; ACurrentHash: THash32; AIDNodeList: TListIDVal);
    function Add(ATXData: TTXData): Integer;
    function FullData: TBytes;
    procedure SetHash();
    procedure SetSign(AIDKey: UInt64; APrK: TPrivKey);

    procedure Clear;
  end;

  TFileHeader = record
  const
    MIN_SIZE = 128;
    tnLabNetID  = 00;
    tnTestNetID = 01;
    tnMainNetID = 02;
  private
  public
    Size: Word;
    TypeNetID: Byte;
    TypeNet: TText;
    NodeID: UInt64;

    class function Empty: TFileHeader; static;

    class operator Equal(const AData1, AData2: TFileHeader): Boolean;
    class operator NotEqual(const AData1, AData2: TFileHeader): Boolean;

    class operator Implicit(var AData: TFileHeader): TBytes;
    class operator Implicit(const AData: TBytes): TFileHeader;

    function Len: Integer;
    function MinLen: Integer;
    procedure Clear;
  end;

  TFileValidatorsList = class
  private
    FPath: string;
    FFileName: string;
    FFileHeader: TFileHeader;

  public
    constructor Create(APath: String; AFileName: string);
    destructor Destroy();

  end;

function fHoursBetween(ADtTm1, ADtTm2: TUnixTime): Int64;
function TBytesToHash(const AData:TBytes): TBytes;
function BytesToHexStr(const AData: TBytes): string;
function HexStrToBytes(const AData: string): TBytes;

implementation

{$REGION 'function'}
function fHoursBetween(ADtTm1, ADtTm2: TUnixTime): Int64;
begin
  Result:= HoursBetween(ADtTm1.ToTDateTime,ADtTm2.ToTDateTime);
end;

function TBytesToHash(const AData:TBytes): TBytes;
var
  ms: TMemoryStream;
begin
  ms:= TMemoryStream.Create;
  ms.Write(AData, ms.Size);
  ms.Seek(0,soBeginning);
  Result:= THashSHA2.GetHashBytes(ms);
  ms.Free;
end;

function ByteToHex(InByte:byte):string;
const
  Digits: array[0..15] of char = '0123456789ABCDEF';
begin
  result := digits[InByte shr 4] + digits[InByte and $0F];
end;

function BytesToHex(const dat: TBytes):string;
var
  i,len: Integer;
begin
  Result:= '';
  len:= Length(dat);
  for i:= 0 to len - 1 do Result:=Result + ByteToHex(dat[i]);
end;

function BytesToHexStr(const AData: TBytes): string;
var
  s: string;
  i,n: Integer;
  b: TBytes;
begin
  SetLength(s, 2*Length(AData));

  {$IFDEF ANDROID}
  s:= BytesToHex(AData);
  {$ELSE}
  System.Classes.BinToHex(@AData[0], PWideChar(@s[1]), Length(AData));
  {$ENDIF}
  if Length(StringReplace(s,'0','',[rfReplaceAll])) = 0 then
    Result:= '0x0'
  else
    Result:= '0x' + LowerCase(s);
end;

function HexStrToBytes(const AData: string): TBytes;
var
  s: string;
  b: TBytes;
begin
  s:= StringReplace(AData,'0x','',[rfReplaceAll]);
  SetLength(b, Round(Length(s)/2));
  {$IFDEF ANDROID}
  HexToBin(PWideChar(s), 0, b, 0, Length(b));
  {$ELSE}
  HexToBin(PWideChar(@s[1]), @b[0],  Length(b));
  {$ENDIF}
  Result:= b;
end;
{$ENDREGION 'function'}

{TUint64Helper}
{$REGION 'TUint64Helper'}
function TUint64Helper.ToBytes: TBytes;
begin
  SetLength(Result, SizeOf(UINt64));
  Move(Self, Result[0], SizeOf(UINt64));
end;

function TUint64Helper.ToString: string;
begin
  Result := UIntToStr(Uint64(Self));
end;

procedure TUint64Helper.SetBytes(AData: TBytes);
begin
  Move(AData[0], Self, SizeOf(Self));
end;
{$ENDREGION 'TUint64Helper'}

{ TArrayOfUInt64 }
{$REGION 'TArrayOfUInt64'}
function TArrayOfUInt64.add(AData: tData): Integer;
var
  i,n: Integer;
begin
  Result:= -1;
  n:= Length(Self.Data);
  if n = 0 then
  begin
//    Self.Size:= 0;
//    Self.FSize:= SizeOf(Self.Count);
    Self.FSize:= Self.MinLen - SizeOf(Self.FSize);
    Self.Count:= 0;
  end;

  for i:= 0 to Pred(n) do
  begin
    if Self.Data[i] = AData then
    begin
      Result:= i;
      Exit
    end;
  end;

  SetLength(Self.Data,n + 1);
  Self.Data[n]:= AData;
  Self.Count:= Self.Count + 1;
  Self.FSize:= Self.FSize + SizeOf(TArrayOfUInt64.tData);
  Result:= n;
end;

function TArrayOfUInt64.Exists(AData: tData): Boolean;
var
  i,n: Integer;
begin
  Result:= False;
  n:= Length(Self.Data);
  for i:= 0 to Pred(n) do
  begin
    if Self.Data[i] = AData then
    begin
      Result:= True;
      Exit
    end;
  end;
end;

procedure TArrayOfUInt64.Clear;
begin
  Self.FSize:= 0;
  Self.IDOrator:= 0;
  Self.IDIter:= 0;
  Self.Count:= 0;
//  FillChar(Self.Data[0],Length(Self.Data),0);
  SetLength(Self.Data,0);
end;

class function TArrayOfUInt64.Empty: TArrayOfUInt64;
begin
  Result.Clear;
end;

class operator TArrayOfUInt64.Equal(const AData1,
  AData2: TArrayOfUInt64): Boolean;
begin
  Result:= (AData1.FSize = ADAta2.FSize)
          and (AData1.IDOrator = ADAta2.IDOrator)
          and (AData1.IDIter = ADAta2.IDIter)
          and (AData1.Count = ADAta2.Count)
          and (Length(AData1.Data) = Length(AData2.Data))
          and (CompareMem(AData1.Data,AData2.Data,Length(AData1.Data)))
end;

class operator TArrayOfUInt64.NotEqual(const AData1,
  AData2: TArrayOfUInt64): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

procedure TArrayOfUInt64.SetSize(ASize: Word);
begin
  Self.FSize:= Self.Len - SizeOf(Self.FSize);
end;

function TArrayOfUInt64.GetSize: Word;
begin
  Self.FSize:= Self.Len - SizeOf(Self.FSize);
  Result:= Self.FSize;
end;

function TArrayOfUInt64.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TArrayOfUInt64.ToString: string;
begin
  Result:= Self;
end;

class operator TArrayOfUInt64.Implicit(var AData: TArrayOfUInt64): TBytes;
var
  i,j,sz: Integer;
begin
  AData.FSize:= AData.Len - SizeOf(AData.FSize);
  AData.Count:= Length(AData.Data);
  SetLength(Result,AData.Len);
  i:= 0;

  sz:= SizeOf(AData.FSize);
  Move(AData.FSize,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.IDOrator);
  Move(AData.IDOrator,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.IDIter);
  Move(AData.IDIter,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.Count);
  Move(AData.Count,Result[i],sz);
  Inc(i,sz);


  if (Length(AData.Data) <> AData.Count) then
  begin
    Result:= [];
    {$IFDEF DEBUG}
    raise Exception.Create('Err. TArrayOfUInt64: Length(AData.Data) <> AData.Count');
    {$ELSE}
    {$ENDIF}
    Exit;
  end;

  sz:= SizeOf(AData.Data[j]);
  for j:= 0 to Pred(AData.Count) do
  begin
    Move(AData.Data[j],Result[i],sz);
    Inc(i,sz);
  end;
end;

class operator TArrayOfUInt64.Implicit(const AData: TBytes): TArrayOfUInt64;
var
  i,j,l,sz: Integer;
begin
  Result.Clear;
  l:= Length(AData);
  if l >= Result.MinLen then
  begin
    i:= 0;

    sz:= SizeOf(Result.FSize);
    Move(AData[i],Result.FSize,sz);
    Inc(i,sz);
    if Result.FSize = l - SizeOf(Result.FSize) then
    begin
      sz:= SizeOf(Result.IDOrator);
      Move(AData[i],Result.IDOrator,sz);
      Inc(i,sz);

      sz:= SizeOf(Result.IDIter);
      Move(AData[i],Result.IDIter,sz);
      Inc(i,sz);

      sz:= SizeOf(Result.Count);
      Move(AData[i],Result.Count,sz);
      Inc(i,sz);
      if (Result.Count > 0)
        and (Result.Count * SizeOf(TArrayOfUInt64.tData) = l - Result.MinLen)
      then
        begin
          SetLength(Result.Data,Result.Count);
          sz:= SizeOf(Result.Data[0]);
          for j:= 0 to Pred(Result.Count) do
          begin
            Move(AData[i],Result.Data[j],sz);
            Inc(i,sz);
          end;
        end
      else
        Result.Clear;
    end
    else
    begin
      Result.Clear;
    end;
  end;
end;

class operator TArrayOfUInt64.Implicit(const AData: TArrayOfUInt64): string;
var
  i: Integer;
begin
  Result:= '';
  Result:= Result + '{IDOrator: ' + AData.IDOrator.ToString
            +', IDIter: ' + AData.IDIter.ToString
            +', Count: ' + AData.Count.ToString;
  if AData.Count > 0 then
  begin
    Result:= Result + '; List: [';
    for i:= 0 to Pred(AData.Count) do
    begin
      Result:= Result + AData.Data[i].ToString;
      if i < Pred(AData.Count) then
        Result:= Result + ',';
    end;
    Result:= Result + ']';
  end;

  Result:= Result + '}';
end;

function TArrayOfUInt64.IsEmpty: Boolean;
begin
  Result:= Self = TArrayOfUInt64.Empty;
end;

function TArrayOfUInt64.Len: Integer;
begin
  Result:= SizeOf(Self.FSize)
            + SizeOf(Self.IDOrator)
            + SizeOf(Self.IDIter)
            + SizeOf(Self.Count)
            + Length(Self.Data) * SizeOf(Self.Data)
//            + Self.FSize
            ;
end;

function TArrayOfUInt64.MinLen: Integer;
begin
  Result:= SizeOf(Self.FSize)
            + SizeOf(Self.IDOrator)
            + SizeOf(Self.IDIter)
            + SizeOf(Self.Count)
//            + Self.Size
            ;
end;
{$ENDREGION 'TArrayOfUInt64'}

{ TText }
{$REGION 'TText'}
procedure TText.Clear;
begin
  FillChar(Self.Data[0],Self.Len,0);
  SetLength(Self.Data,0);
  Self.DataSize:= 0;
end;

class operator TText.Equal(const AData1, AData2: TText): Boolean;
begin
  Result:= CompareMem(AData1.Data,AData2.Data,Length(AData1.Data));
end;

class operator TText.NotEqual(const AData1, AData2: TText): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TText.Implicit(const AData: string): TText;
begin
  Result.Data:= TEncoding.UTF8.GetBytes(AData);
  Result.DataSize:= Length(Result.Data);
end;

class operator TText.Implicit(const AData: TText): string;
begin
//  Result:= string(TEncoding.UTF8.GetChars(AData)) + #0;
  Result:= TEncoding.UTF8.GetString(AData.Data);
end;

class operator TText.Implicit(const AData: TText): TBytes;
begin
  SetLength(Result,AData.Len);
  Move(AData.DataSize,Result[0],SizeOf(AData.DataSize));
  Move(AData.Data[0],Result[SizeOf(AData.DataSize)],AData.DataSize);
end;

class operator TText.Implicit(const AData: TBytes): TText;
begin
  if (Length(AData) >= SizeOf(Result.DataSize)) then
  begin
    Move(AData[0],Result.DataSize,SizeOf(Result.DataSize));
    if (Result.DataSize = Length(AData) - SizeOf(Result.DataSize)) then
    begin
      SetLength(Result.Data,Result.DataSize);
      Move(AData[SizeOf(Result.DataSize)],Result.Data[0],Result.DataSize);
    end
    else
    begin
//      Result.DataSize:= Length(AData);
      Result.DataSize:= 0;
      SetLength(Result.Data,Result.DataSize);
//      Move(AData[0],Result.Data[0],Result.DataSize);
    end;
  end;
end;

function TText.Len: Integer;
begin
  Result:= SizeOf(Self.DataSize) + Self.DataSize;
end;

function TText.ToBytes: TBytes;
begin
  Result:= self;
end;

function TText.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TText'}

{ THash }
{$REGION 'THash32'}
function THash32.BytesToHex(const dat: TBytes): string;
var
  i,len: Integer;
begin
  Result:= '';
  len:= Length(dat);
  for i:= 0 to len - 1 do Result:=Result + ByteToHex(dat[i]);
end;

function THash32.BytesToHexStr(const AData: TBytes): string;
var
  s: string;
  i,n: Integer;
  b: TBytes;
begin
  SetLength(s, 2*Length(AData));
  s:= BytesToHex(AData);
  if Length(StringReplace(s,'0','',[rfReplaceAll])) = 0 then
    Result:= '0x0'
  else
    Result:= '0x' + LowerCase(s);
end;

function THash32.ByteToHex(InByte: byte): string;
const
  Digits: array[0..15] of char = '0123456789ABCDEF';
begin
  result := digits[InByte shr 4] + digits[InByte and $0F];
end;

procedure THash32.Clear;
begin
  Self.Size:= 0;
  FillChar(Self.Data[0],Length(Self.Data),0);
  SetLength(Self.Data,0);
end;

class function THash32.Empty: THash32;
begin
  Result.Clear;
end;

class operator THash32.Equal(const AData1, AData2: THash32): Boolean;
begin
  Result:= (AData1.Size = AData2.Size)
        and CompareMem(AData1.Data,AData2.Data,AData1.Size)
  ;
end;

function THash32.GetHash(AData: TBytes): TBytes;
var
  ms: TMemoryStream;
//  bs: TBytesStream;
begin
  ms:= TMemoryStream.Create;
  ms.Write(AData[0],Length(AData));
  ms.Seek(0,soBeginning);
  Result:= THashSHA2.GetHashBytes(ms);
  ms.Free;
end;

class operator THash32.NotEqual(const AData1, AData2: THash32): Boolean;
begin
  Result:= not (AData1 = AData2);
end;

class operator THash32.Implicit(const AData: THash32): TBytes;
begin
  SetLength(Result, AData.Size + SizeOf(AData.Size));
  Move(AData.Size,Result[0],SizeOf(AData.Size));
  if AData.Size > 0 then
    Move(AData.Data[0],Result[SizeOf(AData.Size)],AData.Size);
end;

class operator THash32.Implicit(const AData: TBytes): THash32;
var
  n: Integer;
begin
  Result.Clear;
  n:= Length(AData);
  if (n > SizeOf(Result.Size)) then
  begin
    SetLength(Result.Data,n - SizeOf(Result.Size));
    Move(AData[0],Result.Size,SizeOf(Result.Size));
    if (Result.Size = n - SizeOf(Result.Size) ) then
    begin
      SetLength(Result.Data,Result.Size);
      Move(AData[SizeOf(Result.Size)],Result.Data[0],Result.Size);
    end
    else
    begin
      Result.Size:= 0;
      SetLength(Result.Data,0);
    end;
  end;
end;

class operator THash32.Implicit(const AData: THash32): string;
begin
  Result:= AData.BytesToHexStr(AData.Data);
end;

function THash32.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

procedure THash32.SetHash(AData: TBytes);
begin
  Self.Clear;
  Self.Data:= GetHash(AData);
  if (Length(Self.Data) > Self.Size.MaxValue - SizeOf(Self.Size)) then
  begin
    Self:= THash32.Empty;
    {$IFDEF DEBUG}
    raise Exception.Create('Length(Self.Data) > Self.Size.MaxValue');
    {$ENDIF}
  end;
  Self.Size:= Length(Self.Data);
end;

function THash32.ToBytes: TBytes;
begin
  Result:= Self;
end;

function THash32.ToString: string;
begin
  Result:= Self;
end;

function THash32.Len: Byte;
begin
//  Result:= Self.Size + SizeOf(Self.Size);
  Result:= SizeOf(Self.Size) + Length(Self.Data);
end;

function THash32.MinLen: Byte;
begin
  Result:= SizeOf(Self.Size);
end;
{$ENDREGION 'THash32'}

{ TNetAddr }
{$REGION 'TNetAddr'}
class function TNetAddr.CheckRecord: Boolean;
var
  s1,s2: string;
  r1,r2: TNetAddr;
begin
  Result:= False;
  s1:= '107.124.131.140';
  r1.Clear;
  r1:= s1;
//  s2:= '107.120.130.140';
  r2.Clear;
//  r2:= s2;
  r2.IPv4[0]:= 107;
  r2.IPv4[1]:= 124;
  r2.IPv4[2]:= 131;
  r2.IPv4[3]:= 140;
  if not (r1 = r2) then
    raise Exception.Create(msgErrCheckRecord)
  else
    Result:= True;
end;

procedure TNetAddr.Clear;
begin
  FillChar(Self.IPv4, Length(Self.IPv4), 0);
  Self.Port:= 0;
end;

class function TNetAddr.Empty: TNetAddr;
begin
//  FillChar(Result.IPv4, Length(Result.IPv4), 0);
//  Result.Port:= 0;
  Result.Clear;
end;

class operator TNetAddr.Equal(const AData1, AData2: TNetAddr): Boolean;
begin
  Result:= CompareMem(@AData1.IPv4[0], @AData2.IPv4[0], Length(AData1.IPv4))
          and (AData1.Port = AData2.Port);
end;

class operator TNetAddr.NotEqual(const AData1, AData2: TNetAddr): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TNetAddr.Implicit(const AData: TNetAddr): TBytes;
begin
  SetLength(Result, AData.Len);
//  CopyMemory(@Result,@AData.Data,AData.Len);
  Move(AData.IPv4[0], Result[0], Length(AData.IPv4));
  Move(AData.Port, Result[Length(AData.IPv4)], SizeOf(AData.Port));
end;

class operator TNetAddr.Implicit(const AData: TBytes): TNetAddr;
begin
  if Length(AData) = Result.Len then
  begin
    Move(AData[0], Result.IPv4[0], Length(Result.IPv4));
    Move(AData[Length(Result.IPv4)], Result.Port, SizeOf(Result.Port));
  end
  else
  begin
    Result.Clear;
  end;
end;

function TNetAddr.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

function TNetAddr.IsLocalHost: Boolean;
begin
  Result:= (Self.ToIPv4 = '127.0.0.1');
end;

class operator TNetAddr.Implicit(const S: string): TNetAddr;
var
 i,k:Integer;
 bIP: TNetAddr;
 b: Byte;
 w: Word;
 sip: string;
 sport: string;
begin
  b:= 0;
  k:= 0;
  w:= 0;
  bIP.Clear;
  for i:= 0 to Pred(S.Length) do
  begin
    if (S.Chars[i] in ['0'..'9']) and (i < S.Length) then
    begin
      if k <= 3 then
        b:= b * 10 + StrToInt(S.Chars[i])
      else
        w:= w * 10 + StrToInt(S.Chars[i])
    end;
    if (S.Chars[i] = ':') or (S.Chars[i] = '.') or (i = Pred(S.Length)) then
    begin
      if k <= 3 then
      begin
        bIP.IPv4[k]:= b;
        b:= 0;
        Inc(k);
      end
      else
        bIP.Port:= w;
    end;
  end;
  Result := bIP;
end;

class operator TNetAddr.Implicit(const AData: TNetAddr): string;
begin
  Result:= IntToStr(Integer(AData.IPv4[0])) + '.'
                   + IntToStr(Integer(AData.IPv4[1])) + '.'
                   + IntToStr(Integer(AData.IPv4[2])) + '.'
                   + IntToStr(Integer(AData.IPv4[3]))
                   + ':' + AData.Port.ToString
                  ;
end;

function TNetAddr.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TNetAddr.ToIPv4: string;
begin
  Result:= IntToStr(Integer(Self.IPv4[0])) + '.'
                   + IntToStr(Integer(Self.IPv4[1])) + '.'
                   + IntToStr(Integer(Self.IPv4[2])) + '.'
                   + IntToStr(Integer(Self.IPv4[3]))
                  ;
end;

function TNetAddr.ToPort: Word;
begin
  Result:= Port;
end;

function TNetAddr.ToString: string;
begin
  Result:= Self;
end;

function TNetAddr.Len: Integer;
begin
  Result:= Length(Self.IPv4) + SizeOf(Self.Port);
end;
{$ENDREGION 'TNetAddr'}

{ TCheckSumm }
{$REGION 'TCheckSumm'}
procedure TCheckSumm.Clear;
begin
  FillChar(Self.Data,Self.Len,0);
end;

class operator TCheckSumm.Equal(const AData1, AData2: TCheckSumm): Boolean;
begin
  Result:= CompareMem(@AData1.Data[0],@AData2.Data[0],Length(AData1.Data));
end;

class operator TCheckSumm.NotEqual(const AData1, AData2: TCheckSumm): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TCheckSumm.Implicit(const AData: TCheckSumm): string;
var
  s: string;
  i,n: Integer;
begin
  SetLength(s, 2*AData.Len);
  BinToHex(@AData.Data[0], PWideChar(@s[1]), Length(AData.Data));
  s:= '0x' + LowerCase(s);
  Result:= s;
end;

function TCheckSumm.Len: Integer;
begin
  Result:= Length(Self.Data);
end;

procedure TCheckSumm.SetCheckSumm(AData: TBytes);
var
  i,n:integer;
  b1,b2: Byte;
begin
  n:= Length(AData);
  b1:= 0;
  b2:= 0;
  for i:= 0 to n - 1 do
  begin
    if i div 2 = 0 then
      b1:= b1 + AData[i]
    else
      b2:= b2 + AData[i];
  end;
  Self.Data[0]:= b1;
  Self.Data[1]:= b2;
end;

function TCheckSumm.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TCheckSumm'}

{ TNetPacket }
{$REGION 'TNetPacket'}
procedure TNetPacket.Clear;
begin
  Self.Size:= 0;
  Self.IDIter:= 0;
  Self.PacketType:= Self.tpNope;
//  FreeMemory(@Self.Data);
  SetLength(Self.Data,0);
  Self.CheckSumm.Clear;
  Self.Sign.Clear;
end;

function TNetPacket.RData: TBytes;
var
  sz: Integer;
begin
  sz:= Self.LenData - Self.Sign.Len;
  SetLength(Result,sz);
  Move(Self.ToBytes[0],Result[0],sz);
end;

class operator TNetPacket.Equal(const AData1, AData2: TNetPacket): Boolean;
begin
  Result:= (AData1.Size = AData2.Size)
          and (AData1.PacketType = AData2.PacketType)
          and (AData1.DataSize = AData2.DataSize)
          and (CompareMem(AData1.Data,AData2.Data,AData1.DataSize))
          and (AData1.CheckSumm = AData2.CheckSumm)
          and (AData1.Sign = AData2.Sign)
          ;
end;

class operator TNetPacket.NotEqual(const AData1, AData2: TNetPacket): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TNetPacket.Implicit(var AData: TNetPacket): TBytes;
var
  i, sz: Integer;
begin
  i:= 0;
  AData.Size:= AData.Len - SizeOf(AData.Size);
  AData.DataSize:= Length(AData.Data);

  SetLength(Result, AData.Len);

  sz:= SizeOf(AData.Size);
  Move(AData.Size,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.IDIter);
  Move(AData.IDIter,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.PacketType);
  Move(AData.PacketType,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.DataSize);
  Move(AData.DataSize,Result[i],sz);
  Inc(i,sz);

  sz:= Length(AData.Data);
  Move(AData.Data[0],Result[i],sz);
  Inc(i,sz);

  sz:= AData.CheckSumm.Len;
  Move(AData.CheckSumm.Data[0],Result[i],sz);
  Inc(i,sz);


  sz:= AData.Sign.Len;
  Move(AData.Sign.ToBytes[0],Result[i],sz);
//  Inc(i,sz);
end;

class operator TNetPacket.Implicit(const AData: TBytes): TNetPacket;
var
  i, l, sz: Integer;
  cs: TCheckSumm;
  b: TBytes;
begin
  i:= 0;
  if Length(AData) < Result.MinLen then
  begin
    Result.Clear;
//    Result.PacketSize:= -1;
    Exit;
  end
  else
  begin
    sz:= SizeOf(Result.Size);
    Move(AData[i],Result.Size,sz);
    Inc(i,sz);
  end;

  if Result.Size <= Length(AData) then
  begin
//    raise Exception.Create('PacketSize > Length(AData). Packet size: ' + Result.PacketSize.ToString);
    sz:= SizeOf(Result.IDIter);
    Move(AData[i],Result.IDIter,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.PacketType);
    Move(AData[i],Result.PacketType,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.DataSize);
    Move(AData[i],Result.DataSize,sz);
    Inc(i,sz);

//    l:= Result.DataSize;
//
//    if l <= 0 then
//      raise Exception.Create('Bad packet. Packet size: ' + Result.Size.ToString);

    sz:= Result.DataSize;
    SetLength(Result.Data,sz);
    Move(AData[i],Result.Data[0],sz);
    Inc(i,sz);

    sz:= Result.CheckSumm.Len;
    Move(AData[i],Result.CheckSumm.Data[0],sz);
    Inc(i,sz);

    cs.SetCheckSumm(Result.Data);
    if cs <> Result.CheckSumm then
      raise Exception.Create('Bad CheckSumm or bad packet. Packet size: ' + Result.Size.ToString);

    sz:= Result.Sign.MinLen;
    Move(AData[i],Result.Sign.Size,sz);
    sz:= Result.Sign.MinLen + Result.Sign.Size;
    SetLength(b,sz);
    Move(AData[i],b[0],sz);
    Result.Sign:= b;
//    Inc(i,sz);
  end
  else
  begin
    raise Exception.Create('PacketSize > Length(AData). Packet size: ' + Result.Size.ToString);
  end;
end;

function TNetPacket.IDSign: UInt64;
begin
  Result:= 0;
  if not Self.Sign.IsEmpty then
    Result:= Self.Sign.IDKey;
end;

class operator TNetPacket.Implicit(const AData: TNetPacket): string;
var
  s,s2: string;
  i,n: Integer;
begin
  SetLength(s, 2*AData.LenData);
  BinToHex(@AData.Data[0], PWideChar(@s[1]), Length(AData.Data));
  s:= '0x' + LowerCase(s);

  case AData.PacketType of
//    tpNope: s2:= 'tpNope';
//    tpTransaction: s2:= 'tpTransaction';
//    tpBlock: s2:= 'tpBlock';

    AData.tpNope: s2:= 'tpNope';
    AData.tpNodeConnect: s2:= 'tpNodeConnect';
    AData.tpGetNodeInfo: s2:= 'tpGetNodeInfo';
    AData.tpNodeInfo: s2:= 'tpNodeInfo';
    AData.tpGetOratorInfo: s2:= 'tpGetOratorInfo';
    AData.tpOratorInfo: s2:= 'tpOratorInfo';

    AData.tpGetIDIteration: s2:= 'tpGetIDIteration';
    AData.tpIDIteration: s2:= 'tpIDIteration';
    AData.tpGetIterationInfo: s2:= 'tpGetIterationInfo';
    AData.tpIterationInfo: s2:= 'tpIterationInfo';
    AData.tpNextIteration: s2:= 'tpNextIteration';
    AData.tpGetValList: s2:= 'tpGetValList';
    AData.tpValList: s2:= 'tpValList';
    AData.tpGetEnableValList: s2:= 'tpGetEnableValList';
    AData.tpEnableValList: s2:= 'tpEnableValList';

    AData.tpGetNodeEnable: s2:= 'tpGetNodeEnable';
    AData.tpNodeEnable: s2:= 'tpNodeEnable';

    AData.tpGetTransaction: s2:= 'tpGetTransaction';
    AData.tpTransaction: s2:= 'tpTransaction';
    AData.tpGetBlock: s2:= 'tpGetBlock';
    AData.tpBlock: s2:= 'tpBlock';

    AData.tpPing: s2:= 'tpPing';
  else
    s2:= IntToStr(AData.PacketType);
  end;

  Result:= '{Packet: {PacketSize: ' + AData.Size.ToString + ';'
          + 'IDIter: ' + AData.IDIter.ToString + ';'
          + 'PacketType: ' + s2 + ';'
          + 'Data: ' + s + ';'
          + 'CheckSumm: ' + AData.CheckSumm.ToString + ';'
          + 'Sign: ' + AData.Sign.ToString + '}}'
          ;
end;

function TNetPacket.IsEmpty: Boolean;
begin
//  Result:= Self = Self.Empty;
end;

function TNetPacket.Len: Integer;
begin
  Self.DataSize:= Length(Self.Data);
  Result:= SizeOf(Self.Size)
         + SizeOf(Self.IDIter)
         + SizeOf(Self.PacketType)
         + SizeOf(Self.DataSize)
         + Length(Self.Data)
         + Self.CheckSumm.Len
         + Self.Sign.Len
         ;
end;

function TNetPacket.LenData: Integer;
begin
  Result:= Length(Self.Data);
end;

function TNetPacket.MinLen: Word;
begin
  Result:= SizeOf(Self.Size)
            + SizeOf(Self.IDIter)
            + SizeOf(Self.PacketType)
            + SizeOf(Self.DataSize)
            + Self.CheckSumm.Len
            + Self.Sign.MinLen;
            ;
end;

//procedure TNetPacket.SetPacket(APacketType: TPacketType; AData: TBytes);
procedure TNetPacket.SetPacket(const APacketType: Word; const AData: TBytes);
begin
  Self.Clear;
  Self.PacketType:= APacketType;
  Self.DataSize:= Length(AData);
  SetLength(Self.Data,Self.DataSize);
  Move(AData[0],Self.Data[0],Self.DataSize);

  Self.CheckSumm.SetCheckSumm(AData);
  Self.Size:= Self.Len - SizeOf(Self.Size);
end;

procedure TNetPacket.SetSignPacket(const APacketType: Word; const AData: TBytes; AIDPrK: UInt64; const APrK: TPrivKey);
var
  hash: THash32;
begin
  Self.Clear;
  Self.PacketType:= APacketType;
  Self.DataSize:= Length(AData);
  SetLength(Self.Data,Self.DataSize);
  Move(AData[0],Self.Data[0],Self.DataSize);

  Self.CheckSumm.SetCheckSumm(AData);

  hash.SetHash(AData);
  Self.Sign.SetSign(hash.ToBytes,AIDPrK,APrK);
  Self.Size:= Self.Len - SizeOf(Self.Size);
end;

procedure TNetPacket.SignPacket(AIDPrK: UInt64; const APrK: TPrivKey);
var
  hash: THash32;
begin
  Self.Sign.Clear;
//  hash.SetHash(Self.Data);
//  Self.Sign.SetSign(hash.ToBytes,AIDPrK,APrK);
//  Self.Size:= Self.Len - SizeOf(Self.Size);
end;

function TNetPacket.CheckSignPacket(APbK: TPubKey): Boolean;
var
  hash: THash32;
begin
  if (not Self.Sign.IsEmpty) then
  begin
    hash.SetHash(Self.Data);
    Result:= Self.Sign.CheckSign(hash.ToBytes,APbK);
  end
  else
    Result:= True;
end;

function TNetPacket.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TNetPacket.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'NetPacket'}

{ TNodeInf }
{$REGION 'TNodeInf'}
procedure TNodeInf.Clear;
begin
  Self.ID:= 0;
  Self.NetAddr.Clear;
  Self.TimeStamp:= 0;
  Self.IDIteration:= 0;
  Self.TimeReceive:= 0;
  Self.Sign.Clear;
end;

class function TNodeInf.Empty: TNodeInf;
begin
  Result.Clear;
end;

function TNodeInf.Data: TBytes;
var
  sz: Integer;
begin
  sz:= Self.Len - Self.Sign.Len;
  SetLength(Result,sz);
  Move(Self.ToBytes[0],Result[0],sz);
end;

procedure TNodeInf.SetSign(const AIDKey: UInt64; const APrK: TPrivKey);
begin
  Self.Sign.SetSign(Self.Data,AIDKey,APrK);
end;

function TNodeInf.CheckSign(const APbK: TPubKey): Boolean;
begin
  Result:= Self.Sign.CheckSign(Self.Data,APbK);
end;

class operator TNodeInf.Equal(const AData1, AData2: TNodeInf): Boolean;
begin
  Result:= (AData1.ID = AData2.ID)
        and (AData1.NetAddr = AData2.NetAddr)
        and (AData1.TimeStamp = AData2.TimeStamp)
//        and (AData1.TimeReceive = AData2.TimeReceive)
//        and (AData1.IDIteration = AData2.IDIteration)
        and (AData1.Sign = AData2.Sign)
        ;
end;

class operator TNodeInf.NotEqual(const AData1, AData2: TNodeInf): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TNodeInf.Implicit(const AData: TNodeInf): TBytes;
var
  i,sz: Integer;
begin
  SetLength(Result,AData.Len);
  i:= 0;

  sz:= SizeOf(AData.ID);
  Move(AData.ID,Result[i],sz);
  Inc(i,sz);

  sz:= AData.NetAddr.Len;
  Move(AData.NetAddr.ToBytes[0],Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.TimeStamp);
  Move(AData.TimeStamp,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.IDIteration);
  Move(AData.IDIteration,Result[i],sz);
  Inc(i,sz);

  sz:= AData.Sign.Len;
  Move(AData.Sign.ToBytes[0],Result[i],sz);
//  Inc(i,sz);
end;

class operator TNodeInf.Implicit(var AData: TBytes): TNodeInf;
var
  b: TBytes;
  i,sz: Integer;
begin
  i:= 0;

  sz:= SizeOf(Result.ID);
  Move(AData[i],Result.ID,sz);
  Inc(i,sz);

  sz:= Result.NetAddr.Len;
  SetLength(b,sz);
  Move(AData[i],b[0],sz);
  Result.NetAddr:= b;
  Inc(i,sz);

  sz:= SizeOf(Result.TimeStamp);
  Move(AData[i],Result.TimeStamp,sz);
  Inc(i,sz);

  sz:= SizeOf(Result.IDIteration);
  Move(AData[i],Result.IDIteration,sz);
  Inc(i,sz);

  sz:= Result.Sign.MinLen;
  Move(AData[i],Result.Sign.Size,sz);
  sz:= Result.Sign.MinLen + Result.Sign.Size;
  SetLength(b,sz);
  Move(AData[i],b[0],sz);
  Result.Sign:= b;
//  Inc(i,sz);

  Result.TimeReceive:= 0;
end;

class operator TNodeInf.Implicit(const AData: TNodeInf): String;
begin
  Result:= 'ID: ' + AData.ID.ToString
          + ' NetAddr: ' + AData.NetAddr.ToString
          + ' TimeStamp: ' + FormatdateTime('dd.mm.yy hh:nn:ss.zzz',AData.TimeStamp)
          + ' IDIteration: ' + AData.IDIteration.ToString
          + ' Sign: ' + AData.Sign.ToString
          ;
end;

function TNodeInf.IsEmpty: Boolean;
begin
//  Result:= Self = TNodeInf.Empty;
  Result:= Self = Self.Empty;
end;

function TNodeInf.IsLocalHost: Boolean;
begin
  Result:= Self.NetAddr.IsLocalHost;
end;

function TNodeInf.Len: Integer;
begin
  Result:= SizeOf(Self.ID)
            + Self.NetAddr.Len
            + SizeOf(Self.TimeStamp)
            + SizeOf(Self.IDIteration)
            + Self.Sign.Len
            ;
end;

function TNodeInf.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TNodeInf.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TNodeInf'}

{ TIteration }
{$REGION 'TIteration'}
procedure TIteration.SetData(AID: UInt64; ATXCount: Integer;
                            AIDCurrentBlock, AIDFirstBlock, AIDLastBlock: UInt64;
                            AHashCurrentBlock, AHashFirstBlock, AHashLastBlock: THash32;
                            ACountVal, ACountValOnLine: Integer;
                            AListIDValOnline, AListIDValOn: TListIDVal);
begin
  Self.Clear;
  Self.ID:= AID;
  Self.TXCount:= ATXCount;
  Self.IDCurrentBlock:= AIDCurrentBlock;
  if ATXCount = 0 then
    Self.IDFirstBlock:= 0
  else
    Self.IDFirstBlock:= Round(ATXCount / ATXCount);
  Self.IDLastBlock:= AIDCurrentBlock + ATXCount;
  Self.HashCurrentBlock:= AHashCurrentBlock;
  Self.HashFirstBlock:= AHashFirstBlock;
  Self.HashLastBlock:= AHashLastBlock;
  Self.CountVal:= ACountVal;
  Self.ListIDValOnline:= AListIDValOnline;
  Self.ListIDValOn:= AListIDValOn;
  Self.Size:= Self.Len - SizeOf(Self.Size);
end;

procedure TIteration.SetSign(const AIDKey: UInt64; const APrK: TPrivKey);
var
  hash: THash32;
begin
  Self.Sign.Clear;
//  hash.SetHash(Self.Data);
//  Self.Sign.SetSign(hash.ToBytes,AIDKey,APrK);
//  Self.Size:= Self.Len - SizeOf(Self.Size);
end;

function TIteration.CheckSign(const APbK: TPubKey): Boolean;
var
  hash: THash32;
begin
  if APbK.IsEmpty then
  begin
    if Self.Sign.IsEmpty then
      Result:= True
    else
      Result:= False;
  end
  else
  begin
    hash.SetHash(Self.Data);
    Result:= Self.Sign.CheckSign(hash.ToBytes,APbK);
  end;
end;

procedure TIteration.CheckSize;
begin
  Self.Size:= Self.Len - SizeOf(Self.Size);
end;

procedure TIteration.Clear;
begin
  Self.Size:= 0;
  Self.ID:= 0;
  Self.TXCount:= 0;
  Self.IDCurrentBlock:= 0;
  Self.IDFirstBlock:= 0;
  Self.IDLastBlock:= 0;
  Self.HashCurrentBlock.Clear;
  Self.HashFirstBlock.Clear;
  Self.HashLastBlock.Clear;
  Self.CountVal:= 0;
  Self.CountValOnLine:= 0;
  Self.ListIDValOnline.Clear;
  Self.ListIDValOn.Clear;
  Self.Sign.Clear;
end;

class function TIteration.Empty: TIteration;
begin
  Result.Clear;
end;

class operator TIteration.Equal(const AData1, AData2: TIteration): Boolean;
begin
  Result:= {(AData1.Size = Adata2.Size)
          and} (AData1.ID = Adata2.ID)
        and (AData1.TXCount = Adata2.TXCount)
        and (AData1.IDCurrentBlock = Adata2.IDCurrentBlock)
        and (AData1.IDFirstBlock = Adata2.IDFirstBlock)
        and (AData1.IDLastBlock = Adata2.IDLastBlock)
        and (AData1.HashCurrentBlock = Adata2.HashCurrentBlock)
        and (AData1.HashFirstBlock = Adata2.HashFirstBlock)
        and (AData1.HashLastBlock = Adata2.HashLastBlock)
//        and (AData1.CountVal = Adata2.CountVal)
//        and (AData1.CountValOnLine = Adata2.CountValOnLine)
//        and (AData1.ListIDValOnline = Adata2.ListIDValOnline)
//        and (AData1.ListIDValOn = Adata2.ListIDValOn)
//        and (AData1.Sign = Adata2.Sign)
        ;
end;

class operator TIteration.NotEqual(const AData1, AData2: TIteration): Boolean;
begin
  Result:= not (AData1 = AData2);
end;

class operator TIteration.Implicit(var AData: TIteration): TBytes;
var
  i,sz: Integer;
  b: TBytes;
begin
  i:= 0;
  AData.Size:= AData.Len - SizeOf(AData.Size);
  if not AData.IsEmpty then
  begin
    SetLength(Result,AData.Len);

    sz:= SizeOf(AData.Size);
    Move(AData.Size,Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.ID);
    Move(AData.ID,Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.TXCount);
    Move(AData.TXCount,Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.IDCurrentBlock);
    Move(AData.IDCurrentBlock,Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.IDFirstBlock);
    Move(AData.IDFirstBlock,Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.IDLastBlock);
    Move(AData.IDLastBlock,Result[i],sz);
    Inc(i,sz);

    sz:= AData.HashCurrentBlock.Len;
    b:= AData.HashCurrentBlock;
    Move(b[0],Result[i],sz);
    Inc(i,sz);

    sz:= AData.HashFirstBlock.Len;
    b:= AData.HashFirstBlock;
    Move(b[0],Result[i],sz);
    Inc(i,sz);

    sz:= AData.HashLastBlock.Len;
    b:= AData.HashLastBlock;
    Move(b[0],Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.CountVal);
    Move(AData.CountVal,Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.CountValOnLine);
    Move(AData.CountValOnLine,Result[i],sz);
    Inc(i,sz);

    sz:= AData.ListIDValOnline.Len;
    b:= AData.ListIDValOnline;
    Move(b[0],Result[i],sz);
    Inc(i,sz);

    sz:= AData.ListIDValOn.Len;
    b:= AData.ListIDValOn;
    Move(b[0],Result[i],sz);
    Inc(i,sz);

    sz:= AData.Sign.Len;
    b:= AData.Sign;
    Move(b[0],Result[i],sz);
    Inc(i,sz);
  end;
end;

class operator TIteration.Implicit(var AData: TBytes): TIteration;
var
  i,sz: Integer;
  b: TBytes;
begin
  Result.Clear;
  if (Length(AData) >= Result.MinLen) then
  begin
    i:= 0;
    sz:= SizeOf(Result.Size);
    Move(AData[i],Result.Size,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.ID);
    Move(AData[i],Result.ID,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.TXCount);
    Move(AData[i],Result.TXCount,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.IDCurrentBlock);
    Move(AData[i],REsult.IDCurrentBlock,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.IDFirstBlock);
    Move(AData[i],REsult.IDFirstBlock,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.IDLastBlock);
    Move(AData[i],REsult.IDLastBlock,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.HashCurrentBlock.Size);
    Move(AData[i],Result.HashCurrentBlock.Size,sz);
    if Result.HashCurrentBlock.Size > 0 then
    begin
      sz:= sz + Result.HashCurrentBlock.Size;
      SetLength(b,sz);
      Move(AData[i],b[0],sz);
      Result.HashCurrentBlock:= b;
    end;
    Inc(i,sz);

    sz:= SizeOf(Result.HashFirstBlock.Size);
    Move(AData[i],Result.HashFirstBlock.Size,sz);
    if Result.HashFirstBlock.Size > 0 then
    begin
      sz:= sz + Result.HashFirstBlock.Size;
      SetLength(b,sz);
      Move(AData[i],b[0],sz);
      Result.HashFirstBlock:= b;
    end;
    Inc(i,sz);

    sz:= SizeOf(Result.HashLastBlock.Size);
    Move(AData[i],Result.HashLastBlock.Size,sz);
    if Result.HashLastBlock.Size > 0 then
    begin
      sz:= sz + Result.HashLastBlock.Size;
      SetLength(b,sz);
      Move(AData[i],b[0],sz);
      Result.HashLastBlock:= b;
    end;
    Inc(i,sz);

    sz:= SizeOf(Result.CountVal);
    Move(AData[i],REsult.CountVal,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.CountValOnLine);
    Move(AData[i],REsult.CountValOnLine,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.ListIDValOnline.FSize);
    Move(AData[i],Result.ListIDValOnline.FSize,sz);
    if Result.ListIDValOnline.FSize > 0 then
    begin
      sz:= sz + Result.ListIDValOnline.FSize;
      SetLength(b,sz);
      Move(AData[i],b[0],sz);
      Result.ListIDValOnline:= b;
    end;
    Inc(i,sz);

    sz:= SizeOf(Result.ListIDValOn.FSize);
    Move(AData[i],Result.ListIDValOn.FSize,sz);
    if Result.ListIDValOn.FSize > 0 then
    begin
      sz:= sz + Result.ListIDValOn.FSize;
      SetLength(b,sz);
      Move(AData[i],b[0],sz);
      Result.ListIDValOn:= b;
    end;
    Inc(i,sz);

    sz:= SizeOf(Result.Sign.Size);
    Move(AData[i],Result.Sign.Size,sz);
    if Result.Sign.Size > 0 then
    begin
      sz:= sz + Result.Sign.Size;
      SetLength(b,sz);
      Move(AData[i],b[0],sz);
      Result.Sign:= b;
    end;
//    Inc(i,sz);
  end;
end;

function TIteration.IDSign: UInt64;
begin
  Result:= Self.Sign.IDKey;
end;

class operator TIteration.Implicit(var AData: TIteration): string;
begin
  AData.Size:= AData.Len - SizeOf(AData.Size);
  Result:= '{Size: ' + AData.Size.ToString
        +  '; ID: ' + AData.ID.ToString
        +  '; TXCount: ' + AData.TXCount.ToString
        +  '; IDCurrentBlock: ' + AData.IDCurrentBlock.ToString
        +  '; IDFirstBlock: ' + AData.IDFirstBlock.ToString
        +  '; IDLastBlock: ' + AData.IDLastBlock.ToString
        +  '; HashCurrentBlock: ' + AData.HashCurrentBlock.ToString
        +  '; HashFirstBlock: ' + AData.HashFirstBlock.ToString
        +  '; HashLastBlock: ' + AData.HashLastBlock.ToString
//        +  '; CountVal: ' + AData.CountVal.ToString
//        +  '; CountValOnLine: ' + AData.CountValOnLine.ToString
//        +  '; ListIDValOnline: ' + AData.ListIDValOnline.ToString
        +  '; ListIDValOn: ' + AData.ListIDValOn.ToString
        +  '; Sign: ' + AData.Sign.ToString
        +  '}'
        ;
end;

function TIteration.IsEmpty: Boolean;
begin
  Result:= Self = TIteration.Empty;
end;

function TIteration.Len: Integer;
begin
  Result:= SizeOf(Self.Size)
          + SizeOf(Self.ID)
          + SizeOf(Self.TXCount)
          + SizeOf(Self.IDCurrentBlock)
          + SizeOf(Self.IDFirstBlock)
          + SizeOf(Self.IDLastBlock)
          + Self.HashCurrentBlock.Len
          + Self.HashFirstBlock.Len
          + Self.HashLastBlock.Len
          + SizeOf(Self.CountVal)
          + SizeOf(Self.CountValOnLine)
          + Self.ListIDValOnline.Len
          + Self.ListIDValOn.Len
          + Self.Sign.Len
          ;
end;

function TIteration.Data: TBytes;
var
  i,sz: Integer;
  b: TBytes;
begin
  i:= SizeOF(Self.Size);
//  sz:= Self.Len - Self.Sign.Len - SizeOF(Self.Size);
//  SetLength(Result,sz);
  b:= Self.ToBytes;
  sz:= Length(b) - SizeOF(Self.Size);
  if sz > 0 then
  begin
    SetLength(Result,sz);
    Move(b[i],Result[0],sz);
  end;
end;

function TIteration.MinLen: Word;
begin
  Result:= SizeOf(Self.Size)
          + SizeOf(Self.ID)
          + SizeOf(Self.TXCount)
          + SizeOf(Self.IDCurrentBlock)
          + SizeOf(Self.IDFirstBlock)
          + SizeOf(Self.IDLastBlock)
          + Self.HashCurrentBlock.MinLen
          + Self.HashFirstBlock.MinLen
          + Self.HashLastBlock.MinLen
          + SizeOf(Self.CountVal)
          + SizeOf(Self.CountValOnLine)
          + Self.ListIDValOnline.MinLen
          + Self.ListIDValOn.MinLen
          + Self.Sign.MinLen
          ;
end;

function TIteration.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TIteration.ToHash: THash32;
begin
  Result.SetHash(Self.Data);
end;

function TIteration.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TIteration'}

{ TDinamicEvent }
{$REGION 'TDinamicEvent'}
procedure TDinamicEvent.Clear;
begin
  Self.Size:= 0;
  Self.ID:= 0;
  Self.TypeEvent:= teNope;
  Self.TimeStamp:= 0;
  FillChar(Self.Data[0],Length(Self.Data),0);
  SetLength(Self.Data,0);
end;

class function TDinamicEvent.Empty: TDinamicEvent;
begin
  Result.Clear;
end;

class operator TDinamicEvent.Equal(const AData1, AData2: TDinamicEvent): Boolean;
begin
  Result:= (AData1.Size = AData2.Size)
          and (AData1.ID = AData2.ID)
          and (AData1.TypeEvent = AData2.TypeEvent)
          and (AData1.TimeStamp = AData2.TimeStamp)
          and CompareMem(AData1.Data,AData2.Data,Length(AData1.Data));
end;

class operator TDinamicEvent.NotEqual(const AData1,
  AData2: TDinamicEvent): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

procedure TDinamicEvent.SetEvent(AID: Integer; ATypeEvent: teType; AData: TBytes);
begin
  Self.Clear;
  Self.Size:= Self.MinLen - SizeOf(Self.Size) + Length(Adata);
  Self.ID:= AID;
  Self.TypeEvent:= ATypeEvent;
  Self.TimeStamp:= Now();

  SetLength(Self.Data, Length(Adata));
  Move(AData[0],Self.Data[0],Length(AData));
end;

class operator TDinamicEvent.Implicit(const AData: TBytes): TDinamicEvent;
var
  i, l, size: Integer;
begin
  i:= 0;
  l:= 0;
  l:= Length(AData)
       - SizeOf(Result.Size)
       - SizeOf(Result.ID)
       - SizeOf(Result.TypeEvent)
       - SizeOf(Result.TimeStamp);

  if l >= 0 then
  begin
    size:= SizeOf(Result.Size);
    Move(AData[i],Result.Size,size);
    Inc(i,size);

    size:= SizeOf(Result.ID);
    Move(AData[i],Result.ID,size);
    Inc(i,size);

    size:= SizeOf(Result.TypeEvent);
    Move(AData[i],Result.TypeEvent,size);
    Inc(i,size);

    size:= SizeOf(Result.TimeStamp);
    Move(AData[i],Result.TimeStamp,size);
    Inc(i,size);

    SetLength(Result.Data,l);
    Move(AData[i],Result.Data[0],l);
//    Inc(i,l);
  end
  else
    raise Exception.Create('Bad event. Data size: ' + l.ToString);
end;

class operator TDinamicEvent.Implicit(const AData: TDinamicEvent): TBytes;
var
  i,size: Integer;
begin
  i:= 0;
  SetLength(Result, AData.Len);

  size:= SizeOf(AData.Size);
  Move(AData.Size,Result[i],size);
  Inc(i,size);

  size:= SizeOf(AData.ID);
  Move(AData.ID,Result[i],size);
  Inc(i,size);

  size:= SizeOf(AData.TypeEvent);
  Move(AData.TypeEvent,Result[i],size);
  Inc(i,size);

  size:= SizeOf(AData.TimeStamp);
  Move(AData.TimeStamp,Result[i],size);
  Inc(i,size);

  size:= Length(AData.Data);
  Move(AData.Data[0],Result[i],size);
//  Inc(i,size);
end;

class operator TDinamicEvent.Implicit(const AData: Boolean): TDinamicEvent;
var
  b: TBytes;
begin
  SetLength(b,SizeOf(AData));
  Move(AData,b[0],SizeOf(AData));
  Result.SetEvent(0,Result.teBool,b);
end;

class operator TDinamicEvent.Implicit(const AData: TDinamicEvent): Boolean;
begin
  Result:= False;
  if AData.TypeEvent = AData.teBool then
    Move(AData.Data[0],Result,SizeOf(Result));
end;

class operator TDinamicEvent.Implicit(const AData: string): TDinamicEvent;
var
  t: TText;
begin
  t:= AData;
  Result.SetEvent(0,Result.teText,t.ToBytes);
end;

class operator TDinamicEvent.Implicit(const AData: TDinamicEvent): string;
var
  s: string;
begin
  case AData.TypeEvent of
    AData.teNope:
    begin
      s:= 'Data: ' + BytesToHexStr(AData.Data);
    end;
    AData.teText:
    begin
      s:= 'Text: ' + TText(AData.Data);
    end;
    AData.teBool:
    begin
      s:= 'Boolean: ' + BytesToHexStr(AData.Data);
    end;
    AData.teBytes:
    begin
      s:= 'Data: ' + BytesToHexStr(AData.Data);
    end;
    else
    begin
      s:= 'Data: ' + BytesToHexStr(AData.Data);
    end;
  end;
  Result:= '{Event: {ID: ' + AData.ID.ToString + ';'
          + 'TypeEvent: ' + AData.TypeEvent.ToString + ';'
          + 'TimeStamp: ' + FormatDateTime(FormatDateTimeRU,AData.TimeStamp) + ';'
//          + 'Data: ' + BytesToHexStr(AData.Data)// + ';'
          + s
          + '}}'
          ;
end;

function TDinamicEvent.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

function TDinamicEvent.Len: Integer;
begin
  Result:= SizeOf(Self.Size)
            + SizeOf(Self.ID)
            + SizeOf(Self.TypeEvent)
            + Length(Self.Data)
            + SizeOf(Self.TimeStamp);
end;

function TDinamicEvent.MinLen: Integer;
begin
  Result:= SizeOf(Self.Size)
            + SizeOf(Self.ID)
            + SizeOf(Self.TypeEvent)
            + SizeOf(Self.TimeStamp);
end;

function TDinamicEvent.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TDinamicEvent.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TDinamicEvent'}

{ TValidator }
{$REGION 'TValidator'}
procedure TValidator.Clear;
begin
  Self.ValInf.Clear;
  Self.PbK.Clear;
  Self.Online:= False;
  Self.Enable:= False;
  Self.Orator:= False;
  Self.Client:= nil;
  Self.CheckTxRx:= Self.chTxRx_Nope;
  Self.TmTx:= 0;
  Self.TmRx:= 0;
  Self.CheckOnlineTime:= 0;
  Self.Iteration.Clear;
end;

class function TValidator.Empty: TValidator;
begin
  Result.Clear;
end;

class operator TValidator.Equal(const AData1, AData2: TValidator): Boolean;
begin
  Result:= (AData1.ValInf = AData2.ValInf)
        and (AData1.Online = AData2.Online)
        and (AData1.Enable = AData2.Enable)
        and (AData1.Orator = AData2.Orator)
        and (AData1.Client = AData2.Client)
//        and (Length(AData1.PbK.PublicKey) = Length(AData2.PbK.PublicKey))
//        and CompareMem(@AData1.PbK.PublicKey[0],@AData2.PbK.PublicKey[0],Length(AData1.PbK.PublicKey))
        and (AData1.PbK = AData2.PbK)
        and (AData1.CheckOnlineTime = AData2.CheckOnlineTime)
        and (AData1.Iteration = AData2.Iteration)
        ;
end;

class operator TValidator.NotEqual(const AData1, AData2: TValidator): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TValidator.Implicit(const AData: TValidator): Pointer;
begin
  Result:= @AData;
end;

procedure TValidator.SetEnable(AData: Boolean);
begin
  Self.Enable:= AData;
end;

function TValidator.GetEnable: Boolean;
begin
  Result:= Self.Enable;
end;

procedure TValidator.SetPbK(AData: TPubKey);
begin
  Self.PbK:= AData;
end;

function TValidator.GetPbK: TPubKey;
begin
  Result:= Self.PbK;
end;

procedure TValidator.SetID(AData: UInt64);
begin
  Self.ValInf.ID:= AData;
end;

function TValidator.GetID: UInt64;
begin
  Result:= Self.ValInf.ID;
end;

function TValidator.IsEmpty: Boolean;
begin
  Result:= Self = TValidator.Empty;
end;
{$ENDREGION 'TValidator'}

{ TSign }
{$REGION 'TSign'}
procedure TSign.Clear;
begin
  Self.Size:= 0;
  Self.IDKey:= 0;
  Self.KeySize:= 0;
  if Length(Self.Data) > 0 then
  begin
    FillChar(Self.Data[0],Length(Self.Data),0);
    SetLength(Self.Data,0);
  end;
end;

class function TSign.Empty: TSign;
begin
  Result.Clear;
end;

class operator TSign.Equal(const AData1, AData2: TSign): Boolean;
begin
  Result:= (AData1.Size = AData2.Size)
        and (AData1.IDKey = AData2.IDKey)
        and (AData1.KeySize = AData2.KeySize)
        and (Length(AData1.Data) = Length(AData2.Data))
        and CompareMem(AData1.Data,AData2.Data, Length(AData1.Data))
end;

class operator TSign.NotEqual(const AData1, AData2: TSign): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TSign.Implicit(const AData: TSign): TBytes;
var
  i, sz: Integer;
begin
  i:= 0;
  SetLength(Result,AData.Len);

  sz:= SizeOf(AData.Size);
  Move(AData.Size,Result[i],sz);
  Inc(i,sz);

  if AData.Size > 0 then
  begin
    sz:= SizeOf(AData.IDKey);
    Move(AData.IDKey,Result[i],sz);
    Inc(i,sz);

    sz:= SizeOf(AData.KeySize);
    Move(AData.KeySize,Result[i],sz);
    Inc(i,sz);

    sz:= Length(AData.Data);
    Move(AData.Data[0],Result[i],sz);
  //  Inc(i,sz);
  end;
end;

class operator TSign.Implicit(const AData: TBytes): TSign;
var
  i, sz: Integer;
begin
  i:= 0;

  sz:= Result.MinLen;
  Move(AData[i],Result.Size,sz);
  Inc(i,sz);

  if (Length(AData) > Result.Size) and (Result.Size > 0) then
  begin
    sz:= SizeOf(Result.IDKey);
    Move(AData[i],Result.IDKey,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.KeySize);
    Move(AData[i],Result.KeySize,sz);
    Inc(i,sz);

    sz:= Result.Size - SizeOf(Result.IDKey) - SizeOf(Result.KeySize);
    SetLength(Result.Data,sz);
    Move(AData[i],Result.Data[0],sz);
//    Inc(i,size);
  end
  else
    Result.Clear;
end;

class operator TSign.Implicit(const AData: TSign): string;
begin
//  Result:= BytesToHexStr(AData.Data);
  Result:= BytesToHexStr(AData.ToBytes);
end;

function TSign.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

class operator TSign.Implicit(const AData: string): TSign;
begin
  Result:= HexStrToBytes(AData);
end;

function TSign.Len: Integer;
begin
  Result:= Self.MinLen + Self.Size;
end;

function TSign.MinLen: Integer;
begin
  Result:= SizeOf(Self.Size) {+ SizeOf(Self.IDKey) + SizeOf(Self.KeySize)};
end;

procedure TSign.SetSign(const AData: TBytes; const AIDKey: UInt64 ;const APrivateKey: TPrivKey);
var
  sz: Integer;
  b: TBytes;
begin
  RSAPrKEncrypt(APrivateKey.PrivKey,AData,b);
  Self.KeySize:= APrivateKey.PrivKey.KeySize;
  Self.IDKey:= AIDKey;

  sz:= Length(b);
  SetLength(Self.Data,sz);
  Move(b[0],Self.Data[0],sz);

  Self.Size:= SizeOf(Self.IDKey) + SizeOf(Self.KeySize) + sz;
end;

function TSign.CheckSign(const AData: TBytes; APubKey: TPubKey): Boolean;
var
  sz: Integer;
  b: TBytes;
begin
  Result:= False;
  if (not Self.IsEmpty) and (not APubKey.IsEmpty) then
  begin
    try
      RSAPbKDecrypt(APubKey.ToPbK,Self.Data,b);
    except
      Result:= False;
      Exit;
    end;
    sz:= Length(b);

    Result:= (Length(AData) = sz)
          and CompareMem(AData,b,sz);
  end
  else
  begin
    Result:= True;
  end;
end;

function TSign.GetData(APubKey: TPubKey): TBytes;
begin
  try
    RSAPbKDecrypt(APubKey.ToPbK,Self.Data,Result);
  except
    Result:= [];
  end;
end;

function TSign.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TSign.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TSign'}

{ TPubKey }
{$REGION 'TPubKey'}
{
procedure TPubKey.Clear;
begin
  try
    FinalizePubKey(Self.PubKey);
//    Self.PubKey.KeySize:= 0;
  except

  end;
end;

class function TPubKey.Empty: TPubKey;
begin
  Result.Clear;
end;

class operator TPubKey.Equal(const AData1, AData2: TPubKey): Boolean;
begin
  Result:= (AData1.Len = AData2.Len)
        and CompareMem(AData1.ToBytes,AData2.ToBytes,AData1.Len);
end;

procedure TPubKey.GetPbK(APrivateKey: TPrivateKey);
begin
  Self.Clear;
  GenPubKey(APrivateKey,Self.PubKey);
end;

class operator TPubKey.NotEqual(const AData1, AData2: TPubKey): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TPubKey.Implicit(const AData: TPubKey): TBytes;
begin
  try
    PubKeyToBytes(AData.PubKey,Result);
  except

  end;
end;

class operator TPubKey.Implicit(const AData: TBytes): TPubKey;
begin
  try
    BytesToPubKey(AData,Result.PubKey);
  except

  end;
end;

class operator TPubKey.Implicit(const AData: string): TPubKey;
begin
  try
    BytesToPubKey(HexStrToBytes(AData),Result.PubKey);
  except

  end;
end;

class operator TPubKey.Implicit(const AData: TPubKey): string;
begin
  Result:= BytesToHexStr(AData.ToBytes);
end;

function TPubKey.Len: Integer;
begin
  Result:= Length(Self.ToBytes);
end;

function TPubKey.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TPubKey.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TPubKey'}

{ TPrivKey }
{$REGION 'TPrivKey'}
procedure TPrivKey.Clear;
begin
  try
    Self.PrivKey.KeySize:= 0;
    FinalizePrivKey(Self.PrivKey);
  except

  end;
end;

class function TPrivKey.Empty: TPrivKey;
begin
  Result.Clear;
end;

class operator TPrivKey.Equal(const AData1, AData2: TPrivKey): Boolean;
begin
  Result:= (AData1.Len = AData2.Len)
        and CompareMem(AData1.ToBytes,AData2.ToBytes,AData1.Len);
end;

procedure TPrivKey.GenPrK(ASizeKey: TSizeKey);
begin
  Self.Clear;
  GenPrivKey(ASizeKey,Self.PrivKey);
end;

class operator TPrivKey.NotEqual(const AData1, AData2: TPrivKey): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TPrivKey.Implicit(const AData: TPrivKey): TBytes;
begin
  try
    PrivKeyToBytes(AData.PrivKey,Result);
  except

  end;
end;

class operator TPrivKey.Implicit(const AData: TBytes): TPrivKey;
begin
  try
    BytesToPrivKey(AData,Result.PrivKey);
  except

  end;
end;

class operator TPrivKey.Implicit(const AData: string): TPrivKey;
begin
  try
    BytesToPrivKey(HexStrToBytes(AData),Result.PrivKey);
  except

  end;
end;

class operator TPrivKey.Implicit(const AData: TPrivKey): string;
begin
  Result:= BytesToHexStr(AData.ToBytes);
end;

function TPrivKey.Len: Integer;
begin
  Result:= Length(Self.ToBytes);
end;

function TPrivKey.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TPrivKey.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TPrivKey'}

{ TListVal }
{$REGION 'TListVal'}
constructor TListVal.Create(ANodeID: UInt64);
begin
  inherited Create;
  FCS:= TCriticalSection.Create;
  FNodeID:= ANodeID;
  FActive:= True;
//  DoReconnect;
//  DoCheckOnline();
end;

destructor TListVal.Destroy;
var
  i: Integer;
begin
  FCS.Enter;
  FActive:= False;
  for i:= Pred(inherited Count) downto 0 do
  begin
    if inherited Items[i].Client <> nil then
    begin
      try
        if inherited Items[i].Client.Connected then
          inherited Items[i].Client.Disconnect;
        inherited Items[i].Client.Free;
//        inherited Items[i].Client:= nil;
      except

      end;
    end;
  end;

  inherited Clear;
  FCS.Leave;
  FCS.Free;
  inherited;
end;

function TListVal.CheckAddr(): Integer;
var
  i,n:Integer;
  Validator: TValidator;
  NetAddr: TNetAddr;
begin
  Result:= -1;
  FCS.Enter;
  n:= inherited Count;
  for i:= 0 to Pred(n) do
  begin
    Validator:= inherited Items[i];
    if (inherited Items[i].Client <> nil) then
    begin
      Validator.Client.OnDisconnectE:= DoOnDisconnect;
      NetAddr:= Validator.Client.IPv4 + ':' + Validator.Client.Port.ToString;
      if Validator.ValInf.NetAddr <> NetAddr then
      begin
        Validator.ValInf.NetAddr:= NetAddr;
      end;
      inherited Items[i]:= Validator;
//      NetAddr:= inherited Items[i].Client.IPv4 + ':' + inherited Items[i].Client.Port.ToString;
//      if Validator.ValInf.NetAddr <> NetAddr then
//      begin
//        inherited Items[i].ValInf.NetAddr:= NetAddr;
//      end;
    end;
  end;
  Result:= n;
  FCS.Leave;
end;

function TListVal.DoCheckOnline(): Integer;
begin
  TThread.CreateAnonymousThread(
      procedure
      begin
        while FActive do
        begin
          Sleep(CHECK_CONNECT_TIMEOUT);
          if FActive then
            CheckOnline();
        end;
      end).Start;
end;

function TListVal.CheckOnline(): Integer;
var
  i,n, online:Integer;
  Validator: TValidator;
begin
  Result:= -1;
  online:= 0;
  FCS.Enter;
  n:= inherited Count;
  for i:= 0 to Pred(n) do
  begin
    Validator:= inherited Items[i];

//    Validator.Enable:= False;
    if (inherited Items[i].Client <> nil) then
    begin
      inherited Items[i].Client.OnDisconnectE:= DoOnDisconnect;
      try
        if (inherited Items[i].Client.Connected)
          and (Validator.CheckOnlineTime + 1/24/60/60/1000 * CHECK_CONNECT_TIMEOUT < Now()) then
        begin
          Validator.Online:= True;
          Validator.CheckOnlineTime:= Now();
//          inherited Items[i].Online:= True;
//          inherited Items[i].CheckOnlineTime:= Now();
          Inc(online);
        end
        else
        begin
          Validator.Online:= False;
          Validator.Enable:= False;
        end;
      except

      end;
    end;
//    if (inherited Items[i].Online <> Validator.Online) then
      inherited Items[i]:= Validator;
  end;
  FCountOnline:= online;
  Result:= n;
  FCS.Leave;
end;

procedure TListVal.CheckTimeReceive(AID: UInt64);
var
  Validator: TValidator;
begin
  Validator:= Self.ValidatorOfID(AID);
  Validator.Online:= True;
  Validator.CheckOnlineTime:= Now();
  Self.Update(Validator);
end;

procedure TListVal.CheckTx(AID: UInt64);
var
  Validator: TValidator;
begin
  Validator:= Self.ValidatorOfID(AID);
  Validator.CheckTxRx:= TValidator.chTxRx_Nope;
  Validator.TmTx:= Now();
  Self.Update(Validator);
end;

procedure TListVal.CheckRx(AID: UInt64);
var
  Validator: TValidator;
begin
  Validator:= Self.ValidatorOfID(AID);
  Validator.TmRx:= Now();
  Validator.CheckTxRx:= TValidator.chTxRx_GOOD;
  Self.Update(Validator);
end;

procedure TListVal.Reconnect;
var
  i,n, online:Integer;
  Validator: TValidator;
begin
  online:= 0;
  while FActive do
  begin
    FCS.Enter;
    n:= inherited Count;
    for i:= 0 to Pred(n) do
    begin
      Validator:= inherited Items[i];
      Validator.Online:= False;
      if not Validator.ValInf.IsEmpty then
      begin
        if (Validator.Client <> nil) and (not Validator.ValInf.NetAddr.IsEmpty) then
        begin
          if Validator.CheckOnlineTime + 1/24/60/60/1000 * RECONNECT_TIMEOUT < Now() then
          begin
            try
              if not (Validator.Client.Connected) then
              begin
                if
                  Validator.Client.TryConnect(Validator.ValInf.NetAddr.ToIPv4,Validator.ValInf.NetAddr.ToPort)
                then
                begin
//                  Validator.Client.SendMessage([0, 0, 0, 0, 0, 0, 0, 0, 0]);
                  Sleep(100);
                  Validator.Online:= True;
                  Inc(online);
                  DoOnReconnect(Validator.Client);
                end;
              end
              else
              begin
                Validator.Online:= True;
                Inc(online);
              end;
            except
              Validator.Online:= False;
            end;
          end;
        end
        else
        begin
          if (not Validator.ValInf.NetAddr.IsEmpty) then
//            if not (Validator.Client.Connected) then
            begin
              if
                Validator.Client.TryConnect(Validator.ValInf.NetAddr.ToIPv4,Validator.ValInf.NetAddr.ToPort)
              then
              begin
//                Validator.Client.SendMessage([0, 0, 0, 0, 0, 0, 0, 0, 0]);
                Validator.Online:= True;
                Inc(online);
                DoOnReconnect(Validator.Client);
              end
              else
              begin
                Validator.Online:= False;
              end;
            end
        end;
      end;
  //    if (inherited Items[i].Online <> Validator.Online) then
      Validator.CheckOnlineTime:= Now();
      inherited Items[i]:= Validator;
    end;
    FCountOnline:= online;
    FCS.Leave;
    Sleep(RECONNECT_TIMEOUT);
//    Sleep(1000);
  end;
end;

procedure TListVal.DoOnDisconnect(AClient: TClient);
begin
  if Assigned(OnDisconnect) then OnDisconnect(AClient);
end;

procedure TListVal.DoOnReconnect(AClient: TClient);
begin
  if Assigned(OnReconnect) then OnReconnect(Self,AClient);
end;

procedure TListVal.DoReconnect;
begin
  TThread.CreateAnonymousThread(
      procedure
      begin
        Reconnect;
      end).Start;
end;

function TListVal.GetCount: Integer;
begin
  FCS.Enter;
  Result:= inherited Count;
  FCS.Leave;
end;

function TListVal.SendData(AData: TBytes): Integer;
var
  i,n: Integer;
begin
  FCS.Enter;
  Result:= 0;
  n:= Count;
  for i:= 0 to Pred(n) do
  begin
    try
      if (Items[i].ID <> 0) {and (Items[i].ID <> FNodeID)} then
        if Items[i].Client <> nil then
//          if Items[i].Client.Connected then
            if Items[i].Client.SendMessage(AData) >= 0 then
              Inc(Result);
    except

    end;
  end;
  FCS.Leave;
end;

function TListVal.SendDataToID(AID: UInt64; AData: TBytes): Integer;
begin
  Result:= Self.ValidatorOfID(AID).Client.SendMessage(AData);
end;

procedure TListVal.SetCountOnline(AData: integer);
begin
  FCS.Enter;
  FCountOnline:= AData;
  FCS.Leave;
end;

function TListVal.GetCountOnline: Integer;
begin
  FCS.Enter;
  Result:= FCountOnline;
  FCS.Leave;
end;

function TListVal.Add(AData: TValidator): Integer;
begin
  FCS.Enter;
  if inherited IndexOf(AData) < 0 then
  begin
    if (AData.Client <> nil) and (Assigned(AData.Client)) then
      AData.Client.OnDisconnectE:= DoOnDisconnect;
    Result:= inherited Add(AData);
  end;
  FCS.Leave;
end;

function TListVal.Delete(AIndex: Integer): Integer;
begin
  FCS.Enter;
  inherited Delete(AIndex);
  FCS.Leave;
end;

function TListVal.GetItem(AIndex: Integer): TValidator;
begin
  FCS.Enter;
  Result:= inherited Items[AIndex];
  FCS.Leave;
end;

function TListVal.IndexOf(const Value: TValidator): Integer;
begin
  FCS.Enter;
  Result:= inherited IndexOf(Value);
  FCS.Leave;
end;

function TListVal.IndexOfID(const AID: UInt64): Integer;
var
  i,n: Integer;
begin
  FCS.Enter;
  Result:= -1;
  for i:= 0 to Pred(inherited count) do
  begin
    if inherited Items[i].ValInf.ID = AID  then
    begin
      Result:= i;
      Break;
    end;
  end;
  FCS.Leave;
end;

function TListVal.ValidatorOfID(const AID: UInt64): TValidator;
var
  i,n: Integer;
begin
  FCS.Enter;
  Result.Clear;
  for i:= 0 to Pred(inherited count) do
  begin
    if inherited Items[i].ValInf.ID = AID  then
    begin
      Result:= inherited Items[i];
      Break;
    end;
  end;
  FCS.Leave;
end;

procedure TListVal.Move(CurIndex, NewIndex: Integer);
begin
  FCS.Enter;
  inherited Move(CurIndex,NewIndex);
  FCS.Leave;
end;

function TListVal.PbKOfID(const AID: UInt64): TPubKey;
var
  i: Integer;
begin
  FCS.Enter;
  Result:= TPubKey.Empty;
  for i:= 0 to Pred(inherited count) do
  begin
    if inherited Items[i].ValInf.ID = AID  then
    begin
      Result:= inherited Items[i].PbK;
      Break;
    end;
  end;
  FCS.Leave;
end;

function TListVal.Remove(AData: TValidator): Integer;
begin
  FCS.Enter;
  Result:= inherited Remove(AData);
  FCS.Leave;
end;

procedure TListVal.SetItem(AIndex: Integer; const Value: TValidator);
begin
  FCS.Enter;
  inherited Items[AIndex]:= Value;
  FCS.Leave;
end;

function TListVal.Update(AData: TValidator): Integer;
var
  i,n: Integer;
begin
  FCS.Enter;
  Result:= -1;
  if (AData.Client <> nil) and (Assigned(AData.Client)) then
    AData.Client.OnDisconnectE:= DoOnDisconnect;
  for i:= 0 to Pred(inherited count) do
  begin
    if inherited Items[i].ValInf.ID = AData.ValInf.ID  then
    begin
      inherited Items[i]:= AData;
      Result:= i;
      Break;
    end;
  end;
  FCS.Leave;
end;
{$ENDREGION 'TListVal'}

{ TPubKey2 }
{$REGION 'TPubKey2'}
procedure TPubKey2.Clear;
begin
  FillChar(Self.Data[0],0,Self.Len);
  SetLength(Self.Data,0);
end;

class function TPubKey2.Empty: TPubKey2;
begin
  Result.Clear;
end;

class operator TPubKey2.Equal(const AData1, AData2: TPubKey2): Boolean;
begin
  Result:= (AData1.Len = AData2.Len)
        and CompareMem(AData1.Data,AData2.Data,AData1.Len);
end;

class operator TPubKey2.NotEqual(const AData1, AData2: TPubKey2): Boolean;
begin
  Result:= not(AData1 = AData2);
end;

class operator TPubKey2.Implicit(const AData: TBytes): TPubKey2;
begin
  SetLength(Result.Data,Length(AData));
  Move(AData[0],Result.Data[0],Length(AData));
end;

class operator TPubKey2.Implicit(const AData: TPubKey2): TBytes;
begin
  SetLength(Result,AData.Len);
  Move(AData.Data[0],Result[0],AData.Len);
end;

class operator TPubKey2.Implicit(const AData: TPubKey2): TPublicKey;
begin
  try
    BytesToPubKey(AData.Data,Result);
  except

  end;
end;

class operator TPubKey2.Implicit(const AData: TPublicKey): TPubKey2;
begin
  try
    PubKeyToBytes(AData,Result.Data);
  except

  end;
end;

class operator TPubKey2.Implicit(const AData: string): TPubKey2;
begin
  try
    Result:= HexStrToBytes(AData);
  except

  end;
end;

class operator TPubKey2.Implicit(const AData: TPubKey2): string;
begin
  Result:= BytesToHexStr(AData.Data);
end;

function TPubKey2.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

procedure TPubKey2.GetPbK(APrivateKey: TPrivateKey);
var
  PbK: TPublicKey;
begin
  Self.Clear;
  GenPubKey(APrivateKey,PbK);
  Self:= PbK;
end;

function TPubKey2.Len: Integer;
begin
  Result:= Length(Self.Data);
end;

function TPubKey2.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TPubKey2.ToPbK: TPublicKey;
begin
  Result:= Self;
end;

function TPubKey2.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TPubKey2'}

{ TTXData }
{$REGION 'TTXData'}
procedure TTXData.Clear;
begin
  Self.IDNode:= 0;
  Self.IDIter:= 0;
  Self.CntTX:= 0;
  Self.Check:= False;
  FillChar(Self.TX[0],Length(Self.TX),0);
  SetLength(Self.TX,0);
end;

class function TTXData.Empty: TTXData;
begin
  Result.Clear;
end;

function TTXData.Len: Integer;
begin
  Result:= SizeOf(Self.IDNode)
         + SizeOf(Self.IDIter)
         + SizeOf(Self.CntTX)
         + Length(Self.TX)
         ;
end;

procedure TTXData.SetData(AIDNode, AIDIter: UInt64; ATX: TBytes);
begin
//  if Self.IDIter < AIDIter then
  begin
    Self.Clear;
    Self.IDNode:= AIDNode;
    Self.IDIter:= AIDIter;
    SetLength(Self.TX, Length(ATX));
    Move(ATX[0],Self.TX[0], Length(ATX));
  end;
end;

{$ENDREGION 'TTXData'}

{ TArrayTXData }
{$REGION 'TArrayTXData'}
procedure TArrayTXData.Clear;
var
  i,n: Integer;
begin
  Self.IDNode:= 0;
  Self.IDIter:= 0;
  Self.CntNode:= 0;
  Self.TimeStamp:= 0;
  Self.CurrentHash.Clear;
  Self.Hash.Clear;
  Self.Sign.Clear;
  n:= Length(Self.Data);
  for i:= 0 to Pred(n) do
    Self.Data[i].Clear;
  SetLength(Self.Data,0);
end;

class function TArrayTXData.Empty: TTXData;
begin
  Result.Clear;
end;

function TArrayTXData.FullData: TBytes;
var
  i,n,check: Integer;
begin
  Result:= [];
  n:= Length(Self.Data);
  for i:= 0 to Pred(n) do
  begin
    Result:= Result + Self.Data[i].TX;
  end;
end;

function TArrayTXData.GetItemID(AIndex: UInt64): TTXData;
var
  i,n: Integer;
begin
  Result.Clear;
  n:= Length(Self.Data);
  for i:= 0 to Pred(n) do
  begin
    if Self.Data[i].IDNode = AIndex then
    begin
      Result:= Self.Data[i];
      Break;
    end;
  end;
end;

procedure TArrayTXData.Init(AIDNode: UInt64; AIDIter: UInt64; ACurrentHash: THash32; AIDNodeList: TListIDVal);
var
  i: Integer;
begin
//  if (Self.IDIter < AIDIter) and (Self.CntNode = AIDNodeList.Count) then
  begin
    Self.Clear;
    Self.IDNode:= AIDNode;
    Self.IDIter:= AIDIter;
    Self.CurrentHash:= ACurrentHash;
    Self.TimeStamp:= Now();
    Self.CntNode:= AIDNodeList.Count;
    Self.CntCheck:= 0;
    SetLength(Self.Data,Self.CntNode);
    for i:= 0 to Pred(Self.CntNode) do
    begin
      Self.Data[i].Clear;
      Self.Data[i].IDIter:= AIDIter;
      Self.Data[i].IDNode:= AIDNodeList.Data[i];
    end;
  end;
end;

//function TArrayTXData.ItemsOfID(AIndex: UInt64): TTXData;
//begin
//  Result:= GetItemID(AIndex);
//end;

function TArrayTXData.Add(ATXData: TTXData): Integer;
var
  i,n: Integer;
begin
  Result:= -1;
  n:= Length(Self.Data);
  for i:= 0 to Pred(n) do
  begin
    if Self.Data[i].IDNode = ATXData.IDNode then
    begin
      if Self.Data[i].IDIter = ATXData.IDIter then
      begin
        ATXData.Check:= Self.Data[i].Check;
        Self.Data[i]:= ATXData;
      end;
      if not Self.Data[i].Check then
      begin
        Self.Data[i].Check:= True;
        Inc(Self.CntCheck);
      end;
      Result:= i;
      Break;
    end;
  end;
  if Self.CntNode = Self.CntCheck then
  begin
    Self.Hash.SetHash(Self.CurrentHash.ToBytes + Self.FullData);
  end
  else
  begin
    Self.Hash.Clear;
  end;
end;

procedure TArrayTXData.SetHash();
begin
//  Self.Hash.SetHash(AData);
  Self.Hash.Clear;
  if Self.CntNode = Self.CntCheck then
    Self.Hash.SetHash(Self.CurrentHash.ToBytes + Self.FullData);
end;

procedure TArrayTXData.SetSign(AIDKey: UInt64; APrK: TPrivKey);
begin
  Self.Sign.Clear;
  if (not Self.Hash.IsEmpty) then
  begin
    Self.Sign.SetSign(Self.Hash,AIDKey,APrK);
  end;
end;

{$ENDREGION 'TArrayTXData'}

{ TValInf }

procedure TVInf.Clear;
begin
  Self.ID:= 0;
  FillChar(Self.Step,Length(Self.Step),0);
end;

{ TQuorumList }
{$REGION 'TQuorumList'}
procedure TQuorumList.Add(AValInf: TVInf);
var
  n: Integer;
begin
  n:= Length(Self.Quorum);
  SetLength(Self.Quorum, n + 1);
  Self.Quorum[n]:= AValInf;
end;

procedure TQuorumList.SetIDStep(AIDStep: Integer; AID: UInt64; AState: Byte);
var
  i, n: Integer;
begin
  n:= Length(Self.Quorum);
  for i:= 0 to Pred(n) do
  begin
    if Self.Quorum[i].ID = AID then
      Self.Quorum[i].Step[AIDStep]:= AState;
  end;
end;

function TQuorumList.CheckStep(AIDStep: Integer): Boolean;
var
  i,n: Integer;
begin
  Result:= False;
  if AIDStep = 0 then
  begin
    Result:= True;
  end
  else
  begin
    n:= Length(Self.Quorum);
    if n >= 1 then
    begin
      for i:= 0 to Pred(n) do
        if (Self.Quorum[i].Step[AIDStep]) = 0 then
        begin
          Result:= False;
          Break;
        end;
      Result:= True;
    end;
  end;
end;

procedure TQuorumList.Clear;
begin
  Self.IDMainNode:= 0;
  Self.IDIter:= 0;
  Self.CurrentStep:= 0;
  SetLength(Self.Quorum,0);
end;

procedure TQuorumList.Init(AIDMainNode: UInt64; AIDIter, ACurrentStep: Integer);
begin
  Self.Clear;
  Self.IDMainNode:= AIDMainNode;
  Self.IDIter:= AIDIter;
  Self.CurrentStep:= ACurrentStep;
end;
{$ENDREGION 'TQuorumList'}


{ TNodeState }
{$REGION 'TNodeState'}
function TNodeState.BooleanToStr(AData: Boolean): string;
begin
  if AData then
    Result:= 'True'
  else
    Result:= 'False';
end;

procedure TNodeState.Clear;
begin
  Self.Size:= Self.MinLen - SizeOf(Self.Size);
  Self.IDNode:= 0;
  Self.Enable:= False;
  Self.IDLastBlock:= 0;
  Self.HashLastBlock.Clear;
end;

class function TNodeState.Empty: TNodeState;
begin
  Result.Clear;
end;

class operator TNodeState.Equal(const AData1, AData2: TNodeState): Boolean;
begin
  Result:= (AData1.Size = Adata2.Size)
        and (AData1.IDNode = Adata2.IDNode)
        and (AData1.Enable = Adata2.Enable)
        and (AData1.IDLastBlock = Adata2.IDLastBlock)
        and (AData1.HashLastBlock = Adata2.HashLastBlock)
        and (AData1.UnixTime = Adata2.UnixTime)
        ;
end;

class operator TNodeState.NotEqual(const AData1, AData2: TNodeState): Boolean;
begin
  Result:= not (AData1 = Adata2);
end;

class operator TNodeState.Implicit(const AData: TNodeState): TBytes;
var
  i,sz: Integer;
  b: TBytes;
begin
  SetLength(Result,AData.Len);

  i:= 0;
  sz:= SizeOf(AData.Size);
  Move(AData.Size,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.IDNode);
  Move(AData.IDNode,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.Enable);
  Move(AData.Enable,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.IDLastBlock);
  Move(AData.IDLastBlock,Result[i],sz);
  Inc(i,sz);

//  sz:= AData.UnixTime.Len;
//  Move(AData.UnixTime.Data,Result[i],sz);
  sz:= SizeOf(AData.UnixTime);
  Move(AData.UnixTime,Result[i],sz);
  Inc(i,sz);

  sz:= AData.HashLastBlock.Len;
  b:= AData.HashLastBlock;
  Move(b[0],Result[i],sz);
  Inc(i,sz);
end;

class operator TNodeState.Implicit(const AData: TBytes): TNodeState;
var
  i,sz: Integer;
  b: TBytes;
begin
  Result.Clear;
  i:= 0;
  if Length(AData) >= Result.MinLen then
  begin
    sz:= SizeOf(Result.Size);
    Move(AData[i],Result.Size,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.IDNode);
    Move(AData[i],Result.IDNode,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.Enable);
    Move(AData[i],Result.Enable,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.IDLastBlock);
    Move(AData[i],Result.IDLastBlock,sz);
    Inc(i,sz);

//    sz:= Result.UnixTime.Len;
//    Move(AData[i],Result.UnixTime.Data,sz);
    sz:= SizeOf(Result.UnixTime);
    Move(AData[i],Result.UnixTime,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.HashLastBlock.MinLen);
    Move(AData[i],Result.HashLastBlock.Size,sz);
    sz:= sz + Result.HashLastBlock.Size;
    SetLength(b,sz);
    Move(AData[i],b[0],sz);
    Result.HashLastBlock:= b;
    Inc(i,sz);
  end;
end;

class operator TNodeState.Implicit(const AData: TNodeState): string;
begin
  Result:= '{ NodeState: {'
            + 'IDNode: ' + AData.IDNode.ToString + ', '
            + 'Enable: ' + Adata.BooleanToStr(AData.Enable) + ', '
            + 'IDLastBlock: ' + AData.IDLastBlock.ToString + ', '
            + 'UnixTime: ' + AData.UnixTime.ToString + ', '
            + 'HashLastBlock: ' + AData.HashLastBlock.ToString + '}}'
end;

function TNodeState.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

function TNodeState.Len: Byte;
begin
  Result:= SizeOf(Self.Size)
         + SizeOf(Self.IDNode)
         + SizeOf(Self.Enable)
         + SizeOf(Self.IDLastBlock)
//         + Self.UnixTime.Len
         + SizeOf(Self.UnixTime)
         + Self.HashLastBlock.Len
         ;
end;

function TNodeState.MinLen: Byte;
begin
  Result:= SizeOf(Self.Size)
         + SizeOf(Self.IDNode)
         + SizeOf(Self.Enable)
         + SizeOf(Self.IDLastBlock)
//         + Self.UnixTime.Len
         + SizeOf(Self.UnixTime)
         + Self.HashLastBlock.MinLen;
end;

procedure TNodeState.SetState(AIDNode: UInt64; AEnable: Boolean;
                              AIDLastBlock: UInt64; AHashLastBlock: THash32);
//var
//  Unixime: TUnixTime;
begin
  Self.Clear;
  Self.IDNode:= AIDNode;
  Self.Enable:= AEnable;
  Self.IDLastBlock:= AIDLastBlock;
  Self.HashLastBlock:= AHashLastBlock;
  Self.UnixTime:= TUnixTime(Now());

  Self.Size:= Self.Len - SizeOf(Self.Size);
end;

function TNodeState.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TNodeState.ToString: string;
begin
  Result:= Self;
end;
{$ENDREGION 'TNodeState'}


{ TUnixTime }

{$REGION 'TUnixTime'}
procedure TUnixTime.Clear;
begin
  Self.Data:= 0;
end;

class function TUnixTime.Empty: TUnixTime;
begin
  Result.Clear;
end;

class operator TUnixTime.Equal(const AData1, AData2: TUnixTime): Boolean;
begin
  Result:= AData1.Data = AData2.Data;
end;

class operator TUnixTime.NotEqual(const AData1, AData2: TUnixTime): Boolean;
begin
  Result:= not (AData1 = AData2);
end;

function TUnixTime.ToString: string;
begin
  Result:= Self;
end;

function TUnixTime.ToTDateTime: TDateTime;
begin
  Result:= Self;
end;

class operator TUnixTime.Implicit(const AData: TUnixTime): string;
begin
  Result:= FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz',AData);
end;

class operator TUnixTime.Implicit(const AData: TUnixTime): Int64;
begin
  Result:= AData.Data;
end;

class operator TUnixTime.Implicit(const AData: Int64): TUnixTime;
begin
  Result.Data:= AData;
end;

class operator TUnixTime.Implicit(const AData: TDateTime): TUnixTime;
begin
  Result:= DateTimeToUnix(AData,False);
end;

class operator TUnixTime.Implicit(const AData: TUnixTime): TDateTime;
begin
//  Result:= UnixToDateTime(AData.Data);
  Result:= UnixToDateTime(AData.Data,True);
end;

function TUnixTime.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

function TUnixTime.Len: Byte;
begin
  Result:= SizeOf(Self.Data);
end;

{$ENDREGION 'TUnixTime'}

{ TFileHeader }
{$REGION 'TFileHeader'}
procedure TFileHeader.Clear;
begin
  Self.Size:= 0;
  Self.TypeNet.Clear;
  Self.NodeID:= 0;
end;

class function TFileHeader.Empty: TFileHeader;
begin
  Result.Clear;
end;

class operator TFileHeader.Equal(const AData1, AData2: TFileHeader): Boolean;
begin
  Result:= (AData1.Size = AData2.Size)
         and (AData1.TypeNet = AData2.TypeNet)
         and (AData1.NodeID = AData2.NodeID)
         ;
end;

class operator TFileHeader.NotEqual(const AData1, AData2: TFileHeader): Boolean;
begin
  Result:= not (AData1 = AData2);
end;

class operator TFileHeader.Implicit(var AData: TFileHeader): TBytes;
var
  i,sz: Integer;
begin
  AData.Size:= AData.Len - SizeOf(Adata.Size);
  SetLength(Result,AData.Len);

  i:= 0;
  sz:= SizeOf(Adata.Size);
  Move(Adata.Size,Result[i],sz);
  Inc(i,sz);


end;

class operator TFileHeader.Implicit(const AData: TBytes): TFileHeader;
begin

end;

function TFileHeader.Len: Integer;
begin

end;

function TFileHeader.MinLen: Integer;
begin
  Result:= SizeOf(Self.Size)
           + Self.TypeNet.Len
           + SizeOf(Self.NodeID);
  if Result < Self.MIN_SIZE then
    Result:= Self.MIN_SIZE;
end;

{$ENDREGION 'TFileHeader'}

{ TFileValidatorsList }
{$REGION 'TFileValidatorsList'}
constructor TFileValidatorsList.Create(APath, AFileName: string);
begin

end;

destructor TFileValidatorsList.Destroy;
begin

end;

{$ENDREGION 'TFileValidatorsList'}

initialization
  TNetAddr.CheckRecord;

end.
