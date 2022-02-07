unit App.Notifyer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs;

type
  TEvents = (nOnAcceptCC, nOnAcceptTransfers, nOnOkAuth, nOnBadAuth, nOnBadVersion, nOnGoodVersion, nOnStartDownalodBlocks, nOnEndDownloadBlocks,
    nOnMainConnect, nOnMainDisconnect, nOnDowloadUpdate, nOnSaveUpdatePackage, nOnStartInstall, nOnSwitchLang, nOnSwitchNET, nOnConsensusEnable,
    nOnConsensusDisable, nOnConsensusWait);

  TNotifyData = record
    TypeEvent: TEvents;
    CallBack: TProc;
    SubscribeToken: Tbytes;
  end;

  TNotifyer = class
    NotifyList: TList<TNotifyData>;
    CS: TCriticalSection;
  public
    procedure Subscribe(ACallBack: TProc; ATypeEvent: TEvents; ASubscribeToken: Tbytes);
    procedure UnSubscribe(ASubscribeToken: Tbytes);
    procedure DoEvent(AEvent: TEvents);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TNotifyer }

constructor TNotifyer.Create;
begin
  CS := TCriticalSection.Create;
  NotifyList := TList<TNotifyData>.Create;
end;

destructor TNotifyer.Destroy;
begin
  NotifyList.Clear;
  NotifyList.Free;
  CS.Free;
end;

procedure TNotifyer.DoEvent(AEvent: TEvents);
begin
  CS.Enter;
  try
    for var item in NotifyList do
      if item.TypeEvent = AEvent then
        try
          tthread.Queue(nil,
            procedure
            begin
              item.CallBack()
            end);
        finally

        end;
  finally
    CS.Leave;
  end;

end;

procedure TNotifyer.Subscribe(ACallBack: TProc; ATypeEvent: TEvents; ASubscribeToken: Tbytes);
var
  Notify: TNotifyData;
begin
  Notify.TypeEvent := ATypeEvent;
  Notify.CallBack := ACallBack;
  Notify.SubscribeToken := ASubscribeToken;
  CS.Enter;
  try
    NotifyList.Add(Notify);
  finally
    CS.Leave;
  end;
end;

procedure TNotifyer.UnSubscribe(ASubscribeToken: Tbytes);
var
  flag: boolean;
begin
  CS.Enter;
  try
    flag := true;
    while flag do
    begin
      flag := False;
      for var item in NotifyList do
        if ASubscribeToken = item.SubscribeToken then
        begin
          NotifyList.Remove(item);
          flag := true;
        end;
    end;
  finally
    CS.Leave;
  end;
end;

end.
