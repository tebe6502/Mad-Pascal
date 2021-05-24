from testutils import testUtils
test = testUtils();

class Test_Multiplications:
        
    def test_simple_multiplication(self):
        
        test.runCode('''
        procedure breaktest; begin end;

        var a:word;
            b:byte;

        begin
            b:=27;
            a:=b*3;
            breaktest;
            
            a:=b*5;
            breaktest;
            
            a:=b*6;
            breaktest;
            
            a:=b*7;
            breaktest;
            
            a:=b*9;
        end.        
        ''', ['breaktest']);
        
        assert test.varByte('b') == 27;   
        assert test.varWord('a') == 27 * 3;
        
        test.resume();
        assert test.varWord('a') == 27 * 5;

        test.resume();
        assert test.varWord('a') == 27 * 6;

        test.resume();
        assert test.varWord('a') == 27 * 7;

        test.resume();
        assert test.varWord('a') == 27 * 9;
    
    def test_another_multiplication_inline(self):

        test.runCode("""
        var a:word;
            b:byte;
            w:word;
        begin
            b := 23;
            a := 45 * b;
            w := a * 10;
        end.
        """);
    
        assert test.varWord('w') == 23 * 45 * 10;

