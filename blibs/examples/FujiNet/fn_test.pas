(* Basic FujiNet operations: interacting with hosts, mounting disk images *)
program fn_test;
uses sio, fn_sio;

var
    slots : FN_HostSlots;  { list of host names }
    devs : FN_DeviceSlots;  { list of mounted disks (metadata + names) }
    dev : ^FN_DeviceSlot;  { auxiliary variable to access device (meta)data }
    i : byte;
    hs : byte;
    direntry : array[0..37] of char;
    dirname : array of char = ''#0;  { directory spec (empty = root) }
    fname : string;

begin
    (* get host slots *)
    FN_GetHostSlots(@slots);
    if DCB.dstats <> 1 then
        writeln('Error retrieving host slots')
    else begin
        writeln(#$9b, 'Host slots:'*);
        for i := 0 to 7 do begin
            write(i + 1, ': ');
            writeln(@slots[i][0]);
        end;
        writeln;
    end;

    (* read directory *)
    write('Host number (0 to exit): ');
    readln(hs);
    if hs = 0 then exit;
    dec(hs);
    FN_MountHost(hs);  { open host for reading }
    FN_OpenDirectory(hs, @dirname, 0);  { open the root directory }
    writeln(#$9b, 'Files:'*);
    direntry[0] := ' ';
    while direntry[0] <> chr($7f) do begin  { $7f - no more entries }
        FN_ReadDirectory(38, hs, @direntry);  { retrieve one entry }
        writeln(@direntry);
    end;
    writeln('Entries: ', FN_GetDirectoryPosition, #$9b);

    (* mount *)
    write('Mount: ');
    readln(fname);
    if fname = '' then exit;
    fname[length(fname) + 1] := #0;
    FN_SetDeviceFilename(0, hs, FN_MOUNT_READ, @fname[1]);  { prepare mount }
    FN_MountDiskImage(0, FN_MOUNT_READ);  { mount the prepared disk image }

    (* get device slots *)
    FN_GetDeviceSlots(@devs);  { retrieve the list of mounted devices }
    if DCB.dstats <> 1 then
        writeln('Error retrieving device slots')
    else begin
        writeln(#$9b, 'Device slots:'*);
        for i := 0 to 7 do begin
            write(i + 1, ': ');
            dev := @devs[i, 0];
            writeln(dev.filename);
        end;
    end;
end.

