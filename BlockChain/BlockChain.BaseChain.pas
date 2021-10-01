unit BlockChain.BaseChain;

interface

uses
  System.IOUtils,
  System.SysUtils,
  System.Generics.Collections,
  App.Types,
  BlockChain.BaseBlock,
  BlockChain.Types,
  BlockChain.FileHandler,
  Wallet.Types;

type
  TBaseChain = class abstract
  protected
    ChainFile: TChainFile;
    FPath: string;
    FName: string;
  public
    Cache: TList<TBaseBlock>;
    procedure AddToFastIndex(AData: TBytes); virtual; abstract;
    procedure SetBlock(ABlock: TBaseBlock); virtual;
    procedure WriteApprovedBlock(ABlock: TBaseBlock);
    procedure DoClearCache;
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
    function WriteApprovedBlocks(ACount: UInt64; AData: TBytes): UInt64;
    function GetBlock(Ind: UInt64): TBaseBlock; virtual; abstract;
    function GetLastBlockID: UInt64;
    function GetBlocksFrom(const AID: UInt64): TBytes;
    function GetLastBlockHash: THash;
    function GetCacheCount: UInt64;
    function GetCachedTrxs: TBytes;
    function CheckID(const AID: UInt64): boolean;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain); virtual;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TBaseChain'}


function TBaseChain.ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;
var
  i: integer;
  Inf: THelpInfoMainChain;
begin
  Result := [];
  if Cache.Count = 0 then
    exit;

  Cache[0].SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);

  if ChainFile.TryWrite(Cache[0].GetData, Cache[0].GetHeader) then
  begin
    AddToFastIndex(Cache[0].GetData);
    Inf.ID := ChainFile.GetLastBlockNumber;
    Inf.HAsh := GetLastBlockHash;
    Result := Result + [Inf];
  end;

  Cache[0].Free;

  if Cache.Count > 1 then
    for i := 1 to Cache.Count - 1 do
    begin
      Cache[i].SignBlock(Awallet, GetLastBlockHash, GetLastBlockID);
      if ChainFile.TryWrite(Cache[i].GetData, Cache[i].GetHeader) then
      begin
        Inf.ID := ChainFile.GetLastBlockNumber;
        Inf.HAsh := GetLastBlockHash;
        Result := Result + [Inf];
      end;
      AddToFastIndex(Cache[i].GetData);
      Cache[i].Free;
    end;

  Cache.Clear;
end;

function TBaseChain.CheckID(const AID: UInt64): boolean;
begin
  if ((AID > ChainFile.GetLastBlockNumber) or (AID = 0)) then
    Result := True
  else
    Result := False;
end;

constructor TBaseChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  FName := AName;
  FPath := TPath.Combine(Paths.GetPathBlockChain, FName);
  ChainFile := TChainFile.Create(FPath, Data);

  Cache := TList<TBaseBlock>.Create;

end;

function TBaseChain.GetBlocksFrom(const AID: UInt64): TBytes;
var
  buf: TBytes;
  BaseBlock: TBaseBlock;
begin
  buf := [];
  for var i := AID to GetLastBlockID do
  begin
    BaseBlock := GetBlock(i);
    buf := buf + BaseBlock.GetSizeBlock.AsBytes + BaseBlock.GetData;
    BaseBlock.Free;
  end;
  Result := buf;
end;

function TBaseChain.GetCacheCount: UInt64;
begin
  Result := Cache.Count;
end;

function TBaseChain.GetCachedTrxs: TBytes;
var
  Data: TBytes;
begin
  Result := [];
  if Cache.Count > 0 then
  begin
    for var item in Cache do
    begin
      Data := item.GetData;
      var Len: UInt64 := Length(Data);
      Result := Result + Len.AsBytes + Data;
    end;
  end;
end;

function TBaseChain.GetLastBlockHash: THash;
var
  Header: THeader;
  Data: TBytes;
  BaseBlockV0: TBaseBlock;
begin
  ChainFile.TryRead(-1, Data);
  Move(Data[0], Header, SizeOf(THeader));
  Result := Header.CurrentHash;
end;

function TBaseChain.GetLastBlockID: UInt64;
begin
  Result := ChainFile.GetLastBlockNumber;
end;

procedure TBaseChain.SetBlock(ABlock: TBaseBlock);
begin
  Cache.Add(ABlock);
end;

procedure TBaseChain.WriteApprovedBlock(ABlock: TBaseBlock);
begin
  if ChainFile.TryWrite(ABlock.GetData, ABlock.GetHeader) then
    AddToFastIndex(ABlock.GetData);
end;

function TBaseChain.WriteApprovedBlocks(ACount: UInt64; AData: TBytes): UInt64;
var
  buf: TBytes;
  Header: THeader;
  Count, countBlocks: integer;
  sizeBlock: UInt64;
begin
  Count := 0;
  countBlocks := 0;
  while (Count < Length(AData)) and (countBlocks < ACount) do
  begin
    Move(AData[Count], sizeBlock, SizeOf(UInt64));
    inc(Count, SizeOf(UInt64));
    setlength(buf, sizeBlock);
    Move(AData[Count], buf[0], sizeBlock);
    inc(Count, sizeBlock);
    Header := copy(buf, 0, SizeOf(THeader));
    if ChainFile.TryWrite(buf, Header) then
      AddToFastIndex(buf);
    inc(countBlocks, 1);
  end;
  Result := Count;
end;

destructor TBaseChain.Destroy;
begin
  ChainFile.Free;
  Cache.Free;
end;

procedure TBaseChain.DoClearCache;
begin
  for var item in Cache do
    item.Free;

  Cache.Clear;
end;

{$ENDREGION}

end.