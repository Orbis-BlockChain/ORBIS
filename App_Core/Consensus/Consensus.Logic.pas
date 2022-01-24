unit Consensus.Logic;

interface

uses
  System.SyncObjs
  ,System.Classes
  ,System.SysUtils

  ,Consensus.Types
  ;

type

//  TConsensusEvent = procedure (AEvent: TBytes) of Object;
  TConsensusEvent = procedure (AEvent: TEvent) of Object;

  SyncData = record
    IDVal: UInt64;
    IDIter: UInt64;
    Check: Boolean;
    Equal: Boolean;

    procedure Clear;
  end;

  TArraySyncData = record
    Data: array of SyncData;

    procedure SetLen(ALen: Integer);
    function GetLen: Integer;
    function Add(AIDVal: UInt64): Integer;
    property Len: Integer read GetLen write SetLen;
    procedure Clear;
  end;

  IterData = record
    IDVal: UInt64;
    IterData: TIteration;
    Check: Boolean;
    Equal: Boolean;

    procedure Clear;
  end;

  TArrayIterData = record
    Data: array of IterData;

    procedure SetLen(ALen: Integer);
    function GetLen: Integer;
    function Add(AIDVal: UInt64): Integer;
    property Len: Integer read GetLen write SetLen;
    procedure Clear;
  end;

  TData = TNetPacket;

  TConsensusLogic = class
  const
    TIMEOUT = 30000;
//    QUORUM_COEFFICIENT = 2/3;
//    QUORUM_PRC = 66.7;
    QUORUM_COEFFICIENT = 3/3;
    QUORUM_PRC = 100;
//      QUORUM_COEFFICIENT = 3/4;
  private
    FCS: TCriticalSection;
    FCSEv: TCriticalSection;
    FIDVal: UInt64;
    FIDIter: UInt64;
    FActive: Boolean;
    FResult: Boolean;
    FCheckResult: Boolean;
    FIteration: TIteration;
    FCountVal: Integer;
    FCountCheck: Integer;
    FCountEqual: Integer;
    FIdEvent: Integer;
    FArrayIterData: TArrayIterData;
    FTimeStart: TDateTime;
    FTimeLastOper: TDateTime;

    FConsensusEvent: TConsensusEvent;
    FTimeOutEvent: TConsensusEvent;
    FBeginEvent: TConsensusEvent;
    FExecuteEvent: TConsensusEvent;
    FEndEvent: TConsensusEvent;
    FMsgEvent: TConsensusEvent;

    procedure SetActive(AValue: Boolean); virtual;
    function GetActive: Boolean;
    function GetResult: Boolean;
    function GetIdEvent: Integer;

    procedure SetIteration(AIteration: TIteration);
    function  GetIteration(): TIteration;

    procedure SetCountVal(AData: Integer);
    function  GetCountVal(): Integer;

    procedure SetCountCheck(AData: Integer);
    function  GetCountCheck(): Integer;

    procedure SetCountEqual(AData: Integer);
    function  GetCountEqual(): Integer;


    function CheckQuorum(): Byte; // percent equal

    procedure DoActive();

    procedure DoOnBegin(AEvent: TEvent);
    procedure DoOnExecute(AEvent: TEvent);
    procedure DoOnEnd(AEvent: TEvent);
    procedure DoOnConsensus(AEvent: TEvent);
    procedure DoOnTimeOut(AEvent: TEvent);
    procedure DoOnMsg(AEvent: TEvent);

    procedure Msg(AData: string);
  public
    constructor Create(AIDVal: UInt64);
    destructor Destroy; override;
    procedure NewIteration(AIDIter: UInt64; AListIDVal: TListIDVal);

    procedure ReceiveIterationDataR(AIDVal: UInt64; AIteration: TIteration);
    procedure ReceiveIterationData(AIDVal: UInt64; AIteration: TIteration);

    property IDIter: UInt64 read FIDIter write FIDIter;
    property IDVal: UInt64 read FIDVal write FIDVal;
    property Iteration: TIteration read GetIteration write SetIteration;

    property CountVal: Integer read GetCountVal write SetCountVal;
    property CountCheck: Integer read GetCountCheck write SetCountCheck;
    property CountEqual: Integer read GetCountEqual write SetCountEqual;

    property Active: Boolean read GetActive write SetActive;
    property Result: Boolean read GetResult;
    property IDEvent: Integer read GetIdEvent;

    function DataReceive(AData: TBytes): Integer;
    { Events }
    property OnBegin: TConsensusEvent read FBeginEvent write FBeginEvent;
    property OnExecute: TConsensusEvent read FExecuteEvent write FExecuteEvent;
    property OnEnd: TConsensusEvent read FEndEvent write FEndEvent;
    property OnConsensus: TConsensusEvent read FConsensusEvent write FConsensusEvent;
    property OnTimeOut: TConsensusEvent read FTimeOutEvent write FTimeOutEvent;
    property OnMsg: TConsensusEvent read FMsgEvent write FMsgEvent;
  end;

