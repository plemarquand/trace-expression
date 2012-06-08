package
{

	import asunit.framework.TestCase;
	
	/**
	 * All trace-expression tests.
	 */
	public class AllTests extends TestCase
	{
		private function runComparison(input : String, expected : String, isReturnStatement : Boolean = false) : void
		{
			var parser : EquationParser = new EquationParser();

			assertEquals( expected, parser.parse( input ) );
			assertEquals( isReturnStatement, parser.isReturnStatement );
		}

		public function testEmptyLine() : void
		{
			runComparison( "", "" );
		}

		public function testSimpleAssignment() : void
		{
			runComparison( "var i:int = 10", "trace(10);" );
		}

		public function testAddition() : void
		{
			runComparison( "var i:int = 10 + 20", "trace(10, \"+\", 20);" );
		}

		public function testStandaloneVariable() : void
		{
			runComparison( "var i:int = myVar", "trace(myVar);" );
		}

		public function testVariableAndPrimitive() : void
		{
			runComparison( "var i:String = myVar + \"hello\";", "trace(myVar, \"+\", \"hello\");" );
		}

		public function testRoundBracesInExpression() : void
		{
			runComparison( "var x : int = (y + 10);", "trace(\"(\", y, \"+\", 10, \")\");" );
		}

		public function testMultipleExpressionsOnOneLine() : void
		{
			runComparison( "var i:int = 10 + 20; var x:Number = 13 + y;", "trace(10, \"+\", 20);\ntrace(13, \"+\", y);" );
		}

		public function testNoSpaces() : void
		{
			runComparison( "var i:int = 10+20", "trace(10, \"+\", 20);" );
		}

		public function testMethod() : void
		{
			runComparison( "Math.round( myVar );", "trace(\"Math.round(\", myVar, \")\");" );
		}

		public function testMethodContainingExpression() : void
		{
			runComparison( "Math.round( myVar + 10 );", "trace(\"Math.round(\", myVar, \"+\", 10, \")\");" );
		}

		public function testNestedMethods() : void
		{
			runComparison( "Math.round( Math.sqrt( 10 ) );", "trace(\"Math.round(\", \"Math.sqrt(\", 10, \")) \");" );
		}

		public function testTernary() : void
		{
			runComparison( "var x : int = (x != y) ? (x) : (y);", "trace(\"(\", x, \"!= \", y, \")? ( \", x, \"): ( \", y, \")\");" );
		}

		public function testArray() : void
		{
			runComparison( "var y : int = arr[0]", "trace(arr[0]);" );
		}

		public function testExpressionInArray() : void
		{
			runComparison( "arr[x + y] + z", "trace(arr[x + y], \"+\", z);" );
		}

		public function testNestedArrays() : void
		{
			runComparison( "arr[arr[x + y] + z]", "trace(arr[arr[x + y] + z]);" );
		}

		public function testReturnStatement() : void
		{
			runComparison( "return 10 + 20", "trace(10, \"+\", 20);", true );
		}
		
		public function testTrailingWhitespace() : void
		{
			runComparison( "10 + 20; ", "trace(10, \"+\", 20);" );
		}
	}
}
