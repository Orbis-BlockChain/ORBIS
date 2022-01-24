unit Consesus.Core.TonyEdition;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.Threading,
  System.Math,
  Net.Core,
  Net.IClient,
  Net.Client,
  BlockChain.Core,
  UI.Abstractions,
  Wallet.Core,
  Crypto.RSA,
  App.Config,
  App.Types,
  App.Packet,
  App.IHandlerCore;

type
  TIP = record
    IP: array [0 .. 3] of byte;
    class operator Implicit(Value: string): TIP;
    class operator Implicit(Value: TIP): string;
    class operator Implicit(Value: TBytes): TIP;
    class operator Implicit(Value: TIP): TBytes;
  end;

  TValidator = record
    ID: UInt64;
    IP: TIP;
    Port: word;
    Client: IClient;
  end;

  TQueueValidator = TQueue<TValidator>;

  TValidators = TList<TValidator>;

  TConsensusCore = class
  private
    NetCore: TNetCore;
    BlockChain: TBlockChainCore;
    WalletCore: TWalletCore;
    UI: TBaseUI;
    Config: TConfig;
    Validators: TValidators;
    CriticalSection: TCriticalSection;
    WaitNewSpeaker: Boolean;
    cancelationToken: Boolean;
    HandlerCore: IBaseHandler;
    procedure ChooseNewSpeaker;
    procedure Refused—hangeSpeaker;
  public
    procedure DoConfigurate;
    procedure ChangeConnect(AData: TBytes);
    procedure DoChangeSpeaker;
    procedure StartSpeakerWork;
    procedure DoRequestAllTransactions;
    procedure SetValidators(AData: TBytes);
    procedure AddToValidators(const AID: UInt64; AIP: string; AClient: IClient);
    procedure Successful—hangeSpeaker;
    procedure UpdateValidators(ID: UInt64);
    function GetValidators: TBytes;
    constructor Create(ANetCore: TNetCore; ABlockChain: TBlockChainCore; AWalletCore: TWalletCore; AUICore: TBaseUI; AConfig: TConfig; AHandlerCore: IBaseHandler);
    destructor Destroy; override;
  end;

implementation

{ ConsensusCore }

procedure TConsensusCore.AddToValidators(const AID: UInt64; AIP: string; AClient: IClient);
var
  ValidatorInfo: TValidator;
begin
  CriticalSection.Enter;
  try
    var
    flag := False;
    for var item in Validators do
      if item.ID = AID then
        flag := true;

    if not flag then
    begin
      ValidatorInfo.ID := AID;
      ValidatorInfo.IP := AIP;
      ValidatorInfo.Port := 0;
      ValidatorInfo.Client := AClient;
      Validators.Add(ValidatorInfo);
    end;

  finally
    CriticalSection.Leave;
  end;
end;

procedure TConsensusCore.ChangeConnect(AData: TBytes);
begin
  // “ÛÚ ‰Ó·ËÒ‡Ú¸ ‚˚·Ó ÍÛ‰‡ ÔÓ‰ÍÎ˛˜‡Ú¸Òˇ
  // –‡ÒÔ‡ÒËÚ¸ Ë ‚˚Á‚‡Ú¸
  // NetCore.ChangeMainClient() Ò ÓÚÔ‡‚ÍÓÈ ÍÓÌÚÓÎ¸ÌÓ„Ó Ô‡ÍÂÚ‡ ·‡ÈÚ
end;

procedure TConsensusCore.ChooseNewSpeaker;
var
  idNewSpeaker: UInt64;
  Packet: TPacket;
