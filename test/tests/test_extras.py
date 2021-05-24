from testutils import testUtils
test = testUtils();

class Test_Extras:
        
    def test_timeout(self):
        timeout = False;
        try:
            test.runCode("""
            begin
                repeat until false;
            end.
            """);
        except TimeoutError as err:
            print(err);
            timeout = True;
            
        assert timeout;


