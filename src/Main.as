package
{

	import fdt.FdtTextEdit;
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
			_bridge.offerProposal( "traceExpression", "traceExpressionIcon", "Create expression trace", "Creates a trace for the expression on this line.", onSelection );
		}

		private function onSelection(id : String, ec : FdtEditorContext) : void
		{
			var selectedText : String = ec.currentLine;

			var parser : EquationParser = new EquationParser();
			var result : String = parser.parse( selectedText );

			var textEdits : Vector.<FdtTextEdit> = new Vector.<FdtTextEdit>();
			var whitespaceResult : Object = /^[\s\t\n]+/.exec( ec.currentLine );
			var whitespace : String = (whitespaceResult) ? (whitespaceResult[0]) : '';
			var toInput : String = whitespace + result.split( "\n" ).join( "\n" + whitespace );

			// traces evaluating return statements should be placed in front of the execution of the line
			// otherwise we'll never see the trace!
			if (parser.isReturnStatement)
			{
				textEdits.push( new FdtTextEdit( ec.currentLineOffset, 0, toInput + "\n" ) );
			}
			else
			{
				textEdits.push( new FdtTextEdit( ec.currentLineOffset + ec.currentLine.length, 0, "\n" + toInput ) );
			}

			_bridge.model.fileDocumentModify( ec.currentFile, textEdits ).sendTo( this, null );
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
