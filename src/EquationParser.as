package
{
	/**
	 * Utility for parsing lines of ActionScript code and converting them to executable trace statements.
	 */
	public class EquationParser
	{
		private static const RESERVED_CHARACTERS : Array = [ '+', '-', '*', '/', '(', ')', ';', '>', '<', '~', '!', '%', '&', '|', ':', '?', '=' ];
		private static const METHOD_IDENTIFIER : String = "@";
		private static const ARR_OPEN_BRACKET : String = "[";
		private static const ARR_CLOSE_BRACKET : String = "]";
		
		public var isReturnStatement : Boolean = false;

		/**
		 * Parses a line of ActionScript code in the form of a string, and returns a trace statement
		 * formatted such that variables in the equation resolve themselves at runtime.
		 */
		public function parse(input : String) : String
		{
			// null input case returns nothing.
			if (input == null || input.length == 0)
			{
				return '';
			}

			var result : String = "";
			var lines : Array = input.split( ';' );

			// it's possible to have multiple expressions on one line.
			if (lines.length > 1)
			{
				// filter out the empty strings and then build several trace statements.
				lines.filter( function(line : String, ...args) : Boolean
				{
					return line.replace(/^\s+|\s+$/g, '').length > 0;
				} ).forEach( function(line : String, index : int, arr : Array) : void
				{
					result += parse( line ) + ((index != arr.length - 1) ? ('\n') : (''));
				} );
				return result;
			}

			// trim out the left hand side of the expression
			var leftHand : Object = /var.+?=/g.exec( input );
			isReturnStatement = !leftHand && ( ( leftHand = /\s*return/g.exec( input ) ) != null );
			if (leftHand)
			{
				input = input.substr( input.indexOf( leftHand[0] ) + leftHand[0]['length'] );
			}

			// get the right hand side of the expression (or the whole string if no assignment exists on the line)
			var expression : String = input;

			// trim whitespace and tokenize every character.
			var trimmed : String = expression.replace( /^\s+|\s+$/g, '' );
			var annotated : String = annotateMethods( trimmed );
			var split : Array = annotated.split( '' );

			var stringOpen : Boolean = false;
			var methodOpen : Boolean = false;
			var arrayCounter : int = 0;
			var len : int = split.length;
			for (var i : int = 0; i < len; i++)
			{
				var token : String = split[i];

				// inside array brackets we just dump content directly in, since to parse it regularly would result in strings used as the index.
				if (token == ARR_CLOSE_BRACKET)
				{
					arrayCounter--;
					result += token;
				}
				else if ( token == ARR_OPEN_BRACKET)
				{
					arrayCounter++;
					result += token;
				}
				else if (arrayCounter > 0)
				{
					result += token;
				}
				else if (token == ' ')
				{
					continue;
				}
				else if (token == METHOD_IDENTIFIER)
				{
					methodOpen = true;
					if (! stringOpen)
					{
						result += (result.length > 0 && result.substr( result.length - 2 ) != ", ") ? (", \"") : ("\"");
					}
				}
				else if (methodOpen)
				{
					result += token;

					if (token == '(')
					{
						result += "\", ";
						stringOpen = false;
						methodOpen = false;
					}
				}
				else
				{
					// it's reserved so we start wrapping it in a string.
					if (RESERVED_CHARACTERS.indexOf( token ) != -1)
					{
						if (! stringOpen)
						{
							result += (result.length > 0) ? (", \"") : ("\"");
						}

						result += token;

						if (stringOpen)
						{
							result += " ";
						}
						stringOpen = true;
					}
					else
					{
						// closes out the string
						if (stringOpen)
						{
							result += "\", ";
							stringOpen = false;
						}
						result += token;
					}
				}
			}

			if (stringOpen)
			{
				result += "\"";
			}

			return "trace(" + format( result ) + ");";
		}

		// inserts the method identifier before methods so the tokenizer knows where they start.
		private function annotateMethods(trimmed : String) : String
		{
			var method : RegExp = /[A-Za-z\._]+\(/g;
			var result : Object = method.exec( trimmed );
			var indicies : Array = [];
			while (result != null)
			{
				indicies.push( result['index'] );
				result = method.exec( trimmed );
			}

			for (var i : int = indicies.length - 1; i >= 0; i--)
			{
				var before : String = trimmed.substr( 0, indicies[i] );
				var after : String = trimmed.substr( indicies[i] );
				trimmed = before + METHOD_IDENTIFIER + after;
			}

			return trimmed;
		}

		private function format(str : String) : String
		{
			var tokens : Array = str.split( '' );
			var len : int = tokens.length;
			var formatted : String = tokens[len - 1];
			for (var i : int = len - 2; i >= 0; i--)
			{
				var token : String = tokens[i];
				if (EquationParser.RESERVED_CHARACTERS.indexOf( token ) != -1)
				{
					formatted = " " + token + " " + formatted;
				}
				else
				{
					formatted = token + formatted;
				}
			}

			// TODO: Format the output nicely.
			return str;
		}
	}
}