var
  _CS: TCriticalSection;

implementation

{ TConsensusLogic }
{$REGION 'TConsensusLogic'}
function TConsensusLogic.CheckQuorum(): Byte;
var
  i,k,n: Integer;
begin
  FCS.Enter;
  try
    Result:= 0;
    if (not FIteration.IsEmpty) then
    begin
      n:= FCountVal;
      if n > 0 then
      begin
        for i:= 0 to Pred(n) do
        begin
          if (not FArrayIterData.Data[i].IterData.IsEmpty)
            and (not FArrayIterData.Data[i].Check)
          then
          begin
            FArrayIterData.Data[i].Check:= True;
            Inc(FCountCheck);
            if (FArrayIterData.Data[i].IterData = FIteration) then
            begin
              FArrayIterData.Data[i].Equal:= True;
              Inc(FCountEqual);
            end
            else
            begin
              FArrayIterData.Data[i].Equal:= False;
            end;
          end
          else
          begin

          end;
        end;
  //    if (Round(FCountEqual/FCountVal) > QUORUM_COEFFICIENT) then
        if (not FCheckResult) then
        if (FCountEqual >= FCountVal * QUORUM_COEFFICIENT) then
        begin
          Result:= Round(FCountEqual/FCountVal * 100);
          FResult:= True;
          FCheckResult:= True;
          FActive:= False;
          DoOnConsensus(True);
          DoOnMsg('CONSENSUS LOGIC [' + FIteration.ID.ToString + '] TRUE');
        end
        else
        begin
          if (FCountVal = FCountCheck) then
          begin
            FActive:= False;
            Result:= Round(FCountEqual/FCountVal * 100);
            FResult:= True;
            FCheckResult:= True;
            DoOnConsensus(False);
            DoOnMsg('CONSENSUS LOGIC [' + FIteration.ID.ToString + '] FALSE');
          end;
        end;
      end;
    end
    else
    begin
      FCountEqual:= 0;
    end;

  except
  end;
  FCS.Leave;
end;

constructor TConsensusLogic.Create(AIDVal: UInt64);
begin
  _CS.Enter;
  FCS:= TCriticalSection.Create;
  FCSEv:= TCriticalSection.Create;
  FCS.Enter;
  try
    FIdEvent:= 0;
    FIDVal:= AIDVal;
    FIDIter:= 0;
    FActive:= False;
    FResult:= False;
    FCheckResult:= False;
    FIteration.Clear;
    FCountVal:= 0;
    FCountCheck:= 0;
    FCountEqual:= 0;
    FArrayIterData.Clear;
  except
    raise Exception.Create('TConsensusLogic.Create');
  end;
  FCS.Leave;
end;

destructor TConsensusLogic.Destroy;
begin
  Factive:= False;
  FCS.Leave;
  inherited;
  FCSEv.Free;
  FCS.Free;
  _CS.Leave;
end;


procedure TConsensusLogic.Msg(AData: string);
var
  Event: TEvent;
  text: TText;
begin
  text:= AData;
  Event.SetEvent(IDEvent,TEvent.teText,text.ToBytes);
  DoOnMsg(Event);
end;

