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
	import ca.aaronfay.dnode.events.RequestEvent;
	import com.junkbyte.console.ConsoleChannel;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Aaron Fay
	 */
	public dynamic class Store extends EventDispatcher 
	{
		
		private var _items:Array = [];
		private var ch:ConsoleChannel;
		
		public function Store() 
		{
			ch = new ConsoleChannel('Store' );
		}
		
		public function has(id):Boolean 
		{
			return items[id] != undefined;
		}
		
		// was "get" in the node version, reserved word in flash
		public function getById(id:*):* 
		{
			if (!has(id)) {
				return null;
			}
			return wrap(items[id]);
		}
		
		public function add(fn, id=undefined):* {
			if (id == undefined) {
				id = items.length;
			}
			items[id] = fn;
			return id;
		}

				
		public function cull(arg):* 
		{
			if (typeof arg == 'function') {
				arg = items.indexOf(arg);
			}
			delete items[arg];
			return arg;
		}
		
		public function indexOf(fn):int {
			return items.indexOf(fn)
		}
		
		
		public function get items():Array 
		{
			return _items;
		}
		
		public function set items(value:Array):void 
		{
			_items = value;
		}

		private function wrap(fn) {
			return function (...args) {
				(fn as Function).apply(this, args)
				autoCull(fn);
			}
			
		}
		private function autoCull(fn) {
			if (fn.hasOwnProperty('times')) {
				if (typeof fn.times == 'number') {
					fn.times --;
					if (fn.times == 0) {
						var id = cull(fn);
						dispatchEvent(new RequestEvent('cull', id));
					}
				}
			}
		}

		

		
	}

}