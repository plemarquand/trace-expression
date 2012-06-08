trace-expression
================

An FDT swf-bridge plugin that takes a line of ActionScript code and creates a trace statement that outputs the expanded form of the expression.

This is best illustrated with an example. Take the following expression, which computes the slope of a line:

```actionscript
var y : Number = m * x + b;
```

Running the trace-expression command (using CMD/CTRL + 2 in FDT) produces:

```actionscript
trace(m, "*", x, "+", b);
var y : Number = m * x + b;
```

## Installation

Copy trace-expression.swf from /bin in to [path-to-fdt]/FDT/swfPlugins. Then go in to FDT and open Preferences > FDT > Swf Plugins and enable trace-expression from the list.