procedure TConsensusLogic.NewIteration(AIDIter: UInt64; AListIDVal: TListIDVal);
var
  i,k,n: Integer;
begin
//  FActive:= False;
  FCS.Enter;
  try
    FResult:= False;
    FCheckResult:= False;
    FIDIter:= AIDIter;
  //  n:= Length(AListIDVal);
    n:= AListIDVal.Count;
    try
      FArrayIterData.Len:= n;
    except
      DoOnMsg(TEvent('ERROR FArrayIterData.Len:= n'));
      FCS.Leave;
      Exit;
    end;
    FIteration.Clear;
    Factive:= True;
    k:= 0;
    for i:= 0 to Pred(n) do
    begin
      FArrayIterData.Add(AListIDVal.Data[i]);
//      if FIDVal <> AListIDVal.Data[i] then
//      begin
//        FArrayIterData.Add(AListIDVal.Data[i]);
//
//  //      FArrayIterData.Data[k].IDVal:= AListIDVal.Data[i];
//  //      FArrayIterData.Data[k].IterData.Clear;
//  //      FArrayIterData.Data[k].Check:= False;
//  //      FArrayIterData.Data[k].Equal:= False;
//  //      Inc(k);
//      end
//      else
//      begin
//  //      SetLength(FArrayIterData, n - 1);
//        FArrayIterData.Len:= n - 1;
//      end;
    end;
  //  FCountVal:= Length(FArrayIterData);
    FCountVal:= FArrayIterData.Len;
    FCountEqual:= 0;
    FCountCheck:= 0;
    FTimeLastOper:= Now();
  except
    FCS.Leave;
    raise Exception.Create('ERROR TConsensusLogic.NewIteration');
  end;
  FCS.Leave;
end;

procedure TConsensusLogic.ReceiveIterationDataR(AIDVal: UInt64;
  AIteration: TIteration);
begin
  TThread.Queue(nil,
            procedure
            begin
              ReceiveIterationDataR(AIDVal,AIteration);
            end);
end;

procedure TConsensusLogic.ReceiveIterationData(AIDVal: UInt64; AIteration: TIteration);
var
  i,n: Integer;
begin
  FCS.Enter;
  try
    if (not AIteration.IsEmpty)
  //    and (not AIteration.Sign.IsEmpty)
  //    and (AIteration.ID = FIDIter)
  //    and (AIDVal <> FIDVal)
  //    and (AIteration.Sign.IDKey <> FIDVal)
  //    and (AIteration.Sign.IDKey <> 0)
    then
    begin
  //    n:= Length(FArrayIterData);
      n:= FArrayIterData.Len;
      for i:= 0 to Pred(n) do
      begin
  //      if FArrayIterData[i].IDVal = AIteration.Sign.IDKey then
        if FArrayIterData.Data[i].IDVal = AIDVal then
        begin
          FArrayIterData.Data[i].IterData:= AIteration;
          FArrayIterData.Data[i].Check:= False;
          FArrayIterData.Data[i].Equal:= False;
  //        if (not FIteration.IsEmpty) then
  //        begin
  //
  //        end;
        end;
      end;
    end;
    FTimeLastOper:= Now();
  except
    FCS.Leave;
    raise Exception.Create('ERROR TConsensusLogic.ReceiveIterationData');
  end;
  FCS.Leave;
  CheckQuorum();
end;

function TConsensusLogic.DataReceive(AData: TBytes): Integer;
var
  Data: TData;
  Event: TEvent;
  text: TText;
begin
  FCS.Enter;
  Result:= 0;
  Data:= AData;
  case Data.PacketType of
    Data.tpNope:
    begin
      Msg('DataReceive: Data.tpNope');
    end;
    Data.tpIterationInfo:
    begin
      Msg('DataReceive: Data.tpIterationInfo');
    end;
    Data.tpIDIteration:
    begin
      Msg('DataReceive: Data.tpIDIteration');
    end;
    Data.tpNextIteration:
    begin
      Msg('DataReceive: Data.tpNextIteration');
    end;
    Data.tpValList:
    begin
      Msg('DataReceive: Data.tpValList');
    end;
  end;
  FCS.Leave;
