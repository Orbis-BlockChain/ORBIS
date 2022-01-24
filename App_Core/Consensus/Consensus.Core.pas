unit Consensus.Core;

interface

uses
  System.Classes,
  System.SysUtils
  ,App.Config
  ,Wallet.Core
  ,BlockChain.Core
  ,UI.Abstractions
  ,App.IHandlerCore
  ,App.Types

  ,App.Packet
  ,Net.Core
  ,Net.IClient
  ,Net.Client
  ,Net.ConnectedClient

  , System.SyncObjs, System.Generics.Collections

  // ,System.Hash

  ,Consensus.Types
  ,Consensus.Logic
  ,Consensus2.Core
  ;
const
  SIZE_BLOCK_HEADER = 30;

type
  TConsensusCore = class(TConsensusCore2);

  // TNodeConnect = procedure (AClient: IClient) of object;
  // TPubKey = TPubKey2;

  // TValidator = record
  // IDAccount: UINT64;
  // IDOM: UINT64;
  // Client: TNetCore;
  //
  // end;

  TValInf = TNodeInf;
  TOratorInf = TNodeInf;

  TListIDValOnline = TArrayOfUInt64;

  TConsensusCore1 = class
  const
    TIMEOUT = 20000;
    ORATOR_TIMEOUT = 15000;
    TIMEOUT_IDITERATION = 2000;
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
    FValID: UInt64;
    FPrK: TPrivKey;
    FPbK: TPubKey;

    FFlagRespBlock: Boolean;

    FServerIPv4: String;
    FServerPort: Word;
    FTimeStart: TDateTime;
    // FValidator: TValidator;

    FDefaultOrator: TOratorInf;
    FOratorInf: TOratorInf;
    FNewOratorInf: TOratorInf;
    FIDIteration: UInt64;
    FMainChainCount: UInt64;
    FLastTmIDIter: TDateTime;
    FListIDOnLineVal: TListIDVal;
    FEnableValList: TListIDVal;
    FConsensusLogic: TConsensusLogic;
    FArrayTXData: TArrayTXData; // <<<<<<<<<< >>>>>>>>>
    FTXData: TTXData;
    FNewBlocks: TBytes;
    FCountNewBlocks: UInt64;

    FActive: Boolean;
    FEnable: Boolean;
    // FValidators: TArray<TValidator>;
    FValidators: TListVal;

    FCheckNetTime: TDateTime;

    procedure Msg(const AData: string);
    procedure Msg2(const AData: string);

    procedure SetValID(AValID: UInt64);

    procedure SetActive(AValue: Boolean); virtual;
    function GetActive: Boolean;

    procedure SetEnable(AValue: Boolean); virtual;
    function GetEnable: Boolean;

    procedure SetOratorInf(AValue: TOratorInf); virtual;
    function GetOratorInf: TOratorInf;

    procedure SetIDIteration(AValue: UInt64);
    function GetIDIteration: UInt64;

    function GetOratorStatus(): Boolean;

    procedure DoActive();
    function GetOMs: TArray<UInt64>;
    function ThisNodeInfo(): TValInf;
    procedure AutoConnect();
    function NewOrator(AState: Boolean = False): TOratorInf;
    function CurentOrator: TOratorInf;
    function AddValToList(): Integer;
    function GetPbKFromBC(AID: UInt64): TPubKey;
    function GetIterationInfo(const AIDIteration: UInt64 = 0): TIteration;
    function GetIterDataFromBC(const AID: UInt64; ASetSign: Boolean = False): TIteration;
    procedure Reconnect(Sender: TObject; AClient: Tclient);

    { fnNetPacket }
    function ToPacket(AData: TBytes): TBytes;
    function NetPacketNope(AData: Integer): TNetPacket; overload;
    function NetPacketNope(ANetPacket: TNetPacket): Integer; overload;

    function NetPacketNodeConnect(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketNodeConnect(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketNodeReconnect(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketNodeReconnect(ANetPacket: TNetPacket): TNodeInf; overload;

    function NetPacketGetNodeEnable(ANetPacket: TNetPacket): UInt64; overload;
    function NetPacketGetNodeEnable(AID: UInt64 = 0): TNetPacket; overload;
    function NetPacketNodeEnable(ANetPacket: TNetPacket): Boolean; overload;
    function NetPacketNodeEnable(ANodeEnable: Boolean = False): TNetPacket; overload;

    function NetPacketIDIteration(AData: TNetPacket): UInt64; overload;
    function NetPacketIDIteration(AIDIter: UInt64 = 0): TNetPacket; overload;
    function NetPacketNextIteration(AData: TNetPacket): UInt64; overload;
    function NetPacketNextIteration(AIDIter: UInt64 = 0): TNetPacket; overload;
    function NetPacketGetIterationInfo(AData: TNetPacket): UInt64; overload;
    function NetPacketGetIterationInfo(AIDIter: UInt64 = 0): TNetPacket; overload;
    function NetPacketIterationInfo(AData: TNetPacket): TIteration; overload;
    function NetPacketIterationInfo(AData: TIteration): TNetPacket; overload;

    function NetPacketGetNodeInfo(AIDNode: UInt64 = 0): TNetPacket; overload;
    function NetPacketGetNodeInfo(AData: TNetPacket): UInt64; overload;
    function NetPacketNodeInfo(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketNodeInfo(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketNodeInfoID(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketNodeInfoID(ANodeInf: TNodeInf): TNetPacket; overload;

    function NetPacketOratorInfo(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketOratorInfo(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketNewOratorInfo(ANetPacket: TNetPacket): TNodeInf; overload;
    function NetPacketNewOratorInfo(ANodeInf: TNodeInf): TNetPacket; overload;
    function NetPacketGetOratorInfo: TNetPacket;

    function NetPacketGetTransaction(ACount: Word = 0): TNetPacket; overload;
    function NetPacketGetTransaction(ANetPacket: TNetPacket): Word; overload;
    function NetPacketTransaction(AData: TBytes = []): TNetPacket; overload;
    function NetPacketTransaction(ANetPacket: TNetPacket): TBytes; overload;

    function NetPacketBlock(ACnt: UInt64 = 0; AData: TBytes = []): TNetPacket; overload;
    function NetPacketBlock(ANetPacket: TNetPacket; ACnt: UInt64 = 0): UInt64; overload;
    function NetPacketBlock(ANetPacket: TNetPacket; AData: TBytes = []): TBytes; overload;

    function NetPacketValList(AData: TListIDVal): TNetPacket; overload;
    function NetPacketValList(ANetPacket: TNetPacket): TListIDVal; overload;

    function NetPacketEnableValList(AData: TListIDVal): TNetPacket; overload;
    function NetPacketEnableValList(ANetPacket: TNetPacket): TListIDVal; overload;
    function NetPacketGetEnableValList(AID: UInt64 = 0): TNetPacket; overload;
    function NetPacketGetEnableValList(AData: TNetPacket): UInt64; overload;

    function NetPacketPing(AData: TNetPacket): TDateTime; overload;
    function NetPacketPing(AIDIter: TDateTime): TNetPacket; overload;

    function NetPacketCheckTx(AData: TNetPacket): TDateTime; overload;
    function NetPacketCheckTx(AIDIter: TDateTime): TNetPacket; overload;

    function NetPacketCheckRx(AData: TNetPacket): TDateTime; overload;
    function NetPacketCheckRx(AIDIter: TDateTime): TNetPacket; overload;

    function ReceiveTransaction(AIDNode: UInt64; AData: TBytes): Integer;
    function TransactionToBytes(ACnt: Integer = 0): TBytes;

    procedure NewIteration(AIDIter: UInt64);
    function GetValList(): TListIDVal;
    function GetOnLineValList(): TListIDVal;
    function GetEnableValList: TListIDVal;

    function GetLastBlock: UInt64;
    procedure EventConsensus(AEvent: TEvent);
    procedure EventConsensusTimeout(AEvent: TEvent);
    procedure EventMsg(AEvent: TEvent);

    function SetIteration(const AIDIter: UInt64; const ATXCount: Integer; AHash: THash32): TIteration;
    procedure BeginIteration(AData: Boolean);
    procedure EndIteration(AData: Boolean);

    procedure DoDisconnect(AClient: Tclient);
    procedure DoDisconnect2(AClient: TConnectedClient);


    procedure RequestGetBlock(AClient: IClient); //EventEndDownloadBlocks
    procedure RequestGetBlock2(AClient: TClient); // EventEndDownloadBlocks

    function ReceiveBlock(AClient: IClient; ANetPacket: TNetPacket): Integer;
    procedure SendToAllClient(AData: TBytes);
    function SendToAllValidators(AData: TBytes): TListIDVal;
    function SendToClient(AClient: IClient; AData: TBytes): Integer;
    function SendToOrator(AData: TBytes): Integer;
    function SendToDefaultOrator(AData: TBytes): Integer;

    procedure SetDefaultOrator;
    function ReceiveTX(AIDNode: UInt64; ANetPacket: TNetPacket): Integer;
    procedure GetBlock2;
    function GetMainLastblocHash: THash32;
    procedure SetNewBlocks();
  public
    // constructor Create(ANetCore: TNetCore; ABlockChain: TBlockChainCore;
    // AWalletCore: TWalletCore; AUICore: TBaseUI);
    constructor Create(ANetCore: TNetCore; ABlockChain: TBlockChainCore; AWalletCore: TWalletCore; AUICore: TBaseUI; AConfig: TConfig;
      AHandlerCore: IBaseHandler);
    destructor Destroy; override;

    property ValID: UInt64 read FValID write SetValID;
    property ServerIPv4: String read FServerIPv4 write FServerIPv4;
    property ServerPort: Word read FServerPort write FServerPort;
    property Validators: TListVal read FValidators write FValidators;
    function CheckValidator: Boolean;

    property Active: Boolean read GetActive write SetActive;
    property Enable: Boolean read GetEnable write SetEnable;
    property Orator: Boolean read GetOratorStatus;
    property OratorInf: TOratorInf read GetOratorInf write SetOratorInf;
    property IDIteration: UInt64 read GetIDIteration write SetIDIteration;

    procedure ReceiveData(AClient: IClient; AData: TBytes);
    procedure ReceiveDataR(AClient: IClient; AData: TBytes);

    
    function ConnectToValidator(ANodeInfo: TNodeInf): Integer;

    procedure EventConnect(AClient: TClient1);
    procedure EventDisconnect(AClient: TClient1);
    procedure EventEndDownloadBlocks(AValue: Boolean);
    // property BlockChain: TBlockChainCore read FBlockChain write FBlockChain;
    // property UI: TBaseUI read FUICore write FUICore;
    // property NetCore: TNetCore read FNetCore write FNetCore;
    // property WalletCore: TWalletCore read FWalletCore write FWalletCore;
  end;

var
  _CS: TCriticalSection;

implementation

{ TConsensusCore }
{$REGION 'TConsensusCore'}

procedure TConsensusCore1.RequestGetBlock(AClient: IClient);
var
  packet: TPacket;
begin
  FCS2.Enter;
  if not FFlagRespBlock then
  begin
    try
      packet.CreatePacket(CMD_REQUEST_GET_BLOCK_V2, FBlockChain.Inquiries.MainChainCount);
  //    FCSRespBlock.Enter;
    except
      FCS2.Leave;
      Exit;
    end;
    try
      AClient.SendMessage(packet);
    except
      on e: Exception do
      begin
        Msg2('   ***   ERROR TConsensusCore.RequestGetBlock: ' + e.Message);
      end;
    end;
    FFlagRespBlock:= True;
    FCS2.Leave;
  end;
end;

procedure TConsensusCore1.RequestGetBlock2(AClient: TClient);
var
  packet: TPacket;
begin
  FCS2.Enter;
  if not FFlagRespBlock then
  begin
    try
      packet.CreatePacket(CMD_REQUEST_GET_BLOCK_V2, FBlockChain.Inquiries.MainChainCount);
  //    FCSRespBlock.Enter;
    except
      FCS2.Leave;
      Exit;
    end;
    try
      AClient.SendMessage(packet);
    except
      on e: Exception do
      begin
        Msg2('   ***   ERROR TConsensusCore.RequestGetBlock2: ' + e.Message);
      end;
    end;
    FFlagRespBlock:= True;
    FCS2.Leave;
  end;
end;

procedure TConsensusCore1.SendToAllClient(AData: TBytes);
begin
  with FNetCore do
  for var i:= 0 to Length(ConnectedClients) - 1 do
  begin
    try
      if (ConnectedClients[i] <> nil) and Assigned(ConnectedClients[i]) {and (ConnectedClients[i].SocketIP <> '127.0.0.1')} then
        if (ConnectedClients[i].IDNode = 0)
          or (Validators.IndexOfID(ConnectedClients[i].IDNode) < 0)
          or ((Validators.IndexOfID(ConnectedClients[i].IDNode) >= 0)
              and (not Validators.ValidatorOfID(ConnectedClients[i].IDNode).Enable)
             )
        then
          ConnectedClients[i].SendMessage(AData);
    except
      on e: Exception do
      begin
        Msg2('   ***   ERROR TConsensusCore.SendToAllClient: ' + e.Message);
      end;
    end;
  end;
end;

procedure TConsensusCore1.EventConnect(AClient: TClient1);
begin
  if CheckValidator then
  if (AClient.IDNode > 0) then
  if (Validators.IndexOfID(AClient.IDNode) >= 0) then
  begin
//    if AClient.IDNode = OratorInf.ID then
//    TThread.Queue(nil,
//                  procedure
//                  begin
//                    RequestGetBlock2(AClient);
//                  end);
//    Sleep(1500);
    AClient.SendMessage(ToPacket(NetPacketNodeConnect(ThisNodeInfo).ToBytes));
//    AClient.SendMessage(ToPacket(NetPacketGetOratorInfo().ToBytes));
    Sleep(50);
  end;
end;

procedure TConsensusCore1.EventDisconnect(AClient: TClient1);
var
 IterInfo1: TIteration;
 TXData: TTXData;
begin
  if CheckValidator then
  begin
    Msg2(' *** TConsensusCore.EventDisconnect: ' + AClient.IDNode.ToString );
    if (AClient.IDNode > 0) then
    if (Validators.IndexOfID(AClient.IDNode) >= 0) then
    begin
      if (AClient.IDNode = OratorInf.ID) then
      begin
//        EventConsensus(False);
      end
      else
      begin
        if Orator then
        begin
          if not FArrayTXData.Hash.IsEmpty then
          begin
            IterInfo1.Clear;
            IterInfo1.ID:= FConsensusLogic.IDIter;
            TXData.SetData(AClient.IDNode,IDIteration,[]);
            FArrayTXData.Add(TXData);
            FConsensusLogic.ReceiveIterationData(AClient.IDNode, IterInfo1);
            if not FArrayTXData.Hash.IsEmpty then
            begin
              ReceiveTX(AClient.IDNode,NetPacketTransaction([])); //????????????????
            end;
          end
        end;
      end;
    end;
  end;
end;

procedure TConsensusCore1.EventEndDownloadBlocks(AValue: Boolean);
begin
  if CheckValidator then
  begin
  //  FCSRespBlock.Leave;
    Msg2(#13#10 + '**********************'
       + #13#10 + 'EventEndDownloadBlocks' + IDIteration.ToString
       + #13#10 + '**********************'
       + #13#10);
    FFlagRespBlock:= False;
    FIDIteration:= GetLastBlock();
    FMainChainCount:= GetLastBlock();
    if (AValue) then
    begin
      if not Orator then
      begin
        if IDIteration < FConsensusLogic.Iteration.IDLastBlock then
        begin
          GetBlock2();
        end
        else
        begin
          SendToOrator(NetPacketGetOratorInfo().ToBytes);
//          SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
          Sleep(100);
          Msg2('1 *********** Enable ***********');
          Enable:= True;
//          OratorInf:= FNewOratorInf;
        end;
    //    SendToOrator();
      end
      else
      begin
//        OratorInf:= NewOrator(True); //????
        SendToOrator(NetPacketGetOratorInfo().ToBytes);
      end;
    end
    else
    begin
      Enable:= False;
    end;
  end;
end;

procedure TConsensusCore1.GetBlock2();
var
  Packet: TPacket;
begin
  FCS.Enter;
  try
    if (not Orator) then
    begin
      TThread.Queue(nil,
                    procedure
                    begin
//                      RequestGetBlock2(FNetCore.MainClient);
                      RequestGetBlock2(Validators.ValidatorOfID(OratorInf.ID).Client);
                    end);
      Sleep(500);
    end;  
//    if Length(FNewBlocks) > SIZE_BLOCK_HEADER then
//    begin
//      if not Orator then
//      begin
//        FBlockChain.Inquiries.SetNewBlocks(FNewBlocks);
//      end;
//      Packet.CreatePacket(CMD_RESPONSE_GET_NEW_BLOCKS,FNewBlocks);
////          FNetCore.SendAll(Packet);
//      TThread.Queue(nil,
//                    procedure
//                    begin
//                      SendToAllClient(Packet);
//                    end);
//      Sleep(500);
//      FNewBlocks:= [];
//    end;
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR FNetCore.SendAll: ' + e.Message);
    end;
  end;
  FCS.Leave;
end;

procedure TConsensusCore1.SetNewBlocks();
var
  Packet: TPacket;
begin
  FCS.Enter;
  try
    if not Orator then
    begin
      Msg2('         FBlockChain.Inquiries.SetNewBlocks: BEGIN');
      try
        FBlockChain.Inquiries.SetNewBlocks(FNewBlocks);
        Msg2('         FBlockChain.Inquiries.SetNewBlocks: END');
      except
        on e: Exception do
        begin
          Msg2('         FBlockChain.Inquiries.SetNewBlocks: EROR: ' + e.Message);
          FCountNewBlocks:= 0;
          FNewBlocks:= [];
          Exit;
        end;
      end;
    end;
    if FCountNewBlocks > 0 then
    begin
      Packet.CreatePacket(CMD_RESPONSE_GET_NEW_BLOCKS,FNewBlocks);

      FNewBlocks:= [];
      TThread.Queue(nil,
                    procedure
                    begin
                      SendToAllClient(Packet);
//                      GetBlock2();
                    end);
    end;
    FCountNewBlocks:= 0;
  except

  end;
  FCS.Leave;
//          FNetCore.SendAll(Packet);
end;

procedure TConsensusCore1.EventConsensus(AEvent: TEvent);
var
  Hash: THash32;
  bln: Boolean;
  Packet: TPacket;
begin
  Msg2('<<<========= CONSENSUS =========>>>');
  Msg2('   OratorInf:' + OratorInf.ToString);
  if (AEvent.TypeEvent = AEvent.teBool) then
  begin
    bln:= AEvent;
    if bln then
    begin
      Msg2('<<<======= Consensus TRUE =======>>>');
      // Write data to block chain
//      GetBlock2();
    end
    else
    begin
      Msg2('<<<======= Consensus FALSE =======>>>');
//      GetBlock2();
    end;
    FIDIteration:= GetLastBlock();
    FMainChainCount:= GetLastBlock();
    if not Orator then
    if IDIteration < FConsensusLogic.Iteration.IDLastBlock then
      GetBlock2();
//      SetNewBlocks();
    if Orator then
    begin
      FNewOratorInf:= NewOrator(True);
      Msg2('FNewOratorInf: ' + FNewOratorInf);
      SendToAllValidators(NetPacketNewOratorInfo(FNewOratorInf).ToBytes);
      Sleep(500);
      OratorInf:= FNewOratorInf;
//      IDIteration:= GetLastBlock();
//      SendToAllValidators(NetPacketNextIteration(IDIteration).ToBytes);
    end
    else
    begin
      Sleep(2000);
      OratorInf:= FNewOratorInf;
    end;

    EndIteration(bln);
//    OratorInf:= FNewOratorInf;
//    BeginIteration(bln);
  end;
  Msg2('  ===>>>>  OratorInf:' + OratorInf.ToString);
end;

procedure TConsensusCore1.EndIteration(AData: Boolean);
var
  Hash: THash32;
begin
//  FCS.Enter;
  FTXData.Clear;
  if (FNewOratorInf.ID <> 0) and (AData) then
  begin
//    OratorInf:= FNewOratorInf;
//    if Orator then
//      FNewOratorInf:= NewOrator();
  end
  else
  begin
//    FNewOratorInf:= FDefaultOrator;
//    OratorInf:= FNewOratorInf
  end;
//  FCS.Leave;
end;


procedure TConsensusCore1.EventConsensusTimeout(AEvent: TEvent);
begin
  Msg2('<<<========= CONSENSUS TIMEOUT =========>>>');
  // EndIteration(AEvent);
//  FDefaultOrator.TimeReceive:= Now();
  FIDIteration:= GetLastBlock();
  FMainChainCount:= GetLastBlock();
  FNewOratorInf:= FDefaultOrator;

//  if not Orator then
//    GetBlock2();
//  Sleep(500);
//  FOratorInf:= FDefaultOrator;
  EndIteration(AEvent);
  Enable:= True;
  OratorInf:= FDefaultOrator;
//  SendToOrator(NetPacketGetOratorInfo().ToBytes);
  Msg2('  OratorInf: ' + OratorInf);
  Msg2('  DefaultOrator: ' + FDefaultOrator);
  Msg2('1 <<<<<<************ BeginIteration ************>>>>>>' );
  BeginIteration(False);
end;

function TConsensusCore1.GetLastBlock(): UInt64;
begin
  FCS2.Enter;
  // get from BC
//  Result:= FIDIteration + 1;
  Result:= 0;
  try
    Result:= FBlockChain.Inquiries.MainChainCount;
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR TConsensusCore.GetLastBlock: ' + e.Message);
    end;
  end;
  FCS2.Leave;
end;

procedure TConsensusCore1.EventMsg(AEvent: TEvent);
begin
  Msg2(AEvent);
end;

procedure TConsensusCore1.NewIteration(AIDIter: UInt64);
begin
  FConsensusLogic.NewIteration(AIDIter, GetEnableValList());
end;


function TConsensusCore1.GetMainLastblocHash(): THash32;
begin
  Result.Clear;
  FCS2.Enter;
  try
    Result:= THash32(TBytes(FBlockChain.Inquiries.GetMainLastblocHash));
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR TConsensusCore.GetLastBlock: ' + e.Message);
    end;
  end;
  FCS2.Leave;
end;

procedure TConsensusCore1.BeginIteration(AData: Boolean);
var
  Hash: THash32;
  TXData: TTXData;
  ListIDVal,ListIDValOnLine: TListIDVal;
  cnt: Integer;
begin
  Msg2('<<<<<<************ BeginIteration ************>>>>>>' );
  if IDIteration = 0 then
  begin
    Msg2('2 *********** Enable ***********');
    Enable:= False;
    Active:= False;
    Exit;
  end;
  Sleep(100);
  Msg2('           >>> FCS3');
  if FCS3.TryEnter then
  begin
    Msg2('           >>> FCS3.TryEnter');
    try
      if AData then
      begin
        Hash:= GetMainLastblocHash();
      end
      else
      begin
        Hash:= FConsensusLogic.Iteration.HashCurrentBlock;
      end;
      // if FValID = FNewOratorInf.ID then
      if Orator then
//      if FValID = FDefaultOrator.ID then
      begin
        // OratorInf:= FNewOratorInf;
    //    if FIDIteration > GetLastBlock() then
    //    begin
    //      FNewOratorInf:= OratorInf;
    //    end
    //    else
    //    begin
    //      FNewOratorInf:= NewOrator();
    //    end;

    //    IDIteration:= GetLastBlock();
    //    Validators.SendData(ToPacket(NetPacketNewOratorInfo(FNewOratorInf).ToBytes));
        Sleep(100);
        try
          Validators.CheckOnline;
          ListIDVal.Clear;
          ListIDVal:= GetOnLineValList();
          ListIDVal.IDIter:= IDIteration;
          ListIDValOnLine.Clear;
          ListIDValOnLine:= GetOnLineValList();
          ListIDValOnLine.IDIter:= IDIteration;
          if (ListIDVal <> ListIDValOnLine) then
          begin
            Validators.SendData(ToPacket(NetPacketGetNodeEnable().ToBytes));
            Sleep(100);
            ListIDValOnLine.Clear;
            ListIDValOnLine:= GetEnableValList();
            ListIDValOnLine.IDIter:= IDIteration;
          end;
          FListIDOnLineVal:= ListIDValOnLine;
          FEnableValList:= GetEnableValList();
          cnt:= 0;
          while (not FEnableValList.Exists(FValID)) and (cnt < 4) do
          begin
            Enable:= True;
            Sleep(500);
            FEnableValList:= GetEnableValList();
            Msg2('3 *********** Enable ***********');
            Inc(cnt);
          end;
        except
          on e: Exception do
          begin
            Msg2('** ERROR ListIDVal:= GetEnableValList(): ' + e.Message);
          end;
        end;
        Msg2('BeginIteration ListIDVal: ' + FEnableValList.ToString);
        try
          FConsensusLogic.NewIteration(IDIteration, FEnableValList);
        except
          on e: Exception do
          begin
            Msg2('ERROR FConsensusLogic.NewIteration:' + e.Message);
          end;
        end;
        Sleep(100);
        try
          FArrayTXData.Init(FValID, IDIteration, Hash, FEnableValList);
        except
          on e: Exception do
          begin
            Msg2('ERROR FArrayTXData.Init: ' + e.Message);
          end;
        end;
        Sleep(100);
        try
          {
          if (ListIDValOnLine.Exists(FValID)) then
            FTXData.SetData(FValID, IDIteration, TransactionToBytes())
          else
            FTXData.SetData(FValID, IDIteration, []);
          }
          FTXData.SetData(FValID, IDIteration, []);
          FArrayTXData.Add(FTXData);
          Sleep(100);
    //      Validators.SendData(ToPacket(NetPacketEnableValList(ListIDValOnLine).ToBytes));
    //      if ListIDValOnLine.Count <> 0 then
          ListIDVal:= SendToAllValidators(NetPacketEnableValList(FEnableValList).ToBytes);
          if ListIDVal.Count >= 0 then
          begin
            Msg2(' +++ SendToAllValidators OK cnt: ' + ListIDVal.ToString);
          end
          else
          begin
            Msg2(' --- SendToAllValidators NO cnt: ' + ListIDVal.ToString);
          end;
          Sleep(100);
        except
          on e: Exception do
          begin
            Msg2('   ***   ERROR: ' + e.Message);
          end;
        end;
      end
      else
      begin
        Sleep(1000);
//        if not FFlagRespBlock then
//          SendToOrator(NetPacketGetOratorInfo().ToBytes);
//          SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
    //    Sleep(1000);
        SendToOrator(NetPacketGetEnableValList().ToBytes);
      end;
    except

    end;
  end
  else
  begin
    Msg2('           >>> FCS3.TryEnter FALSE');
  end;
  FCS3.Leave;
  Msg2('           >>> FCS3.Leave');
end;

function GenIter(): TIteration;
begin

end;

function TConsensusCore1.GetIterDataFromBC(const AID: UInt64; ASetSign: Boolean = False): TIteration;
var
  ID: UInt64;
  TXCount: Integer;
  IDCurrentBlock, IDFirstBlock, IDLastBlock: UInt64;

  HashCurrentBlock, HashFirstBlock, HashLastBlock: THash32;

  CountVal, CountValOnLine: Integer;
  ListIDValOnline, ListIDValOn: TListIDVal;
begin
  Result.Clear;

  // *****************
  // *****************
  // *****************
  // FBlockChain.Inquiries.MainChainCount
  // *****************
  // *****************
  // *****************
  ID:= AID;
  TXCount:= 0;
  IDCurrentBlock:= ID;
  IDFirstBlock:= ID + 1;
  IDLastBlock:= IDFirstBlock + TXCount;

  HashCurrentBlock.Clear;
  HashCurrentBlock.SetHash([0]);

  HashFirstBlock.Clear;
  HashLastBlock.Clear;
  CountVal:= 0;
  CountValOnLine:= 0;

  ListIDValOnline.Clear;
  ListIDValOn.Clear;
  Result.SetData(ID, TXCount, IDCurrentBlock, IDFirstBlock, IDLastBlock, HashCurrentBlock, HashFirstBlock, HashLastBlock, CountVal, CountValOnLine,
    ListIDValOnline, ListIDValOn);

//  if ASetSign then
//    Result.SetSign(FValID, FPrK); // sign data
end;

function TConsensusCore1.GetIterationInfo(const AIDIteration: UInt64 = 0): TIteration;
begin
  if (AIDIteration = 0) or (AIDIteration = IDIteration) then
  begin
    // Result:= GetIterDataFromBC(AIDIteration);
    Result:= GetIterDataFromBC(IDIteration);
  end
  else
  begin
    Result:= GetIterDataFromBC(AIDIteration);
  end;
end;

{$REGION 'fnNetPacket'}

function TConsensusCore1.NetPacketNope(AData: Integer): TNetPacket;
var
  b: TBytes;
begin
  SetLength(b, SizeOf(AData));
  Move(AData, b[0], SizeOf(AData));
  Result.SetPacket(TNetPacket.tpNope, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketNope(ANetPacket: TNetPacket): Integer;
begin
  Result:= Result.MinValue;
  if (ANetPacket.PacketType = TNetPacket.tpNope) then
  begin
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
  end;
end;

function TConsensusCore1.NetPacketNodeConnect(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNodeConnect, ANodeInf.ToBytes);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketNodeConnect(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNodeConnect then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketNodeReconnect(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNodeReconnect, ANodeInf.ToBytes);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketNodeReconnect(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNodeReconnect then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketGetNodeEnable(AID: UInt64 = 0): TNetPacket;
var
  b: TBytes;
begin
  Result.Clear;
  // if ANodeEnable then
  // Result.SetPacket(TNetPacket.tpNodeEnable,[100])
  // else
  // Result.SetPacket(TNetPacket.tpNodeEnable,[200]);
  SetLength(b, SizeOf(AID));
  Move(AID, b[0], SizeOf(AID));
  Result.SetPacket(TNetPacket.tpGetNodeEnable, b);
  Result.IDIter:= IDIteration;
//  Result.SignPacket(FValID, FPrK);
end;

function TConsensusCore1.NetPacketGetNodeEnable(ANetPacket: TNetPacket): UInt64;
begin
  if (ANetPacket.PacketType = TNetPacket.tpGetNodeEnable) then
  begin
    // if ANetPacket.Data[0] = 100 then
    // Result:= True;
    // if ANetPacket.Data[0] = 200 then
    // Result:= False;

    Move(ANetPacket.Data[0], Result, SizeOf(Result));
  end;
end;
function TConsensusCore1.NetPacketNodeEnable(ANodeEnable: Boolean = False): TNetPacket;
var
  b: TBytes;
begin
  Result.Clear;
  // if ANodeEnable then
  // Result.SetPacket(TNetPacket.tpNodeEnable,[100])
  // else
  // Result.SetPacket(TNetPacket.tpNodeEnable,[200]);
  SetLength(b, SizeOf(ANodeEnable));
  Move(ANodeEnable, b[0], SizeOf(ANodeEnable));
  Result.SetPacket(TNetPacket.tpNodeEnable, b);
  Result.IDIter:= IDIteration;
//  Result.SignPacket(FValID, FPrK);
end;

function TConsensusCore1.NetPacketNodeEnable(ANetPacket: TNetPacket): Boolean;
begin
  if (ANetPacket.PacketType = TNetPacket.tpNodeEnable) then
  begin
    // if ANetPacket.Data[0] = 100 then
    // Result:= True;
    // if ANetPacket.Data[0] = 200 then
    // Result:= False;

    Move(ANetPacket.Data[0], Result, SizeOf(Result));
  end;
end;

function TConsensusCore1.NetPacketIDIteration(AIDIter: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz:= SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpIDIteration, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketIDIteration(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpIDIteration then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore1.NetPacketNextIteration(AIDIter: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz:= SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpNextIteration, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketNextIteration(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpNextIteration then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore1.NetPacketGetIterationInfo(AIDIter: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz:= SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpGetIterationInfo, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketGetIterationInfo(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpGetIterationInfo then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore1.NetPacketIterationInfo(AData: TIteration): TNetPacket;
begin
  Result.Clear;
  Result.SetPacket(TNetPacket.tpIterationInfo, AData.ToBytes);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketIterationInfo(AData: TNetPacket): TIteration;
begin
  Result.Clear;
  if AData.PacketType = AData.tpIterationInfo then
    Result:= AData.Data;
end;

function TConsensusCore1.NetPacketGetNodeInfo(AIDNode: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
  IDNode: UInt64;
begin
  if AIDNode = 0 then
    IDNode:= FValID
  else
    IDNode:= AIDNode;
  Result.Clear;
  sz:= SizeOf(AIDNode);
  SetLength(b, sz);
  Move(AIDNode, b[0], sz);
  Result.SetPacket(TNetPacket.tpGetNodeInfo, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketGetNodeInfo(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpGetNodeInfo then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore1.NetPacketNodeInfo(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNodeInfo, ANodeInf.ToBytes);
  Result.IDIter:= IDIteration;
  // Result.SignPacket(FValID,FPrK);
end;

function TConsensusCore1.NetPacketNodeInfo(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNodeInfo then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketNodeInfoID(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNodeInfoID, ANodeInf.ToBytes);
  Result.IDIter:= IDIteration;
  // Result.SignPacket(FValID,FPrK);
end;

function TConsensusCore1.NetPacketNodeInfoID(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNodeInfoID then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketOratorInfo(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpOratorInfo, ANodeInf.ToBytes);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketOratorInfo(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpOratorInfo then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketNewOratorInfo(ANodeInf: TNodeInf): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpNewOratorInfo, ANodeInf.ToBytes);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketNewOratorInfo(ANetPacket: TNetPacket): TNodeInf;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpNewOratorInfo then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketGetOratorInfo(): TNetPacket;
begin
  Result.Clear;
  Result.SetPacket(TNetPacket.tpGetOratorInfo, [0]);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketGetTransaction(ANetPacket: TNetPacket): Word;
begin
  Result:= 0;
  if ANetPacket.PacketType = ANetPacket.tpGetTransaction then
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
end;

function TConsensusCore1.NetPacketGetTransaction(ACount: Word = 0): TNetPacket;
var
  b: TBytes;
begin
  Result.Clear;
  SetLength(b, SizeOf(ACount));
  Move(ACount, b[0], SizeOf(ACount));
  Result.SetPacket(TNetPacket.tpGetTransaction, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketTransaction(AData: TBytes = []): TNetPacket;
begin
  Result.Clear;
  Result.SetPacket(TNetPacket.tpTransaction, AData);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketTransaction(ANetPacket: TNetPacket): TBytes;
begin
  Result:= [];
  if ANetPacket.PacketType = ANetPacket.tpTransaction then
  begin
    SetLength(Result, ANetPacket.DataSize);
    Move(ANetPacket.Data[0], Result[0], ANetPacket.DataSize);
  end;
end;

function TConsensusCore1.NetPacketBlock(ACnt: UInt64 = 0;AData: TBytes = []): TNetPacket;
begin
  Result.Clear;
  Result.SetPacket(TNetPacket.tpBlock, ACnt.ToBytes + AData);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketBlock(ANetPacket: TNetPacket; ACnt: UInt64): UInt64;
begin
  Result:= 0;
  if ANetPacket.PacketType = ANetPacket.tpBlock then
  begin
    Move(ANetPacket.Data[0], Result, SizeOf(Result));
  end;
end;

function TConsensusCore1.NetPacketBlock(ANetPacket: TNetPacket; AData: TBytes): TBytes;
begin
  Result:= [];
  if ANetPacket.PacketType = ANetPacket.tpBlock then
  begin
    SetLength(Result, ANetPacket.DataSize - SizeOf(UInt64));
    Move(ANetPacket.Data[SizeOf(UInt64)], Result[0], ANetPacket.DataSize - SizeOf(UInt64));
  end;
end;

function TConsensusCore1.NetPacketValList(AData: TListIDVal): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpValList, AData.ToBytes);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketValList(ANetPacket: TNetPacket): TListIDVal;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpValList then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketEnableValList(AData: TListIDVal): TNetPacket;
begin
  Result.SetPacket(TNetPacket.tpEnableValList, AData.ToBytes);
  Result.IDIter:= IDIteration;
//  Result.SignPacket(FValID, FPrK);
end;

function TConsensusCore1.NetPacketEnableValList(ANetPacket: TNetPacket): TListIDVal;
begin
  Result.Clear;
  if ANetPacket.PacketType = ANetPacket.tpEnableValList then
    Result:= ANetPacket.Data;
end;

function TConsensusCore1.NetPacketGetEnableValList(AID: UInt64 = 0): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz:= SizeOf(AID);
  SetLength(b, sz);
  Move(AID, b[0], sz);
  Result.SetPacket(TNetPacket.tpGetEnableValList, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketGetEnableValList(AData: TNetPacket): UInt64;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpGetEnableValList then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore1.NetPacketPing(AIDIter: TDateTime): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz:= SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpPing, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketPing(AData: TNetPacket): TDateTime;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpPing then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore1.NetPacketCheckTx(AIDIter: TDateTime): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz:= SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpCheckTx, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketCheckTx(AData: TNetPacket): TDateTime;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpCheckTx then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

function TConsensusCore1.NetPacketCheckRx(AIDIter: TDateTime): TNetPacket;
var
  b: TBytes;
  sz: Integer;
begin
  Result.Clear;
  sz:= SizeOf(AIDIter);
  SetLength(b, sz);
  Move(AIDIter, b[0], sz);
  Result.SetPacket(TNetPacket.tpCheckRx, b);
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.NetPacketCheckRx(AData: TNetPacket): TDateTime;
var
  b: TBytes;
  sz: Integer;
begin
  Result:= 0;
  if AData.PacketType = TNetPacket.tpCheckRx then
  begin
    sz:= SizeOf(Result);
    Move(AData.Data[0], Result, sz);
  end;
end;

{$ENDREGION 'fnNetPacket'}

function TConsensusCore1.GetPbKFromBC(AID: UInt64): TPubKey;
begin
  // *************************************
  // *************************************
  // *************************************
  Result:= sPbK;
  // Result:= FBlockChain.Inquiries.
  // *************************************
  // *************************************
  // *************************************
end;

function TConsensusCore1.GetValList: TListIDVal;
var
  i, n: Integer;
begin
  Result.Clear;
  n:= Validators.Count;
  for i:= 0 to Pred(n) do
  begin
    Result.Add(Validators.Items[i].ValInf.ID);
  end;
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.GetOnLineValList: TListIDVal;
var
  i, n: Integer;
begin
  Result.Clear;
  n:= Validators.Count;
  for i:= 0 to Pred(n) do
    if (Validators.Items[i].Online) then
//      if (Validators.Items[i].ValInf.TimeReceive + 1/24/60/60/1000 * ORATOR_TIMEOUT < Now()) then
        Result.Add(Validators.Items[i].ValInf.ID);
end;

function TConsensusCore1.GetEnableValList: TListIDVal;
var
  i, n: Integer;
begin
  Result.Clear;
  n:= Validators.Count;
  for i:= 0 to Pred(n) do
    if ((Validators.Items[i].Client <> nil)
//      and (Validators.Items[i].Online)
//      and (Validators.Items[i].Enable)
      ) //or (Validators.Items[i].ValInf.ID = FValID)
    then
      Result.Add(Validators.Items[i].ValInf.ID);
  Result.IDOrator:= OratorInf.ID;
  Result.IDIter:= IDIteration;
end;

function TConsensusCore1.AddValToList(): Integer;
var
  i, n: Integer;
  aOMs: TArray<UInt64>;
  Val: TValidator;
begin
  Result:= 0;
  aOMs:= GetOMs;
  n:= Length(aOMs);
  for i:= 0 to Pred(n) do
  begin
    if FValidators.IndexOfID(aOMs[i]) < 0 then
    begin
      Val.Clear;
      Val.ValInf.ID:= aOMs[i];
      // Val.ValInf.NetAddr:=
      Val.PbK:= GetPbKFromBC(aOMs[i]);
      FValidators.Add(Val);
    end;
  end;
  Result:= n;
end;

function TConsensusCore1.CheckValidator: Boolean;
var
  i,n: Integer;
  aOMs: TArray<UInt64>;
begin
  Result:= False;
  if (FValID > 0) and ((NodeState = Validator) or (NodeState = Speaker) or (ParamStr(1) = 'init')) then
  begin
    try
      aOMs:= GetOMs;
      n:= Length(aOMs);
      for i:= 0 to Pred(n) do
      if FValID = aOMs[i] then
      begin
        Result:= True;
        Break;
      end;
    except

    end;
  end;
end;

function TConsensusCore1.ConnectToValidator(ANodeInfo: TNodeInf): Integer;
var
  Validator: TValidator;
begin
  // FCS.Enter;
  Result:= -1;
  if (ANodeInfo.ID = 0) and (ANodeInfo.NetAddr.IsEmpty) then
    Exit;

  Validator:= Validators.ValidatorOfID(ANodeInfo.ID);
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
      Validator.ValInf:= ANodeInfo;
      Validator.Online:= False;
//      Validator.Enable:= False;
      try
        Validator.Client:= FNetCore.ConnectToValidator(ANodeInfo.ID, ANodeInfo.NetAddr.ToIPv4, ANodeInfo.NetAddr.Port);
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
            Validator.Online:= True;
            // Validator.Enable:= True;
            Result:= Validators.IndexOfID(ANodeInfo.ID);
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
        Validator.Online:= False;
//        Validator.Enable:= False;
      end;
      Validator.CheckOnlineTime:= Now();
      Validators.Update(Validator);
      Sleep(10);
    end
    else
    begin
      if (Validator.Client <> nil) and (Validator.Client.Connected) then
      begin      
        Validator.Online:= True; 
        Validators.Update(Validator);
      end;
      Result:= Validators.IndexOfID(ANodeInfo.ID);
    end;
  end;
  // FCS.Leave;
end;

constructor TConsensusCore1.Create(ANetCore: TNetCore; ABlockChain: TBlockChainCore; AWalletCore: TWalletCore; AUICore: TBaseUI; AConfig: TConfig;
  AHandlerCore: IBaseHandler);
var
  i, n: Integer;
  aOMs: TArray<UInt64>;
  Val: TValidator;
  NetAddr: TNetAddr;
begin
//  _CS.Enter;
  FCS:= TCriticalSection.Create;
  FCS2:= TCriticalSection.Create;
  FCS3:= TCriticalSection.Create;
  FCSRespBlock:= TCriticalSection.Create;
  FFlagRespBlock:= False;
  FTimeStart:= Now();

  FNetCore:= ANetCore;
  FNetCore.OnDisconnectE2:= DoDisconnect2;
  FBlockChain:= ABlockChain;
  FWalletCore:= AWalletCore;
  FUICore:= AUICore;
  FConfig:= AConfig;
  FHandlerCore:= AHandlerCore;

  FIDIteration:= 0;
  FMainChainCount:= GetLastBlock();
  FLastTmIDIter:= 0;

  // ***********************************************
  // ***********************************************
  // ***********************************************
  FValID:= WalletID;
  FPrK:= sPrK;
  FPbK:= sPbK;
  // ***********************************************
  // ***********************************************
  // ***********************************************

  FValidators:= TListVal.Create(FValID);
  // FValidator.Clear;
  // FValidator.TimeStamp:= FTimeStart;
  // FValidator.ID:= FValID;
  // FValidator.Enable:=

  // aOMs:= GetOMs;
  // n:= Length(aOMs);
  // for i:=0 to Pred(n) do
  // begin
  // Val:= Val.Empty;
  /// /    Val.Num:= i;
  // Val.ValInf.ID:= aOMs[i];
  /// /    Val.IDOM:= 0;
  /// /    Val.NetAddr:= '';
  // Val.PbK:= TPubKey.Empty;
  //
  /// /    Val.Online:= False;
  // FValidators.Add(Val);
  // end;

  // Msg(ClassName + ' create');

  // Msg('NodeInfo: ' + ThisNodeInfo.ToString);
  // FUICore.ShowMessage('TConsensusCore create');

  // NetAddr:= '10.10.10.10:1000';
  // Msg('NetAddr: ' + NetAddr.ToString);
  // NetAddr.Clear;
  // Msg('NetAddr: ' + NetAddr.ToString);
  // NetAddr:= '127.255.255.0:10000';
  // Msg('NetAddr: ' + NetAddr.ToString);

{$REGION 'TEST'}
  // Msg('HASH: ' + BytesToHexStr(GetHash(TEncoding.UTF8.GetBytes('111'))));
  // Msg('HASH: ' + BytesToHexStr(GetHash(TEncoding.UTF8.GetBytes('222'))));
  {
    var list,list2: TArrayOfUInt64;
    var b: TBytes;
    list.add(11111);
    list.add(22222);
    list.add(44444);
    list.add(11111);
    list.add(88888);
    list.add(55555);
    list.add(33333);
    b:= list;
    Msg('List: ' + list.ToString);
    list.Clear;
    list2:= b;
    Msg('List: ' + list.ToString);
    Msg('List2: ' + list2.ToString);
    var iter,iter2: Titeration;
    var hash: THash32;
    hash.SetHash([1,2,3]);
    //  iter.ID:= 111;
    //  Iter.TXCount:= 222;
    //  iter.IDCurrentBlock:= 333;
    //  iter.IDFirstBlock:= 444;
    //  iter.IDLastBlock:= 555;
    //  iter.HashCurrentBlock.SetHash([1,1,1]);
    //  iter.HashFirstBlock.SetHash([2,2,2]);
    //  iter.HashLastBlock.SetHash([3,3,3]);
    iter:= SetIteration(0,25,hash);
    //  iter.HashCurrentBlock.SetHash(TEncoding.UTF8.GetBytes('111'));
    //  iter.HashFirstBlock.SetHash(TEncoding.UTF8.GetBytes('222'));
    //  iter.HashLastBlock.SetHash(TEncoding.UTF8.GetBytes('333'));
    //  iter.CountVal:= 8;
    //  iter.CountValOnLine:= 6;
    //  iter.ListIDValOnline:= list2;
    //  iter.SetSign(FValID,FPrK);
    Msg('iter1: ' + iter.ToString);
    b:= iter;
    //  iter.Clear;
    iter2:= b;
    Msg('iter2: ' + iter2.ToString);
    Msg('iter1: ' + BytesToHexStr(iter.ToBytes));
    Msg('iter2: ' + BytesToHexStr(iter2.ToBytes));
    if (iter = iter2) then
    Msg('iter = iter2')
    else
    Msg('iter <> iter2');
  }
{$ENDREGION 'TEST'}
{$REGION 'TEST ConsensusLogic'}
  {
    var j,x: Integer;
    var ListIdVal: TListIDVal;
    var iter: TIteration;
    var IDIter: UInt64;
    IDIter:= 101;
    ListIdVal.Clear;

    n:= 1;
    for i:= 1 to n do
    begin
    ListIdVal.add(i*10);
    end;

    x:= 10;
    for j:= 0 to x do
    begin
    //  ListIdVal.add(10);
    //  ListIdVal.add(20);
    //  ListIdVal.add(30);
    iter:= GetIterDataFromBC(IDIter);
    iter.SetSign(FValID,sPrk);
    FConsensusLogic.NewIteration(IDIter,ListIdVal);
    FConsensusLogic.Iteration:= iter;

    //  iter.TXCount:= 1;
    for i:= 1 to n do
    begin
    iter.SetSign(i*10,sPrk);
    FConsensusLogic.ReceiveIterationData(i*10,iter);
    end;
    //    iter.SetSign(FValID,sPrk);
    //    FConsensusLogic.Iteration:= iter;
    Sleep(100);
    end;

    //  iter.SetSign(10,sPrk);
    //  FConsensusLogic.ReceiveIterationData(iter);
    //  iter.SetSign(20,sPrk);
    //  FConsensusLogic.ReceiveIterationData(iter);
    //  iter.SetSign(30,sPrk);
    //  FConsensusLogic.ReceiveIterationData(iter);
  }
{$ENDREGION 'TEST ConsensusLogic'}
{$REGION 'TEST TArrayTXData'}
  {
    var ArrayTXData: TArrayTXData;
    var iter: TIteration;
    var ListIdVal: TListIDVal;
    var TXData: TTXData;
    var IDIter: UInt64;
    IDIter:= 10;
    iter:= GetIterDataFromBC(IDIter);
    ListIdVal.add(10);
    ListIdVal.add(20);
    ArrayTXData.Init(FValID,IDIter,iter.HashCurrentBlock,ListIdVal);
    TXData.IDNode:= 10;
    TXData.IDIter:= IDIter;
    TXData.TX:= TransactionToBytes();
    TXData.TX:= [1,2,3];
    ArrayTXData.Add(TXData);
    TXData.IDNode:= 20;
    TXData.TX:= TransactionToBytes();
    TXData.TX:= [1,2,3];
    ArrayTXData.Add(TXData);
    ArrayTXData.SetSign(FValID,sPrk);
    Msg2(' *** TEST ArrayTXData.Hash.ToString: ' + ArrayTXData.Hash.ToString);
    Msg2(' *** TEST ArrayTXData.Sign.ToString: ' + ArrayTXData.Sign.ToString);
  }
{$ENDREGION 'TEST TArrayTXData'}
end;

destructor TConsensusCore1.Destroy;
begin
  FActive:= False;
  FCS.Enter;
  // FValidators:= [];
  FValidators.Free;
  FCS.Leave;
  FCSRespBlock.Free;
  FCS3.Enter;
  FCS3.Leave;
  FCS3.Free;
  FCS2.Free;
  FCS.Free;
  inherited;
//  _CS.Leave;
end;

function TConsensusCore1.GetOMs: TArray<UInt64>;
begin
  FCS2.Enter;
  try
    
    Result:= FBlockChain.Inquiries.GetOMs;
  except
    on e: Exception do
    begin
      Msg2('   ***   ERROR TConsensusCore.GetOMs: ' + e.Message);
    end;
  end;
  FCS2.Leave;  
end;

function TConsensusCore1.GetOratorStatus: Boolean;
begin
  Result:= FOratorInf.ID = FValID;
end;

procedure TConsensusCore1.Msg(const AData: string);
begin
{$IFDEF CONSOLEI}
  try
    if FUICore.ShowMessage <> nil then
      FUICore.ShowMessage(AData)
    else
    begin
      TThread.Queue(nil,
//      TThread.Synchronize(nil,
        procedure
        begin
          Writeln(FormatDateTime('  [hh:nn:ss.zzz] >> ', Now()) + AData);
        end);
    end;
  except
    TThread.Queue(nil,
//    TThread.Synchronize(nil,
      procedure
      begin
        Writeln(FormatDateTime('  [hh:nn:ss.zzz] >> ', Now()) + AData);
      end);
  end;
{$ENDIF}
end;

procedure TConsensusCore1.Msg2(const AData: string);
begin
  {$IFDEF DEBUG}
  Msg(AData);
  {$ENDIF}
end;

function TConsensusCore1.ToPacket(AData: TBytes): TBytes;
var
  Packet: TPacket;
begin
  Packet.CreatePacket(40, AData);
  Result:= Packet;
end;

procedure TConsensusCore1.AutoConnect();
var
  NetPacket: TNetPacket;
  i: Integer;
  Validator: TValidator;
begin
  if Validators.IndexOfID(FValID) >= 0 then
  begin
    Validator.Clear;
    i:= Validators.IndexOfID(FValID);
    Validator:= Validators.Items[i];
    Validator.ValInf.NetAddr:= ServerIPv4 + ':' + ServerPort.ToString;
//    Validator.ValInf.NetAddr:= '127.0.0.1:' + ServerPort.ToString;
    Validator.Online:= True;
    Validators.Items[i]:= Validator;

    Validator.Client:= FNetCore.ConnectToValidator(FValID, Validator.ValInf.NetAddr.ToIPv4, Validator.ValInf.NetAddr.Port);
    if (Validator.Client <> nil) then
    begin
      Validator.Enable:= True;
      Validators.Update(Validator);
      // NetPacket.SetPacket(TNetPacket.tpNodeConnect, ThisNodeInfo().ToBytes);
      // Validator.Client.SendMessage(ToPacket(NetPacket.ToBytes));

      // NetPacket:= NetPacketNodeConnect(ThisNodeInfo());
      // Validator.Client.SendMessage(ToPacket(NetPacket.ToBytes));
    end;
    Validators.Update(Validator);
  end;
end;

function TConsensusCore1.SendToClient(AClient: IClient; AData: TBytes): Integer;
begin
  try
    Result:= AClient.SendMessage(ToPacket(AData));
  except
    on e: Exception do
    begin
      Msg2(' *** Err. SendToClient[' + AClient.IDNode.ToString + ']: ' + e.Message);
    end;
  end;
end;
  
function TConsensusCore1.SendToAllValidators(AData: TBytes): TListIDVal;
var
  i, n, j: Integer;
  Validator: TValidator;
begin
  Result.Clear;
  n:= Validators.Count;
  for i:= 0 to Pred(n) do
  begin
    Validator:= Validators.Items[i];
    if (not Validator.ValInf.NetAddr.IsEmpty)
    // and (Validator.ID <> FValID)
    // and (Validator.Online)
      and (Validator.Client <> nil) and (Validator.Client.Connected)
    then
    begin
      j:= -1;
      try
        j:= Validator.Client.SendMessage(ToPacket(AData));
      except
        on e: Exception do
        begin
          Msg(' *** Err. SendToAllValidators[' + i.ToString + ']: ' + e.Message);
        end;
      end;
      if j >= 0 then
      begin
        Validator.Online:= True;
        Result.Add(Validator.ID);
      end
      else
      begin
        Validator.Online:= False;
        // Validator.Enable:= False;
      end;
      Validator.CheckOnlineTime:= Now();
      Validators.Update(Validator);
    end;
  end;
end;

function TConsensusCore1.SendToOrator(AData: TBytes): Integer;
var
  Val: TValidator;
begin
  Result:= -1;
  Result:= Validators.SendDataToID(OratorInf.ID,ToPacket(AData));
  if Result < 0 then
  begin
    Val:= Validators.ValidatorOfID(OratorInf.ID);
    Val.Online:= False;
    Validators.Update(Val);
//    OratorInf:= NewOrator(True);
  end
  else
  begin
    Val:= Validators.ValidatorOfID(OratorInf.ID);
    Val.Online:= True;
    Validators.Update(Val);
  end;
end;

function TConsensusCore1.SendToDefaultOrator(AData: TBytes): Integer;
var
  Val: TValidator;
begin
  Result:= -1;
  Result:= Validators.SendDataToID(FDefaultOrator.ID,ToPacket(AData));
  if Result < 0 then
  begin
    Val:= Validators.ValidatorOfID(FDefaultOrator.ID);
    Val.Online:= False;
    Validators.Update(Val);
  end
  else
  begin
    Val:= Validators.ValidatorOfID(OratorInf.ID);
    Val.Online:= True;
    Validators.Update(Val);
  end;
end;

procedure TConsensusCore1.ReceiveDataR(AClient: IClient; AData: TBytes);
begin
  TThread.Queue(nil,
            procedure
            begin  
              ReceiveDataR(AClient,AData);
            end);
end;

procedure TConsensusCore1.ReceiveData(AClient: IClient; AData: TBytes);
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
  Hash: THash32;
  sIDIter: UInt64;

  function SendToClient(AData: TBytes): Integer;
  begin
    Result:= Self.SendToClient(AClient,AData);
  end;
  procedure MsgNodeInf(ANodeInf: TNodeInf; AInfo: string);
  begin
    Msg2('[' + AClient.IDNode.ToString + '] ' + AInfo
        + #13#10 + '   Validators.IndexOfID: ' + Validators.IndexOfID(ANodeInf.ID).ToString
        + #13#10 + '   ID: ' + ANodeInf.ID.ToString
        + #13#10 + '   NetAddr: ' + ANodeInf.NetAddr.ToString
        + #13#10 + '   tm: ' + FormatDateTime('dd.mm.yy hh:nn:ss.zzz', ANodeInf.TimeStamp)
        + #13#10 + '   IDIteration: ' + ANodeInf.IDIteration.ToString
        );
  end;

begin
  FCheckNetTime:= Now();
  if not CheckValidator then
    Exit;
  FCS.Enter;
  try

    sIDIter:= 0;
    if (Length(AData) >= 9) and (Length(AData) <= 14) then
      Msg2(' *** Length(Adata) AClient.IDNode[' + AClient.IDNode.ToString + ']: ');
    try
      NetPacket:= AData;
      sIDIter:= NetPacket.IDIter;
    except
      on e: Exception do
      begin
        SetLength(b, 20);
        Move(AData[0], b[0], 20);
        Msg2(' *** Err. TConsensusCore.ReceiveData AClient.IDNode[' + AClient.IDNode.ToString + ']: '
           + #13#10 + '   *****   ' + #13#10 + '   b: ' + Length(AData).ToString
           + #13#10 + '   AData: ' + BytesToHexStr(b)
           + #13#10 + e.Message
           + #13#10 + '   *****   '
           );
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
      NetPacket1:= NetPacketNope(0);
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
            NetPacket1:= NetPacketNodeConnect(ThisNodeInfo);
            NetPacket1.SignPacket(FValID, FPrK);
            SendToClient(NetPacket1.ToBytes);
          end;
        TNetPacket.tpNodeConnect: // CONNECT
          begin
            AddValToList();
            NodeInfo:= NetPacketNodeConnect(NetPacket);
            CheckSign2:= NodeInfo.CheckSign(Validators.PbKOfID(NodeInfo.ID));
            if (NodeInfo.ID = 0) then
            begin
              SendToClient(NetPacketNope(0).ToBytes);
            end
            else
            begin
              NodeInfo.TimeReceive:= Now();
              if (IDIteration < NodeInfo.IDIteration) then
              begin
                RequestGetBlock(AClient);
              end;

              if (AClient.IDNode = 0)
//                  and (CheckSign2)
//                  and (NodeInfo.ID = NodeInfo.Sign.IDKey) 
              then
              begin
                AClient.IDNode:= NodeInfo.ID;
              end;

              if (FDefaultOrator.NetAddr = NodeInfo.NetAddr) then
              begin
                FDefaultOrator:= NodeInfo;
                Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeInfo' 
                    + #13#10 + '   ***   DefaultOrator: ' + FDefaultOrator.ToString
                    + #13#10 + '   ***   ');
              end;
//              if FOratorInf.IsEmpty then
//                FOratorInf:= FDefaultOrator;
              if FOratorInf.IsEmpty then
                FOratorInf:= NodeInfo;

              i:= ConnectToValidator(NodeInfo);
              if i >= 0 then
              begin
                Msg2(' *** [' + AClient.IDNode.ToString + '] '
                  + 'ConnectToValidator: OK [' + i.ToString + ']');
//                Validators.CheckTx(AClient.IDNode);
//                Validators.SendDataToID(AClient.IDNode,ToPacket(NetPacketCheckTx(Now()).ToBytes));
              end
              else
              begin
                Msg2(' *** [' + AClient.IDNode.ToString + '] ' + 'ConnectToValidator: NO [' + i.ToString + ']');
              end;
              SetDefaultOrator();

              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeConnect');
              Sleep(1);

//              if IDIteration > NodeInfo.IDIteration then
//              begin
//                SendToClient(NetPacketIDIteration(IDIteration).ToBytes);
//              end;

//              SendToClient(NetPacketNodeInfo(ThisNodeInfo).ToBytes);
//              Sleep(1);
              SendToClient(NetPacketNodeEnable(Enable).ToBytes);
              Sleep(100);
  //            if not Orator then
  //            begin
  //              NetPacket1:= NetPacketOratorInfo(OratorInf);
  //              SendToClient(NetPacket1.ToBytes);
  //              Sleep(100);
  //            end;
              for i:= 0 to Pred(Validators.Count) do
              begin
                if (Validators.Items[i].ValInf.ID <> FValID)
                  and (Validators.Items[i].ValInf.ID <> 0)
                  and (Validators.Items[i].ValInf.ID <> NodeInfo.ID)
                  and (not Validators.Items[i].ValInf.NetAddr.IsEmpty)
//                  and (Validators.Items[i].CheckTxRx = TValidator.chTxRx_GOOD)
                then
                begin
                  NetPacket1:= NetPacketNodeInfoID(Validators.Items[i].ValInf);
                  SendToClient(NetPacket1.ToBytes);
                  Sleep(100);
                end;
              end;
              if (AClient.IDNode = OratorInf.ID)
                and (OratorInf.ID = FDefaultOrator.ID)
                and (FConsensusLogic.IDIter <> IDIteration)
              then
              else
              begin
                BeginIteration(False);
                Sleep(100);
              end;
            end;
            MsgNodeInf(NodeInfo, 'NetPackt.PacketType: tpNodeConnect');
          end;
        TNetPacket.tpNodeReconnect:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeReconnect');
            // **********************
            NodeInfo:= NetPacketNodeReconnect(NetPacket);
            NodeInfo.TimeReceive:= Now();
          end;
        TNetPacket.tpGetNodeEnable:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeEnable');
            if AClient.IDNode <> FValID then
              SendToClient(NetPacketNodeEnable(Enable).ToBytes);
            Sleep(500);
          end;
        TNetPacket.tpNodeEnable:
          begin
            if AClient.IDNode <> FValID then
            begin
              Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeEnable');
              if AClient.IDNode <> 0 then
              begin
                sEnable:= NetPacketNodeEnable(NetPacket);
                // Validators.Items[AClient.IDNode].pEnable:= sEnable;
                if sEnable then
                  Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeEnable' + ' TRUE ')
                else
                  Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeEnable' + ' FALSE ');

                // Validators.ValidatorOfID(AClient.IDNode).pEnable:= sEnable;
                Validator:= Validators.ValidatorOfID(AClient.IDNode);
//                Validator.Online:= sEnable;
                Validator.Enable:= sEnable;
                Validators.Update(Validator);

                if (Orator) and (AClient.IDNode <> FValID) {and (not sEnable)} then
                begin
                  IterInfo1.Clear;
                  IterInfo1.ID:= FConsensusLogic.IDIter;
                  TXData.SetData(AClient.IDNode,IDIteration,[]);
                  FArrayTXData.Add(TXData);
                  FConsensusLogic.ReceiveIterationData(AClient.IDNode, IterInfo1);
                  if not FArrayTXData.Hash.IsEmpty then
                  begin
                    ReceiveTX(FValID,NetPacketTransaction([]));
                  end;
                end
                else
                begin
                  if (sEnable) then
                  begin

                  end;
                end;
              end;

            end;
          end;
        TNetPacket.tpGetNodeInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeInfo');
            ID:= NetPacketGetNodeInfo(NetPacket);
            if ID = 0 then
            begin
              NodeInfo1:= ThisNodeInfo();
              NetPacket1:= NetPacketNodeInfo(NodeInfo1);
              SendToClient(NetPacket1.ToBytes);
              Sleep(500);
            end
            else
            begin
              if (Validators.IndexOfID(ID) >= 0) then
              begin
                NetPacket1:= NetPacketNodeInfoID(Validators.ValidatorOfID(ID).ValInf);
                SendToClient(NetPacket1.ToBytes);
                Sleep(500);
              end;
            end;
          end;
        TNetPacket.tpNodeInfo:
          begin
            // NodeInfo:= NetPacket.Data;
            NodeInfo:= NetPacketNodeInfo(NetPacket);
            CheckSign2:= NodeInfo.CheckSign(Validators.PbKOfID(NodeInfo.ID));
            MsgNodeInf(NodeInfo, 'NetPackt.PacketType: tpNodeInfo');
            NodeInfo.TimeReceive:= Now();

//            if (IDIteration > NodeInfo.IDIteration) then
//            begin
//              SendToClient(NetPacketIDIteration(IDIteration).ToBytes);
//            end;
//
//            if (IDIteration < NodeInfo.IDIteration) then
//            begin
//              Enable:= False;
//              RequestGetBlock(AClient);
//            end;

            if (IDIteration = NodeInfo.IDIteration) then
            begin
//              Enable:= False;
              if (FOratorInf.IsEmpty) and (not NodeInfo.IsEmpty) then
                OratorInf:= NodeInfo;
            end;

            // if FDefaultOrator.IsEmpty then
            // begin
            // FDefaultOrator:= NodeInfo;
            // Msg('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetNodeInfo'
            // +#13#10 + 'FDefaultOrator: ' + FDefaultOrator.ToString);
            // end;

            if (not NodeInfo.IsEmpty) and (not NodeInfo.NetAddr.IsEmpty) then
            begin
              i:= ConnectToValidator(NodeInfo);
              SetDefaultOrator;
            end;

            // Msg('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeInfo');
            // if AClient.IDNode <> NodeInfo.ID then
            if (AClient.IDNode = 0) and (CheckSign2) and (NodeInfo.ID = NodeInfo.Sign.IDKey) then
            begin
              AClient.IDNode:= NodeInfo.ID;
              // if FOratorInf.ID = 0 then
              // begin
              // CurentOrator();
              // end;
            end;
          end;
        TNetPacket.tpNodeInfoID:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNodeInfoID');

            NodeInfo:= NetPacketNodeInfoID(NetPacket);
            NodeInfo.TimeReceive:= Now();
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
            NetPacket1:= NetPacketValList(GetValList);
            NetPacket1.SignPacket(FValID, FPrK);
            // AClient.SendMessage(ToPacket(NetPacket1.ToBytes));
//            SendToClient(NetPacket1);
          end;
        TNetPacket.tpValList:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpValList.');
            ValList:= NetPacketValList(NetPacket);
            // ************************
          end;
        TNetPacket.tpGetEnableValList:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetEnableValList.');
                Msg2('SendToClient[' + AClient.IDNode.ToString + '] '
                    + #13#10 + ' FEnableValList: ' + FEnableValList.ToString
                    + #13#10
                    );
            ID:= NetPacketGetEnableValList(NetPacket);
            if (Orator) and (AClient.IDNode <> FValID) then
            begin
              if (FEnableValList.Count <> 0) then
              begin
                SendToClient(NetPacketEnableValList(FEnableValList).ToBytes);
                Msg2('SendToClient[' + AClient.IDNode.ToString + '] '
                  + ' FEnableValList: ' + FEnableValList.ToString);
              end
              else
              begin
                if (Orator) then
                begin
//                  Enable:= True;
                  FEnableValList:= GetEnableValList;
                  SendToClient(NetPacketEnableValList(FEnableValList).ToBytes);
                  Msg2('SendToClient[' + AClient.IDNode.ToString + '] '
                      + #13#10 + ' ***************** '
                      + #13#10 + ' FEnableValList: ' + FEnableValList.ToString
                      + #13#10 + ' ***************** '
                      + #13#10
                      );
                end;
              end;
            end
            else
            begin
              if (AClient.IDNode <> FValID) then
              begin
//                SendToClient(NetPacketEnableValList(FEnableValList).ToBytes);
//                SendToClient(NetPacketNewOratorInfo(FNewOratorInf).ToBytes);
//                Sleep(100);
                SendToClient(NetPacketOratorInfo(OratorInf).ToBytes);
              end
              else
              begin  // Orator
//                SendToOrator(NetPacketGetOratorInfo().ToBytes);
//                SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
              end;
            end;
          end;
        TNetPacket.tpEnableValList: // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpEnableValList.');
            ValList:= NetPacketEnableValList(NetPacket);

            Msg2('[' + AClient.IDNode.ToString + '] ' + 'ValList: ' + ValList.ToString);
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'OratorInf: ' + OratorInf.ToString);
            // ************************
            if (AClient.IDNode = OratorInf.ID)
//               and (not Orator)
//               and (ValList.IDOrator = OratorInf.ID)
            then
            begin
              if ValList.Count = 0 then
              begin
                if Orator then
                begin
                  Enable:= True;
                end
                else
                begin
                  SendToOrator(NetPacketGetEnableValList().ToBytes);
                end;
              end
              else
              begin
                if (AClient.IDNode = OratorInf.ID) and (IDIteration < ValList.IDIter) then
                begin
                  TThread.Queue(nil,
                                procedure
                                begin
                                  RequestGetBlock(AClient);
                                end);
                  Sleep(100);
                end
                else
                begin
                  if (ValList.Exists(FValID)) {and (Enable)} then
                  begin
                    FEnableValList:= ValList;
                    if ValList.IDIter = IDIteration then
                    begin
                      IDIteration:= ValList.IDIter;
                      if not Orator then
                        FConsensusLogic.NewIteration(IDIteration, ValList);

                      if (not Orator) then
                        FTXData.SetData(FValID, IDIteration, TransactionToBytes())
                      else
                        FTXData:= FArrayTXData.ItemsOfID[FValID];
                      // FArrayTXData.Init(FValID
                      // ,FIDIteration
                      // ,Hash
                      // ,ValList);
                      // FArrayTXData.Add(TXData);
                      // Sleep(100);
                      if SendToClient(NetPacketTransaction(FTXData.TX).ToBytes) >= 0 then
                        Msg2(' ** SendToClient(TX) OK ** TXData.Len: ' + TXData.Len.ToString)
                      else
                        Msg2(' ** SendToClient(TX) NO ** TXData.Len: ' + TXData.Len.ToString);
                      Sleep(1);
                    end
                    else
                    begin
                      Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpEnableValList.'
                            + #13#10 + '    ***>>>>> ValList.IDIter <> IDIteration'
                            + #13#10 + '    ***>>>>>' + ValList.IDIter.ToString + '<>' + IDIteration.ToString
                            );
                      Enable:= False;
                      SendToClient(NetPacketTransaction([]).ToBytes);
                      IterInfo1.Clear;
                      IterInfo1.ID:= FConsensusLogic.IDIter;
                      SendToClient(NetPacketIterationInfo(IterInfo1).ToBytes);
                      SendToClient(NetPacketGetEnableValList().ToBytes);
                      Sleep(1);
                      if (not Orator) and (ValList.IDIter > IDIteration) then
                      begin
  //                        RequestGetBlock(AClient);
                        TThread.Queue(nil,
                                      procedure
                                      begin
                                        RequestGetBlock(AClient);
                                      end);
                        Sleep(100);
                      end;
                      if (AClient.IDNode = OratorInf.ID) and (ValList.IDIter > IDIteration) then
                      begin

                      end;
                    end;
                  end
                  else
                  begin
                    if (not ValList.Exists(FValID)) then
                    begin
                      if Enable then
                        SendToClient(NetPacketNodeEnable(Enable).ToBytes)
                      else
                        Enable:= True;
                    end;

                    SendToClient(NetPacketTransaction([]).ToBytes);
                    Sleep(10);
                    IterInfo1.Clear;
                    IterInfo1.ID:= FConsensusLogic.IDIter;
                    SendToClient(NetPacketIterationInfo(IterInfo1).ToBytes);
                    Sleep(10);
                    /// ********************************
                  end;
                end;
              end;
            end
            else
            begin
              if (ValList.IDOrator <> OratorInf.ID) and (not Orator) then
              begin
                SendToOrator(NetPacketGetOratorInfo().ToBytes);
//                SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
                Sleep(200);
              end
              else
              begin   // Œ–¿“Œ–
                // œŒƒ”Ã¿“‹....
                FTXData:= FArrayTXData.ItemsOfID[FValID];
                SendToClient(NetPacketTransaction(FTXData.TX).ToBytes);
                if (ValList.Count < 2) and (FDefaultOrator.ID <> FValID) then
                begin
//                  OratorInf:= FDefaultOrator;
                end;
              end;
//                Validators.ValidatorOfID(OratorInf.ID).Client.SendMessage(ToPacket(NetPacketGetOratorInfo().ToBytes));
//              Msg(' ** SendToClient(TX) ** TXData.Len: ' + FTXData.Len.ToString);
//              SendToClient(NetPacketTransaction(FTXData.TX).ToBytes);
            end;
          end;

        TNetPacket.tpGetOratorInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetOratorInfo.');
            if (AClient.IDNode <> FValID) then
            begin
              if (AClient.IDNode = OratorInf.ID) then
              begin
//                NetPacket1:= NetPacketOratorInfo(NewOrator(True));
                NetPacket1:= NetPacketOratorInfo(OratorInf);
//                SendToClient(NetPacket1);
              end
              else
              begin
                NetPacket1:= NetPacketOratorInfo(OratorInf);
                SendToClient(NetPacket1);
              end;
              Sleep(10);
            end
            else
            begin
              if (FDefaultOrator.ID <> FValID ) and (GetEnableValList.Count > 1) then
              begin
                NetPacket1:= NetPacketOratorInfo(FDefaultOrator);
                SendToClient(NetPacket1);
                Sleep(10);
              end
              else
              begin
                NetPacket1:= NetPacketOratorInfo(NewOrator(True));
//                NetPacket1.SignPacket(FValID, FPrK);
                SendToClient(NetPacket1);
                Sleep(10);
              end;
            end;
          end;
        TNetPacket.tpOratorInfo:
          begin
            sOratorInf:= NetPacketOratorInfo(NetPacket);
            sOratorInf.TimeReceive:= Now();
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpOratorInfo.'
                + '[' + sOratorInf.ID.ToString + ' ' + sOratorInf.NetAddr.ToString +  ']');
            // OratorInf:= NetPacket.Data;
            if (sOratorInf.ID > 0)
                and (AClient.IDNode = OratorInf.ID)
//                and (sOratorInf.IDIteration >= IDIteration)
//                and (not Orator)
            then
            begin
              if (sOratorInf.ID = OratorInf.ID) then
              begin
                if (sOratorInf.IDIteration > IDIteration) then
                begin
                  TThread.Queue(nil,
                                procedure
                                begin
                                  RequestGetBlock(AClient);
                                end);
                  Sleep(1);
                end
                else
                begin
                  SendToClient(NetPacketGetEnableValList().ToBytes);
                end;
              end
              else
              begin
                OratorInf:= sOratorInf;
                MsgNodeInf(sOratorInf, 'NetPackt.PacketType: tpOratorInfo');
              end;

//              SendToClient(NetPacketGetEnableValList().ToBytes);
//              SendToOrator(NetPacketGetEnableValList().ToBytes);
            end
            else
            begin
              if (sOratorInf.ID > 0) and (not Orator) then
              begin
//                SendToOrator(NetPacketGetOratorInfo().ToBytes);
//                SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
                Sleep(200);
              end
              else
              begin

              end;
            end;
            
            // NetPacket.SetPacket(TNetPacket.tpGetIterationInfo,[0]);
            // AClient.SendMessage(ToPacket(NetPacket.ToBytes));
          end;
        TNetPacket.tpNewOratorInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpNewOratorInfo.');
            sOratorInf:= NetPacketNewOratorInfo(NetPacket);
            // if not sOratorInf.IsEmpty then
            if (sOratorInf.ID > 0) then
              if (AClient.IDNode = OratorInf.ID)then
              begin
                sOratorInf.TimeReceive:= Now();
                FNewOratorInf:= sOratorInf;
                // OratorInf:= sOratorInf;

                // FIDIteration:= sOratorInf.IDIteration;
                // FOratorInf.TimeStamp:= Now();

                MsgNodeInf(sOratorInf, 'NetPackt.PacketType: tpNewOratorInfo');
              end
              else
              begin
                if (not Orator) then
                begin
                  SendToOrator(NetPacketGetOratorInfo().ToBytes);
                  Sleep(200);
                end;
              end;
          end;

        TNetPacket.tpGetIDIteration:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetIDIteration.');
            NetPacket1:= NetPacketIDIteration(FConsensusLogic.IDIter);
            // NetPacket1.SignPacket(FValID,FPrK);
            SendToClient(NetPacket1.ToBytes);
          end;
        TNetPacket.tpIDIteration:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpIDIteration.');
            ID:= NetPacketIDIteration(NetPacket);
            if (not Orator) and (AClient.IDNode = OratorInf.ID)
            then
            begin
              if (ID = FConsensusLogic.IDIter) then
              begin
//                Enable:= True;
              end
              else
              begin
                if (ID > GetLastBlock()) then
                begin
                  Enable:= False;
                  SendToClient(NetPacketTransaction([]).ToBytes);
                  TThread.Queue(nil,
                                procedure
                                begin
                                  RequestGetBlock(AClient);
                                end);
                  Sleep(1);
                end;
              end;
            end
            else
            begin

            end;
          end;
        TNetPacket.tpNextIteration:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetIDIteration.');
            ID:= NetPacketNextIteration(NetPacket);
            if (AClient.IDNode = OratorInf.ID) then
            begin
              if IDIteration < ID then
              begin
                Enable:= False;
                RequestGetBlock(AClient);
              end
              else
              begin
//                OratorInf:= FNewOratorInf;
              end;
            end
            else
            begin
              if not Orator then
              begin
                SendToOrator(NetPacketGetOratorInfo().ToBytes);
//                SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
                Sleep(200);
              end;
            end;
          end;

        TNetPacket.tpGetIterationInfo:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetIterationInfo.');
            ID:= NetPacketGetIterationInfo(NetPacket);

//            IterInfo:= GetIterationInfo(ID);
            if Orator then
            begin
              IterInfo1:= FConsensusLogic.Iteration;
              // Msg('[' + AClient.IDNode.ToString + '] ' + 'IterInfo.ToHash.ToString: ' + IterInfo.ToHash.ToString);
              // IterInfo.CountVal:= 200;
              // IterInfo.IDCurrentBlock:= 200200;
              // Msg('[' + AClient.IDNode.ToString + '] ' + 'IterInfo.ToHash.ToString: ' + IterInfo.ToHash.ToString);
              NetPacket1:= NetPacketIterationInfo(IterInfo1);
               SendToClient(NetPacket1);
            end
            else
            begin
//              SendToOrator(NetPacketGetOratorInfo().ToBytes);
              SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
              Sleep(200);
            end;
          end;
        TNetPacket.tpIterationInfo:
          begin
            // IterInfo:= NetPacket.Data;
            try
              ID:= NetPacket.IDIter;
              IterInfo:= NetPacketIterationInfo(NetPacket);
            except
              on e: Exception do
              begin
                SetLength(b, 20);
                Msg2(' *** Err. TNetPacket.tpIterationInfo AClient.IDNode[' + AClient.IDNode.ToString + ']: '
                  + #13#10 + '   *****   '
                  + #13#10 + '   b: ' + Length(AData).ToString
                  + #13#10 + '   AData: ' + BytesToHexStr(AData)
                  + #13#10 + '   NetPacket.PacketType: ' + NetPacket.PacketType.ToString
                  + #13#10 + e.Message
                  + #13#10 + '   *****   '
                  );
                NetPacket.Clear;
              end;
            end;
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpIterationInfo.');
            Msg2('[' + AClient.IDNode.ToString + '] '
              + #13#10 + '              IterInfo: ' + IterInfo.ToString
              + #13#10 + '              IterInfo.ToHash: ' + IterInfo.ToHash.ToString
            // + #13#10 + '              BytesToHexStr(IterInfo): ' + BytesToHexStr(IterInfo.ToBytes)
            // + #13#10 + '              BytesToHexStr(NetPacket): ' + BytesToHexStr(NetPacket.ToBytes)
              );
            CheckSign2:= IterInfo.CheckSign(Validators.PbKOfID(IterInfo.IDSign));
            if (not CheckSign2) then
            begin
              if (not CheckSign2) then
                Msg2('*** [' + AClient.IDNode.ToString + '] ' + 'IterInfo.CheckSign: False');
              // Exit;
            end
            else
            begin
              Msg2('*** [' + AClient.IDNode.ToString + '] ' + 'IterInfo.CheckSign: True');
              if AClient.IDNode = OratorInf.ID then
              begin
                if (ID <> IDIteration)  then
                begin
                  Msg2('*** [' + AClient.IDNode.ToString + '] ' + 'IterInfo ID <> IDIteration: False');
                end;
                FConsensusLogic.Iteration:= IterInfo;
                FConsensusLogic.ReceiveIterationData(AClient.IDNode, IterInfo);
              end;
              if (AClient.IDNode <> OratorInf.ID) then
              begin
                try
                  FConsensusLogic.ReceiveIterationData(AClient.IDNode, IterInfo);
                except
                  on e: Exception do
                  begin
                    Msg2('Err.: FConsensusLogic.ReceiveIterationData. Msg: ' + e.Message);
                  end;
                end;
                if (IterInfo.ID = FConsensusLogic.IDIter) then
                begin

                end
                else
                begin
//                  SendToClient(NetPacketGetIterationInfo().ToBytes);
//                  if (IterInfo.ID < FConsensusLogic.IDIter) then
//                    SendToClient(NetPacketIDIteration().ToBytes);
                end;
              end;
            end;
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'IterInfo.ToHash.ToString: ' + IterInfo.ToHash.ToString);
            // Msg('[' + AClient.IDNode.ToString + '] ' + 'IterInfo.ToHash.ToString: ' + IterInfo.Sign.GetData(Validators.PbKOfID(IterInfo.IDSign)));
            // Msg('[' + AClient.IDNode.ToString + '] IterInfo: ' + IterInfo.ToString);
          end;

        TNetPacket.tpGetTransaction:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpGetTransaction');
            if (AClient.IDNode = OratorInf.ID) then
            begin
              // TXData.SetData(FValID,FIDIteration,TransactionToBytes());
              // FArrayTXData.Add(TXData);

              NetPacket1:= NetPacketTransaction(FArrayTXData.ItemsOfID[FValID].TX);
              // NetPacket1:= NetPacketTransaction(FArrayTXData.ItemsOfID(FValID).TX);
              NetPacket1.SignPacket(FValID, FPrK);
              SendToClient(NetPacket1);
              Msg('Send TX, NetPacket1.Size: ' + NetPacket1.Size.ToString + ' b');
            end
            else
            begin
//              if not Orator then
//                SendToOrator(NetPacketGetOratorInfo().ToBytes);
              Sleep(1);
//              Validators.ValidatorOfID(OratorInf.ID).Client.SendMessage(ToPacket(NetPacketGetOratorInfo().ToBytes));
            end;
          end;
        TNetPacket.tpTransaction:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpTransaction');
            ReceiveTX(AClient.IDNode,NetPacket);
          end;
        TNetPacket.tpBlock:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpBlock');
            ReceiveBlock(AClient,NetPacket);
          end;
        TNetPacket.tpPing:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpPing'
              + #13#10 + 'Tm: ' + FormatDateTime('yyyy.mm.dd hh:nn:ss.zzz', NetPacketPing(NetPacket)));
            if OratorInf.ID = AClient.IDNode then
            begin

            end;
          end;
        TNetPacket.tpCheckTx:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpCheckTx');
            Validators.CheckRx(AClient.IDNode);
            Validators.SendDataToID(AClient.IDNode,ToPacket(NetPacketCheckRx(Now()).ToBytes));
          end;
        TNetPacket.tpCheckRx:
          begin
            Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpCheckRx');
            Validators.CheckRx(AClient.IDNode);
          end;
      end;
      NetPacket.Clear;
    end;
  except
    on e: Exception do
    begin
      SetLength(b, 20);
      Move(AData[0], b[0], 20);
      Msg2(' *** Err. TConsensusCore.ReceiveData AClient.IDNode[' + AClient.IDNode.ToString + ']: ' + #13#10 + '   *****   ' + #13#10 + '   b: ' +
        Length(AData).ToString + #13#10 + '   b: ' + BytesToHexStr(b) + #13#10 + '   AData: ' + BytesToHexStr(AData) + #13#10 +
        '   NetPacket.PacketType: ' + NetPacket.PacketType.ToString + #13#10 + e.Message + #13#10 + '   *****   ');
      NetPacket.Clear;
    end;
  end;

  FCS.Leave;
end;

function TConsensusCore1.ReceiveTX(AIDNode: UInt64; ANetPacket: TNetPacket): Integer;
var
  TXData: TTXData;
  Hash: THash32;
  IterInfo1: TIteration;
  i: Integer;  
begin
  Msg2('[' + AIDNode.ToString + '] ' + 'Receive TX, NetPacket.Size: ' + ANetPacket.Size.ToString + ' b');
  // i:= ReceiveTransaction(NetPacketTransaction(NetPacket));
  // if FValID = FOratorInf.ID then
  // if Orator then

  // if OratorInf.ID = AClient.IDNode then
  // begin
  // i:= ReceiveTransaction(AClient.IDNode, NetPacketTransaction(NetPacket));
  // FArrayTXData.Add(TXData);
  // end
  // else
  // if (AClient.IDNode <> OratorInf.ID) then
  if Orator then
  begin
    if AIDNode <> FValID then
    begin
      TXData.SetData(AIDNode, IDIteration, NetPacketTransaction(ANetPacket));
      FArrayTXData.Add(TXData);
    end;
    if (not FArrayTXData.Hash.IsEmpty) then
    begin
      Msg2('[' + AIDNode.ToString + '] ' + 'FArrayTXData.Hash: ' + FArrayTXData.Hash.ToString);
      // FArrayTXData.SetSign(FValID,FPrK);
      Hash.Clear;
      FCS2.Enter;
      try
        i:= FBlockChain.Inquiries.MainChainCount;
        IterInfo1.SetData( i
                          ,0
                          ,i
                          ,i + 1
                          ,0
                          ,THash32(TBytes(FBlockChain.Inquiries.GetMainLastblocHash))
                          ,THash32.Empty
                          ,Hash
                          ,0
                          ,0
                          ,TListIDVal.Empty
                          ,FEnableValList
                          );
      except
        on e: Exception do
        begin
          Msg2('   ***   ERROR TNetPacket.tpTransaction: ' + e.Message);
        end;
      end;
      try
        for var z := 0 to Length(FArrayTXData.Data) - 1 do
          if (Length(FArrayTXData.Data[z].TX) > 0) then
            FBlockChain.Inquiries.SetAllCacheTrx(FArrayTXData.Data[z].TX);

        // Œ◊»“—“»“‹ FArrayTXData !!!!!!!!!
        FArrayTXData.Clear;
      except
        on e: Exception do
        begin
          Msg2('********************************************************'
              + #13#10 + '   ***   ERROR TNetPacket.tpTransaction: ' + e.Message
              + #13#10 + '********************************************************');
        end;
      end;
      var countBlocks: uint64; // ÓÎË˜ÂÒÚ‚Ó ·ÎÓÍÓ‚
      countBlocks:= 0;
      try
        if FBlockChain.Inquiries.CountCacheBlock > 0 then
          FBlockChain.Inquiries.ApproveAllCachedBlocks(FWalletCore.CurrentWallet,countBlocks);
        FCountNewBlocks:= countBlocks;
      except
        on e: Exception do
        begin
          Msg2('********************************************************'
              + #13#10 + '   ***   ERROR FBlockChain.Inquiries.ApproveAllCachedBlocks: ' + e.Message
              + #13#10 + '********************************************************'
              );
        end;
      end;
//                var DataForSend: Tbytes;
//                if countBlocks > 0 then
//                  DataForSend:= FBlockChain.Inquiries.GetBlocksFrom(FBlockChain.Inquiries.MainChainCount - countBlocks)
//                else
//                  DataForSend:= [];
      try
        FNewBlocks:= FBlockChain.Inquiries.GetBlocksFrom(FBlockChain.Inquiries.MainChainCount - countBlocks);
        Hash.SetHash(FNewBlocks);
        IterInfo1.TXCount:= FCountNewBlocks;
        IterInfo1.HashLastBlock:= Hash;
//                IterInfo1.SetSign(FValID,FPrK);
        FIDIteration:= GetLastBlock();
        FMainChainCount:= GetLastBlock();
        var LastBlockHash:= FBlockChain.Inquiries.GetMainLastblocHash;
      except
        on e: Exception do
        begin
          Msg2('   ***   ERROR FNewBlocks: ' + e.Message);
        end;
      end;
      FCS2.Leave;
      FConsensusLogic.Iteration:= IterInfo1;
//                NetPacket1:= NetPacketIterationInfo(IterInfo1);
//                NetPacket1.IDIter:= FIDIteration;
//                SendToAllValidators(NetPacket1.ToBytes);

      SendToAllValidators(NetPacketIterationInfo(IterInfo1).ToBytes);
      Sleep(1);

      SendToAllValidators(NetPacketBlock(FCountNewBlocks,FNewBlocks).ToBytes);
      Sleep(1);

      Msg2('[' + AIDNode.ToString + '] '
          + #13#10 + '              IterInfo1: ' + IterInfo1.ToString 
          + #13#10 + '              IterInfo1.ToHash: ' + IterInfo1.ToHash.ToString
      // + #13#10 + '              BytesToHexStr(IterInfo1): ' + BytesToHexStr(IterInfo1.ToBytes)
      // + #13#10 + '              BytesToHexStr(NetPacket1): ' + BytesToHexStr(NetPacket1.ToBytes)
        );

    end;
  end
  else
  begin
    SendToOrator(NetPacketGetOratorInfo().ToBytes);
//    SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
    Sleep(200);
//    SendToClient(AClient,NetPacketNewOratorInfo(FNewOratorInf).ToBytes);
//    Sleep(100);
//    SendToClient(AClient,NetPacketOratorInfo(OratorInf).ToBytes);
//    Sleep(100);
  end

end;

function TConsensusCore1.ReceiveBlock(AClient: IClient; ANetPacket: TNetPacket): Integer;
var
  Hash: THash32;
  IterInfo1: TIteration; 
  i: Integer; 
begin
  if (AClient.IDNode = OratorInf.ID) and (ANetPacket.IDIter = IDIteration) then
  begin
    FCountNewBlocks:= NetPacketBlock(ANetPacket,0);
    FNewBlocks:= NetPacketBlock(ANetPacket,[]);
    Hash.SetHash(FNewBlocks);

//              ID:= FBlockChain.Inquiries.MainChainCount;
//              Hash:= TBytes(FBlockChain.Inquiries.GetMainLastblocHash);
//              FBlockChain.Inquiries.CountCacheBlock;
//              FBlockChain.Inquiries.GetMainLastblocHashFromID(0);
    FCS2.Enter;
    try
      i:= FBlockChain.Inquiries.MainChainCount;
      IterInfo1.SetData( i
                        ,FCountNewBlocks
                        ,i
                        ,i + 1
                        ,0
                        ,THash32(TBytes(FBlockChain.Inquiries.GetMainLastblocHash))
                        ,THash32.Empty
                        ,Hash
                        ,0
                        ,0
                        ,TListIDVal.Empty
                        ,FListIDOnLineVal
                        );
    except
      on e: Exception do
      begin
        Msg2('   ***   ERROR FNewBlocks: ' + e.Message);
      end;
    end;
    FCS2.Leave;
//              FBlockChain.Inquiries.SetNewBlocks(NetPacketBlock(NetPacket)); //Ò‰ÂÎ‡Ú¸ ÓÚ‰ÂÎ¸˚ÌÈ Í˝¯


//              i:= ReceiveTransaction(AClient.IDNode, NetPacketBlock(NetPacket));
    Msg2('[' + AClient.IDNode.ToString + '] ' + 'NetPackt.PacketType: tpBlock, b: ' + ANetPacket.Size.ToString + ' b');

//              IterInfo1:= SetIteration(FIDIteration, i, Hash);
//              FConsensusLogic.Iteration:= IterInfo1;

    FConsensusLogic.ReceiveIterationData(FValID,IterInfo1);

//              NetPacket1:= NetPacketIterationInfo(IterInfo1);
    SendToAllValidators(NetPacketIterationInfo(IterInfo1).ToBytes);
    Sleep(1);
    Result:= 0;
  end
  else
  begin
    Result:= -1;
//    if (OratorInf.ID = AClient.IDNode) then
//      SendToClient(AClient,NetPacketGetEnableValList().ToBytes);
  end;

end;

procedure TConsensusCore1.SetIDIteration(AValue: UInt64);
begin
  if (FLastTmIDIter + 1/24/60/60/1000 * TIMEOUT_IDITERATION < Now()) then
  begin
    FIDIteration:= GetLastBlock();
    FLastTmIDIter:= Now();
  end;
//  FIDIteration:= AValue;
end;

function TConsensusCore1.GetIDIteration: UInt64;
begin
  if (FLastTmIDIter + 1/24/60/60/1000 * TIMEOUT_IDITERATION < Now()) then
  begin
    FIDIteration:= GetLastBlock();
    Result:= FIDIteration;
    FLastTmIDIter:= Now();
  end
  else
    Result:= FIDIteration;
end;

function TConsensusCore1.SetIteration(const AIDIter: UInt64; const ATXCount: Integer; AHash: THash32): TIteration;
begin
  Result.Clear;
  Result.ID:= AIDIter;
  Result.TXCount:= ATXCount;
  Result.IDCurrentBlock:= 0;
  Result.IDFirstBlock:= 0;
  Result.IDLastBlock:= Result.IDFirstBlock + ATXCount;
  Result.HashCurrentBlock.SetHash([1, 2, 3]);
  Result.HashFirstBlock.SetHash([1, 2, 3]);
  Result.HashLastBlock:= AHash;
  Result.CountVal:= 0;
  Result.CountValOnLine:= 0;
  Result.ListIDValOn.Clear;

  // Result.SetData()

  Result.SetSign(FValID, FPrK);
end;

function TConsensusCore1.TransactionToBytes(ACnt: Integer = 0): TBytes; // generate test TX
begin
  FCS2.Enter;
  try
    Result:= FBlockChain.Inquiries.GetAllCacheTrx;
  except
    on e: Exception do
    begin
      Msg('   ***   ERROR TConsensusCore.TransactionToBytes: ' + e.Message);
    end;
  end;
  FCS2.Leave;
end;

function TConsensusCore1.ReceiveTransaction(AIDNode: UInt64; AData: TBytes): Integer;
const
  SIZE_TX = 100;
begin
  // Check TX
  Result:= Round(Length(AData) / SIZE_TX);
end;

procedure TConsensusCore1.Reconnect(Sender: TObject; AClient: Tclient);
var
  NetPacket: TNetPacket;
begin
  Msg('******************' + #13#10 + '<<< Reconnect >>>' + #13#10 + '******************');
  Msg('[' + AClient.IDNode.ToString + '] ' + '<<< Reconnect >>>');
  if AClient.IDNode > 0 then
  begin
    NetPacket.SetPacket(TNetPacket.tpNodeReconnect, ThisNodeInfo.ToBytes);
//    NetPacket.SignPacket(FValID, FPrK);
    AClient.SendMessage(ToPacket(NetPacket));
  end;
end;

procedure TConsensusCore1.SetDefaultOrator;
var
  NetAddr: TNetAddr;
  i,n: Integer;  
begin
  if FDefaultOrator.ID = 0 then
  begin
    NetAddr:= FConfig.ConnectTo[0] + ':' + FConfig.ClientPort.ToString;
    n:= Validators.Count;
    for i:= 0 to Pred(n) do
    begin  
      if Validators.Items[i].ValInf.NetAddr = NetAddr then
      begin
        FDefaultOrator:= Validators.Items[i].ValInf;
        Break;
      end;
    end;
  end;
end;

procedure TConsensusCore1.DoActive;
var
  Packet: TPacket;
  NetPacket: TNetPacket;
  b: TBytes;
  i,n: Integer;
  Validator: TValidator;
begin
  Sleep(2000);
  FDefaultOrator.Clear;
  FDefaultOrator.NetAddr:= FConfig.ConnectTo[0] + ':' + FConfig.ClientPort.ToString;
  if not CheckValidator then
  begin
    FActive:= False;
    Exit;
  end;
  FActive:= True;  
  IDIteration:= GetLastBlock();
  Sleep(500);

  FOratorInf.Clear;
  FNewOratorInf.Clear;

  FArrayTXData.Clear;

  FConsensusLogic:= TConsensusLogic.Create(FValID);
  FConsensusLogic.OnConsensus:= EventConsensus;
  FConsensusLogic.OnMsg:= EventMsg;
  FConsensusLogic.OnTimeOut:= EventConsensusTimeout;


  FValidators.OnReconnect:= Reconnect;
  FValidators.OnDisconnect:= DoDisconnect;

//  if FValID = 0 then
//  begin
//    FActive:= False;
//    Exit;
//  end;
  
  // if (FNetCore.MainClient.IDNode = 0) then
  // begin
  //
  // end
  // else
  // begin
  // FOratorInf.ID:= FNetCore.MainClient.IDNode;
  // FOratorInf.NetAddr:= Validators.Items[(Validators.IndexOfID(FOratorInf.ID))].ValInf.NetAddr;
  // end;
  //

  Msg('Consensus active');
  Msg2('NodeInfo: ' + ThisNodeInfo.ToString);

  // FValidators:= [];

  n:= AddValToList();
  Msg2('Count OM: ' + n.ToString + ' Count validators: ' + FValidators.Count.ToString);
  
  // b:= ThisNodeInfo();
  // NetPacket.SetPacket(TNetPacket.tpNodeInfo, b);
  // NetPacket.SetPacket(TNetPacket.tpNodeConnect, ThisNodeInfo().ToBytes);

  NetPacket:= NetPacketNodeConnect(ThisNodeInfo());
//  NetPacket.SignPacket(FValID, FPrK);
  // Packet.CreatePacket(40,NetPacket.ToBytes);
  try
    FNetCore.SendPacket(ToPacket(NetPacket.ToBytes));
  finally

  end;
  Sleep(1500);
  AutoConnect();

  Sleep(500);
  // NetPacket.SetPacket(TNetPacket.tpGetOratorInfo,[0]);
  // NetPacket.SignPacket(FValID,FPrK);
  // try
  // FNetCore.SendPacket(ToPacket(NetPacket.ToBytes));
  // except
  //
  // end;

  Validators.CheckAddr();

  // Validators.Items[0].Client.Disconnect;
  // Validators.Reconnect;
  // NetPacket.SetPacket(TNetPacket.tpNodeReconnect,ThisNodeInfo);
  // NetPacket.SignPacket(FValID,FPrK);
  // try
  // FNetCore.SendPacket(ToPacket(NetPacket.ToBytes));
  // except
  //
  // end;
  Msg2('0 *********** Enable ***********');
  Enable:= True;
  // FOratorInf.TimeStamp:= Now();
  // FOratorInf.TimeReceive:= Now();

  FConsensusLogic.Active:= True;
  while FActive do
  begin
    if (FCheckNetTime + 1/24/60/60/1000 * (TIMEOUT * 4) < Now()) then
    begin
      SendToOrator(NetPacketPing(Now()).ToBytes);
    end;
    // Validators.SendData(ToPacket(NetPacketPing(Now()).ToBytes));
    // Sleep(1000);
    if (OratorInf.TimeReceive + 1/24/60/60/1000 * (TIMEOUT * 2) < Now()) then
    begin
      if not FConsensusLogic.Active then
      begin
        FConsensusLogic.Active:= True;
        EventConsensusTimeout(TEvent.Empty);
      end;
    end;
    Sleep(1000);
  end;
  Msg('Consensus desactive');
end;

procedure TConsensusCore1.DoDisconnect(AClient: Tclient);
var
  Val: TValidator;
begin
  Msg2('   ***   DoDisconnect: AClient.IDNode[' + AClient.IDNode.ToString + ']');
//  Validators.ValidatorOfID(AClient.IDNode).pEnable:= False;
  if Validators.IndexOfID(AClient.IDNode) >=0 then
  begin
    Val:= Validators.ValidatorOfID(AClient.IDNode);
    Val.Online:= False;
    Val.Enable:= False;
    Val.Client:= nil;
    Validators.Update(Val);
  //  if Val.ValInf.ID = OratorInf.ID then
    if (AClient.IDNode = OratorInf.ID) then
    begin
      Val:= Validators.ValidatorOfID(FNewOratorInf.ID);
      if (Val.Online) and (Val.Enable) and (Val.Client.Connected) then
      begin
        OratorInf:= FNewOratorInf;
      end
      else
      begin
        OratorInf:= NewOrator(True);
      end;
    end;
    if Orator then
    begin
      EndIteration(False);
      Msg2('2 <<<<<<************ BeginIteration ************>>>>>>' );
      BeginIteration(False);
    end;
  end;
  Sleep(1000);
end;

procedure TConsensusCore1.DoDisconnect2(AClient: TConnectedClient);
begin
  if CheckValidator then
  begin
    Msg2('TConsensusCore.DoDisconnect2: ' + AClient.IDNode.ToString);
    Sleep(1000);
  end;
end;


function TConsensusCore1.ThisNodeInfo(): TValInf;
begin
  Result.Clear;
  Result.ID:= FValID;
  // ServerIPv4:= '127.0.0.1';
  Result.NetAddr:= ServerIPv4 + ':' + ServerPort.ToString;
  Result.TimeStamp:= FTimeStart;
  Result.IDIteration:= IDIteration;
//  Result.SetSign(FValID, FPrK);
end;

function TConsensusCore1.NewOrator(AState: Boolean = False): TOratorInf;
var
  a, i, n: Integer;
begin
  Result.Clear;
  Result:= FDefaultOrator;
  Result.IDIteration:= IDIteration;
  if (FOratorInf.ID = FValID) or (AState) or (OratorInf.IsEmpty) then
  begin

    i:= Validators.IndexOfID(FOratorInf.ID);
//     Result:= Validators.Items[i].ValInf;
//    Result:= FOratorInf;

    a:= i;
    if (i >= 0) then
    begin
      Inc(i);
      if i > Pred(Validators.Count) then
        i:= 0;      
      while i <> a do
      begin
        if (Validators.Items[i].ValInf.ID <> 0)
          and (Validators.Items[i].ValInf.ID <> FValID)
          and (Validators.Items[i].Online)
//          and (Validators.Items[i].Enable)
          and (Validators.Items[i].Client.Connected)
//         and (Validators.Items[i].ValInf.TimeStamp + 1/24/60/60/1000 * (ORATOR_TIMEOUT * 2) < Now())
          and (Validators.Items[i].ValInf.TimeReceive + 1 / 24 / 60 / 60 / 1000 * (ORATOR_TIMEOUT * 2) < Now())
        then
        begin
          if Validators.Items[i].Client <> nil then
          begin
            try
              if Validators.Items[i].Client.Connected then
              begin

                Result:= Validators.Items[i].ValInf;
                // Result.TimeStamp:= FTimeStart;
                Result.TimeStamp:= Now();
//                Result.IDIteration:= FIDIteration + 1;
                Result.IDIteration:= GetLastBlock;
                Break;
              end;
            except
              on e: Exception do
              begin
                Msg('Err. NewOrator()' + e.Message);
              end;
            end;
          end;
        end;
        Inc(i);
        if i > Pred(Validators.Count) then
          i:= 0;
      end;
      // FOratorInf.TimeStamp:= Now();
    end;
    // Result:= FDefaultOrator;
    // Result.IDIteration:= FIDIteration + 1;
  end;
end;

function TConsensusCore1.CurentOrator(): TOratorInf;
var
  i: Integer;
begin
  Result.Clear;
  if (FNetCore.MainClient.IDNode = 0) then
  begin
    FOratorInf.NetAddr:= FNetCore.MainClient.IPv4 + ':' + FNetCore.MainClient.Port.ToString;
    Result:= FOratorInf;
    // Validators.CheckAddr;
  end
  else
  begin
    FOratorInf:= Validators.ValidatorOfID(FNetCore.MainClient.IDNode).ValInf;
    // FOratorInf.ID:= FNetCore.MainClient.IDNode;
    // FOratorInf.NetAddr:= FNetCore.MainClient.IPv4 + ':' + FNetCore.MainClient.Port.ToString;
    // i:= Validators.IndexOfID(FOratorInf.ID);
    // if i >= 0 then
    // if Validators.Items[i].Online then
    // FOratorInf.NetAddr:= Validators.Items[i].ValInf.NetAddr;

    Result:= FOratorInf;
  end;
end;

procedure TConsensusCore1.SetActive(AValue: Boolean);
begin
  if CheckValidator then
  begin
    if AValue <> FActive then
    begin
      if AValue then
      begin
        TThread.CreateAnonymousThread(
          procedure
          begin
            DoActive;
          end).Start;
      end
      else
      begin
        FConsensusLogic.Active:= AValue;
      end;
      Msg2('4 *********** Enable ***********');
      Enable:= AValue;
      FActive:= AValue;
    end;
  end
  else
  begin
    Enable:= False;
    FActive:= False;
  end;
end;

function TConsensusCore1.GetActive: Boolean;
begin
  Result:= FActive;
end;

procedure TConsensusCore1.SetEnable(AValue: Boolean);
var
  Validator: TValidator;
begin
  if CheckValidator then
  begin
    if FEnable <> AValue then
    begin
      FEnable:= AValue;
      Validator:= Validators.ValidatorOfID(FValID);
      Validator.Enable:= FEnable;
      Validators.Update(Validator);
      SendToAllValidators(NetPacketNodeEnable(AValue).ToBytes)
    end;
    if AValue then
    begin
      Validator:= Validators.ValidatorOfID(FValID);
      Validator.Enable:= AValue;
      Validators.Update(Validator);
//      SendToAllValidators(NetPacketNodeEnable(AValue).ToBytes)
    end
    else
    begin
      Validator:= Validators.ValidatorOfID(FValID);
      Validator.Enable:= AValue;
      Validators.Update(Validator);
//      SendToAllValidators(NetPacketNodeEnable(AValue).ToBytes)
    end;
  end
  else
  begin
    FEnable:= False;
  end;
end;

function TConsensusCore1.GetEnable: Boolean;
begin
  Result:= FEnable;
end;

procedure TConsensusCore1.SetOratorInf(AValue: TOratorInf);
begin
  Msg2('<<<<<<************ SetOratorInf ************>>>>>>' );
  if (AValue.ID <> 0)  then
  begin
    if (Orator) and (FListIDOnLineVal.Count > 1) then
//    if False then
    begin
//      Enable:= False;
      if (FOratorInf.ID <> AValue.ID) and (Validators.IndexOfID(AValue.ID) >= 0) then
      begin
        FOratorInf:= AValue;
        FNetCore.MainClient:= Validators.Items[Validators.IndexOfID(FOratorInf.ID)].Client;
        Msg('SetOrator: ' + FOratorInf.ToString);
      end;
      Msg2('3 <<<<<<************ BeginIteration ************>>>>>>' );
      BeginIteration(FConsensusLogic.Result);
    end
    else
    begin
      if (FOratorInf.ID <> AValue.ID) and (Validators.IndexOfID(AValue.ID) >= 0) then
      begin
        FOratorInf:= AValue;
        FNetCore.MainClient:= Validators.Items[Validators.IndexOfID(FOratorInf.ID)].Client;
        Msg('SetOrator: ' + FOratorInf.ToString);
      end;
      if Orator then
      begin
        if (Active) then
        begin
          Msg2('5 *********** Enable ***********');
          Enable:= True;
          Msg(#13#10 + '<<<<<<<<<<< ****** >>>>>>>>>>>'
            + #13#10 + '<<<<<<<<<<< ORATOR >>>>>>>>>>>'
            + #13#10 + '<<<<<<<<<<< ****** >>>>>>>>>>>');
          FNewOratorInf:= NewOrator();
  //        SendToAllValidators(NetPacketNewOratorInfo(FNewOratorInf).ToBytes);
    //      Validators.SendData(ToPacket(NetPacketNewOratorInfo(FNewOratorInf).ToBytes));
          Sleep(1);
          Msg2('4 <<<<<<************ BeginIteration ************>>>>>>' );
          BeginIteration(FConsensusLogic.Result);
        end
        else
        begin
          Enable:= False;
  //        SendToAllValidators(NetPacketOratorInfo(NewOrator()).ToBytes);
          // œŒƒ”Ã¿“‹
        end;
      end
      else
      begin
        SendToOrator(NetPacketGetOratorInfo().ToBytes);
//        SendToDefaultOrator(NetPacketGetOratorInfo().ToBytes);
//        SendToOrator(NetPacketGetEnableValList().ToBytes);
  //      Validators.SendData(ToPacket(NetPacketGetEnableValList().ToBytes));
        Sleep(500);
        Msg2('5 <<<<<<************ BeginIteration ************>>>>>>' );
        BeginIteration(FConsensusLogic.Result);
      end;

    end;
  end;
end;

procedure TConsensusCore1.SetValID(AValID: UInt64);
begin
  FValID:= AValID;
  if FConsensusLogic <> nil then
    FConsensusLogic.IDVal:= FValID;
end;

function TConsensusCore1.GetOratorInf: TOratorInf;
begin
  Result:= FOratorInf;
  Result.TimeStamp:= Now();
  Result.IDIteration:= IDIteration;
end;

{$ENDREGION 'TConsensusCore'}

initialization
  _CS:= TCriticalSection.Create;

finalization
  _CS.Free;

end.