begin
  idNewSpeaker := 0;
  if Validators.Count < 2 then
    StartSpeakerWork;

  if Validators.Count = 2 then
  begin
    var
    flag := False;
    for var item in Validators do
      if item.ID <> walletID then
      begin
        for var Client in NetCore.Clients do
          if Client.IDNode = item.ID then
          begin
            Packet.CreatePacket(CMD_REQUEST_YOU_SPEAKER, []);
            Client.SendMessage(Packet);
            WaitNewSpeaker := true;
            flag := true;
          end;
      end;

    if not flag then
      StartSpeakerWork;
  end;

  if Validators.Count > 2 then
  begin
    var
    flag := False;
    var
      randID: UInt64;
    Randomize;
    repeat
      randID := RandomRange(0, Validators.Count);
    until (Validators[randID].ID <> walletID);

    for var Client in NetCore.Clients do
      if Client.IDNode = Validators[randID].ID then
      begin
        Packet.CreatePacket(CMD_REQUEST_YOU_SPEAKER, []);
        Client.SendMessage(Packet);
        WaitNewSpeaker := true;
        flag := true;
        UI.ShowMessage('System Info: Now Speaker Node with ID - ' + Client.IDNode.AsString);
      end;

    Successful—hangeSpeaker;
  end;
end;

constructor TConsensusCore.Create(ANetCore: TNetCore; ABlockChain: TBlockChainCore; AWalletCore: TWalletCore; AUICore: TBaseUI; AConfig: TConfig;
  AHandlerCore: IBaseHandler);
begin
  NetCore := ANetCore;
  BlockChain := ABlockChain;
  WalletCore := AWalletCore;
  UI := AUICore;
  Config := AConfig;
  HandlerCore := AHandlerCore;
  Validators := TValidators.Create;
  CriticalSection := TCriticalSection.Create;
  WaitNewSpeaker := False;
end;

destructor TConsensusCore.Destroy;
begin
  cancelationToken := true;
  Validators.Clear;
  Validators.Free;
  CriticalSection.Free;
  inherited;
end;

procedure TConsensusCore.DoChangeSpeaker;
begin

end;

procedure TConsensusCore.DoConfigurate;
var
  Packet: TPacket;
  buf, cryptBuf: TBytes;
  Valid: TValidator;
begin
  if (NodeState = Speaker) and (walletID > 0) then
  begin
    var
    flag := False;

    for var item in Validators do
      if item.ID = walletID then
        flag := true;

    if not flag then
    begin
      Valid.ID := walletID;
      Valid.IP := Config.StaticIP;
      Validators.Add(Valid);
    end;
    StartSpeakerWork;
  end;

  if (NodeState = Validator) and (walletID > 0) then
  begin
    buf := walletID.AsBytes;
    cryptBuf := RSAEncrypt(WalletCore.CurrentWallet.PrivKey, buf);
    Packet.CreatePacket(CMD_REQUEST_ID_IN_SYSTEM, buf + cryptBuf);
    NetCore.MainClient.SendMessage(Packet);
  end;

  if NodeState = FullNode then
  begin
    Packet.CreatePacket(CMD_REQUEST_GET_VALIDATORS, []);
    NetCore.MainClient.SendMessage(Packet);
  end;
end;

procedure TConsensusCore.DoRequestAllTransactions;
var
  Packet: TPacket;
begin
  for var item in NetCore.Clients do
  begin
    if item.IDNode > 0 then
    begin
      Packet.CreatePacket(CMD_REQUEST_GET_CACHE, []);
      item.SendMessage(Packet);
    end;
  end;
end;

function TConsensusCore.GetValidators: TBytes;
begin
  Result := [];
  for var item in Validators do
    Result := Result + item.ID.AsBytes + TBytes(item.IP);
end;

procedure TConsensusCore.Refused—hangeSpeaker;
begin

end;

procedure TConsensusCore.SetValidators(AData: TBytes);
var
  counter: integer;
  Validator: TValidator;
