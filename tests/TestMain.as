package
{

	import asunit.textui.TestRunner;

	/**
	 * Root class for trace-expression tests.
	 */
	public class TestMain extends TestRunner
	{
		public function TestMain()
		{
			start( AllTests );
		}
	}
}
