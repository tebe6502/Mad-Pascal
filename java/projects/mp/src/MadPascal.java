import javax.script.Bindings;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.*;

// https://www.baeldung.com/java-nashorn
public class MadPascal {

	public static void main(String[] args) {

		ScriptEngine engine = new ScriptEngineManager().getEngineByName("nashorn");
		Bindings bindings = engine.getBindings(ScriptContext.ENGINE_SCOPE);

		try {
			Object result = engine
					.eval("load('classpath:mp.js');" + "var greeting='hello world';" + "print(greeting);" + "greeting");
		} catch (ScriptException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
