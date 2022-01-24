unit BlockChain.Types;

interface

uses
  System.Types,
  System.IOUtils,
  System.SysUtils,
  System.Classes,
  System.Hash,
  App.Types,
  Crypto.RSA;

const
  MaxFileSize = 209715200;
  IndexBaseFileName = 'IndexData';
  ChainBaseFileName = 'ChainData';

type
  TTypesChain = (Main, Accounts, Tokens, Transfers, MultiSigns, VotingResults, Commissions,
  VoteRequest, Mining, FastIndex);

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

  TToken = (Coin, Token); // 1 - orbcoin=coin

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
    datetime: UInt64;
    block_number: UInt64;
    Afrom: THash; //
    Ato: THash; //
    Hash: THash; //
    Token: TSymbol; //
    sent: Double; //
    received: Double; //
    fee: Double; //
  end;

  THelpInfoMainChain = record
    ID: UInt64;
    HAsh: THash;
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
    FastIndex:
      case AVersionBlock of
        0:
          Result := SIZE_FAST_INDEX_ACCOUNT;
        1:
          Result := SIZE_FAST_INDEX_TOKENS;
        2:
          Result := SIZE_FAST_INDEX_TRANSFERS;
      end;
  end;
end;

end.
