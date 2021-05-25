from testutils import testUtils
test = testUtils()

class Test_Extras:
        
    def test_timeout(self):
        timeout = False
        try:
            test.runCode("""
            begin
                repeat until false;
            end.
            """)
        except TimeoutError as err:
            print(err)
            timeout = True
            
        assert timeout

    def test_counter(self):
        test.setIncrementingByte(500)
        test.runCode("""
        var a, b:byte;
        begin
            a := peek(500);
            asm { nop };
            b := peek(500);
        end.
        """)
            
        assert test.varByte('a') != test.varByte('b')