unit Consensus2.Core;

interface

{$IFDEF DEBUG}
{$DEFINE APPLOG}
{$ENDIF}
uses
  System.Classes,
  System.SysUtils
  ,App.Config
  ,App.IHandlerCore
  ,App.Types
  ,App.Packet
  ,App.Notifyer
  {$IFDEF APPLOG}
  ,App.Log
  {$ENDIF}
  ,Wallet.Core
  ,BlockChain.Core
  ,UI.Abstractions
  ,Net.Core
  ,Net.IClient
  ,Net.Client
  ,Net.ConnectedClient
  ,System.SyncObjs
  ,System.Generics.Collections
  ,Consensus.Types

  ;

type
  TConsensusCore2 = class
  const
    TIMEOUT = 35000;
    ORATOR_TIMEOUT = 15000;
    TIMEOUT_IDITERATION = 2000;
    csDisable = 1;
    csWiat = 2;
    csEnable = 3;
  private
    // ****************************
    FNetCore: TNetCore;
    FBlockChain: TBlockChainCore;
    FWalletCore: TWalletCore;
    FUICore: TBaseUI;
    FConfig: TConfig;
    FHandlerCore: IBaseHandler;
    // ****************************

    FCS: TCriticalSection;
    FCS2: TCriticalSection;
    FCS3: TCriticalSection;
    FCSRespBlock: TCriticalSection;
    FManagmentCS: TCriticalSection;

    FFlagRespBlock: Boolean;

    FServerIPv4: String;
    FServerPort: Word;
    FTimeStart: TDateTime;
    // FValidator: TValidator;

    FDefaultOrator: TOratorInf;
    FQuorumList: TQuorumList;
    FNodeState: TNodeState;
    FOratorInf: TOratorInf;
    FNewOratorInf: TOratorInf;
    FIDIteration: UInt64;
    FMainChainCount: UInt64;
    FLastTmIDIter: TDateTime;
    FListIDOnLineVal: TListIDVal;
    FEnableValList: TListIDVal;
    FArrayTXData: TArrayTXData; // <<<<<<<<<< >>>>>>>>>
    FTXData: TTXData;
    FNewBlocks: TBytes;
    FCountNewBlocks: UInt64;

    FValID: UInt64;
    FPrK: TPrivKey;
    FPbK: TPubKey;
    FActive: Boolean;
    FEnable: Boolean;
    // FValidators: TArray<TValidator>;
    FValidators: TListVal;

    FCheckNetTime: TDateTime;

    procedure Msg(const AData: string);
    procedure Msg2(const AData: string);

    procedure SetActive(AValue: Boolean); virtual;
    function GetActive: Boolean;

    procedure SetEnable(AValue: Boolean); virtual;
    function GetEnable: Boolean;

    procedure SetNodeState(ANodeState: TNodeState); virtual;
    function GetNodeState(): TNodeState;

    procedure SetOratorInf(AValue: TOratorInf); virtual;
    function GetOratorInf: TOratorInf;

    procedure SetIDIteration(AValue: UInt64);
    function GetIDIteration: UInt64;

    function GetOratorStatus(): Boolean;
    function GetLastBlock: UInt64;

    procedure DoActive();
    function GetOMs: TArray<UInt64>;
    function ThisNodeInfo(): TValInf;

    procedure RequestGetBlock(AClient: IClient); // EventEndDownloadBlocks
    procedure RequestGetBlock2(AClient: TClient); // EventEndDownloadBlocks

    procedure DoDisconnect(AClient: TClient);
    procedure DoDisconnect2(AClient: TConnectedClient);

    function ToPacket(AData: TBytes): TBytes;
    function NetPacketNope(AData: Integer): TNetPacket; overload;
    function NetPacketNope(ANetPacket: TNetPacket): Integer; overload;

    function NetPacketNodeConnect(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketNodeConnect(ANetPacket: TNetPacket): TNodeInf; overload;

    function NetPacketOratorInfo(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketOratorInfo(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketNewOratorInfo(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketNewOratorInfo(ANodeInf: TNodeInf): TNetPacket; overload;

    function NetPacketGetNodeEnable(ANetPacket: TNetPacket): UInt64; overload;
    function NetPacketGetNodeEnable(AID: UInt64 = 0): TNetPacket; overload;
    function NetPacketNodeEnable(ANetPacket: TNetPacket): TNodeState; overload;
    function NetPacketNodeEnable(ANodeState: TNodeState): TNetPacket; overload;
//    function NetPacketNodeEnable(ANetPacket: TNetPacket): Boolean; overload;
//    function NetPacketNodeEnable(ANodeEnable: Boolean = False): TNetPacket; overload;

    function NetPacketGetDefNodeInfo(AIDNode: UInt64 = 0): TNetPacket; overload;
    function NetPacketGetDefNodeInfo(AData: TNetPacket): UInt64; overload;
    function NetPacketDefNodeInfo(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketDefNodeInfo(ANodeInf: TNodeInf): TNetPacket; overload;

    function NetPacketGetNodeInfo(AIDNode: UInt64 = 0): TNetPacket; overload;
    function NetPacketGetNodeInfo(AData: TNetPacket): UInt64; overload;
    function NetPacketNodeInfo(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketNodeInfo(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketNodeInfoID(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketNodeInfoID(ANodeInf: TNodeInf): TNetPacket; overload;

    function NetPacketValList(AData: TListIDVal): TNetPacket; overload;
    function NetPacketValList(ANetPacket: TNetPacket): TListIDVal; overload;

    function NetPacketEnableValList(AData: TListIDVal): TNetPacket; overload;
    function NetPacketEnableValList(ANetPacket: TNetPacket): TListIDVal; overload;

    function NetPacketNextIteration(AData: TNetPacket): UInt64; overload;
    function NetPacketNextIteration(AIDIter: UInt64 = 0): TNetPacket; overload;

    function NetPacketGetTransaction(ACount: Word = 0): TNetPacket; overload;
    function NetPacketGetTransaction(ANetPacket: TNetPacket): Word; overload;
    function NetPacketTransaction(AData: TBytes = []): TNetPacket; overload;
    function NetPacketTransaction(ANetPacket: TNetPacket): TBytes; overload;

    function NetPacketGetBlock(ACount: Word = 0): TNetPacket; overload;
    function NetPacketGetBlock(ANetPacket: TNetPacket): Word; overload;
    function NetPacketBlock(ACnt: UInt64 = 0; AData: TBytes = []): TNetPacket; overload;
    function NetPacketBlock(ANetPacket: TNetPacket; ACnt: UInt64 = 0): UInt64; overload;
    function NetPacketBlock(ANetPacket: TNetPacket; AData: TBytes = []): TBytes; overload;

    function NetPacketGetIterationInfo(AData: TNetPacket): UInt64; overload;
    function NetPacketGetIterationInfo(AIDIter: UInt64 = 0): TNetPacket; overload;
    function NetPacketIterationInfo(AData: TNetPacket): TIteration; overload;
    function NetPacketIterationInfo(AData: TIteration): TNetPacket; overload;

    function NetPacketPing(AData: TNetPacket): TDateTime; overload;
    function NetPacketPing(AIDIter: TDateTime): TNetPacket; overload;

    function SelfConnect(): Integer;
    procedure SetValID(const AValID: UInt64);
    function SendToAllValidators(AData: TBytes): TListIDVal;
    function SendToClient(AClient: IClient; AData: TBytes): Integer; overload;
    function SendToClient(AClient: TClient1; AData: TBytes): Integer; overload;
    function SendToDefaultOrator(AData: TBytes): Integer;
    function SendToOrator(AData: TBytes): Integer;
    procedure SendToAllClient(AData: TBytes);

    function AddValToList: Integer;
    function GetPbKFromBC(AID: UInt64): TPubKey;
    procedure SetDefaultOrator;

    function GetValList: TListIDVal;
    function GetEnableValList: TListIDVal;
    function GetOnLineValList: TListIDVal;
    procedure Reconnect(Sender: TObject; AClient: TClient);

    function GetAllCacheTrx(): TBytes;
    function ApproveAllCachedBlocks(ACacheTrx: TArrayTXData; var NewBlocks: TBytes): Integer;
    procedure SetNewBlocks();
    function DoManagment(AStep: Integer): Integer;
    function GetMainLastblocHash: THash32;

    procedure DoLog(ANameProc: string; AMsg: string);
    procedure DoConsensusStatus(AStatus: Byte);
  public
    constructor Create(ANetCore: TNetCore; ABlockChain: TBlockChainCore; AWalletCore: TWalletCore; AUICore: TBaseUI; AConfig: TConfig;
      AHandlerCore: IBaseHandler);
    destructor Destroy; override;

    property Active: Boolean read GetActive write SetActive;
    property Enable: Boolean read GetEnable write SetEnable;

    property Orator: Boolean read GetOratorStatus;
    property ValID: UInt64 read FValID write SetValID;
    property ServerIPv4: String read FServerIPv4 write FServerIPv4;
    property ServerPort: Word read FServerPort write FServerPort;

    property csNodeState: TNodeState read GetNodeState write SetNodeState;
    property OratorInf: TOratorInf read GetOratorInf write SetOratorInf;
    property Validators: TListVal read FValidators write FValidators;
    property IDIteration: UInt64 read GetIDIteration write SetIDIteration;

    function CheckValidator: Boolean;
    function ConnectToValidator(ANodeInfo: TNodeInf): Integer;

    procedure ReceiveData(AClient: IClient; AData: TBytes);
    procedure ReceiveDataR(AClient: IClient; AData: TBytes);

    procedure EventConnect(AClient: TClient1);
    procedure EventDisconnect(AClient: TClient1);
    procedure EventEndDownloadBlocks(AValue: Boolean);

    function Managment(AStep: Integer): Integer;

  end;

implementation

function TConsensusCore2.DoManagment(AStep: Integer): Integer;
const
  TIMEOUT_ENABLE_VAL = 5000;
  TIMEOUT = 30000;
var
  Step: Integer;
  tm: TDateTime;
  i, n: Integer;
begin
  tm := Now();
  Step := 0;
  FQuorumList.Clear;
  FQuorumList.Init(FValID, FIDIteration, Step);
  while FActive do
  begin
    if FValID = FDefaultOrator.ID then
    begin
      FManagmentCS.Enter;
      case FQuorumList.CurrentStep of
        0: // get enable
          begin
            FQuorumList.Init(FValID, FIDIteration, Step);
            if FQuorumList.CheckStep(FQuorumList.CurrentStep) then
            begin
              FQuorumList.CurrentStep := FQuorumList.CurrentStep + 1;
              Managment(FQuorumList.CurrentStep); // 1. NetPacketGetNodeEnable
              FEnableValList.Clear;
              FEnableValList.IDIter := IDIteration;
              tm := Now();
            end
            else
            begin

            end;
          end;
        1: // Update FEnableValList
          begin
            if tm + 1 / 24 / 60 / 60 / 1000 * TIMEOUT_ENABLE_VAL < Now() then
            // if FQuorumList.CheckStep(FQuorumList.CurrentStep) then
            begin
              n := Length(FEnableValList.Data);
              if n < 1 then
              begin
                FQuorumList.CurrentStep := 0;
              end
              else
              begin
                for i := 0 to Pred(n) do
                begin
                  var
                    ValInf: TVInf;
                  ValInf.Clear;
                  ValInf.ID := FEnableValList.Data[i];
                  FQuorumList.Add(ValInf);
                  FQuorumList.SetIDStep(FQuorumList.CurrentStep, FEnableValList.Data[i], 1);
                end;
                // for i:= 0 to Pred(Lengtth(FEnableValList.Data)) do
                // begin
                // FQuorumList.SetIDStep(FQuorumList.CurrentStep,FEnableValList.Data[i],2);
                // end;
                if Length(FEnableValList.Data) > 1 then
                  i := Random(Pred(Length(FEnableValList.Data)))
                else
                  i := 0;
                FQuorumList.SetIDStep(FQuorumList.CurrentStep, FEnableValList.Data[i], 1);
                OratorInf := Validators.ValidatorOfID(FEnableValList.Data[i]).ValInf;
                FQuorumList.CurrentStep := FQuorumList.CurrentStep + 1;
                Managment(FQuorumList.CurrentStep); // 2. NetPacketOratorInfo
                tm := Now();
              end;
            end
            else
            begin

            end;
          end;
        2: // return oratorinf
          begin
            if FQuorumList.CheckStep(FQuorumList.CurrentStep) then
            begin
              FEnableValList.IDOrator := OratorInf.ID;
              DoLog('TConsensusCore2.DoManagment','FEnableValList: ' + FEnableValList.ToString);
              FQuorumList.CurrentStep := FQuorumList.CurrentStep + 1;
              Managment(FQuorumList.CurrentStep); // 3. NetPacketEnableValList
              tm := Now();
            end
            else
            begin

            end;
          end;
        3: // return FEnableValList
          begin
            if FQuorumList.CheckStep(FQuorumList.CurrentStep) then
            begin
              FQuorumList.CurrentStep := FQuorumList.CurrentStep + 1;
              Managment(FQuorumList.CurrentStep); // 4. NetPacketGetTransaction
              // FQuorumList.CurrentStep:= 0;
              tm := Now();
            end
            else
            begin

            end;
          end;
        4:
          begin
            if FQuorumList.CheckStep(FQuorumList.CurrentStep) then
            begin
              FQuorumList.CurrentStep := FQuorumList.CurrentStep + 1;
              Managment(FQuorumList.CurrentStep); // 5. NetPacketGetBlock
              tm := Now();
            end
            else
            begin

            end;
          end;
        5:
          begin
            if FQuorumList.CheckStep(FQuorumList.CurrentStep) then
            begin
              FQuorumList.CurrentStep := FQuorumList.CurrentStep + 1;
              Managment(FQuorumList.CurrentStep); // 6. NetPacketNextIteration
              tm := Now();
            end
            else
            begin

            end;
          end;
        6:
          begin
            if FQuorumList.CheckStep(FQuorumList.CurrentStep) then
            begin
              FQuorumList.CurrentStep := 0;
              // Managment(FQuorumList.CurrentStep);  // 7.
              // FQuorumList.Init(FValID,FIDIteration,0);
              FIDIteration := FIDIteration + 1;
              tm := Now();
            end
            else
            begin

            end;
          end;
      end;
      FManagmentCS.Leave;
    end;
    // if tm + 1/24/60/60/1000 * TIMEOUT_ENABLE_VAL < Now() then
    // FQuorumList.CurrentStep:= 0;
    Sleep(1000);
  end;
end;

function TConsensusCore2.Managment(AStep: Integer): Integer;
begin
  Result := -1;
  if FValID = FDefaultOrator.ID then
  begin
    case AStep of
      1:
        begin
          FEnableValList.Clear;
          FEnableValList.IDIter := IDIteration;
          SendToAllValidators(NetPacketGetNodeEnable().ToBytes);
          Result := AStep;
        end;
      2:
        begin
          SendToAllValidators(NetPacketOratorInfo(OratorInf).ToBytes);
          Result := AStep;
        end;
      3:
        begin
          SendToAllValidators(NetPacketEnableValList(FEnableValList).ToBytes);
          Result := AStep;
        end;
      4:
        begin
          SendToAllValidators(NetPacketGetTransaction().ToBytes);
          Result := AStep;
        end;
      5:
        begin
          SendToAllValidators(NetPacketGetBlock().ToBytes);
          Result := AStep;
        end;
      6:
        begin
          SendToAllValidators(NetPacketNextIteration(IDIteration).ToBytes);
          Result := AStep;
        end;
    end;

  end;
end;

procedure TConsensusCore2.Msg(const AData: string);
begin
{$IFDEF CONSOLEI}
  try
    if FUICore.ShowMessage <> nil then
      FUICore.ShowMessage(AData)
    else
    begin
      TThread.Queue(nil,
        // TThread.Synchronize(nil,
        procedure
        begin
          Writeln(FormatDateTime('  [hh:nn:ss.zzz] >> ', Now()) + AData);
        end);
    end;
  except
    TThread.Queue(nil,
    // TThread.Synchronize(nil,
      procedure
      begin
        Writeln(FormatDateTime('  [hh:nn:ss.zzz] >> ', Now()) + AData);
      end);
  end;
{$ENDIF}
end;

procedure TConsensusCore2.Msg2(const AData: string);
begin
{$IFDEF DEBUG}
  if FValID < 10 then
    Msg(AData);
{$ENDIF}
end;

procedure TConsensusCore2.DoLog(ANameProc, AMsg: string);
begin
  {$IFDEF APPLOG}
  ConsensusLog.DoAlert(ANameProc, AMsg);
  {$ENDIF}
end;

function TConsensusCore2.ToPacket(AData: TBytes): TBytes;
var
  Packet: TPacket;
begin
  Packet.CreatePacket(40, AData);
  Result := Packet;
end;

function TConsensusCore2.GetOMs: TArray<UInt64>;
begin
  FCS2.Enter;
  try

    Result := FBlockChain.Inquiries.GetOMs;
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR TConsensusCore.GetOMs: ' + e.Message);
      DoLog('TConsensusCore2.GetOMs',e.Message);
    end;
  end;
  FCS2.Leave;
end;

function TConsensusCore2.GetMainLastblocHash(): THash32;
begin
  Result.Clear;
  FCS2.Enter;
  try
//    Result:= THash32(TBytes(FBlockChain.Inquiries.GetMainLastblocHash));
    Result.Data:= TBytes(FBlockChain.Inquiries.GetMainLastblocHash);
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR TConsensusCore.GetLastBlock: ' + e.Message);
      DoLog('TConsensusCore2.GetMainLastblocHash', e.Message);
    end;
  end;
  FCS2.Leave;
end;

function TConsensusCore2.ApproveAllCachedBlocks(ACacheTrx: TArrayTXData; var NewBlocks: TBytes): Integer;
begin
  FCS2.Enter;
  try
    for var z := 0 to Length(ACacheTrx.Data) - 1 do
      if (Length(ACacheTrx.Data[z].TX) > 0) then
        FBlockChain.Inquiries.SetAllCacheTrx(ACacheTrx.Data[z].TX);

    // Î×ÈÒÑÒÈÒÜ FArrayTXData !!!!!!!!!
    // ACacheTrx.Clear;
  except
    on e: Exception do
    begin
      Msg2(#13#10 + '********************************************************'
         + #13#10 + '   ***   ERROR TNetPacket.tpTransaction: ' + e.Message
         + #13#10 + '********************************************************');
      DoLog('ERROR TConsensusCore2.ApproveAllCachedBlocks', 'FBlockChain.Inquiries.SetAllCacheTrx: ' + e.Message);
    end;
  end;
  var
    countBlocks: UInt64; // Êîëè÷åñòâî áëîêîâ
  countBlocks := 0;
  try
    if FBlockChain.Inquiries.CountCacheBlock > 0 then
      FBlockChain.Inquiries.ApproveAllCachedBlocks(FWalletCore.CurrentWallet, countBlocks);
    Result := countBlocks;
  except
    on e: Exception do
    begin
      Msg2(#13#10 + '********************************************************'
         + #13#10 +'   ***   ERROR FBlockChain.Inquiries.ApproveAllCachedBlocks: ' + e.Message
         + #13#10 + '********************************************************');
      DoLog('ERROR TConsensusCore2.ApproveAllCachedBlocks', 'FBlockChain.Inquiries.ApproveAllCachedBlocks: ' + e.Message);
    end;
  end;
  try
    FNewBlocks := FBlockChain.Inquiries.GetBlocksFrom(FBlockChain.Inquiries.MainChainCount - countBlocks);
    FCountNewBlocks := countBlocks;
    Result := countBlocks;
    // FIDIteration:= GetLastBlock();
    // FMainChainCount:= GetLastBlock();
    // var LastBlockHash:= FBlockChain.Inquiries.GetMainLastblocHash;
    Msg(#13#10 + '********************************************************'
      + #13#10 + '   ***   ApproveAllCachedBlocks: ' + FCountNewBlocks.ToString
      + #13#10 + '********************************************************');
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR FNewBlocks: ' + e.Message);
      DoLog('ERROR TConsensusCore2.ApproveAllCachedBlocks', 'FBlockChain.Inquiries.GetBlocksFrom: ' + e.Message);
    end;
  end;
  FCS2.Leave;
end;

procedure TConsensusCore2.SetNewBlocks();
var
  Packet: TPacket;
  strErr: string;
begin
  FCS.Enter;
  try
    if not Orator then
    begin
      Msg2('         FBlockChain.Inquiries.SetNewBlocks: BEGIN  cnt: ' + FCountNewBlocks.ToString);
      try
        if FBlockChain.Inquiries.SetNewBlocks(FNewBlocks,strErr) then
          Msg2('         FBlockChain.Inquiries.SetNewBlocks: END')
        else
        begin
          Msg2('         FBlockChain.Inquiries.SetNewBlocks: ' + strErr);
          DoLog('ERROR TConsensusCore2.SetNewBlocks', 'FBlockChain.Inquiries.SetNewBlocks: ' + strErr);
        end;
      except
        on e: Exception do
        begin
          Msg2('         FBlockChain.Inquiries.SetNewBlocks: EROR: ' + e.Message);
          DoLog('ERROR TConsensusCore2.SetNewBlocks', 'FBlockChain.Inquiries.SetNewBlocks: ' + e.Message);
          FCountNewBlocks := 0;
          FNewBlocks := [];
          Exit;
        end;
      end;
    end;
    if FCountNewBlocks > 0 then
    begin
      Packet.CreatePacket(CMD_RESPONSE_GET_NEW_BLOCKS, FNewBlocks);

      FNewBlocks := [];
      TThread.Queue(nil,
        procedure
        begin
          SendToAllClient(Packet);
          // GetBlock2();
        end);
    end;
    FCountNewBlocks := 0;
  except

  end;
  FCS.Leave;
  // FNetCore.SendAll(Packet);
end;

procedure TConsensusCore2.SetNodeState(ANodeState: TNodeState);
begin

end;

function TConsensusCore2.GetNodeState: TNodeState;
begin
  Result.IDNode:= FValID;
  Result.Enable:= Enable;
  Result.IDLastBlock:= GetLastBlock();
  Result.HashLastBlock:= GetMainLastblocHash();
  Result.UnixTime:= TUnixTime(Now());
end;

function TConsensusCore2.SelfConnect(): Integer;
var
  NetPacket: TNetPacket;
  i: Integer;
  Validator: TValidator;
begin
  Result:= -1;
  if Validators.IndexOfID(FValID) >= 0 then
  begin
    Validator.Clear;
    i:= Validators.IndexOfID(FValID);
    Validator := Validators.Items[i];
    Validator.ValInf.NetAddr := ServerIPv4 + ':' + ServerPort.ToString;
    // Validator.ValInf.NetAddr:= '127.0.0.1:' + ServerPort.ToString;
    Validator.Online := True;
    Validators.Items[i] := Validator;

    Validator.Client := FNetCore.ConnectToValidator(FValID, Validator.ValInf.NetAddr.ToIPv4, Validator.ValInf.NetAddr.Port);
    if (Validator.Client <> nil) then
    begin
      Validator.Enable := True;
      Validator.Online := True;
      Validators.Update(Validator);
      Result:= 0;
      // NetPacket.SetPacket(TNetPacket.tpNodeConnect, ThisNodeInfo().ToBytes);
      // Validator.Client.SendMessage(ToPacket(NetPacket.ToBytes));

      // NetPacket:= NetPacketNodeConnect(ThisNodeInfo());
      // Validator.Client.SendMessage(ToPacket(NetPacket.ToBytes));
    end
    else
    begin
      Result:= -1;
    end;
    Validators.Update(Validator);
  end;
end;

function TConsensusCore2.GetOratorStatus: Boolean;
begin
  Result := FOratorInf.ID = FValID;
end;

constructor TConsensusCore2.Create(ANetCore: TNetCore; ABlockChain: TBlockChainCore; AWalletCore: TWalletCore; AUICore: TBaseUI; AConfig: TConfig;
AHandlerCore: IBaseHandler);
var
  i, n: Integer;
  aOMs: TArray<UInt64>;
  Val: TValidator;
  NetAddr: TNetAddr;
begin
  // _CS.Enter;
  DoLog('TConsensusCore2.Create','OK');

  FCS := TCriticalSection.Create;
  FCS2 := TCriticalSection.Create;
  FCS3 := TCriticalSection.Create;
  FCSRespBlock := TCriticalSection.Create;
  FManagmentCS := TCriticalSection.Create;
  FTimeStart := Now();

  FNetCore := ANetCore;
  FNetCore.OnDisconnectE2 := DoDisconnect2;
  FBlockChain := ABlockChain;
  FWalletCore := AWalletCore;
  FUICore := AUICore;
  FConfig := AConfig;
  FHandlerCore := AHandlerCore;

  FIDIteration := 0;
  FMainChainCount := GetLastBlock();
  FLastTmIDIter := 0;

  // ***********************************************
  // ***********************************************
  // ***********************************************
  FValID := WalletID;
  FPrK := sPrK;
  FPbK := sPbK;
  // ***********************************************
  // ***********************************************
  // ***********************************************

  FValidators := TListVal.Create(FValID);

  {$REGION 'TEST'}
  {$IFDEF DEBUG}
//  var t1,t2: TUnixTime;
//  var i64: Int64;
//  var NodeStat1,NodeStat2: TNodeState;
//  var Hash: THash32;
//  var b1,b2: TBytes;
//  Hash.SetHash([1,2,3,4]);
//  t1:= Now();
//  i64:= t1;
//  t2:= i64;
//  Msg('t1: ' + t1.ToString);
//  Msg('t2: ' + t2.ToString);
//
//  t1:= Now();
//  t2:= Now() - 1/24;
//  Msg('fHoursBetween: ' + fHoursBetween(t1, t2).ToString);
//  NodeStat1.SetState(1,Enable,0,Hash);
//  b1:= NodeStat1;
//  SetLength(b2,Length(b1));
//  Move(b1[0],b2[0],Length(b1));
//  NodeStat2:= b2;
//  Msg('NodeStat1: ' + NodeStat1.ToString);
//  Msg('NodeStat2: ' + NodeStat2.ToString);
  {$ENDIF}
  {$ENDREGION 'TEST'}
end;

destructor TConsensusCore2.Destroy;
begin
  FActive := False;
  FCS.Enter;
  // FValidators:= [];
  FManagmentCS.Free;
  FValidators.Free;
  FCS.Leave;
  FCSRespBlock.Free;
  FCS3.Enter;
  FCS3.Leave;
  FCS3.Free;
  FCS2.Free;
  FCS.Free;
  inherited;
  // _CS.Leave;
end;

function TConsensusCore2.ConnectToValidator(ANodeInfo: TNodeInf): Integer;
var
  Validator: TValidator;
begin
  // FCS.Enter;
  Result := -1;
  if (ANodeInfo.ID = 0) and (ANodeInfo.NetAddr.IsEmpty) then
    Exit;

  Validator := Validators.ValidatorOfID(ANodeInfo.ID);
  // Result:= Validators.IndexOfID(ANodeInfo.ID);
  if (Validator.Client <> nil) then
  begin
    // Validator.Client.Socket.Close;
    // Validator.Client.Disconnect;
    // Validator.Client.Free;
    // Validator.Client:= nil;
    // Validator.Client.Destroy;
  end;
  if (ANodeInfo.ID <> 0) then
  begin
    // if (not Validator.Online) then
    if (Validator.Client = nil) or (not Validator.Client.Connected) then
    begin
      Validator.ValInf := ANodeInfo;
      Validator.Online := False;
      // Validator.Enable:= False;
      try
        Validator.Client := FNetCore.ConnectToValidator(ANodeInfo.ID, ANodeInfo.NetAddr.ToIPv4, ANodeInfo.NetAddr.Port);
      except
        on e: Exception do
        begin
          Msg2('Err.: FNetCore.ConnectToValidator - ' + e.Message);
        end;
      end;
      Sleep(10);
      if (Validator.Client <> nil) then
      begin
        try
          if (Validator.Client.SendMessage(ToPacket(NetPacketNodeConnect(ThisNodeInfo).ToBytes)) >= 0) then
          begin
            Validator.Online := True;
            // Validator.Enable:= True;
            Result := Validators.IndexOfID(ANodeInfo.ID);
            Msg2('SendMessage: NetPacketNodeConnect');
          end
          else
          begin
            Msg2('!!!!!!!!!!         SendMessage NO        !!!!!!!!!!!');
          end;
        except
          Msg2('  !!!ERROR!!!     !!!ERROR!!!     !!!ERROR!!!     !!!ERROR!!!   ');
        end;
      end
      else
      begin
        Validator.Online := False;
        // Validator.Enable:= False;
      end;
      Validator.CheckOnlineTime := Now();
      Validators.Update(Validator);
      Sleep(10);
    end
    else
    begin
      if (Validator.Client <> nil) and (Validator.Client.Connected) then
      begin
        Validator.Online := True;
        Validators.Update(Validator);
      end;
      Result := Validators.IndexOfID(ANodeInfo.ID);
    end;
  end;
  // FCS.Leave;
end;

function TConsensusCore2.ThisNodeInfo: TValInf;
begin
  Result.Clear;
  Result.ID := FValID;
  // ServerIPv4:= '127.0.0.1';
  Result.NetAddr := ServerIPv4 + ':' + ServerPort.ToString;
  Result.TimeStamp := FTimeStart;
  Result.IDIteration := IDIteration;
  // Result.SetSign(FValID, FPrK);
end;

{$REGION 'fnNetPacket'}
function TConsensusCore2.NetPacketNope(AData: Integer): TNetPacket;
var
  b: TBytes;
begin
  SetLength(b, SizeOf(AData));
  Move(AData, b[0], SizeOf(AData));
  Result.SetPacket(TNetPacket.tpNope, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketNope(ANetPacket: TNetPacket): Integer;
begin
  Result := Result.MinValue;
  if (ANetPacket.PacketType = TNetPacket.tpNope) then
  begin
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
  end;
end;

function TConsensusCore2.NetPacketNodeConnect(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNodeConnect, ANodeInf.ToBytes);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketNodeConnect(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNodeConnect then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketOratorInfo(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpOratorInfo, ANodeInf.ToBytes);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketOratorInfo(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpOratorInfo then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketNewOratorInfo(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNewOratorInfo, ANodeInf.ToBytes);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketNewOratorInfo(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNewOratorInfo then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketGetNodeEnable(AID: UInt64 = 0): TNetPacket;
var
  b: TBytes;
begin
  Result.Clear;
  SetLength(b, SizeOf(AID));
  Move(AID, b[0], SizeOf(AID));
  Result.SetPacket(TNetPacket.tpGetNodeEnable, b);
  Result.IDIter := IDIteration;
  // Result.SignPacket(FValID, FPrK);
end;

function TConsensusCore2.NetPacketGetNodeEnable(ANetPacket: TNetPacket): UInt64;
begin
  if (ANetPacket.PacketType = TNetPacket.tpGetNodeEnable) then
  begin
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
  end;
end;

//TNodeState
function TConsensusCore2.NetPacketNodeEnable(ANodeState: TNodeState): TNetPacket;
var
  b: TBytes;
begin
  Result.Clear;
  b:= ANodeState;
  Result.SetPacket(TNetPacket.tpNodeEnable, b);
  Result.IDIter := IDIteration;
  // Result.SignPacket(FValID, FPrK);
end;

function TConsensusCore2.NetPacketNodeEnable(ANetPacket: TNetPacket): TNodeState;
begin
  if (ANetPacket.PacketType = TNetPacket.tpNodeEnable) then
  begin
    Result:= ANetPacket.Data;
  end;
end;

//function TConsensusCore2.NetPacketNodeEnable(ANodeEnable: Boolean = False): TNetPacket;
//var
//  b: TBytes;
//begin
//  Result.Clear;
//  SetLength(b, SizeOf(ANodeEnable));
//  Move(ANodeEnable, b[0], SizeOf(ANodeEnable));
//  Result.SetPacket(TNetPacket.tpNodeEnable, b);
//  Result.IDIter := IDIteration;
//  // Result.SignPacket(FValID, FPrK);
//end;
//
//function TConsensusCore2.NetPacketNodeEnable(ANetPacket: TNetPacket): Boolean;
//begin
//  if (ANetPacket.PacketType = TNetPacket.tpNodeEnable) then
//  begin
//    Move(ANetPacket.Data[0], Result, SizeOf(Result));
//  end;
//end;

function TConsensusCore2.NetPacketGetDefNodeInfo(AIDNode: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
  IDNode: UInt64;
begin
  if AIDNode = 0 then
    IDNode := FValID
  else
    IDNode := AIDNode;
  Result.Clear;
  sz := SizeOf(AIDNode);
  SetLength(b, sz);
  Move(AIDNode, b[0], sz);
  Result.SetPacket(TNetPacket.tpGetDefNodeInfo, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketGetDefNodeInfo(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result := 0;
  if AData.PacketType = TNetPacket.tpGetDefNodeInfo then
  begin
    sz := SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore2.NetPacketDefNodeInfo(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpDefNodeInfo, ANodeInf.ToBytes);
  Result.IDIter := IDIteration;
  // Result.SignPacket(FValID,FPrK);
end;

function TConsensusCore2.NetPacketDefNodeInfo(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpDefNodeInfo then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketGetNodeInfo(AIDNode: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
  IDNode: UInt64;
begin
  if AIDNode = 0 then
    IDNode := FValID
  else
    IDNode := AIDNode;
  Result.Clear;
  sz := SizeOf(AIDNode);
  SetLength(b, sz);
  Move(AIDNode, b[0], sz);
  Result.SetPacket(TNetPacket.tpGetNodeInfo, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketGetNodeInfo(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result := 0;
  if AData.PacketType = TNetPacket.tpGetNodeInfo then
  begin
    sz := SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore2.NetPacketNodeInfo(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNodeInfo, ANodeInf.ToBytes);
  Result.IDIter := IDIteration;
  // Result.SignPacket(FValID,FPrK);
end;

function TConsensusCore2.NetPacketNodeInfo(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNodeInfo then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketNodeInfoID(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNodeInfoID, ANodeInf.ToBytes);
  Result.IDIter := IDIteration;
  // Result.SignPacket(FValID,FPrK);
end;

function TConsensusCore2.NetPacketNodeInfoID(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNodeInfoID then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketValList(AData: TListIDVal): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpValList, AData.ToBytes);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketValList(ANetPacket: TNetPacket): TListIDVal;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpValList then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketEnableValList(AData: TListIDVal): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpEnableValList, AData.ToBytes);
  Result.IDIter := IDIteration;
  // Result.SignPacket(FValID, FPrK);
end;

function TConsensusCore2.NetPacketEnableValList(ANetPacket: TNetPacket): TListIDVal;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpEnableValList then
    Result := ANetPacket.Data;
end;

function TConsensusCore2.NetPacketNextIteration(AIDIter: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz := SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpNextIteration, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketNextIteration(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result := 0;
  if AData.PacketType = TNetPacket.tpNextIteration then
  begin
    sz := SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore2.NetPacketGetTransaction(ANetPacket: TNetPacket): Word;
begin
  Result := 0;
  if ANetPacket.PacketType = ANetPacket.tpGetTransaction then
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
end;

function TConsensusCore2.NetPacketGetTransaction(ACount: Word = 0): TNetPacket;
var
  b: TBytes;
begin
  Result.Clear;
  SetLength(b, SizeOf(ACount));
  Move(ACount, b[0], SizeOf(ACount));
  Result.SetPacket(TNetPacket.tpGetTransaction, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketTransaction(AData: TBytes = []): TNetPacket;
begin
  Result.Clear;
  Result.SetPacket(TNetPacket.tpTransaction, AData);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketTransaction(ANetPacket: TNetPacket): TBytes;
begin
  Result := [];
  if ANetPacket.PacketType = ANetPacket.tpTransaction then
  begin
    SetLength(Result, ANetPacket.DataSize);
    Move(ANetPacket.Data[0], Result[0], ANetPacket.DataSize);
  end;
end;

function TConsensusCore2.NetPacketGetBlock(ANetPacket: TNetPacket): Word;
begin
  Result := 0;
  if ANetPacket.PacketType = ANetPacket.tpGetBlock then
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
end;

function TConsensusCore2.NetPacketGetBlock(ACount: Word = 0): TNetPacket;
var
  b: TBytes;
begin
  Result.Clear;
  SetLength(b, SizeOf(ACount));
  Move(ACount, b[0], SizeOf(ACount));
  Result.SetPacket(TNetPacket.tpGetBlock, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketBlock(ACnt: UInt64 = 0; AData: TBytes = []): TNetPacket;
begin
  Result.Clear;
  Result.SetPacket(TNetPacket.tpBlock, ACnt.ToBytes + AData);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketBlock(ANetPacket: TNetPacket; ACnt: UInt64): UInt64;
begin
  Result := 0;
  if ANetPacket.PacketType = ANetPacket.tpBlock then
  begin
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
  end;
end;

function TConsensusCore2.NetPacketBlock(ANetPacket: TNetPacket; AData: TBytes): TBytes;
begin
  Result := [];
  if ANetPacket.PacketType = ANetPacket.tpBlock then
  begin
    SetLength(Result, ANetPacket.DataSize - SizeOf(UInt64));
    Move(ANetPacket.Data[SizeOf(UInt64)], Result[0], ANetPacket.DataSize - SizeOf(UInt64));
  end;
end;

function TConsensusCore2.NetPacketGetIterationInfo(AIDIter: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz := SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpGetIterationInfo, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketGetIterationInfo(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result := 0;
  if AData.PacketType = TNetPacket.tpGetIterationInfo then
  begin
    sz := SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore2.NetPacketIterationInfo(AData: TIteration): TNetPacket;
begin
  Result.Clear;
  Result.SetPacket(TNetPacket.tpIterationInfo, AData.ToBytes);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketIterationInfo(AData: TNetPacket): TIteration;
begin
  Result.Clear;
  if AData.PacketType = AData.tpIterationInfo then
    Result := AData.Data;
end;

function TConsensusCore2.NetPacketPing(AIDIter: TDateTime): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz := SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpPing, b);
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.NetPacketPing(AData: TNetPacket): TDateTime;
var
  b: TBytes;
  sz: Integer;
begin
  Result := 0;
  if AData.PacketType = TNetPacket.tpPing then
  begin
    sz := SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

{$ENDREGION 'fnNetPacket'}

function TConsensusCore2.GetValList: TListIDVal;
var
  i, n: Integer;
begin
  Result.Clear;
  n := Validators.Count;
  for i := 0 to Pred(n) do
  begin
    Result.Add(Validators.Items[i].ValInf.ID);
  end;
  Result.IDIter := IDIteration;
end;

function TConsensusCore2.GetOnLineValList: TListIDVal;
var
  i, n: Integer;
begin
  Result.Clear;
  n := Validators.Count;
  for i := 0 to Pred(n) do
    if (Validators.Items[i].Online) then
      // if (Validators.Items[i].ValInf.TimeReceive + 1/24/60/60/1000 * ORATOR_TIMEOUT < Now()) then
      Result.Add(Validators.Items[i].ValInf.ID);
end;

function TConsensusCore2.GetEnableValList: TListIDVal;
var
  i, n: Integer;
begin
  Result.Clear;
  n := Validators.Count;
  for i := 0 to Pred(n) do
    if ((Validators.Items[i].Client <> nil)
    // and (Validators.Items[i].Online)
    // and (Validators.Items[i].Enable)
      ) // or (Validators.Items[i].ValInf.ID = FValID)
    then
      Result.Add(Validators.Items[i].ValInf.ID);
  Result.IDOrator := OratorInf.ID;
  Result.IDIter := IDIteration;
end;

procedure TConsensusCore2.Reconnect(Sender: TObject; AClient: TClient);
var
  NetPacket: TNetPacket;
begin
  Msg(         '******************'
    + #13#10 + '<<< Reconnect >>>'
    + #13#10 + '******************');
  Msg('[' + AClient.IDNode.ToString + '] ' + '<<< Reconnect >>>');
  if AClient.IDNode > 0 then
  begin
    NetPacket.SetPacket(TNetPacket.tpNodeReconnect, ThisNodeInfo.ToBytes);
    // NetPacket.SignPacket(FValID, FPrK);
    AClient.SendMessage(ToPacket(NetPacket));
  end;
end;

procedure TConsensusCore2.DoActive;
var
  Packet: TPacket;
  NetPacket: TNetPacket;
  b: TBytes;
  i, n: Integer;
  Validator: TValidator;
  Hash: THash32;
begin
  DoConsensusStatus(csWiat);
  Sleep(1000);
  FDefaultOrator.Clear;
  FDefaultOrator.NetAddr := FConfig.ConnectTo[0] + ':' + FConfig.ClientPort.ToString;
  if not CheckValidator then
  begin
    FActive := False;
    DoConsensusStatus(csDisable);
    Exit;
  end;
  FActive := True;
  IDIteration := GetLastBlock();
  Sleep(500);

  FOratorInf.Clear;
  FNewOratorInf.Clear;

  FArrayTXData.Clear;

  FValidators.OnReconnect := Reconnect;
  FValidators.OnDisconnect := DoDisconnect;

  Msg('<<< Consensus active >>>');
  Msg('HashLastBlock: ' + GetMainLastblocHash.ToString);
  DoLog('DoActive','HashLastBlock: ' + GetMainLastblocHash.ToString);
  try
    DoLog('TConsensusCore2','<<< Consensus active >>>');
  except
    Msg('ERROR ConsensusLog.DoAlert');
  end;
  Msg2('NodeInfo: ' + ThisNodeInfo.ToString);

  n := AddValToList();
  Msg2('Count OM: ' + n.ToString + ' Count validators: ' + FValidators.Count.ToString);

  // b:= ThisNodeInfo();
  // NetPacket.SetPacket(TNetPacket.tpNodeInfo, b);
  // NetPacket.SetPacket(TNetPacket.tpNodeConnect, ThisNodeInfo().ToBytes);

  NetPacket := NetPacketNodeConnect(ThisNodeInfo());
  // NetPacket.SignPacket(FValID, FPrK);
  // Packet.CreatePacket(40,NetPacket.ToBytes);
  try
    FNetCore.SendPacket(ToPacket(NetPacket.ToBytes));
  except
    on e: Exception do
    begin
      Msg('<<< FNetCore.SendPacket ERROR >>>');
      DoLog('TConsensusCore2.DoActive','FNetCore.SendPacket: ' + e.Message);
    end;
  end;
  Sleep(1500);

  if SelfConnect() >=0 then
  begin
    Sleep(500);

    Validators.CheckAddr();

    Enable := True;
    // FOratorInf.TimeStamp:= Now();
    // FOratorInf.TimeReceive:= Now();
    DoConsensusStatus(csEnable);
    while FActive do
    begin
      if (FCheckNetTime + 1 / 24 / 60 / 60 / 1000 * (TIMEOUT * 4) < Now()) then
      begin
  //      SendToOrator(NetPacketPing(Now()).ToBytes);
        SendToDefaultOrator(NetPacketPing(Now()).ToBytes);
      end;
      // Validators.SendData(ToPacket(NetPacketPing(Now()).ToBytes));
      // Sleep(1000);
//      if (OratorInf.TimeReceive + 1 / 24 / 60 / 60 / 1000 * (TIMEOUT * 2) < Now()) then
//      begin
//
//      end;
      Sleep(1000);
    end;
  end;
  Msg('<<< Consensus desactive >>>');
  DoConsensusStatus(csDisable);
end;

procedure TConsensusCore2.DoConsensusStatus(AStatus: Byte);
begin
  try
    case AStatus of
      csDisable:
        begin
          Notifyer.DoEvent(TEvents.nOnConsensusDisable)
        end;
      csWiat:
        begin
          Notifyer.DoEvent(TEvents.nOnConsensusWait)
        end;
      csEnable:
        begin
          Notifyer.DoEvent(TEvents.nOnConsensusEnable)
        end;
    end;
  except
    on e: Exception do
    begin
      Msg2('ERROR TConsensusCore2.DoConsensusStatus: ' + e.Message);
      DoLog('TConsensusCore2.DoConsensusStatus', e.Message)
    end;
  end;
end;

procedure TConsensusCore2.DoDisconnect(AClient: TClient);
begin
  if CheckValidator then
  begin
    Msg2('  ***  TConsensusCore2.DoDisconnect: AClient.IDNode[' + AClient.IDNode.ToString + ']');
    DoLog('TConsensusCore2.DoDisconnect','AClient.IDNode[' + AClient.IDNode.ToString + ']');
  end;
end;

procedure TConsensusCore2.DoDisconnect2(AClient: TConnectedClient);
begin
  if CheckValidator then
  begin
    Msg2('TConsensusCore.DoDisconnect2: ' + AClient.IDNode.ToString);
    DoLog('TConsensusCore2.DoDisconnect2','AClient.IDNode[' + AClient.IDNode.ToString + ']');
//    Sleep(1000);
  end;
end;

procedure TConsensusCore2.EventDisconnect(AClient: TClient1);
var
  i, n: Integer;
begin
  if CheckValidator then
  begin
    Msg2(' *** TConsensusCore.EventDisconnect: ' + AClient.IDNode.ToString);
    DoLog('TConsensusCore2.EventDisconnect','AClient.IDNode[' + AClient.IDNode.ToString + ']');
//    if (FValID = FOratorInf.ID) then
    if (FValID = FDefaultOrator.ID) then
    begin
      if FEnableValList.Exists(AClient.IDNode) then
        for i := FQuorumList.CurrentStep to 6 do
          FQuorumList.SetIDStep(i, AClient.IDNode, 2);
    end;
  end;
end;

procedure TConsensusCore2.EventConnect(AClient: TClient1);
begin
  if CheckValidator then
  begin
    Msg2(' *** TConsensusCore.EventConnect: ' + AClient.IDNode.ToString);
    DoLog('TConsensusCore2.EventConnect','AClient.IDNode[' + AClient.IDNode.ToString + ']');
    Sleep(1000);
//    if (FDefaultOrator.ID <> 0) and (AClient.IDNode = 0) then
    if (AClient.IDNode <> 0) and (Validators.IndexOfID(AClient.IDNode) >= 0 ) then
    begin
      Sleep(2000);
      SendToClient(AClient,NetPacketNodeConnect(ThisNodeInfo).ToBytes);
    end;
  end
  else
  begin
    Msg2('CheckValidator = FALSE');
  end;
end;

procedure TConsensusCore2.EventEndDownloadBlocks(AValue: Boolean);
begin
  if CheckValidator then
  begin
    FMainChainCount := GetLastBlock();
    Msg2(#13#10 + '************************** '
       + #13#10 + '* EventEndDownloadBlocks * ' + FMainChainCount.ToString
       + #13#10 + '************************** '
       + #13#10);
    FFlagRespBlock := False;
  end;
end;

function TConsensusCore2.GetActive: Boolean;
begin
  Result := FActive;
end;

function TConsensusCore2.GetAllCacheTrx: TBytes;
begin
  FCS2.Enter;
  try
    Result := FBlockChain.Inquiries.GetAllCacheTrx;
  except
    on e: Exception do
    begin
      Msg('   ***   ERROR TConsensusCore.GetAllCacheTrx: ' + e.Message);
      DoLog('TConsensusCore2.GetAllCacheTrx', 'FBlockChain.Inquiries.GetAllCacheTrx: ' + e.Message);
    end;
  end;
  FCS2.Leave;
end;

function TConsensusCore2.GetLastBlock: UInt64;
begin
  FCS2.Enter;
  // get from BC
  // Result:= FIDIteration + 1;
  Result := 0;
  try
    Result := FBlockChain.Inquiries.MainChainCount;
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR TConsensusCore.GetLastBlock: ' + e.Message);
      DoLog('TConsensusCore2.GetLastBlock', 'FBlockChain.Inquiries.MainChainCount: ' + e.Message);
    end;
  end;
  FCS2.Leave;
end;

function TConsensusCore2.GetOratorInf: TOratorInf;
begin
  Result := FOratorInf;
  Result.TimeStamp := Now();
  Result.IDIteration := IDIteration;
end;

procedure TConsensusCore2.RequestGetBlock(AClient: IClient);
var
  Packet: TPacket;
begin
  FCS2.Enter;
  if not FFlagRespBlock then
  begin
    try
      Packet.CreatePacket(CMD_REQUEST_GET_BLOCK_V2, FBlockChain.Inquiries.MainChainCount);
      // FCSRespBlock.Enter;
    except
      on e: Exception do
      begin
        FCS2.Leave;
        DoLog('TConsensusCore2.RequestGetBlock', 'Packet.CreatePacket: ' + e.Message);
        Exit;
      end;
    end;
    try
      AClient.SendMessage(Packet);
    except
      on e: Exception do
      begin
        Msg2('   ***   ERROR TConsensusCore.RequestGetBlock: ' + e.Message);
        DoLog('TConsensusCore2.RequestGetBlock', 'AClient.SendMessage: ' + e.Message);
      end;
    end;
    FFlagRespBlock := True;
    FCS2.Leave;
  end;
end;

procedure TConsensusCore2.RequestGetBlock2(AClient: TClient);
var
  Packet: TPacket;
begin
  FCS2.Enter;
  if not FFlagRespBlock then
  begin
    try
      Packet.CreatePacket(CMD_REQUEST_GET_BLOCK_V2, FBlockChain.Inquiries.MainChainCount);
      // FCSRespBlock.Enter;
    except
      on e: Exception do
      begin
        FCS2.Leave;
        DoLog('TConsensusCore2.RequestGetBlock2', 'Packet.CreatePacket: ' + e.Message);
        Exit;
      end;
    end;
    try
      AClient.SendMessage(Packet);
    except
      on e: Exception do
      begin
        Msg2('   ***   ERROR TConsensusCore.RequestGetBlock2: ' + e.Message);
        DoLog('TConsensusCore2.RequestGetBlock2', 'AClient.SendMessage: ' + e.Message);
      end;
    end;
    FFlagRespBlock := True;
    FCS2.Leave;
  end;
end;

procedure TConsensusCore2.SetActive(AValue: Boolean);
begin
  if CheckValidator then
  begin
    if AValue <> FActive then
    begin
      Enable := AValue;
      FActive := AValue;
      if AValue then
      begin
        TThread.CreateAnonymousThread(
          procedure
          begin
            DoActive;
          end).Start;

        TThread.CreateAnonymousThread(
          procedure
          begin
            DoManagment(0);
          end).Start;
      end
      else
      begin

      end;
    end;
  end
  else
  begin
    Enable := False;
    FActive := False;
  end;
end;

procedure TConsensusCore2.SetEnable(AValue: Boolean);
var
  Validator: TValidator;
begin
  if CheckValidator then
  begin
    if FEnable <> AValue then
    begin
      FEnable := AValue;
      Validator := Validators.ValidatorOfID(FValID);
      Validator.Enable := FEnable;
      Validators.Update(Validator);
//      SendToAllValidators(NetPacketNodeEnable(AValue).ToBytes)
    end;
  end;
end;

function TConsensusCore2.GetEnable: Boolean;
begin
  Result := FEnable;
end;

procedure TConsensusCore2.SetIDIteration(AValue: UInt64);
begin
  FIDIteration := AValue;
end;

function TConsensusCore2.GetIDIteration: UInt64;
begin
  Result := FIDIteration;
end;

procedure TConsensusCore2.SetOratorInf(AValue: TOratorInf);
begin
  if (FOratorInf.ID <> AValue.ID) and (Validators.IndexOfID(AValue.ID) >= 0) then
  begin
    FOratorInf := AValue;
    FNetCore.MainClient:= Validators.Items[Validators.IndexOfID(FOratorInf.ID)].Client;
    Msg('SetOrator: ' + FOratorInf.ToString);
  end;
  DoLog('TConsensusCore2.SetOratorInf','SetOrator: ' + AValue.ToString);
end;

procedure TConsensusCore2.SetValID(const AValID: UInt64);
begin
  FValID := AValID;
end;

function TConsensusCore2.SendToClient(AClient: IClient; AData: TBytes): Integer;
var
  s: string;
begin
  try
    Result := AClient.SendMessage(ToPacket(AData));
  except
    on e: Exception do
    begin
      s:= ' *** Err. SendToClient[' + AClient.IDNode.ToString + ']: ' + e.Message;
      Msg2(s);
      DoLog('TConsensusCore2.SendToClient1',s);
    end;
  end;
end;

function TConsensusCore2.SendToClient(AClient: TClient1; AData: TBytes): Integer;
var
  s: string;
begin
  try
    Result := AClient.SendMessage(ToPacket(AData));
  except
    on e: Exception do
    begin
      s:= ' *** Err. SendToClient[' + AClient.IDNode.ToString + ']: ' + e.Message;
      Msg2(s);
      DoLog('TConsensusCore2.SendToClient2',s);
    end;
  end;
end;

function TConsensusCore2.SendToAllValidators(AData: TBytes): TListIDVal;
var
  i, n, j: Integer;
  Validator: TValidator;
  s: string;
begin
  Result.Clear;
  n := Validators.Count;
  for i := 0 to Pred(n) do
  begin
    Validator := Validators.Items[i];
    if (not Validator.ValInf.NetAddr.IsEmpty)
    // and (Validator.ID <> FValID)
    // and (Validator.Online)
      and (Validator.Client <> nil) and (Validator.Client.Connected)
    then
    begin
      j := -1;
      try
        j := Validator.Client.SendMessage(ToPacket(AData));
      except
        on e: Exception do
        begin
          s:= ' *** Err. SendToAllValidators[' + i.ToString + ']: ' + e.Message;
          Msg(s);
          DoLog('TConsensusCore2.SendToAllValidators', s);
        end;
      end;
      if j >= 0 then
      begin
        Validator.Online := True;
        Result.Add(Validator.ID);
      end
      else
      begin
        Validator.Online := False;
        // Validator.Enable:= False;
      end;
      Validator.CheckOnlineTime := Now();
      Validators.Update(Validator);
    end;
  end;
end;

function TConsensusCore2.SendToOrator(AData: TBytes): Integer;
var
  Val: TValidator;
begin
  Result := -1;
  Result := Validators.SendDataToID(OratorInf.ID, ToPacket(AData));
  if Result < 0 then
  begin
    Val := Validators.ValidatorOfID(OratorInf.ID);
    Val.Online := False;
    Validators.Update(Val);
    // OratorInf:= NewOrator(True);
  end
  else
  begin
    Val := Validators.ValidatorOfID(OratorInf.ID);
    Val.Online := True;
    Validators.Update(Val);
  end;
end;

procedure TConsensusCore2.SendToAllClient(AData: TBytes);
var
  s: String;
begin
  with FNetCore do
    for var i := 0 to Length(ConnectedClients) - 1 do
    begin
      try
        if (ConnectedClients[i] <> nil) and Assigned(ConnectedClients[i]) { and (ConnectedClients[i].SocketIP <> '127.0.0.1') } then
          if (ConnectedClients[i].IDNode = 0) or (Validators.IndexOfID(ConnectedClients[i].IDNode) < 0) or
            ((Validators.IndexOfID(ConnectedClients[i].IDNode) >= 0)
              and (not Validators.ValidatorOfID(ConnectedClients[i].IDNode).Enable))
          then
          begin
            try
              ConnectedClients[i].SendMessage(AData);
              Msg2('>> SendTo[' + i.ToString + '] size: ' + Length(AData).ToString + ' OK');
            except
              on e: Exception do
              begin
                Msg2('>> SendTo[' + i.ToString + '] size: ' + Length(AData).ToString + ' NO');
                s:= 'SendTo ' + i.ToString + ' of ' + Length(ConnectedClients).ToString + ' size: ' + Length(AData).ToString;
                DoLog('ERROR TConsensusCore2.SendToAllClient', s + #13#10 + e.Message);
              end;
            end;
          end;
      except
        on e: Exception do
        begin
          Msg2('   ***   ERROR TConsensusCore.SendToAllClient: ' + e.Message);
          DoLog('* ERROR TConsensusCore2.SendToAllClient', e.Message);
        end;
      end;
    end;
end;

function TConsensusCore2.SendToDefaultOrator(AData: TBytes): Integer;
var
  Val: TValidator;
begin
  Result := -1;
  Result := Validators.SendDataToID(FDefaultOrator.ID, ToPacket(AData));
  if Result < 0 then
  begin
    Val := Validators.ValidatorOfID(FDefaultOrator.ID);
    Val.Online := False;
    Validators.Update(Val);
  end
  else
  begin
    Val := Validators.ValidatorOfID(OratorInf.ID);
    Val.Online := True;
    Validators.Update(Val);
  end;
end;

function TConsensusCore2.CheckValidator: Boolean;
var
  i, n: Integer;
  aOMs: TArray<UInt64>;
begin
  Result := False;
  if (FValID > 0)
    and ((NodeState = Validator) or (NodeState = Speaker) {or (ParamStr(1) = 'init')})
    and FHandlerCore.CheckLocalHost()
  then
  begin
    try
      aOMs := GetOMs;
      n := Length(aOMs);
      for i := 0 to Pred(n) do
        if FValID = aOMs[i] then
        begin
          Result := True;
          Break;
        end;
    except
      on e: exception do
        DoLog('TConsensusCore2.CheckValidator', 'CHECK THIS PLACE ' + e.Message)
    end;
  end;
end;

procedure TConsensusCore2.SetDefaultOrator;
var
  NetAddr: TNetAddr;
  i, n: Integer;
begin
  if FDefaultOrator.ID = 0 then
  begin
    NetAddr := FConfig.ConnectTo[0] + ':' + FConfig.ClientPort.ToString;
    n := Validators.Count;
    for i := 0 to Pred(n) do
    begin
      if Validators.Items[i].ValInf.NetAddr = NetAddr then
      begin
        FDefaultOrator := Validators.Items[i].ValInf;
        Break;
      end;
    end;
  end;
end;

function TConsensusCore2.GetPbKFromBC(AID: UInt64): TPubKey;
begin
  // *************************************
  // *************************************
  // *************************************
  Result := sPbK;
  // Result:= FBlockChain.Inquiries.
  // *************************************
  // *************************************
  // *************************************
end;

function TConsensusCore2.AddValToList(): Integer;
var
  i, n: Integer;
  aOMs: TArray<UInt64>;
  Val: TValidator;
begin
  Result := 0;
  aOMs := GetOMs;
  n := Length(aOMs);
  for i := 0 to Pred(n) do
  begin
    if FValidators.IndexOfID(aOMs[i]) < 0 then
    begin
      Val.Clear;
      Val.ValInf.ID := aOMs[i];
      // Val.ValInf.NetAddr:=
      Val.PbK := GetPbKFromBC(aOMs[i]);
      FValidators.Add(Val);
    end;
  end;
  Result := n;
end;

procedure TConsensusCore2.ReceiveDataR(AClient: IClient; AData: TBytes);
begin
  TThread.Queue(nil,
    procedure
    begin
      // ReceiveDataR(AClient,AData);
    end);
end;

procedure TConsensusCore2.ReceiveData(AClient: IClient; AData: TBytes);
var
  NetPacket, NetPacket1: TNetPacket;
  NodeInfo, NodeInfo1: TValInf;
  sOratorInf: TOratorInf;
  Validator: TValidator;
  sEnable: Boolean;
  b: TBytes;
  i: Integer;
  CheckSign, CheckSign2: Boolean;
  IterInfo, IterInfo1: TIteration;
  ID: UInt64;
  ValList: TListIDVal;
  TXData: TTXData;
  Hash,Hash1: THash32;
  sIDIter: UInt64;
  NodeStat: TNodeState;
  utm: TUnixTime;

  function SendToClient(AData: TBytes): Integer;
  begin
    Result := Self.SendToClient(AClient, AData);
  end;
  procedure MsgNodeInf(ANodeInf: TNodeInf; AInfo: string);
  begin
    Msg2('[' + AClient.IDNode.ToString + '] ' + AInfo
        + #13#10 + '   Validators.IndexOfID: ' + Validators.IndexOfID(ANodeInf.ID).ToString
        + #13#10 + '   ID: ' + ANodeInf.ID.ToString
        + #13#10 + '   NetAddr: ' + ANodeInf.NetAddr.ToString
        + #13#10 + '   tm: ' + FormatDateTime('dd.mm.yy hh:nn:ss.zzz', ANodeInf.TimeStamp)
        + #13#10 + '   IDIteration: ' + ANodeInf.IDIteration.ToString);
  end;

begin
  FCheckNetTime := Now();
  if (not CheckValidator) and (not Active) then
    Exit;
  FCS.Enter;
  try

    sIDIter := 0;
    if (Length(AData) >= 9) and (Length(AData) <= 14) then
      Msg2(' *** Length(Adata) AClient.IDNode[' + AClient.IDNode.ToString + ']: ');
    try
      NetPacket := AData;
      sIDIter := NetPacket.IDIter;
    except
      on e: Exception do
      begin
        SetLength(b, 20);
        Move(AData[0], b[0], 20);
        Msg2(' *** Err. TConsensusCore.ReceiveData AClient.IDNode[' + AClient.IDNode.ToString + ']: '
            + #13#10 + '   *****   ' + #13#10 + '   b: ' + Length(AData).ToString
            + #13#10 + '   AData: ' + BytesToHexStr(b)
            + #13#10 + e.Message
            + #13#10 + '   *****   ');
        NetPacket.Clear;
      end;
    end;
    // *******************************************
    // *******************************************
    // CheckSign:= NetPacket.CheckSignPacket(Validators.Items[Validators.IndexOfID(NodeInfo.ID)].PbK);
    // try
    // if NetPacket.IDSign = 0 then
    // CheckSign:= NetPacket.CheckSignPacket(sPbK)
    // else
    // CheckSign:= NetPacket.CheckSignPacket(Validators.PbKOfID(NetPacket.IDSign));
    // except
    // on e: Exception do
    // begin
    // CheckSign:= False;
    // Msg('[' + AClient.IDNode.ToString + '] ' + 'NetPacket.CheckSignPacket ERROR: ' + e.Message);
    // end;
    // end;
    // if not CheckSign then
    // begin
    // Msg('[' + AClient.IDNode.ToString + '] ' + 'NetPacket.CheckSignPacket: False');
    /// /    Exit;
    // end
    // else
    // begin
    // Msg('[' + AClient.IDNode.ToString + '] ' + 'NetPacket.CheckSignPacket: True');
    // end;

    if (AClient.IDNode = 0) and ((NetPacket.PacketType <> TNetPacket.tpNodeConnect) and (NetPacket.PacketType <> TNetPacket.tpNope)) then
    begin
      Msg('AClient.IDNode = 0 | IDSign: ' + NetPacket.IDSign.ToString);
      NetPacket1 := NetPacketNope(0);
      NetPacket1.SignPacket(0, sPrK);
      SendToClient(NetPacket1.ToBytes);
      NetPacket.Clear;
    end
    else
    begin
      Validators.CheckTimeReceive(AClient.IDNode);
      // *******************************************
      // *******************************************
      // if CheckSign then
      case NetPacket.PacketType of
        TNetPacket.tpNope:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNope');
            NetPacket1 := NetPacketNodeConnect(ThisNodeInfo);
            NetPacket1.SignPacket(FValID, FPrK);
            SendToClient(NetPacket1.ToBytes);
          end;
        TNetPacket.tpNodeConnect: // CONNECT
          begin
            AddValToList();
            NodeInfo := NetPacketNodeConnect(NetPacket);
            CheckSign2 := NodeInfo.CheckSign(Validators.PbKOfID(NodeInfo.ID));
            if (NodeInfo.ID = 0) then
            begin
              MsgNodeInf(NodeInfo, 'NetPackt.PacketType: tpNodeConnect');
              SendToClient(NetPacketNope(0).ToBytes);
            end
            else
            begin
              NodeInfo.TimeReceive := Now();
              if (IDIteration < NodeInfo.IDIteration) then
              begin
                RequestGetBlock(AClient);
              end;

              if (AClient.IDNode = 0)
              // and (CheckSign2)
              // and (NodeInfo.ID = NodeInfo.Sign.IDKey)
              then
              begin
                AClient.IDNode := NodeInfo.ID;
              end;

              if (FDefaultOrator.NetAddr = NodeInfo.NetAddr) then
              begin
                FDefaultOrator := NodeInfo;
                Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeInfo'
                      + #13#10 + '   ***   DefaultOrator: ' + FDefaultOrator.ToString
                      + #13#10 + '   ***   ');
              end;
              // if FOratorInf.IsEmpty then
              // FOratorInf:= FDefaultOrator;
              if FOratorInf.IsEmpty then
                FOratorInf := NodeInfo;

              MsgNodeInf(NodeInfo, 'NetPackt.PacketType: tpNodeConnect');
              if (NodeInfo.NetAddr.IsLocalHost) then
              begin
                if FConfig.ConnectTo[0] <> '127.0.0.1' then
                begin
                  DoLog('TNetPacket.tpNodeConnect','[' + AClient.IDNode.ToString + '] '
                        + ' Check IPv4 NodeInfo: ' + NodeInfo.ToString);
                  Exit;
                end;
              end;
              i := ConnectToValidator(NodeInfo);
              if i >= 0 then
              begin
                Msg2(' *** [' + AClient.IDNode.ToString + '] ' + 'ConnectToValidator: OK [' + i.ToString + ']');
                DoLog('TNetPacket.tpNodeConnect','[' + AClient.IDNode.ToString + '] '
                      + ' + ConnectToValidator: connected ' + NodeInfo.ToString);
                // Validators.CheckTx(AClient.IDNode);
                // Validators.SendDataToID(AClient.IDNode,ToPacket(NetPacketCheckTx(Now()).ToBytes));
                SetDefaultOrator();

                Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeConnect');
                Sleep(1);

                for i := 0 to Pred(Validators.Count) do
                begin
                  if (Validators.Items[i].ValInf.ID <> FValID) and (Validators.Items[i].ValInf.ID <> 0) and
                    (Validators.Items[i].ValInf.ID <> NodeInfo.ID) and (not Validators.Items[i].ValInf.NetAddr.IsEmpty)
                  // and (Validators.Items[i].CheckTxRx = TValidator.chTxRx_GOOD)
                  then
                  begin
                    NetPacket1 := NetPacketNodeInfoID(Validators.Items[i].ValInf);
                    SendToClient(NetPacket1.ToBytes);
                    Sleep(10);
                  end;
                end;
                if (AClient.IDNode = OratorInf.ID) and (OratorInf.ID = FDefaultOrator.ID) then
                else
                begin
                  // BeginIteration(False);
                  Sleep(10);
                end;
              end
              else
              begin
                Msg2(' *** [' + AClient.IDNode.ToString + '] ' + 'ConnectToValidator: NO [' + i.ToString + ']');
                DoLog('TNetPacket.tpNodeConnect','[' + AClient.IDNode.ToString + '] '
                      + ' - ConnectToValidator: not connected ' + NodeInfo.ToString);
              end;
            end;
          end;
        TNetPacket.tpNodeReconnect:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeReconnect');
            // **********************
            NodeInfo.TimeReceive := Now();
          end;
        TNetPacket.tpGetNodeEnable:
          begin
            if (AClient.IDNode = FDefaultOrator.ID) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeEnable');
              if (Enable) and (AClient.IDNode <> FValID) then
                IDIteration:= NetPacket.IDIter;
//              SendToClient(NetPacketNodeEnable(Enable).ToBytes);
              SendToClient(NetPacketNodeEnable(csNodeState).ToBytes);
            end;
          end;
        TNetPacket.tpNodeEnable:
          begin
             if (FValID = FDefaultOrator.ID) then
            begin
              // Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeEnable');
//              sEnable := NetPacketNodeEnable(NetPacket);
              NodeStat:= NetPacketNodeEnable(NetPacket);
              utm:= Now();
//              if sEnable then
              if (NodeStat.Enable)
                and (NodeStat.IDLastBlock = csNodeState.IDLastBlock)
                and (NodeStat.HashLastBlock = csNodeState.HashLastBlock)
                and (fHoursBetween(utm,NodeStat.UnixTime) <= 1)
              then
                begin
                  FManagmentCS.Enter;
                  if (not FQuorumList.CheckStep(1)) then
                  /// ///=====================//////
                  begin
                    FEnableValList.Add(AClient.IDNode);
                    Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeEnable' + ' TRUE +++');
                  end
                  else
                  begin
                    Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeEnable' + ' TRUE ---');
                  end;
                  FManagmentCS.Leave;
                end
              else
                begin
                  Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeEnable' + ' FALSE ');
                  DoLog('NetPackt.PacketType: tpNodeEnable' ,'IDNode[' + AClient.IDNode.ToString + '] '
                        + #13#10 + '   NodeStat: ' + NodeStat.ToString
                        + #13#10 + 'csNodeState: ' + csNodeState.ToString);
                  if (NodeStat.IDLastBlock = csNodeState.IDLastBlock)
                    and (NodeStat.HashLastBlock <> csNodeState.HashLastBlock)
                  then
                    begin
                      // AClient BC corrupted
                      Msg2('[' + AClient.IDNode.ToString + '] ' + ' ~~~~ BC corrupt ~~~~');
                      DoLog('NetPackt.PacketType: tpNodeEnable' ,'IDNode[' + AClient.IDNode.ToString + '] '
                            + #13#10 + 'NodeStat.HashLastBlock <> csNodeState.HashLastBlock'
    //                        + #13#10 + '   NodeStat: ' + NodeStat.ToString
    //                        + #13#10 + 'csNodeState: ' + csNodeState.ToString
                            );
                    end
                  else
                    begin
                      if (NodeStat.IDLastBlock < csNodeState.IDLastBlock) then
                        ;
                    end;
                end;
            end;
          end;
        TNetPacket.tpGetDefNodeInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeInfo');
            ID := NetPacketGetNodeInfo(NetPacket);
            if not FDefaultOrator.IsEmpty then
              SendToClient(NetPacketDefNodeInfo(FDefaultOrator).ToBytes);
            Sleep(1);
          end;
        TNetPacket.tpDefNodeInfo:
          begin
            // NodeInfo:= NetPacket.Data;
            if (FDefaultOrator.IsEmpty) or (AClient.IDNode = FDefaultOrator.ID) then
            begin
              NodeInfo := NetPacketNodeInfo(NetPacket);
              CheckSign2 := NodeInfo.CheckSign(Validators.PbKOfID(NodeInfo.ID));
              NodeInfo.TimeReceive := Now();
              if (NodeInfo.ID <> FDefaultOrator.ID) then
              begin
                FDefaultOrator := NodeInfo;
                MsgNodeInf(NodeInfo, 'NetPackt.PacketType: tpDefNodeInfo');
              end;
              Sleep(1);
            end;
          end;
        TNetPacket.tpGetNodeInfo:
          begin
            ID := NetPacketGetNodeInfo(NetPacket);
            if Validators.IndexOfID(ID) >= 0 then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeInfo' + ' [' + ID.ToString + ']');
            end;
          end;
        TNetPacket.tpNodeInfo:
          begin
            // NodeInfo:= NetPacket.Data;
            NodeInfo := NetPacketNodeInfo(NetPacket);
            CheckSign2 := NodeInfo.CheckSign(Validators.PbKOfID(NodeInfo.ID));
            if (NodeInfo.ID <> FValID) and (Validators.IndexOfID(NodeInfo.ID) >= 0) then
            begin
              NodeInfo.TimeReceive := Now();
              if (ConnectToValidator(NodeInfo) >= 0) then
                Msg2('+++ ConnectToValidator' + NodeInfo.ToString)
              else
                Msg2('!!! NOT ConnectToValidator' + NodeInfo.ToString);
              Sleep(1);
            end
          end;
        TNetPacket.tpNodeInfoID:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeInfoID');

            NodeInfo := NetPacketNodeInfoID(NetPacket);
            NodeInfo.TimeReceive := Now();
            if (NodeInfo.ID <> FValID) and (Validators.IndexOfID(NodeInfo.ID) >= 0) then
            begin
              if ConnectToValidator(NodeInfo) >= 0 then
                Msg2('+++ ConnectToValidator' + NodeInfo.ToString)
              else
                Msg2('!!! NOT ConnectToValidator' + NodeInfo.ToString);
            end
          end;
        TNetPacket.tpGetValList:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetValList.');
            // NetPacket:= NetPacketValList(GetValList);
            NetPacket1 := NetPacketValList(GetValList);
            // NetPacket1.SignPacket(FValID, FPrK);
            // AClient.SendMessage(ToPacket(NetPacket1.ToBytes));
            // SendToClient(NetPacket1);
          end;
        TNetPacket.tpValList:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpValList.');
            ValList := NetPacketValList(NetPacket);
          end;
        TNetPacket.tpGetEnableValList:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetEnableValList.');
            Sleep(1);
          end;
        TNetPacket.tpEnableValList:
          begin
            if (AClient.IDNode = FDefaultOrator.ID) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpEnableValList.');
              ValList := NetPacketEnableValList(NetPacket);
              FEnableValList := ValList;
              IDIteration:= ValList.IDIter;
              if (FValID <> FDefaultOrator.ID) then
                SendToClient(NetPacketEnableValList(FEnableValList).ToBytes);
              Sleep(1);
              if (ValList.IDOrator = OratorInf.ID) then
              begin
                if (Orator) then
                  FArrayTXData.Init(FValID, IDIteration, THash32.Empty, ValList);
                Sleep(1);
              end
            end
            else
            begin
              /// Ckeck Step
              if FEnableValList.Exists(AClient.IDNode) then
              begin

                FManagmentCS.Enter;
                FQuorumList.SetIDStep(3, AClient.IDNode, 1);
                /// ///=====================//////
                FManagmentCS.Leave;
                Sleep(1);
              end;
            end;
          end;

        TNetPacket.tpGetOratorInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetOratorInfo.');
          end;
        TNetPacket.tpOratorInfo:
          begin
            if (AClient.IDNode = FDefaultOrator.ID) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpOratorInfo.');
              sOratorInf := NetPacketOratorInfo(NetPacket);
              OratorInf := sOratorInf;
              if FValID <> FDefaultOrator.ID then
                SendToClient(NetPacketNewOratorInfo(sOratorInf).ToBytes);
            end;
          end;
        TNetPacket.tpNewOratorInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNewOratorInfo.');
            sOratorInf := NetPacketNewOratorInfo(NetPacket);
            if (sOratorInf.ID = OratorInf.ID) and (FEnableValList.Exists(AClient.IDNode)) then
            begin
              FManagmentCS.Enter;
              FQuorumList.SetIDStep(2, AClient.IDNode, 1);
              /// ///=====================//////
              FManagmentCS.Leave;
            end;

            // Check Step
          end;

        TNetPacket.tpGetIDIteration:
          begin
            if (AClient.IDNode = FDefaultOrator.ID) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetIDIteration.');
              TXData.IDNode := FValID;
              TXData.SetData(FValID, IDIteration, GetAllCacheTrx());
            end;
          end;
        TNetPacket.tpIDIteration:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpIDIteration.');
          end;
        TNetPacket.tpNextIteration:
          begin
            if (AClient.IDNode = FDefaultOrator.ID) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNextIteration. ' + IDIteration.ToString);
              ID := NetPacketNextIteration(NetPacket);
            end;
            if FValID = FDefaultOrator.ID then
            begin
              // Check Step
              FQuorumList.SetIDStep(6, AClient.IDNode, 1);
            end;
          end;

        TNetPacket.tpGetIterationInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetIterationInfo.');
            ID := NetPacketGetIterationInfo(NetPacket);
          end;
        TNetPacket.tpIterationInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpIterationInfo.');
            // IterInfo:= NetPacket.Data;
            try
              ID := NetPacket.IDIter;
              IterInfo := NetPacketIterationInfo(NetPacket);
            except
              on e: Exception do
              begin
                Msg2(' *** Err. TNetPacket.tpIterationInfo AClient.IDNode[' + AClient.IDNode.ToString + ']: ');
              end;
            end;
          end;

        TNetPacket.tpGetTransaction:
          begin
            if (AClient.IDNode = FDefaultOrator.ID) and (IDIteration = NetPacket.IDIter) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetTransaction ***');

              if (not Orator) and (IDIteration = NetPacket.IDIter) and (FEnableValList.Exists(FValID)) then
              begin
                NetPacket1:= NetPacketTransaction(GetAllCacheTrx());
                SendToOrator(NetPacket1.ToBytes);
                if NetPacket1.DataSize > 0 then
                  DoLog('TNetPacket.tpGetTransaction: ','SendToOrator(NetPacketTransaction(TX))');
              end;
              if (FValID <> FDefaultOrator.ID) and (FDefaultOrator.ID <> OratorInf.ID) then
                SendToDefaultOrator(NetPacketTransaction([]).ToBytes);
            end;
          end;
        TNetPacket.tpTransaction:
          begin
            if (FEnableValList.Exists(FValID)) and (IDIteration = NetPacket.IDIter) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpTransaction ****');
              // ReceiveTX(AClient.IDNode,NetPacket);
              if (Orator) then
              begin
                TXData.SetData(AClient.IDNode, IDIteration, NetPacketTransaction(NetPacket));
                FArrayTXData.Add(TXData);
                // if not FArrayTXData.Hash.IsEmpty then
                // begin
                // FCountNewBlocks:= ApproveAllCachedBlocks(FArrayTXData,FNewBlocks);
                // SendToAllValidators(NetPacketBlock(FCountNewBlocks,FNewBlocks).ToBytes);
                /// /                   TThread.Queue(nil,
                /// /                    procedure
                /// /                    begin
                /// ///                      RequestGetBlock2(FNetCore.MainClient);
                /// /                      RequestGetBlock2(Validators.ValidatorOfID(OratorInf.ID).Client);
                /// /                    end);
                // Sleep(500);
                // end;
              end;
              if FValID = FDefaultOrator.ID then
              begin
                // Check Step
                FQuorumList.SetIDStep(4, AClient.IDNode, 1);
              end;
              Sleep(1);
            end;
          end;
        TNetPacket.tpGetBlock:
          begin
            if (AClient.IDNode = FDefaultOrator.ID) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetBlock ***');

              if (Orator) then
              begin
                FCS2.Enter;
                try
                  if FBlockChain.Inquiries.NeedCalcMine then
                  begin
                    FBlockchain.Inquiries.domining(FWalletCore.CurrentWallet,i);
                    Msg2('FBlockChain.Inquiries.NeedCalcMine' + ' domining: ' + i.ToString);
                    DoLog('FBlockChain.Inquiries.NeedCalcMine', 'domining: ' + i.ToString);
                  end;

                except
                  on e: Exception do
                  begin
                    Msg2('ERROR FBlockChain.Inquiries.NeedCalcMine' +  ' domining: ' + i.ToString
                          + #13#10 + e.Message);
                    DoLog('ERROR FBlockChain.Inquiries.NeedCalcMine', 'domining: ' + i.ToString
                          + #13#10 + e.Message);
                  end;
                end;
                FCS2.Leave;
                Hash:= GetMainLastblocHash();
                ID:= GetLastBlock();

                FCountNewBlocks := ApproveAllCachedBlocks(FArrayTXData, FNewBlocks);
                Hash1.SetHash(FNewBlocks);

                if FCountNewBlocks > 0 then
                DoLog('TNetPacket.tpGetBlock: ','SendToAllValidators(NetPacketBlock(..))'
                            + #13#10 + ' IDIteration: ' + IDIteration.ToString
                            + #13#10 + ' MainLastblocHash: ' + Hash.ToString
                            + #13#10 + ' CountBlocks: ' + ID.ToString
                            + #13#10 + ' HashNewBlocks: ' + Hash1.ToString
                            + #13#10 + ' FCountNewBlocks: ' + FCountNewBlocks.ToString
                            );
                SendToAllValidators(NetPacketBlock(FCountNewBlocks, FNewBlocks).ToBytes);
                // if (FValID <> FDefaultOrator.ID) and (FDefaultOrator.ID <> OratorInf.ID) then
                // SendToDefaultOrator(NetPacketBlock().ToBytes);
              end;
            end;
          end;
        TNetPacket.tpBlock:
          begin
            if (FEnableValList.Exists(FValID)) and (NetPacket.IDIter = IDIteration) then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpBlock');
              // ReceiveBlock(AClient,NetPacket);
              if (not Orator) then
              begin
                Hash:= GetMainLastblocHash();
                ID:= GetLastBlock();

                FCountNewBlocks := NetPacketBlock(NetPacket, 0);
                FNewBlocks := NetPacketBlock(NetPacket, []);
                Hash1.SetHash(FNewBlocks);

                if FCountNewBlocks > 0 then
                DoLog('TNetPacket.tpGetBlock: ','SendToAllValidators(NetPacketBlock(..))'
                            + #13#10 + ' IDIteration: ' + IDIteration.ToString
                            + #13#10 + ' MainLastblocHash: ' + Hash.ToString
                            + #13#10 + ' CountBlocks: ' + ID.ToString
                            + #13#10 + ' HashNewBlocks: ' + Hash1.ToString
                            + #13#10 + ' FCountNewBlocks: ' + FCountNewBlocks.ToString
                            );
                Sleep(1);
              end;
              SetNewBlocks();
              if FValID = FDefaultOrator.ID then
              begin
                // Check Step
                FQuorumList.SetIDStep(5, AClient.IDNode, 1);
                Sleep(1);
              end;
            end
            else
            begin

            end;
          end;
        TNetPacket.tpPing:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpPing'
              + #13#10 + 'Tm: ' + FormatDateTime('yyyy.mm.dd hh:nn:ss.zzz', NetPacketPing(NetPacket)));
          end;
        TNetPacket.tpCheckTx:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpCheckTx');
          end;
        TNetPacket.tpCheckRx:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpCheckRx');
          end;
      end;
//      NetPacket.Clear;
    end;
  except
    on e: Exception do
    begin
      DoLog('TConsensusCore.ReceiveData','AClient.IDNode[' + AClient.IDNode.ToString + ']: ');
      DoLog('TConsensusCore.ReceiveData','AClient.IDNode[' + AClient.IDNode.ToString + ']: '
            + #13#10 + '   NetPacket.PacketType: ' + NetPacket.PacketType.ToString
            + #13#10 + e.Message);
      Msg2(' *** Err. TConsensusCore.ReceiveData AClient.IDNode[' + AClient.IDNode.ToString + ']: '
            + #13#10 + '   *****   '
            + #13#10 + '   AData: ' + BytesToHexStr(AData)
            + #13#10 + '   NetPacket.PacketType: ' + NetPacket.PacketType.ToString
            + #13#10 + e.Message
            + #13#10 + '   *****   ');
//      NetPacket.Clear;
    end;
  end;
  FCS.Leave;
end;

end.
