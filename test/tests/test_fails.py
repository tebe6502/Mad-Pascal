from testutils import testUtils
test = testUtils()

class Test_Failures:

    def test_complex_fail_1(self):

        test.runCode("""
        var
          itout  : word;
          itin   : word;
          index  : word;
          primes : array[0..3] of word absolute $2000;
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
        """)
        assert test.getWord(0x2000 + 2*2) == 5
        assert test.getWord(0x2000 + 3*2) == 7

      
    def test_consecutive_reading_of_changing_register_fails (self):
      
        test.runCode("""
        var a, b, c: byte;
            timer: byte = 0; // initialized to suppress warning
        begin
            a := timer;
            asm { nop }; // nop fixes that
            b := timer;
                          // without fix
            c := timer;
        end.
        """,
        counters = ['timer'] )
            
        assert test.varByte('a') != test.varByte('b')
        assert test.varByte('b') != test.varByte('c')

        test.clearCounters()

