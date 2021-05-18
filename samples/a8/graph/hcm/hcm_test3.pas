uses crt, hcm2, zx0;

{$r hcm_test3.rc}

var i: byte;
    p: pointer;
    ch: char;

begin

 HCMInit(LoRes);

 while true do begin

 GetResourceHandle(p, 'pic1');
 unZX0(p, pointer(HCMBase));
 while consol <> cn_start do;

 GetResourceHandle(p, 'pic4');
 unZX0(p, pointer(HCMBase));
 while consol <> cn_start do;

 GetResourceHandle(p, 'pic2');
 unZX0(p, pointer(HCMBase));
 while consol <> cn_start do;

 GetResourceHandle(p, 'pic3');
 unZX0(p, pointer(HCMBase));
 while consol <> cn_start do;

 GetResourceHandle(p, 'pic5');
 unZX0(p, pointer(HCMBase));

 while consol <> cn_start do;

 end;

end.