end;

procedure TConsensusLogic.DoActive;
begin
  FTimeStart:= Now();
  FTimeLastOper:= Now();
  while Factive do
  begin
//    Sleep(TIMEOUT);

//    DoOnConsensus(Self.Result);
//    FCS.Enter;
    if (FTimeLastOper + 1/24/60/60/1000 * TIMEOUT < Now()) then
    begin
//      FCS.Enter;
      try
        Factive:= False;
        DoOnTimeOut(Self.Result);
        DoOnMsg('CONSENSUS LOGIC [' + FIteration.ID.ToString + '] TIMEOUT');
      finally

      end;
//      FCS.Leave;
    end;
//    FCS.Leave;
    Sleep(1000);
  end;
end;

procedure TConsensusLogic.DoOnBegin(AEvent: TEvent);
begin
//  FCSEv.Enter;
  if Assigned(OnBegin) then
  TThread.Queue(nil,
    procedure
    begin
      OnBegin(AEvent);
    end);
//  FCSEv.Leave;
end;

procedure TConsensusLogic.DoOnConsensus(AEvent: TEvent);
begin
//  FCSEv.Enter;
  try
    if Assigned(OnConsensus) then OnConsensus(AEvent);
//    if Assigned(OnConsensus) then
//    TThread.Queue(nil,
//      procedure
//      begin
//         OnConsensus(AEvent);
//      end);
  finally

  end;
//  FCSEv.Leave;
end;

procedure TConsensusLogic.DoOnTimeOut(AEvent: TEvent);
begin
//  FCSEv.Enter;
  try
  if Assigned(OnTimeOut) then
  TThread.Queue(nil,
    procedure
    begin
      OnTimeOut(AEvent);
    end);
  finally

  end;
//  FCSEv.Leave;
end;

procedure TConsensusLogic.DoOnEnd(AEvent: TEvent);
begin
//  FCSEv.Enter;
  if Assigned(OnEnd) then
  TThread.Queue(nil,
    procedure
    begin
      FActive:= False;
      OnEnd(AEvent);
//      FCSEv.Leave;
    end);
//  FCSEv.Leave;
end;

procedure TConsensusLogic.DoOnExecute(AEvent: TEvent);
begin
//  FCSEv.Enter;
  if Assigned(OnExecute) then
  TThread.Queue(nil,
    procedure
    begin
      OnExecute(AEvent);
    end);
//  FCSEv.Leave;
end;

procedure TConsensusLogic.DoOnMsg(AEvent: TEvent);
begin
//  FCSEv.Enter;
  try
//  if Assigned(OnMsg) then OnMsg(AEvent);
  if Assigned(OnMsg) then
  TThread.Queue(nil,
    procedure
    begin
      OnMsg(AEvent);
    end);
  finally

  end;
//  FCSEv.Leave;
end;

function TConsensusLogic.GetActive: Boolean;
begin
//  FCS.Enter;
  Result:= FActive;
//  FCS.Leave;
end;

procedure TConsensusLogic.SetCountVal(AData: Integer);
begin
  FCS.Enter;
//  FCountVal:= Length(FArrayIterData);
  FCountVal:= FArrayIterData.Len;
  FCS.Leave;
end;

function TConsensusLogic.GetCountVal: Integer;
begin
  FCS.Enter;
//  Result:= Length(FArrayIterData);
  Result:= FArrayIterData.Len;
  FCS.Leave;
end;

procedure TConsensusLogic.SetCountCheck(AData: Integer);
var
  i,n: Integer;
begin
  FCS.Enter;
  FCountCheck:= 0;
//  n:= Length(FArrayIterData);
  n:= FArrayIterData.Len;
  for i:= 0 to Pred(n) do
  begin
    if FArrayIterData.Data[i].Check then
      Inc(FCountCheck);
  end;
  FCS.Leave;
end;

function TConsensusLogic.GetCountCheck: Integer;
var
  i,n: Integer;
begin
  FCS.Enter;
  Result:= 0;
