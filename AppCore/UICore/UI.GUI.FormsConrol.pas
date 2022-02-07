unit UI.GUI.FormsConrol;

interface

{$IFDEF GUII}

uses
  App.Notifyer,
  App.Globals,
  App.Meta,
  App.Types,
  DGUI.Form.Resources,
  DGUI.Form.LogIn,
  DGUI.Form.Registration,
  DGUI.Form.NewTransaction,
  DGUI.Form.Verification,
  DGUI.Form.Transactions,
  DGUI.Form.TransactionInfo,
  DGUI.Form.MyAddress,
  DGUI.ConfirmTransaction,
  DGUI.Form.Waiting,
  DGUI.Form.ResCryptocontainer,
  DGUI.Form.EnterCryptoKeys,
  DGUI.Form.FileCryptocontainer,
  DGUI.Form.GenCryptoKeys,
  DGUI.ConfirmOM,
  DGUI.Form.CreateToken,
  DGUI.Form.Progress,

  UI.Types,
  App.IHandlerCore,
  FMX.Forms,
  System.SysUtils,
  System.Generics.Collections,
  System.Hash,
  System.Classes;

type
  TFormsControl = class
  private
    PrevForm: TCommonCustomForm;
    subscribeKey: TBytes;
    procedure CreateForms(Args: TArray<string>);
    procedure HideAllForm;
    procedure doNetStateConnect;
    procedure doNetStateDisconnect;
  public
    procedure PreapareUpdate;
    procedure Initialize;
    procedure ShowForm(AType: byte; atgs: TArray<string>);
    constructor Create;
    destructor Destroy; override;
  end;
{$ENDIF}

implementation

{ TFormsControl }
{$IFDEF GUII}

procedure TFormsControl.doNetStateConnect;
begin
  Application.MainForm.Caption := GetCaption;
  if Assigned(TransactionsForm) then
    TransactionsForm.Caption := GetCaption;

  if Assigned(TransactionInfoForm) then
    TransactionInfoForm.Caption := GetCaption;

  if Assigned(MyAddressForm) then
    MyAddressForm.Caption := GetCaption;

  if Assigned(CreateTokenForm) then
    CreateTokenForm.Caption := GetCaption;
end;

procedure TFormsControl.doNetStateDisconnect;
begin
  ShowForm(ord(fLogin),[]);
  Application.MainForm.Caption := GetCaption;
end;

constructor TFormsControl.Create;
begin
  subscribeKey := THashSHA2.GetHashBytes(DateTimeToStr(Now));
  Notifyer.Subscribe(doNetStateConnect, TEvents.nOnMainConnect, subscribeKey);
  Notifyer.Subscribe(doNetStateDisconnect, TEvents.nOnMainDisconnect,
    subscribeKey);
end;

procedure TFormsControl.CreateForms(Args: TArray<string>);
begin
  Application.CreateForm(TWaitingForm, WaitingForm);
  Application.CreateForm(TResourcesForm, ResourcesForm);
end;

destructor TFormsControl.Destroy;
begin
  if Assigned(CreateTokenForm) then
  begin
    CreateTokenForm.Free;
    CreateTokenForm := nil
  end;
  if Assigned(TransactionsForm) then
  begin
    TransactionsForm.Free;
    TransactionsForm := nil;
  end;
  if Assigned(MyAddressForm) then
  begin
    MyAddressForm.Free;
    MyAddressForm := nil;
  end;
  if Assigned(TransactionInfoForm) then
  begin
    TransactionInfoForm.Free;
    TransactionInfoForm := nil;
  end;
  Notifyer.UnSubscribe(subscribeKey);
  Application.MainForm.Destroy;
end;

procedure TFormsControl.HideAllForm;
begin
  if Assigned(CreateTokenForm) then
    CreateTokenForm.Hide;
  if Assigned(TransactionsForm) then
    TransactionsForm.Hide;
  if Assigned(MyAddressForm) then
    MyAddressForm.Hide;
  if Assigned(TransactionInfoForm) then
    TransactionInfoForm.Hide;
end;

procedure TFormsControl.Initialize;
begin
  Application.Initialize;
  CreateForms([]);
end;

procedure TFormsControl.PreapareUpdate;
begin
  Application.CreateForm(TProgressForm, ProgressForm);
end;

procedure TFormsControl.ShowForm(AType: byte; atgs: TArray<string>);
var
  TypeForm: TDesktopForms;
  X, Y: integer;
  needDestroy: boolean;
