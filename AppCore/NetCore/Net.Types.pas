unit Net.Types;

interface

uses
  System.SysUtils

  ;

const
  LABNETPORT = 30300;
  TESTNETPORT = 30301;
  MAINNETPORT = 30302;
  HEART_BEAT_PACKET: Tbytes = [0,192,28];
type
  TDataSize = record
  const
    etNope = 0;
    etNotEqual = 1;
    etBadSizeData = 2;
    etBadData = 3;
  private
    function TypeErrorToStr: string;
  public
    Data: Integer;
    InvertData: Integer;
    Error: Boolean;
    TypeError: Byte;

    class function Empty: TDataSize; static;

    class operator Equal(const AData1: TDataSize; const AData2: Integer): Boolean; overload;
    class operator Equal(const AData1, AData2: TDataSize): Boolean; overload;
    class operator NotEqual(const AData1, AData2: TDataSize): Boolean;

    class operator Implicit(const AData: Integer): TDataSize;
    class operator Implicit(var AData: TDataSize): Integer;
    class operator Implicit(const AData: TBytes): TDataSize;
    class operator Implicit(const AData: TDataSize): TBytes;
    class operator Implicit(const AData: TDataSize): string;

    function Len: Integer;
    function IsEmpty: Boolean;
    function ErrToStr: string;
    function ToString: string;
    function ToBytes: TBytes;
    function ToInteger: Integer;
    function Name: string;
    procedure Clear;
  end;

implementation

{ TDataSize }

procedure TDataSize.Clear;
begin
  Self.Data:= 0;
  Self.InvertData:= 0;
  Self.Error:= False;
  Self.TypeError:= Self.etNope;
end;

class function TDataSize.Empty: TDataSize;
begin
  Result.Clear;
end;

class operator TDataSize.Equal(const AData1: TDataSize; const AData2: Integer): Boolean;
begin
  Result:= AData1.ToInteger = AData2;
end;

class operator TDataSize.Equal(const AData1, AData2: TDataSize): Boolean;
begin
  Result:= (AData1.Data = AData2.Data)
       and (AData1.InvertData = AData2.InvertData)
       and (AData1.Error = AData2.Error)
       and (AData1.TypeError = AData2.TypeError)
       ;
end;

function TDataSize.ErrToStr: string;
begin
  Result:= Self.TypeErrorToStr;
end;

function TDataSize.Name: string;
begin
  Result:= 'TDataSize';
end;

class operator TDataSize.NotEqual(const AData1, AData2: TDataSize): Boolean;
begin
  Result:= not (AData1 = AData2);
end;

class operator TDataSize.Implicit(const AData: TDataSize): string;
begin
  if (AData.Data = -1 * AData.InvertData) then
    Result:= AData.Data.ToString
  else
    Result:= 'Bad TDataSize: ' + AData.ErrToStr;
end;

class operator TDataSize.Implicit(var AData: TDataSize): Integer;
begin
  if (not AData.Error) then
    Result:= AData.Data
  else
  begin
    case AData.TypeError of
      AData.etNope:
      begin
        Result:= AData.etNope;
      end;
      AData.etNotEqual:
      begin
        Result:= -1 * AData.etNotEqual;
      end;
      AData.etBadSizeData:
      begin
        Result:= -1 * AData.etBadSizeData;
      end;
      AData.etBadData:
      begin
        Result:= -1 * AData.etBadSizeData;
      end;
    end;
    AData.Error:= True;
  end;
end;

class operator TDataSize.Implicit(const AData: Integer): TDataSize;
begin
  Result.Clear;
  Result.Data:= AData;
  Result.InvertData:= -1 * Adata;
end;

class operator TDataSize.Implicit(const AData: TDataSize): TBytes;
var
  i,sz: Integer;
begin
  SetLength(Result,AData.Len);

  i:= 0;
  sz:= SizeOf(AData.Data);
  Move(AData.Data,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.InvertData);
  Move(AData.InvertData,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.Error);
  Move(AData.Error,Result[i],sz);
  Inc(i,sz);

  sz:= SizeOf(AData.TypeError);
  Move(AData.TypeError,Result[i],sz);

end;

class operator TDataSize.Implicit(const AData: TBytes): TDataSize;
var
  i,sz: Integer;
  bn: Boolean;
begin
  Result.Clear;
  if (Length(Adata) >= Result.Len) then
  begin
    i:= 0;
    sz:= SizeOf(Result.Data);
    Move(AData[i],Result.Data,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.InvertData);
    Move(AData[i],Result.InvertData,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.Error);
    Move(AData[i],Result.Error,sz);
    Inc(i,sz);

    sz:= SizeOf(Result.TypeError);
    Move(AData[i],Result.TypeError,sz);
    if (Result.Data <> -1 * Result.InvertData) then
    begin
      if (Result.TypeError = Result.etNotEqual) and (not Result.Error) then
      else
        if (Result.TypeError = Result.etNotEqual) then
        begin
          Result.TypeError:= Result.etBadData;
        end;
      Result.Error:= True;
    end;
  end
  else
  begin
    Result.Error:= True;
    Result.TypeError:= Result.etBadSizeData;
  end;
end;

function TDataSize.IsEmpty: Boolean;
begin
  Result:= Self = Self.Empty;
end;

function TDataSize.Len: Integer;
begin
  Result:= SizeOf(Self.Data)
         + SizeOf(Self.InvertData)
         + SizeOf(Self.Error)
         + SizeOf(Self.TypeError)
         ;
end;

function TDataSize.ToBytes: TBytes;
begin
  Result:= Self;
end;

function TDataSize.ToInteger: Integer;
begin
  Result:= Self;
end;

function TDataSize.ToString: string;
begin
  Result:= Self;
end;

function TDataSize.TypeErrorToStr: string;
begin
  case Self.TypeError of
    Self.etNope:
    begin
      Result:= 'etNope';
    end;
    Self.etNotEqual:
    begin
      Result:= 'etNotEqual';
    end;
    Self.etBadSizeData:
    begin
      Result:= 'etBadSizeData';
    end;
    Self.etBadData:
    begin
      Result:= 'etBadData';
    end;
    else
    begin
      Result:= '* none *';
    end;
  end;
end;

end.
