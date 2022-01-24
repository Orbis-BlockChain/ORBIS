unit App.Notifyer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  TEvents = (nOnAcceptCC, nOnAcceptTransfers, nOnOkAuth, nOnBadAuth, nOnBadVersion, nOnGoodVersion, nOnStartDownalodBlocks,
  nOnEndDownloadBlocks);

  TNotifyData = record
    TypeEvent: TEvents;
    CallBack: TProc;
  end;

  TNotifyer = class
    NotifyList: TList<TNotifyData>;
  public
    procedure Subscribe(ACallBack: TProc; ATypeEvent: TEvents);
    procedure DoEvent(AEvent: TEvents);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TNotifyer }

constructor TNotifyer.Create;
begin
  NotifyList := TList<TNotifyData>.Create;
end;

destructor TNotifyer.Destroy;
begin
  NotifyList.Clear;
  NotifyList.Free;
end;

procedure TNotifyer.DoEvent(AEvent: TEvents);
begin
  for var item in NotifyList do
    if item.TypeEvent = AEvent then
      try
        tthread.Synchronize(nil,
          procedure
          begin
            item.CallBack()
          end);
      finally

      end;
end;

procedure TNotifyer.Subscribe(ACallBack: TProc; ATypeEvent: TEvents);
var
  Notify: TNotifyData;
begin
  Notify.TypeEvent := ATypeEvent;
  Notify.CallBack := ACallBack;
  NotifyList.Add(Notify);
end;

end.
