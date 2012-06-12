package
{

	import asunit.framework.TestCase;
	import flash.display.Sprite;
	import flash.geom.Point;

	/**
	 * All trace-expression tests.
	 */
	public class ASTTests extends TestCase
	{
		public function ASTTests()
		{
			super();
		}
		
		public function testSimplePrimitive() : void
		{
			10;
			trace(10);
		}

		public function testSimpleAssignment() : void
		{
			var i:int = 10;
			trace(i,":",int,"=",10);
		}

		public function testAddition() : void
		{
			10 + 20;
			trace(10,"+",20);
		}
		
		public function testStandaloneVariable() : void
		{
			var myVar : int = 1;
			var i:int = myVar;
			trace(i,":",int,"=",myVar);
		}

		public function testVariableAndPrimitive() : void
		{
			var myVar : int = 1;
			var i:String = myVar + "hello";
			trace(i,":",String,"=",myVar,"+","hello");
		}
		
		public function testRoundBracesInExpression() : void
		{
			var y : int = 1;
			var x : int = (y + 10);
			trace(x,":",int,"=(",y,"+",10,")");
		}
	
		public function testMethod() : void
		{
			var myVar : Number = .5;
			method( myVar );
			trace(method(myVar));
		}
		
		public function testStaticMethod() : void
		{
			var myVar : Number = .5;
			Math.round( myVar );
			trace(Math.round(myVar));
		}
		
		public function testMethodContainingExpression() : void
		{
			var myVar : Number = .5;
			Math.round( myVar + 10 );
			trace(Math.round(myVar+10));
		}
		
		public function testNestedMethods() : void
		{
			var myVar : Number = .5;
			Math.round( Math.sqrt( myVar ) );
			trace(Math.round(Math.sqrt(myVar)));
		}
		
		public function testTernary() : void
		{
			var y : Number = .5;
			var x : int = (x != y) ? (x) : (y);
			trace(x,":",int,"=(",x,"!=",y,")?(",x,"):(",y,")");
		}
		
		public function testArray() : void
		{
			var arr : Array = [1];
			var y : int = arr[0];
			trace(y,":",int,"=",arr[0]);
		}
		
		public function testExpressionInArray() : void
		{
			var arr : Array = [ 1 ];
			var x : int, y : int, z : int;
			arr[x + y] + z;
			trace(arr[x+y],"+",z);
		}
		
		public function testNestedArrays() : void
		{
			var arr : Array = [ 1 ];
			var x : int, y : int, z : int;
			arr[arr[x + y] + z];
			trace(arr[arr[x+y]+z]);
		}
		
		public function testReturnStatement() : int
		{
			return 10 + 20;
			trace(10,"+",20);
		}
		
		public function testMethodCall() : void
		{
			var x : int, y : int, obj : Point;
			x + obj.clone().x + y;
			trace(x,"+",obj.clone().x,"+",y);
		}
		
		public function testDynamicObjectGetter() : void
		{
			var x : Object;
			x['y'] + 10;
			trace(x['y'],"+",10);
		}
		
		public function testNewObject() : void
		{
			var x : Object = new Object();
			trace(x,":",Object,"=",new Object());
		}
		
		public function testNewObjectWithParameters() : void
		{
			var y : int, z : int;
			var x : Point = new Point(y, z);
			trace(x,":",Point,"=",new Point(y,z));
		}
		
		public function testNewObjectMethodCall() : void
		{
			var x : int = new Point().add(new Point()).x + 10;
			trace(x,":",int,"=",new Point().add(new Point()).x,"+",10);
		}
		
		public function testNewObjectLiteral() : void
		{
			var x : int = {y:10}.y + 10;
			trace(x,":",int,"=",{y:10}.y,"+",10);
		}
		
		public function testNewObjectLiteralWithDynamicAccess() : void
		{
			var x : int = {y:10}['y'] + 10;
			trace(x,":",int,"=",{y:10}['y'],"+",10);
		}
		
		public function testChainedMethodsWithArgumentExpressions() : void
		{
			var whitespace : String, r : String;
			var y : String = whitespace + r.split( "\n" ).join( "\n" + whitespace );
			trace(y,":",String,"=",whitespace,"+",r.split("\n").join("\n"+whitespace));
		}
		
		public function testMethodWithNewObject() : void
		{
			var obj : Sprite;
			obj.addChildAt( new Sprite(), 1 );
			trace(obj.addChildAt(new Sprite(),1));
		}
		
		private function method(...args) : void 
		{
		}	
	}
}
