trace-expression
================

An swf-bridge plugin for FDT 5.5 that takes a line of ActionScript code and creates a trace statement that outputs the expanded form of the expression.

This is best illustrated with an example. Take the following expression, which computes the slope of a line:

```actionscript
var y : Number = m * x + b;
```

Running the trace-expression command (using CMD/CTRL + 2 in FDT) produces:

```actionscript
var y : Number = m * x + b;
trace(m,"*",x,"+",b);
```

## Installation

Copy trace-expression.swf from /bin in to ~Library/ApplicationSupport/FDT/swfPlugins on Mac, or . If the folder doesn't exist, create it and copy trace-expression.swf in to it. In Preferences > FDT > Swf Plugins trace-expression should be enabled in the list. You can toggle its avaliability from here.