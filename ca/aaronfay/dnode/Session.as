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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Aaron Fay
	 */
	public dynamic class Session extends EventDispatcher 
	{
		private var _id:Number;
		public var remote:Object;
		public var instance:Object;
		private var ch:ConsoleChannel;
		
		private var localStore:Store;
		private var remoteStore:Store;
		private var scrubber:Scrubber;
		private var protocol:DnodeProtocol;
		
		private var _tempId;
		
		public function Session(id, wrapper) 
		{
			ch = new ConsoleChannel('Session')
			ch.debug('new session id: ' + id);
			_id = id;
			remote = { };

			instance = typeof(wrapper) == "function" ? new wrapper(remote, this) : wrapper || {};
			
			localStore = new Store();
			remoteStore = new Store();
			
			localStore.addEventListener('cull', function (id) {
				dispatchEvent(new RequestEvent('request', {
					method: 'cull', 
					arguments: [id],
					callbacks: {}
				}));
			});
			
			scrubber = new Scrubber(localStore);
			
		}
		
		public function start():void {
			this.request('methods', [instance]);
		}
		
		public function request(method:*, args:*):void {
			var scrub = scrubber.scrub(args);
			
			if (method == "0") {
				method = 0;
			}
			
			dispatchEvent(new RequestEvent('request', {
				method: method, 
				arguments: scrub.arguments,
				callbacks: scrub.callbacks,
				links: scrub.links
			}));
		}
		
		public function parse(line:String):void {
			var msg:Object = JSON.decode(line);
			// TODO: what exceptions does decode throw?
			handle(msg);
		}

		
		private function handle(req:Object):void 
		{
			var args:Array = scrubber.unscrub(req, function(id) {
				if (!remoteStore.has(id)) {
					// create a function only if one hasn't already been added for this id
					remoteStore.add(function(...args) {
						request(id, args)
						//request(id, Array.prototype.slice.apply(args));
					}, id);
				}
				
				var foo = remoteStore.getById(id)
				return foo
				
			});

			if (req.method == 'methods') {
				handleMethods(args[0]);
			}
			else if (req.method == 'error') {
				var methods = args[0];
				dispatchEvent(new RequestEvent('remoteError', methods));
			}
			else if (req.methods == 'cull') {
				args.forEach(function (id) {
					remoteStore.cull(id);
				})
			}
			else if (typeof req.method == 'string') {
				if (instance.propertyIsEnumerable(req.method)) {
					// don't think this will work...
					apply(instance[req.method], instance, args);
					//instance[req.method](args);
				} else {
					dispatchEvent(new ErrorEvent('error', false, false, "Request for a non-enumerable method: " + req.method));
				}
			} else if (typeof req.method == 'number') {
				apply(localStore.getById(req.method), instance, args);
				//localStore.getById(req.method)(args);
			}
		}
		
		private function handleMethods(methods:Object):void 
		{

			if (typeof methods != 'object') {
				methods = { };
			}
			
			for (var key in remote) {
				delete remote[key];
			}
			
			for (var key2 in methods) {
				remote[key2] = methods[key2];
			}

			dispatchEvent(new RequestEvent('remote', remote));
			dispatchEvent(new Event('ready'));
			
		}
		
		private function apply(f, obj, args) {
			f.apply(obj, args);
		}
		
	}

}
























