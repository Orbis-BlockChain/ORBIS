unit BlockChain.Types;

interface

uses
  System.Types,
  System.IOUtils,
  System.SysUtils,
  System.Classes,
  System.Hash,
  System.DateUtils,
  App.Types;

const
  MaxFileSize = 209715200;
  IndexBaseFileName = 'IndexData';
  ChainBaseFileName = 'ChainData';

type
  TTypesChain = (Main, Accounts, Tokens, Transfers, MultiSigns, VotingResults, Commissions, VoteRequest, Mining, FastIndex, Service,
    ServiceResult, Mined);

  THeader = packed record
    IDBlock: UInt64; // 8
    TypeBlock: Byte; // 1
    VersionData: Byte; // 1
    CurrentHash: THash; // 32
    UnixTime: int64; // 8
    WitnessID: UInt64; // 8
    Sign: TSignedHash; // 64
    function GetSize: UInt64;
    class operator Implicit(Buf: THeader): TBytes;
    class operator Implicit(Buf: THeader): string;
    class operator Implicit(Buf: TBytes): THeader;
    class operator Add(buf1: TBytes; buf2: THeader): TBytes;
    class operator Add(buf2: THeader; buf1: TBytes): TBytes;
  end;

  TIndexData = packed record
    Size: UInt64;
    TypeChain: Byte;
    VersionData: Byte;
    StartByte: integer;
  end;

  TMembers = packed record
    IDFrom: UInt64;
    IDTo: UInt64;
  end;

  TToken = (Coin, Token);

  TTransferHistoryData = record
    DirectFrom: UInt64;
    DirectTo: UInt64;
    Plus: boolean;
    Amount: UInt64;
    TokenID: UInt64;
    UnixTime: int64;
    BlockHash: THash;
  end;

  TTransHistoryItem = record
    datetime: int64;
    block_number: UInt64;
    Afrom: THash;
    Ato: THash;
    Hash: THash;
    Token: TSymbol;
    sent: Double;
    sentstr: String;
    received: Double;
    receivedstr: String;
    fee: Double;
  end;

  TMinedInfo = record
    ValidAddress: THash;
    BlockNumber: UInt64;
    DateTime: Int64;
  end;

  THelpInfoMainChain = record
    ID: UInt64;
    Hash: THash;
  end;

function GetBlockSize(const ATypeChaine, AVersionBlock: Byte): UInt64;

var
  SIZE_MAIN_CHAIN_INFO_V0: integer;
  SIZE_ACCOUNT_INFO_V0: integer;
  SIZE_MULTISIGN_INFO_V0: integer;
  SIZE_VOTINGRESULT_INFO_V0: integer;
  SIZE_COMMISSION_INFO_V0: integer;
  SIZE_MINING_INFO_V0: integer;
  SIZE_TOKENS_INFO_V0: integer;
  SIZE_TRANSFER_INFO_V0: integer;
  SIZE_FAST_INDEX_ACCOUNT: integer;
  SIZE_FAST_INDEX_TOKENS: integer;
  SIZE_FAST_INDEX_TRANSFERS: integer;
  SIZE_SERVICE_INFO_V0: integer;
  SIZE_FAST_INDEX_SERVICE: integer;
  SIZE_SERVICERESULT_INFO_V0: integer;
  SIZE_MINED_INFO_V0: integer;

implementation

{ THeader }

class operator THeader.Add(buf1: TBytes; buf2: THeader): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(THeader));
  Move(buf2, LData[0], SizeOf(THeader));
  RData := RData + LData;
  Result := RData;
end;

class operator THeader.Add(buf2: THeader; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(THeader));
  Move(buf2, LData[0], SizeOf(THeader));
  RData := LData + RData;
  Result := RData;
end;

function THeader.GetSize: UInt64;
begin
  Result := SizeOf(Self);
end;

class operator THeader.Implicit(Buf: THeader): string;
begin
  Result := 'Header: ';
  try
  Result := Result + 'IDBlock :' + Buf.IDBlock.AsString +
  ', TypeBlock:'+ buf.TypeBlock.ToString +
  ', VersionData: ' + buf.VersionData.ToString +
  ', CurrentHash:' + buf.CurrentHash +
  ', UnixTime: ' + DateTimeToStr(UnixToDateTime(buf.UnixTime,False)) +
  ', WitnessID: ' + buf.WitnessID.AsString +
  ', Sign:' + string(buf.Sign);
  except

  end;
end;

class operator THeader.Implicit(Buf: THeader): TBytes;
begin
  SetLength(Result, SizeOf(THeader));
  Move(Buf, Result[0], SizeOf(THeader));
end;

class operator THeader.Implicit(Buf: TBytes): THeader;
begin
  Move(Buf[0], Result, SizeOf(THeader));
end;

function GetBlockSize(const ATypeChaine, AVersionBlock: Byte): UInt64;
begin
  case TTypesChain(ATypeChaine) of
    Main:
      case AVersionBlock of
        0:
          Result := SIZE_MAIN_CHAIN_INFO_V0;
      end;
    Accounts:
      case AVersionBlock of
        0:
          Result := SIZE_ACCOUNT_INFO_V0;
      end;
    Tokens:
      case AVersionBlock of
        0:
          Result := SIZE_TOKENS_INFO_V0;
      end;
    Transfers:
      case AVersionBlock of
        0:
          Result := SIZE_TRANSFER_INFO_V0;
      end;
    MultiSigns:
      case AVersionBlock of
        0:
          Result := SIZE_MULTISIGN_INFO_V0;
      end;
    VotingResults:
      case AVersionBlock of
        0:
          Result := SIZE_VOTINGRESULT_INFO_V0;
      end;
    Service:
      case AVersionBlock of
        0:
          Result := SIZE_SERVICE_INFO_V0;
      end;
    ServiceResult:
      case AVersionBlock of
        0:
          Result := SIZE_SERVICERESULT_INFO_V0;
      end;
    Commissions:
      case AVersionBlock of
        0:
          Result := SIZE_COMMISSION_INFO_V0;
      end;
    Mining:
      case AVersionBlock of
        0:
          Result := SIZE_MINING_INFO_V0;
      end;
    Mined:
      case AVersionBlock of
        0:
          Result := SIZE_MINED_INFO_V0;
      end;
    FastIndex:
      case AVersionBlock of
        0:
          Result := SIZE_FAST_INDEX_ACCOUNT;
        1:
          Result := SIZE_FAST_INDEX_TOKENS;
        2:
          Result := SIZE_FAST_INDEX_TRANSFERS;
        3:
          Result := SIZE_FAST_INDEX_SERVICE;
      end;

  end;
end;

end.
