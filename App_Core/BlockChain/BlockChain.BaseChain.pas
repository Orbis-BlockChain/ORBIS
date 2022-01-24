unit BlockChain.BaseChain;

interface

uses
  System.IOUtils,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  App.Types,
  App.Log,
  BlockChain.BaseBlock,
  BlockChain.Types,
  BlockChain.FileHandler,
  Wallet.Types;

type
  TBaseChain = class abstract
  protected
    ChainFile: TChainFile;
    cs: TCriticalSection;
    FPath: string;
    FName: string;
  public
    Cache: TList<TBytes>;
    function ApproveBlocks(Awallet: TWallet): TArray<THelpInfoMainChain>;  virtual; abstract;
    function WriteApprovedBlocks(ACount: UInt64; AData: TBytes): UInt64;
    function GetBlock(Ind: UInt64): TBaseBlock; virtual; abstract;
    function GetLastBlockID: UInt64;
    function GetBlocksFrom(const AID: UInt64): TBytes;
    function GetLastBlockHash: THash;
    function GetCacheCount: UInt64;
    function GetCachedTrxs: TBytes;
    function CheckID(const AID: UInt64): boolean;
    procedure AddToFastIndex(AData: TBytes); virtual; abstract;
    procedure SetBlock(ABlock: TBytes); virtual;
    procedure WriteApprovedBlock(ABlock: TBaseBlock);
    procedure DoClearCache;
    procedure Corrupted;
    constructor Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain); virtual;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TBaseChain'}

function TBaseChain.CheckID(const AID: UInt64): boolean;
begin
  if (AID <= ChainFile.GetLastBlockNumber) then
    Result := True
  else
    Result := False;
end;

procedure TBaseChain.Corrupted;
begin
  ChainFile.Corupted;
end;

constructor TBaseChain.Create(AName: string; const Data: TBytes; AtypeChain: TTypesChain);
begin
  cs := TCriticalSection.Create;
  FName := AName;
  FPath := TPath.Combine(Paths.GetPathBlockChain, FName);
  ChainFile := TChainFile.Create(FPath, Data);

  Cache := TList<TBytes>.Create;

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
  BlockChainLogs.DoAlert('TBaseChain.GetCacheCount','criticalSection.TryEnter');
  cs.enter;
  BlockChainLogs.DoAlert('TBaseChain.GetCacheCount','criticalSection.Enter');
  Result := Cache.Count;
  cs.Leave;
  BlockChainLogs.DoAlert('TBaseChain.GetCacheCount','criticalSection.Leave');
end;

function TBaseChain.GetCachedTrxs: TBytes;
var
  Data: TBytes;
begin
  BlockChainLogs.DoAlert('TBaseChain.GetCachedTrxs','criticalSection.TryEnter');
  cs.Enter;
  BlockChainLogs.DoAlert('TBaseChain.GetCachedTrxs','criticalSection.Enter');
  Result := [];
  if Cache.Count > 0 then
  begin
    for var item in Cache do
    begin
      Data := item;
      var Len: UInt64 := Length(Data);
      Result := Result + Len.AsBytes + Data;
    end;
  end;
  cs.Leave;
  BlockChainLogs.DoAlert('TBaseChain.GetCachedTrxs','criticalSection.Leave');
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

procedure TBaseChain.SetBlock(ABlock: TBytes);
begin
  BlockChainLogs.DoAlert('TBaseChain.SetBlock','criticalSection.TryEnter');
  cs.Enter;
  BlockChainLogs.DoAlert('TBaseChain.SetBlock','criticalSection.Enter');
  Cache.Add(ABlock);
  cs.Leave;
  BlockChainLogs.DoAlert('TBaseChain.SetBlock','criticalSection.Leave');
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
  cs.Enter;
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
    BlockChainLogs.DoAlert(FName+'SetNewBlocks', 'Header: '+Header);
    if ChainFile.TryWrite(buf, Header) then
      AddToFastIndex(buf);
    inc(countBlocks, 1);
  end;
  Result := Count;
  cs.Leave;
end;

destructor TBaseChain.Destroy;
begin
  ChainFile.Free;
  Cache.Free;
  cs.Free;
end;

procedure TBaseChain.DoClearCache;
begin
  BlockChainLogs.DoAlert('TBaseChain.DoClearCache','criticalSection.TryEnter');
  cs.Enter;
  BlockChainLogs.DoAlert('TBaseChain.DoClearCache','criticalSection.Enter');
  Cache.Clear;
  cs.Leave;
  BlockChainLogs.DoAlert('TBaseChain.DoClearCache','criticalSection.Leave');
end;

{$ENDREGION}

end.