begin
  counter := 0;
  while counter < Length(AData) do
  begin
    Validator := Default (TValidator);

    var
    flag1 := False;
    var
    flag2 := False;

    Move(AData[counter], Validator.ID, SizeOf(Validator.ID));
    inc(counter, SizeOf(Validator.ID));

    Move(AData[counter], Validator.IP, SizeOf(Validator.IP));
    inc(counter, SizeOf(Validator.IP));

    for var item in NetCore.Clients do
      if item.GetIP = Validator.IP then
      begin
        flag1 := true;
        Validator.Client := item;
      end;

    for var anyValid in Validators.List do
      if anyValid.ID = Validator.ID then
      begin
        flag2 := true;
      end;

    if not flag1 then
    begin
      Validator.Client := NetCore.NewValidatorClient(Validator.IP, Config.ClientPort, Validator.ID);
    end;

    if not flag2 then
    begin
      Validators.Add(Validator);
    end;
  end;
end;

procedure TConsensusCore.StartSpeakerWork;
var
  Count: integer;
begin
  cancelationToken := False;
  TTask.Run(
    procedure
    var
      countBlocks: UInt64;
      Packet: TPacket;
    begin
      UI.ShowMessage('System Info: Start Speaker work');

      repeat
        DoRequestAllTransactions;
        Sleep(Speaker_DELAY);
      until (BlockChain.Inquiries.CountCacheBlock > 0) or cancelationToken;

      UI.ShowMessage('System Info: Accept blocks');

      if cancelationToken then
        exit;
      TThread.Synchronize(nil,
        procedure
        begin
          UI.ShowMessage('System Info: Start Aprove blocks');
          BlockChain.Inquiries.ApproveAllCachedBlocks(WalletCore.CurrentWallet, countBlocks);
          UI.ShowMessage('System Info: End Aprove blocks');
          Packet.CreatePacket(CMD_RESPONSE_GET_NEW_BLOCKS, BlockChain.Inquiries.GetBlocksFrom(BlockChain.Inquiries.MainChainCount - countBlocks));
          NetCore.SendAll(Packet);
          ChooseNewSpeaker;
        end);
    end);
end;

procedure TConsensusCore.Successful—hangeSpeaker;
begin
  WaitNewSpeaker := False;
  NodeState := Validator;
  UI.ShowMessage('System Info: Now you are - Validator');
end;

procedure TConsensusCore.UpdateValidators(ID: UInt64);
var
  Packet: TPacket;
begin
  if (NodeState = Validator) or (NodeState = Speaker) then
    if Validators.Count > 0 then
      if ID = Validators.List[Validators.Count - 1].ID then
      begin
        Packet.CreatePacket(CMD_RESPONSE_GET_VALIDATORS, GetValidators);
        NetCore.SendAllMy(Packet);
      end;
end;

class operator TIP.Implicit(Value: TIP): string;
begin
  Result := Value.IP[0].ToString + '.' + Value.IP[1].ToString + '.' + Value.IP[2].ToString + '.' + Value.IP[3].ToString;
end;

class operator TIP.Implicit(Value: string): TIP;
var
  IP: TIP;
begin
  var
    items: TArray<string> := SplitString(Value, '.');
  if (items.Length < 4) or (items[0].ToInteger > 255) or (items[1].ToInteger > 255) or (items[2].ToInteger > 255) or (items[3].ToInteger > 255) or
    (items[0].ToInteger < 0) or (items[1].ToInteger < 0) or (items[2].ToInteger < 0) or (items[3].ToInteger < 0) then
    IP := Default (TIP)
  else
  begin
    IP.IP[0] := items[0].ToInteger;
    IP.IP[1] := items[1].ToInteger;
    IP.IP[2] := items[2].ToInteger;
    IP.IP[3] := items[3].ToInteger;
  end;
  Result := IP;
end;

class operator TIP.Implicit(Value: TIP): TBytes;
var
  Data: TBytes;
begin
  SetLength(Data, SizeOf(TIP));
  Move(Value.IP[0], Data[0], SizeOf(TIP));
  Result := Data;
end;

class operator TIP.Implicit(Value: TBytes): TIP;
var
  RIP: TIP;
begin
  Move(Value[0], RIP.IP[0], Length(Value));
  Result := RIP;
end;

end.