//  n:= Length(FArrayIterData);
  n:= FArrayIterData.Len;
  for i:= 0 to Pred(n) do
  begin
    if FArrayIterData.Data[i].Check then
      Inc(Result);
  end;
  FCS.Leave;
end;

procedure TConsensusLogic.SetCountEqual(AData: Integer);
var
  i,n: Integer;
begin
  FCS.Enter;
  FCountEqual:= 0;
//  n:= Length(FArrayIterData);
  n:= FArrayIterData.Len;
  for i:= 0 to Pred(n) do
  begin
    if (FArrayIterData.Data[i].Check) and (FArrayIterData.Data[i].Equal) then
      Inc(FCountEqual);
  end;
  FCS.Leave;
end;

function TConsensusLogic.GetCountEqual: Integer;
var
  i,n: Integer;
begin
  FCS.Enter;
  Result:= 0;
//  n:= Length(FArrayIterData);
  n:= FArrayIterData.Len;
  for i:= 0 to Pred(n) do
  begin
    if (FArrayIterData.Data[i].Check) and (FArrayIterData.Data[i].Equal) then
      Inc(Result);
  end;
  FCS.Leave;
end;

function TConsensusLogic.GetIdEvent: Integer;
begin
  FCS.Enter;
  Result:= FIdEvent;
  Inc(FIdEvent);
  if (FIdEvent = FIdEvent.MaxValue) or (FIdEvent < 0) then
    FIdEvent:= 0;
  FCS.Leave;
end;

procedure TConsensusLogic.SetActive(AValue: Boolean);
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

    end;
    FActive:= AValue;
  end;
end;

procedure TConsensusLogic.SetIteration(AIteration: TIteration);
begin
  FCS.Enter;
  FIteration:= AIteration;
  FCS.Leave;
  CheckQuorum();
end;

function TConsensusLogic.GetIteration: TIteration;
begin
//  FCS.Enter;
  Result:= FIteration;
//  FCS.Leave;
end;

function TConsensusLogic.GetResult: Boolean;
begin
  Result:= FResult;
end;

{$ENDREGION 'TConsensusLogic'}


{ TArrayIterData }
{$REGION 'TArrayIterData'}
function TArrayIterData.Add(AIDVal: UInt64): Integer;
var
  i,n: Integer;
begin
  Result:= -1;
  n:= Self.Len;
  for i:= 0 to Pred(n) do
  begin
    if Self.Data[i].IDVal = AIDVal then
    begin
      Result:= i;
      Exit;
    end;
    if Self.Data[i].IDVal = 0 then
    begin
      Self.Data[i].Clear;
      Self.Data[i].IDVal:= AIDVal;
      Result:= i;
      Exit;
    end;
  end;
  SetLength(Self.Data, n + 1);
  Self.Data[n].IDVal:= AIDVal;
  Result:= n;
end;

procedure TArrayIterData.Clear;
var
  i,n: Integer;
begin
  n:= Length(Self.Data);
  for i:= 0 to Pred(n) do
  begin
    Self.Data[i].Clear;
  end;
  SetLength(Self.Data,0);
end;

function TArrayIterData.GetLen: Integer;
begin
  Result:= Length(Self.Data);
end;

procedure TArrayIterData.SetLen(ALen: Integer);
begin
  SetLength(Self.Data,ALen);
end;

{$ENDREGION 'TArrayIterData'}
{ IterData }

procedure IterData.Clear;
begin
  Self.IDVal:= Self.IDVal.MinValue;
  Self.IterData.Clear;
  Self.Check:= False;
  Self.Equal:= False;
end;


{ SyncData }

procedure SyncData.Clear;
begin
  Self.IDVal:= Self.IDVal.MinValue;
  Self.IDIter:= 0;
  Self.Check:= False;
  Self.Equal:= False;
end;

{ TArraySyncData }

function TArraySyncData.Add(AIDVal: UInt64): Integer;
begin

end;

procedure TArraySyncData.Clear;
begin

end;

function TArraySyncData.GetLen: Integer;
begin

end;

procedure TArraySyncData.SetLen(ALen: Integer);
begin

end;

initialization
  _CS:= TCriticalSection.Create;

finalization
  _CS.Free;

end.

