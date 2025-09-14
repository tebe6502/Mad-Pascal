copy test_lib.obx disk
copy test.obx disk\autorun.

dir2atr.exe -md -B foxdos.obx disk.atr disk\

altirra64.exe disk.atr
pause
