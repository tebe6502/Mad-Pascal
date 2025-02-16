unit rle;
(*
 @type: unit
 @author: Tomasz 'Tebe' Biela
 @name: RLE (Run Length Encoder)

 @version: 1.0

 @description:

*)

interface

function RLECompress(src,dst:PByte; srcSize:Word):Word; Register;
(*
@description:
*)

function RLEDecompress(src,dst:PByte; srcSize:Word):Word; Register;
(*
@description:
*)


implementation

function RLECompress(src,dst:PByte; srcSize:Word):Word; Register;
var
  repval:Byte;
  curr:Byte;
  prev:Byte;

begin
  result:=word(dst);
  repval:=0; curr:=0;

  prev:=src^ xor $ff; // The previous byte MUST always be different at the start
  while srcSize>0 do
  begin
    curr:=src^; inc(src); dec(srcSize);
    if curr<>prev then
    begin
      if (repval>0) then
      begin
        dst^:=repval-1; inc(dst);
        repval:=0;
      end;
      dst^:=curr; inc(dst);
    end
    else
    begin
      if (repval=0) then
      begin
        dst^:=curr; inc(dst);
      end;
      inc(repval);
      if repval=255 then
      begin
        dst^:=repval-1; inc(dst);
        repval:=0;
      end;
    end;
    prev:=curr;
  end;
  if (repval>0) then
  begin
    dst^:=repval-1; inc(dst);
    repval:=0;
  end;
  result:=word(dst)-result;
end;

function RLEDecompress(src,dst:PByte; srcSize:Word):Word; Register;
var
  repval:Byte;
  curr:Byte;
  prev:Byte;

begin
  result:=word(dst);
  repval:=0; curr:=0;

  prev:=src^ xor $ff; // The previous byte MUST always be different at the start
  while (srcSize>0) do
  begin
    curr:=src^; inc(src); dec(srcSize);
    dst^:=curr; inc(dst);
    if (curr=prev) then // repeated value
    begin
      repval:=src^; inc(src); dec(srcSize);
      if repval>0 then
        repeat
          dst^:=curr; inc(dst); dec(repval);
        until (repval=0);
    end;
    prev:=curr;
  end;
  result:=word(dst)-result;
end;

end.