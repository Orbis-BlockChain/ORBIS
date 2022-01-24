unit BlockChain.BaseBlock;

interface

uses
  System.SysUtils,
  System.Hash,
  System.Classes,
  App.Types,
  Wallet.Core,
  Wallet.Types,
  BlockChain.Types,
  Crypto.RSA;

type
  TBaseBlock = class abstract
  protected
    Header: THeader;
  public
    function GetHeader: THeader;
    procedure SignBlock(AWallet: TWallet; APreviousHash: THash;
      APreviosID: UInt64);
    function GetSizeBlock: UInt64; virtual; abstract;
    function GetData: TBytes; virtual; abstract;
    function GetDataWithoutHeader: TBytes; virtual; abstract;
    function GetDataHeader: TBytes; virtual; abstract;
    function GetHash: THash;
    procedure SetData(const AData: TBytes); virtual; abstract;
  end;

implementation

{ TBaseBlock }

function TBaseBlock.GetHash: THash;
begin
  Result := Header.CurrentHash;
end;

function TBaseBlock.GetHeader: THeader;
begin
  Result := Header;
end;

procedure TBaseBlock.SignBlock(AWallet: TWallet; APreviousHash: THash;
  APreviosID: UInt64);
var
  Buf: TMemoryStream;
  data, body: TBytes;
begin

  body := GetDataWithoutHeader;
  Buf := TMemoryStream.Create;
  Buf.WriteData(APreviousHash + body, SizeOf(THash) + Length(body));
  Buf.Position := 0;
  Header.CurrentHash := THashSHA2.GetHashBytes(Buf);
  Buf.Destroy;
  Header.IDBlock := APreviosID + 1;
  Header.WitnessID := WalletID;
  Buf := TMemoryStream.Create;
  Buf.WriteData(data, Length(data));
  Buf.Position := 0;
  Header.Sign := RSAEncrypt(AWallet.PrivKey, Header.CurrentHash);
  Buf.Destroy;
end;

end.
