unit BlockChain.MainChain;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Hash,
  System.DateUtils,
  App.Types,
  App.Log,
  Wallet.Types,
  BlockChain.BaseBlock,
  BlockChain.BaseChain,
  BlockChain.Types,
  Crypto.RSA;

const
  LastVersionMain = 0;

type
  TMainInfoV0 = packed record
    IDChain: byte;
    IDBlock: integer;
    HashBlock: THash;
    function GetSize: integer;
    class operator Implicit(Buf: TMainInfoV0): TBytes;
    class operator Implicit(Buf: TBytes): TMainInfoV0;
    class operator Add(buf1: TBytes; buf2: TMainInfoV0): TBytes;
    class operator Add(buf2: TMainInfoV0; buf1: TBytes): TBytes;
  end;

  TMainTrxV0 = packed record // 192
    MainInfo: TMainInfoV0; // 128
    OwnerSign: TSignedHash; // 64
    function GetSize: integer;
    procedure SignTrx(Wallet: TWallet);
    class operator Implicit(Buf: TMainTrxV0): TBytes;
    class operator Implicit(Buf: TBytes): TMainTrxV0;
    class operator Add(buf1: TBytes; buf2: TMainTrxV0): TBytes;
    class operator Add(buf2: TMainTrxV0; buf1: TBytes): TBytes;
  end;

  TMainBlockV0 = class(TBaseBlock)
  protected
    MainTrx: TMainTrxV0;
  public
    class function GenerateInitBlock: TBytes; static;
    function GetSizeBlock: uint64; override;
    function GetTrxData: TBytes;
    function GetData: TBytes; override;
    function GetDataWithoutHeader: TBytes; override;
    procedure SetData(const AData: TBytes); override;
    constructor Create(AMainInfo: TMainTrxV0; LastBlockHash: THash); overload;
    constructor Create; overload;
  end;

  TMainChain = class(TBaseChain)
  public
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
    function GetBlock(Ind: uint64): TBaseBlock; override;
    function GetLastBlockID: uint64;
    procedure AddToFastIndex(AData: TBytes); override;
  end;

implementation

{$REGION 'TMainInfoV0'}

class operator TMainInfoV0.Add(buf1: TBytes; buf2: TMainInfoV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMainInfoV0));
  Move(buf2, LData[0], SizeOf(TMainInfoV0));
  RData := RData + LData;
  Result := RData;
end;

class operator TMainInfoV0.Add(buf2: TMainInfoV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMainInfoV0));
  Move(buf2, LData[0], SizeOf(TMainInfoV0));
  RData := LData + RData;
  Result := RData;
end;

function TMainInfoV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TMainInfoV0.Implicit(Buf: TMainInfoV0): TBytes;
begin
  SetLength(Result, SizeOf(TMainInfoV0));
  Move(Buf, Result[0], SizeOf(TMainInfoV0));
end;

class operator TMainInfoV0.Implicit(Buf: TBytes): TMainInfoV0;
begin
  Move(Buf[0], Result, SizeOf(TMainInfoV0));
end;
{$ENDREGION}
{$REGION 'TMainTrxV0'}

class operator TMainTrxV0.Add(buf1: TBytes; buf2: TMainTrxV0): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMainTrxV0));
  Move(buf2, LData[0], SizeOf(TMainTrxV0));
  RData := LData + RData;
  Result := RData;
end;

