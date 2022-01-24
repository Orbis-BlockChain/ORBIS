unit App.Packet;

interface

uses
  System.SysUtils;

type
  TPacket = packed record
    PacketType: Byte; // 1
    PacketSize: UInt64; // 8
    PacketBody: TBytes; // any
    class operator Implicit(Buf: TPacket): TBytes;
    class operator Implicit(Buf: TBytes): TPacket;
    class operator Add(buf1: TBytes; buf2: TPacket): TBytes;
    class operator Add(buf2: TPacket; buf1: TBytes): TBytes;
    procedure CreatePacket(APacketType: Byte; const data: TBytes); overload;
    procedure CreatePacket(APacketType: Byte; const data: UInt64); overload;
  end;

  TPackets = packed record
    Items: array of TPacket;
    class operator Implicit(Buf: TPackets): TBytes;
    class operator Implicit(const Buf: TBytes): TPackets;
  end;

implementation

{ TPackage }

class operator TPacket.Add(buf1: TBytes; buf2: TPacket): TBytes;
var
  LData, RData: TBytes;
  counter: integer;
begin
  RData := buf1;
  SetLength(LData, SizeOf(buf2.PacketType) + SizeOf(buf2.PacketSize) + buf2.PacketSize);
  counter := 0;
  Move(buf2.PacketType, LData[0], SizeOf(buf2.PacketType));
  inc(counter);

  Move(buf2.PacketType, LData[counter], SizeOf(buf2.PacketSize));
  inc(counter, SizeOf(buf2.PacketSize));

  Move(buf2.PacketBody[0], LData[counter], buf2.PacketSize);
  RData := RData + LData;
  Result := RData;
end;

class operator TPacket.Add(buf2: TPacket; buf1: TBytes): TBytes;
var
  LData, RData: TBytes;
  counter: integer;
begin
  RData := buf1;
  SetLength(LData, SizeOf(buf2.PacketType) + SizeOf(buf2.PacketSize) + buf2.PacketSize);
  counter := 0;
  Move(buf2.PacketType, LData[0], SizeOf(buf2.PacketType));
  inc(counter);

  Move(buf2.PacketType, LData[counter], SizeOf(buf2.PacketSize));
  inc(counter, SizeOf(buf2.PacketSize));

  Move(buf2.PacketBody[0], LData[counter], buf2.PacketSize);
  RData := LData + RData;
  Result := RData;
end;

procedure TPacket.CreatePacket(APacketType: Byte; const data: UInt64);
var
  Buf: TBytes;
begin
  PacketType := APacketType;
  PacketSize := SizeOf(data);
  SetLength(Buf, SizeOf(data));
  Move(data, Buf[0], SizeOf(data));
  PacketBody := Buf;
end;

procedure TPacket.CreatePacket(APacketType: Byte; const data: TBytes);
begin
  PacketType := APacketType;
  PacketSize := Length(data);
  PacketBody := data;
end;

class operator TPacket.Implicit(Buf: TBytes): TPacket;
var
  counter: integer;
begin
  counter := 0;
  Move(Buf[counter], Result.PacketType, SizeOf(Result.PacketType) + SizeOf(Result.PacketSize));
  inc(counter, SizeOf(Result.PacketType) + SizeOf(Result.PacketSize));

  SetLength(Result.PacketBody, Result.PacketSize);
  Move(Buf[counter], Result.PacketBody[0], Result.PacketSize);
end;

class operator TPacket.Implicit(Buf: TPacket): TBytes;
var
  Size: integer;
  counter: integer;
begin
  counter := 0;
  SetLength(Result, SizeOf(Buf.PacketType) + SizeOf(Buf.PacketSize) + Buf.PacketSize);
  Move(Buf, Result[counter], SizeOf(Buf.PacketType) + SizeOf(Buf.PacketSize));
  inc(counter, SizeOf(Buf.PacketType) + SizeOf(Buf.PacketSize));
  Move(Buf.PacketBody[0], Result[counter], Buf.PacketSize);
end;

{ TPackets }

class operator TPackets.Implicit(const Buf: TBytes): TPackets;
var
  Packet: TPacket;
  counter, BufSize, PacketSize: integer;
begin
  Result.Items := [];

  BufSize := Length(Buf);
  counter := 0;
  while counter < BufSize do
  begin
    Packet.PacketType := Buf[counter];
    inc(counter, SizeOf(Packet.PacketType));

    Move(Buf[counter], Packet.PacketSize, SizeOf(Packet.PacketSize));
    inc(counter, SizeOf(Packet.PacketSize));

    SetLength(Packet.PacketBody, Packet.PacketSize);

    Move(Buf[counter], Packet.PacketBody[0], Packet.PacketSize);
    inc(counter, Packet.PacketSize);

    Result.Items := Result.Items + [Packet];
  end;
end;

class operator TPackets.Implicit(Buf: TPackets): TBytes;
var
  Packet: TPacket;
begin
  Result := [];
  for Packet in Buf.Items do
    Result := Result + Packet;
end;

end.
