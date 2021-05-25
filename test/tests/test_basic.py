from testutils import testUtils
test = testUtils()

class Test_Basic_Arithmetics:

    def test_addition1(self):

        test.runCode("""
        var a:shortInt;
            b:byte;
            c:word;
        begin
            a := -30;
            b := 64;
            c := a + b;
        end.
        """)
    
        assert test.varWord('c') == 34

    def test_addition2(self):

        test.runCode("""
        var a:byte;
            b:word;
            c:cardinal;
            
        begin
            a := 200;
            b := 60000;
            c := b + b + a + 10;
        end.
        """)
    
        assert test.varCardinal('c') == 120210

