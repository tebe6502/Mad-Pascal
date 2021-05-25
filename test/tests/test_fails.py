from testutils import testUtils
test = testUtils();

class Test_Failures:

    def test_complex_fail_1(self):

        test.runCode("""
        var
          itout  : word;
          itin   : word;
          index  : word;
          primes : array[0..2] of word absolute $2000;
        begin
          index := 0;
          primes[0] := 2; primes[1] := 3; inc(index, 2);
          for itout := 5 to 7 do begin
            if (itout and 1) <> 0 then begin
              for itin := 3 to itout-1 do begin
                if (itout mod itin) = 0 then break;
              end;
              if itin = (itout-1) then begin
                primes[index] := itout; inc(index);
              end;
            end;
          end;
        end.
        """);
        assert test.getWord(0x2000 + 2*2) == 5;
        assert test.getWord(0x2000 + 3*2) == 7;

