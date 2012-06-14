package
{

	import fdt.FdtTextEdit;
	import fdt.ast.IFdtAstNode;
	import swf.bridge.FdtEditorContext;
	import swf.bridge.IFdtActionBridge;
	import swf.plugin.ISwfActionPlugin;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	/**
	 * Main class for trace-expression
	 */
	[FdtSwfPlugin(name="trace-expression", pluginType="action", toolTip="Inspect an expression in a trace statement.")]
	public class Main extends Sprite implements ISwfActionPlugin
	{
		[Embed(source="../assets/quotes.png", mimeType="application/octet-stream")]
		private var _icon : Class;
		
		private var _bridge : IFdtActionBridge;
		private var _context : FdtEditorContext;
		private var _ec : FdtEditorContext;
		private var _visitor : ExpressionVisitor;

		public function Main()
		{
			FdtSwfPluginIcon;
		}

		public function init(bridge : IFdtActionBridge) : void
		{
			_bridge = bridge;
			_bridge.ui.registerImage( "traceExpressionIcon", new _icon() ).sendTo( null, null );
		}

		public function createProposals(ec : FdtEditorContext) : void
		{
			trace("Main.createProposals(",ec,")");
			_bridge.offerProposal( "traceExpression", "traceExpressionIcon", "Create expression trace", "Creates a trace for the expression on this line.", onSelection );
		}

		private function onSelection(id : String, ec : FdtEditorContext) : void
		{
			trace("Main.onSelection(",id, ec,")");
			_ec = ec;
			_bridge.editor.getCurrentContext().sendTo( this, useContext );
		}

		private function useContext(context : FdtEditorContext) : void
		{
			trace("Main.useContext(",context, context.currentFile,")");
			_context = context;
			_bridge.model.fileAst( context.currentFile ).sendTo( this, useAst );
		}

		private function useAst(root : IFdtAstNode) : void
		{
			trace("Main.useAst(",root,")");
			_visitor = new ExpressionVisitor( _context, onParsed );
			_visitor.visit( root );
		}

		private function onParsed(result : String) : void
		{
			trace("Main.onParsed(",result,")");
			var textEdits : Vector.<FdtTextEdit> = new Vector.<FdtTextEdit>();
			var whitespaceResult : Object = /^[\s\t\n]+/.exec( _ec.currentLine );
			var whitespace : String = (whitespaceResult) ? (whitespaceResult[0]) : '';
			var toInput : String = whitespace + result.split( "\n" ).join( "\n" + whitespace );

			// traces evaluating return statements should be placed in front of the execution of the line
			// otherwise we'll never see the trace!
			if (_visitor.isReturnStatement)
			{
				textEdits.push( new FdtTextEdit( _ec.currentLineOffset, 0, toInput + "\n" ) );
			}
			else
			{
				textEdits.push( new FdtTextEdit( _ec.currentLineOffset + _ec.currentLine.length, 0, "\n" + toInput ) );
			}

			_bridge.model.fileDocumentModify( _ec.currentFile, textEdits ).sendTo( this, null );
		}

		public function callEntryAction(entryId : String) : void
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
