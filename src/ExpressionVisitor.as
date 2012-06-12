package
{

	import fdt.ast.FdtAstAllocation;
	import fdt.ast.FdtAstArguments;
	import fdt.ast.FdtAstArrayAccess;
	import fdt.ast.FdtAstObjectInitializer;
	import fdt.ast.FdtAstReturn;
	import fdt.ast.FdtAstString;
	import fdt.ast.IFdtAstNode;
	import fdt.ast.util.FdtAstVisitor;
	import swf.bridge.FdtEditorContext;

	/**
	 * A visitor for parsing single line expressions and converting them to executable trace statements.
	 */
	public class ExpressionVisitor extends FdtAstVisitor
	{
		private static const RESERVED_OPERANDS : Array = [ '+', '-', '*', '/', ';', '>', '<', '~', '!', '%', '&&', '||', ':', ';', '?', '=', '==', '!=', '||=' ];
		private static const PARENTHESES : Array = [ '(', ')' ];
		private var _context : FdtEditorContext;
		private var _output : String;
		private var _stringOpen : Boolean;
		private var _resultCallback : Function;
		private var _createdEdit : Boolean;
		private var _arrayAccessorCount : int = 0;
		private var _allocationCount : int = 0;
		private var _argumentCount : int = 0;
		private var _isReturnStatement : Boolean;
		private var _ignoreParentheses : Boolean;

		public function ExpressionVisitor(context : FdtEditorContext, resultCallback : Function)
		{
			super();

			_resultCallback = resultCallback;
			_context = context;
			_output = "";
		}

		override protected function enterNode(depth : int, parent : IFdtAstNode, name : String, index : int, node : IFdtAstNode) : Boolean
		{
			if (node && isNodeOnCurrentLine( node ))
			{
				var expression : String = _context.currentLine.substr( node.offset - _context.currentLineOffset, node.length );

				if (node is FdtAstArguments)
				{
					var args : FdtAstArguments = node as FdtAstArguments;
					if (args.children.length && _allocationCount == 0)
					{
						_argumentCount++;
					}
					else
					{
						_ignoreParentheses = true;
					}
				}
				else if (node is FdtAstArrayAccess )
				{
					_arrayAccessorCount++;
				}
				else if (node is FdtAstReturn)
				{
					_isReturnStatement = true;
				}
				else if (node is FdtAstAllocation || node is FdtAstObjectInitializer)
				{
					if (_stringOpen)
					{
						_stringOpen = false;
						_output += '",';
					}

					_allocationCount++;

					if (node is FdtAstAllocation)
					{
						_output += "new ";
					}
				}
				else if (node is FdtAstString)
				{
					_output += parseChunk( expression );
				}
			}

			if ( ! _createdEdit && node && node.offset >= _context.selectionOffset + _context.currentLine.length)
			{
				_createdEdit = true;
				_resultCallback( wrapInTrace( _output ) );
				return false;
			}

			return true;
		}

		override protected function leaveNode(depth : int, parent : IFdtAstNode, name : String, index : int, node : IFdtAstNode) : void
		{
			if (node && isNodeOnCurrentLine( node ))
			{
				if (node is FdtAstArrayAccess )
				{
					_arrayAccessorCount--;
				}
				else if (node is FdtAstAllocation)
				{
					_allocationCount--;
				}
				else if (node is FdtAstObjectInitializer)
				{
					_allocationCount--;
				}
				else if (node is FdtAstArguments)
				{
					var args : FdtAstArguments = node as FdtAstArguments;
					if (args.children.length && _allocationCount == 0)
					{
						_argumentCount--;
					}
					else
					{
						_ignoreParentheses = false;
					}
				}

				if (name == "start" && ! _createdEdit)
				{
					_resultCallback( wrapInTrace( _output ) );
				}
			}
		}

		private function wrapInTrace(str : String) : String
		{
			return "trace(" + str + ");";
		}

		override protected function visitToken(depth : int, parent : IFdtAstNode, name : String, index : int, tokenOffset : int) : void
		{
			if (isTokenOnCurrentLine( tokenOffset ))
			{
				var token : String = _context.currentLine.substr( tokenOffset - _context.currentLineOffset, 1 );
				_output += parseChunk( token );
			}
		}

		private function parseChunk(token : String) : String
		{
			// if we're inside an array accessor we just return everything literally, otherwise
			// we'd end up with accessors like arr[x, "+", y], which obviously wont compile.
			if (_arrayAccessorCount > 0 || _allocationCount > 0 || _argumentCount > 0)
			{
				return token;
			}

			if (RESERVED_OPERANDS.indexOf( token ) != -1 || (! _ignoreParentheses && PARENTHESES.indexOf( token ) != -1))
			{
				if (token == ';')
				{
					return (_stringOpen) ? ('"') : ('');
				}

				if (! _stringOpen)
				{
					_stringOpen = true;
					return ((_output.length) ? (',"') : ('"')) + token;
				}

				return token;
			}

			if (_stringOpen)
			{
				_stringOpen = false;
				return '",' + token;
			}
			else
			{
				return token;
			}
		}

		private function isNodeOnCurrentLine(node : IFdtAstNode) : Boolean
		{
			var lineStart : int = _context.currentLineOffset;
			var lineEnd : int = _context.currentLineOffset + _context.currentLine.length;
			return node.offset >= lineStart && node.offset + node.length <= lineEnd;
		}

		private function isTokenOnCurrentLine(tokenOffset : int) : Boolean
		{
			var lineStart : int = _context.currentLineOffset;
			var lineEnd : int = _context.currentLineOffset + _context.currentLine.length;
			return tokenOffset >= lineStart && tokenOffset <= lineEnd;
		}

		/**
		 * Returns true if the statement parsed contains a return statement.
		 */
		public function get isReturnStatement() : Boolean
		{
			return _isReturnStatement;
		}
	}
}
