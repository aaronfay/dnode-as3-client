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
	import com.adobe.serialization.json.JSON;
	import com.junkbyte.console.ConsoleChannel;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Aaron Fay
	 */
	public class Scrubber extends EventDispatcher 
	{
		private var _store:Store;
		private var callbacks;		
		private var ch:ConsoleChannel;
		private var _paths = { };
		
		public function Scrubber(store:Store=undefined) 
		{
			
			ch = new ConsoleChannel('Scrubber');
			ch.debug('started Scrubber')
			_store = store || new Store();
			callbacks = store.items;
			
		}
		
		public function scrub(obj:Object)
		{
			var paths = { };
			var links = [];

			// Traverse goes here...
			//var args = 
			var t:Traverse = new Traverse(obj);
			var args = t.map(function (node) {
				// scope is "traverse.state"
				if (typeof(node) == 'function') {
					var i:int = store.indexOf(node);
					//ch.debug('function index: ' + i)
					if (i >= 0 && !(i in paths)) {
						paths[i] = this.path;
					}
					else {
						var id = store.add(node);
						paths[id] = this.path;
					}
					
					this.update('[Function]');
				}
				else if (this.circular) {
					links.push( { from: this.circular.path, to: this.path } );
					this.update('[Circular]');
				}
				
			});
			
			
			_paths = paths;
			
			return {
				arguments: args,
				callbacks: paths,
				links: links
			}
		
		}
		
		public function unscrub(msg, f):Array {
			
			
			var args:Array = msg.arguments || [];
			
			//ch.debug(args)
			
			for (var key in msg.callbacks || { } ) { 
				var id = parseInt(key, 10);
				var path = msg.callbacks[id];
				
				args = setAt(args, path, f(id));
			}
			
			if (Object(msg).hasOwnProperty('links') && msg['links'].length > 0 ) {
				msg.links.forEach(function(link) {
					var value = getAt(args, link.from);
					args = setAt(args, link.to, value);
				});
			}

			return args;
		}
		
		private function setAt(ref, path:Array, value):*
		{

			var node = ref;
			for (var i:int = 0; i < (path as Array).length -1; i ++) {
				var key = path[i];
				if (node.propertyIsEnumerable(key)) {
					node = node[key];
				}
				else return undefined;
			}
			var last = (path as Array).slice( -1)[0];
			if (last == undefined) {
				return value;
			}
			else {
				node[last] = value;
				return ref;
			}
		}
		
		private function getAt(node:Array, path):* 
		{
			for (var i:int = 0; i < (path as Array).length; i ++) {
				var key = path[i];
				if (Object.prototype.propertyIsEnumerable.call(node, key)) {
					node = node[key];
				}
				else {
					return undefined
				}
			}
			return node;
		}
		
		
		
		public function get store():Store 
		{
			return _store;
		}
		
	}

}























