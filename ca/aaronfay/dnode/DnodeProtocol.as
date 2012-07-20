/**
 * VERSION: 0.0.1
 * DATE: 2012-06-01
 * AS3 
 * 
 * Copyright (c) 2012 Aaron Fay - http://aaronfay.ca/
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, merge, 
 * publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
 * to whom the Software is furnished to do so, subject to the following conditions:
 *
 * - The above copyright notice and this permission notice shall be included in all copies or 
 *   substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 * 
 * Have a nice day :)
 * 
 **/
 
package ca.aaronfay.dnode 
{
	import com.junkbyte.console.ConsoleChannel;

	/**
	 * ...
	 * @author Aaron Fay
	 */
	public class DnodeProtocol 
	{
		private var ch:ConsoleChannel 
		private var _wrapper:Object;
		private var session:Session;
		
		public function DnodeProtocol(wrapper:Object) 
		{
			ch = new ConsoleChannel("DnodeProtocol");
			ch.debug('Started');
			
			_wrapper = wrapper;
		}
		
		public function create():Session {
			var id = Math.floor(Math.random() * Math.pow(2,32)).toString(16);
			session = new Session(id, _wrapper);
			return session;
		}
		
		public function destroy():void {
			session = undefined;
		}

		// parse connection parameters
		public static function parseArgs(arguments):Object {
			// set up debugger for static method
			//var ch = new ConsoleChannel("ParseArgs");

			var params = {};
			arguments.slice().forEach(function (arg) {
				if (typeof arg === 'string') {
					if (arg.match(/^\d+$/)) {
						params.port = parseInt(arg, 10);
					}
					else if (arg.match('^/')) {
						params.path = arg;
					}
					else {
						params.host = arg;
					}
				}
				else if (typeof arg === 'number') {
					params.port = arg;
				}
				else if (typeof arg === 'function') {
					params.block = arg; // the callback
				}
				else if (typeof arg === 'object') {
					// merge vanilla objects into params
					for(var key:String in arg) {
					  params[key] = arg[key];
					}
				}
				else if (typeof arg === 'undefined') {
					// ignore
				}
				else {
					throw new Error('DnodeProtocol parse error: not sure what to do about '
						+ typeof arg + ' objects');
				}
				
			});
			//ch.inspect(params);
			return params;
		}
		

		
	}

}