begin
  TypeForm := TDesktopForms(AType);
  X := Application.MainForm.Left;
  Y := Application.MainForm.Top;

  PrevForm := Application.MainForm;
  needDestroy := True;
  case TypeForm of
    fRegestrattion:
      begin
        Application.MainForm.Hide;
        HideAllForm;
        RegistrationForm := TRegistrationForm.Create(nil);
        Application.MainForm := RegistrationForm;
        Application.MainForm.Show;
      end;
    fVerification:
      begin
        Application.MainForm.Hide;
        VerificationForm := TVerificationForm.Create(nil);
        Application.MainForm := VerificationForm;
        VerificationForm.Password := atgs[0];
        Application.MainForm.Show;
      end;
    fLogin:
      begin
        Application.MainForm.Hide;
        HideAllForm;
        LogInForm := TLogInForm.Create(nil);
        Application.MainForm := LogInForm;
        Application.MainForm.Show;
      end;
    fNewTransaction:
      begin
        Application.MainForm.Hide;
        NewTransactionForm := TNewTransactionForm.Create(nil);
        NewTransactionForm.ClearFields;
        Application.MainForm := NewTransactionForm;
        Application.MainForm.Show;
      end;
    fTransactionHistory:
      begin
        if not Assigned(TransactionsForm) then
          TransactionsForm := TTransactionsForm.Create(nil);
        needDestroy := False;
        TransactionsForm.Top := Y;
        TransactionsForm.Left := X + 30;
        TransactionsForm.Handler := Handler;
        TransactionsForm.token := atgs[0];
        TransactionsForm.Show;
      end;
    fTransaction:
      begin
        if not Assigned(TransactionInfoForm) then
          TransactionInfoForm := TTransactionInfoForm.Create(nil);
        needDestroy := False;
        TransactionInfoForm.Top := Y;
        TransactionInfoForm.Left := X + 30;
        TransactionInfoForm.SetData(atgs);
        TransactionInfoForm.Show;
      end;
    fMyAddress:
      begin
        if not Assigned(MyAddressForm) then
          MyAddressForm := TMyAddressForm.Create(nil);

        needDestroy := False;
        MyAddressForm.Top := Y;
        MyAddressForm.Left := X + 30;
        MyAddressForm.Show;
      end;
    fRestoreSelection:
      begin
        Application.MainForm.Hide;
        ResCryptocontainerForm := TResCryptocontainerForm.Create(nil);
        Application.MainForm := ResCryptocontainerForm;
        Application.MainForm.Show;
      end;
    fEnterWods:
      begin
        Application.MainForm.Hide;
        EnterWords := TEnterWords.Create(nil);
        Application.MainForm := EnterWords;
        Application.MainForm.Show;
      end;
    fChooseCC:
      begin
        Application.MainForm.Hide;
        FileCryptocontainerForm := TFileCryptocontainerForm.Create(nil);
        Application.MainForm := FileCryptocontainerForm;
        Application.MainForm.Show;
      end;
    fApproveTrx:
      begin
        Application.MainForm.Hide;
        ConfirmTransForm := TConfirmTransForm.Create(nil);
        ConfirmTransForm.SetData(atgs);
        Application.MainForm := ConfirmTransForm;
        Application.MainForm.Show;
      end;
    fWords:
      begin
        Application.MainForm.Hide;
        GenCryptoKeysForm := TGenCryptoKeysForm.Create(nil);
        Application.MainForm := GenCryptoKeysForm;
        Application.MainForm.Show;
      end;
    fApproveOM:
      begin
        Application.MainForm.Hide;
        ConfirmOMForm := TConfirmOMForm.Create(nil);
        ConfirmOMForm.SetData(atgs);
        Application.MainForm := ConfirmOMForm;
        Application.MainForm.Show;
      end;
    fCreateToken:
      begin
        if not Assigned(CreateTokenForm) then
          CreateTokenForm := TCreateTokenForm.Create(nil);
        needDestroy := False;
        CreateTokenForm.Top := Y;
        CreateTokenForm.Left := X + 30;
        CreateTokenForm.Show;
      end;
    fProgressBar:
      begin
        Application.MainForm.Hide;
        ProgressForm := ProgressForm.Create(nil);
        Application.MainForm := ProgressForm;
        Application.MainForm.Show;
      end;

    fWaiting:
      begin
        Application.MainForm.Hide;
        WaitingForm := TWaitingForm.Create(nil);
        Application.MainForm := WaitingForm;
        Application.MainForm.Show;
      end;
  end;
  Application.MainForm.Top := Y;
  Application.MainForm.Left := X;
{$IFDEF MSWINDOWS}
  if needDestroy then
    PrevForm.Free;
{$ENDIF}
end;
{$ENDIF}

end.
