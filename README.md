This 'library' currently only works with dnode<1.0.0.  


WARNING
===

This is an early implementation of the dnode-as3-client project and should be considered 'alpha' quality at best.  Use at your own risk.


WARNING 2
===

Use of this library will require that you hack your dnode installation.  Yikes!  Yes, it's true, I've chosen the XMLSocket class for communications with dnode, however, dnode-protocol is a '\n' (newline) delimited protocol, and XMLSocket requires a '\0' terminator in order for the proper data event to fire in actionscript.  In similar fashion, dnode-protocol has to be hacked to strip the '\0' character or the JSON parser gets mad.  I will fix this in the next version to use the Socket class.



TODO
===
 
 - Fix for use with dnode@1.0.x
 - Replace XMLSocket with Socket class
 - Remove cruft
 - Tests
 - Examples
 - Documentation
 - Coffee break

License - MIT
===

Copyright (c) 2012 Aaron Fay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