class operator TMainTrxV0.Add(buf2: TMainTrxV0; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
begin
  RData := buf1;
  SetLength(LData, SizeOf(TMainTrxV0));
  Move(buf2, LData[0], SizeOf(TMainTrxV0));
  RData := RData + LData;
  Result := RData;
end;

function TMainTrxV0.GetSize: integer;
begin
  Result := SizeOf(self);
end;

class operator TMainTrxV0.Implicit(Buf: TMainTrxV0): TBytes;
begin
  SetLength(Result, SizeOf(TMainTrxV0));
  Move(Buf, Result[0], SizeOf(TMainTrxV0));
end;

class operator TMainTrxV0.Implicit(Buf: TBytes): TMainTrxV0;
begin
  Move(Buf[0], Result, SizeOf(TMainTrxV0));
end;

procedure TMainTrxV0.SignTrx(Wallet: TWallet);
var
  Buf: TMemoryStream;
  Bytes: TBytes;
begin
  Buf := TMemoryStream.Create;
  Buf.Write(MainInfo, MainInfo.GetSize);
  SetLength(Bytes, SizeOf(THash));
  Buf.Position := 0;
  Move(THashSHA2.GetHashBytes(Buf)[0], Bytes[0], SizeOf(THash));
  Buf.Destroy;

  OwnerSign := RSAEncrypt(Wallet.PrivKey, Bytes);
end;

{$ENDREGION}
{$REGION 'TMainBlockV0'}

constructor TMainBlockV0.Create;
begin
  //
end;

constructor TMainBlockV0.Create(AMainInfo: TMainTrxV0; LastBlockHash: THash);
var
  Buf: TMemoryStream;
  data: TBytes;
begin

  Header.VersionData := LastVersionMain;
  Header.TypeBlock := byte(Main);
  Header.UnixTime := DateTimeToUnix(now, False);

  MainTrx := AMainInfo;
end;

class function TMainBlockV0.GenerateInitBlock: TBytes;
var
  LocalHeader: THeader;
  LocalMain: TMainTrxV0;
begin
  LocalHeader := Default (THeader);
  LocalMain := Default (TMainTrxV0);
  FIllChar(LocalMain, SizeOf(LocalMain), 0);
  case NetState of
    MAINNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 0);
    TESTNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 1);
    LABNET:
      FIllChar(LocalHeader.CurrentHash, SizeOf(LocalHeader.CurrentHash), 2);
  end;
  Result := LocalHeader + LocalMain;
end;

function TMainBlockV0.GetData: TBytes;
begin
  Result := Header + MainTrx;
end;

function TMainBlockV0.GetDataWithoutHeader: TBytes;
begin
  Result := MainTrx;
end;

function TMainBlockV0.GetSizeBlock: uint64;
begin
  Result := Header.GetSize + MainTrx.GetSize;
end;

function TMainBlockV0.GetTrxData: TBytes;
begin
  Result := MainTrx;
end;

procedure TMainBlockV0.SetData(const AData: TBytes);
var
  counter: integer;
begin
  counter := 0;

  Move(AData[counter], Header, SizeOf(THeader));
  inc(counter, SizeOf(THeader));

  MainTrx := Copy(AData, counter, MainTrx.GetSize);
  inc(counter, SizeOf(TMainTrxV0));
end;

{$ENDREGION}
{$REGION 'TMainChain'}

function TMainChain.ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
var
  i: integer;
  Inf: THelpInfoMainChain;
  Header: THeader;
begin
  Result := [];
  if Cache.Count = 0 then
    exit
  else
  begin
    for i := 0 to Cache.Count - 1 do
    begin
      Header := Copy(Cache[i], 0, SizeOf(THeader));
      case Header.VersionData of
        0:
          begin
            var
              Block: TMainBlockV0;
            Block := TMainBlockV0.Create;
            Block.SetData(Cache[i]);
            Block.SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);
            if ChainFile.TryWrite(Block.GetData, Block.GetHeader) then
            begin
              AddToFastIndex(Block.GetData);
              Inf.ID := ChainFile.GetLastBlockNumber;
              Inf.Hash := GetLastBlockHash;
              BlockChainLogs.DoAlert('ApproveBlocks',
                ' IDChain: ' + Block.MainTrx.MainInfo.IDChain.ToString +
                ' IDBlock: ' + Block.MainTrx.MainInfo.IDBlock.ToString +
                ' HashBlock: ' + Block.MainTrx.MainInfo.HashBlock +
                ' Header: ' + Block.GetHeader);

              Result := Result + [Inf];
            end;
            Block.Free;
          end;
      end;
    end;
  end;

  Cache.Clear;
end;

procedure TMainChain.AddToFastIndex(AData: TBytes);
begin

end;

function TMainChain.GetBlock(Ind: uint64): TBaseBlock;
var
  Header: THeader;
  data: TBytes;
var
  MainBlockV0: TMainBlockV0;
begin
  ChainFile.TryRead(Ind, data);
  Move(data[0], Header, SizeOf(THeader));
  case Header.VersionData of
    0:
      begin
        MainBlockV0 := TMainBlockV0.Create;
        MainBlockV0.SetData(data);
        Result := MainBlockV0;
      end;
  else
    Result := nil;
  end;
end;

function TMainChain.GetLastBlockID: uint64;
begin
  Result := ChainFile.GetLastBlockNumber;
end;

{$ENDREGION}

end.
