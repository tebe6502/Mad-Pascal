import javax.script.Bindings;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.*;

// https://www.baeldung.com/java-nashorn
public class MadPascal {
	ScriptEngine engine;
	long startTimeMillis;

	public static final class ScriptConsole {

		public ScriptConsole() {

		}

		static String toString(Object o) {
			return o == null ? "null" : o.toString();
		}

		public Object log(Object o1) {
			MadPascal.log(toString(o1));
			return null;
		}
	}

	private static void log(String message) {
		System.out.println(message);
	}

	private MadPascal() {
		engine = new ScriptEngineManager().getEngineByName("nashorn");
	}

	private void beginTimer(String id) {
		log("Starting "+id);
		startTimeMillis=System.currentTimeMillis();
	}
	
	private void endTimer() {
		String ms;
		ms= Long.toString(System.currentTimeMillis()-startTimeMillis);
		log("Completed after "+ms +" ms.");
		
	}
	
	private void run() {
		Bindings bindings = engine.getBindings(ScriptContext.ENGINE_SCOPE);
		ScriptConsole console = new ScriptConsole();

		bindings.put("console", console);
		System.out.println("Starting.");
		try {
			beginTimer("Loading");
			engine.eval("load('classpath:mp.js');");
			endTimer();
			beginTimer("Compiling 1");
			engine.eval("rtl.run();");
			endTimer();

			beginTimer("Compiling 2");
			engine.eval("rtl.run();");
			endTimer();
} catch (ScriptException ex) {
			// TODO Auto-generated catch block
			ex.printStackTrace();
		}
	}

	public static void main(String[] args) {

		MadPascal mp = new MadPascal();
		mp.run();
	}

}
