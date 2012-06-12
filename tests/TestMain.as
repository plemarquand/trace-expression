package
{

	import fdt.ast.IFdtAstNode;
	import swf.bridge.FdtEditorContext;
	import swf.bridge.IFdtActionBridge;
	import swf.plugin.ISwfActionPlugin;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	/**
	 * Root class for trace-expression tests.
	 */
	[FdtSwfPlugin(name="trace-expression-tests", pluginType="action", toolTip="Unit tests for trace-expression")]
	public class TestMain extends Sprite implements ISwfActionPlugin
	{	
		[Embed(source="../tests/ASTTests.as",mimeType="application/octet-stream")]
		public var sourceFile : Class;
		
		private static const TEST_FILE : String = "/tests/ASTTests.as";
		
		private var _bridge : IFdtActionBridge;
		private var _context : FdtEditorContext;

		public function init(bridge : IFdtActionBridge) : void
		{
			_bridge = bridge;
			_bridge.editor.getCurrentContext().sendTo( this, useContext );
		}

		private function useContext(context : FdtEditorContext) : void
		{
			_context = context;

			// Assumes we're running the test from inside FDT,
			// starting it from a file that is within the trace-expression project.
			var split : Array = context.currentFile.split( "/" );
			var path : String = "/" + split[1] + TEST_FILE;

			context.currentFile = path;

			_bridge.model.fileAst( path ).sendTo( this, useAst );
		}

		private function useAst(root : IFdtAstNode) : void
		{
			var expressionVisitor : TestVisitor = new TestVisitor( new sourceFile(), _context, _bridge, testsComplete );
			expressionVisitor.visit( root );
		}

		private function testsComplete(passedTests : int, failedTests : int, failedTestNames : Array) : void
		{
			trace( "========TESTS COMPLETE========" );
			trace( "Passsed tests:", passedTests );
			trace( "Failed tests:", failedTests );

			if (failedTestNames.length)
			{
				trace( '\t', failedTestNames.join( '\n\t' ) );
			}
		}

		public function callEntryAction(entryId : String) : void
		{
		}

		public function createProposals(ec : FdtEditorContext) : void
		{
		}

		public function dialogClosed(dialogInstanceId : String, result : String) : void
		{
		}

		public function setOptions(options : Dictionary) : void
		{
		}
	}
}

import fdt.ast.FdtAstFunction;
import fdt.ast.IFdtAstNode;
import fdt.ast.util.FdtAstVisitor;
import swf.bridge.FdtEditorContext;
import swf.bridge.IFdtActionBridge;

class TestVisitor extends FdtAstVisitor
{
	private var _completeCallback : Function;
	private var _context : FdtEditorContext;
	private var _bridge : IFdtActionBridge;
	private var _source : String;
	
	public var failedTests : int = 0;
	public var passedTests : int = 0;
	public var failedTestNames : Array = [];

	public function TestVisitor(source : String, context : FdtEditorContext, bridge : IFdtActionBridge, completeCallback : Function)
	{
		super();

		_source = source;
		_context = context;
		_bridge = bridge;
		_completeCallback = completeCallback;
	}

	override protected function enterNode(depth : int, parent : IFdtAstNode, name : String, index : int, node : IFdtAstNode) : Boolean
	{
		if (node is FdtAstFunction)
		{
			var fn : FdtAstFunction = node as FdtAstFunction;
			if (fn.name.content.indexOf( "test" ) == 0)
			{
				var statements : Vector.<IFdtAstNode> = fn.block.statements;
				if ( statements.length >= 2 )
				{
					var testStatement : IFdtAstNode = statements[statements.length - 2];
					var expectedStatement : IFdtAstNode = statements[statements.length - 1];
					var expectedResult : String = _source.substr( expectedStatement.offset, expectedStatement.length );
					
					_context.selectionOffset = testStatement.offset;
					_context.currentLineOffset = testStatement.offset;
					_context.currentLine = _source.substr( testStatement.offset, testStatement.length );

					var visitor : ExpressionVisitor = new ExpressionVisitor( _context, function(result : String) : void
					{
						if (result != expectedResult)
						{
							failedTests++;
							failedTestNames.push( fn.name.content + ": " + "Failure in " + fn.name.content + ". Expected " + expectedResult + " but was " + result );
						}
						else
						{
							passedTests++;
						}
					} );
					
					visitor.visit( testStatement );
				}
			}
		}
		return true;
	}

	override protected function leaveNode(depth : int, parent : IFdtAstNode, name : String, index : int, node : IFdtAstNode) : void
	{
		if (name == 'start')
		{
			_completeCallback( passedTests, failedTests, failedTestNames );
		}
		
		super.leaveNode( depth, parent, name, index, node );
	}
}

