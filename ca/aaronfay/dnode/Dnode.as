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
	import ca.aaronfay.dnode.events.StreamEvent;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.ConsoleChannel;
	import com.adobe.serialization.json.JSON;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import ca.aaronfay.dnode.events.RawMessageEvent;
	import ca.aaronfay.dnode.DnodeProtocol;

	/**
	 * ...
	 * @author Aaron Fay
	 */
	public class Dnode extends EventDispatcher
	{


		private var ch:ConsoleChannel;
		private var proto:DnodeProtocol;
		private var stack:Array;
		private var stream:Stream;
		private var client:Session = undefined;
		private var params:Object;
		
		// set up the layers of the dnode protocol
		// dnodeProtocol object
		// traverse object (static?)
		// Session
		// Scrubber
		// Store
		// don't forget to add 'parseArgs' to DnodeProtocol
		
		
		public function Dnode(wrapper:*)
		{
			
			if (wrapper == undefined) {
				wrapper = {}
			}
			
			// some debug bits
			ch = new ConsoleChannel('Dnode');
			ch.debug('Started');

			if (wrapper == undefined) {
				wrapper = {}
			}
			// protocol instance
			proto = new DnodeProtocol(wrapper);
			stack = [];
			//
		}
		
		public function connect(...arguments):Dnode {
			// TODO: I skipped a whoooole bunch of stuff I don't think we need
			// from the original version
			params = DnodeProtocol.parseArgs(arguments);
			stream = new Stream(params.host, params.port);
			
			// if(params.reconnect)
			if (true) {
				// TODO: RECONNECT HERE
				// add listeners for security errors, etc
				
			}
			stream.addEventListener('error', onStreamError); // TODO: namespace events
			stream.addEventListener(StreamEvent.CONNECTION_CLOSED, onStreamClose);
			stream.addEventListener(StreamEvent.IO_ERROR, onStreamClose);
			attachDnode();
			
			return this;
		}
		
		private function onStreamClose(e:Event):void 
		{
			ch.warn('the stream has closed');
			dispatchEvent(e.clone());
			
		}
		
		private function attachDnode():void {
			client = createClient(proto, stream);
			
			client.end = function () {
				if (params.reconnect) {
					params.reconnect = false;
				}
				stream.end();
			}
			
			client.addEventListener('ready', function (e:Event) {
				dispatchEvent(e);
			});
			
			stack.forEach(function(middleware) {
				// TODO: not implemented
				//middleware.call(client.instance, client.remote, client);
			})
			
			// the callback for startup
			if (params.block) {
				client.addEventListener("remote", function() {
					params.block.call(client.instance, client.remote, client);
				})
			}
			
			client.addEventListener('error', onClientError);
			
			client.start();
			
		}
		
		private function onClientError(e:Event):void 
		{
			// TODO: if we got here, bad things happened
			// do something fancy
			ch.error(e);
		}
		
		private function createClient(proto:DnodeProtocol, stream:Stream):Session 
		{
			client = proto.create(); 
			client.stream = stream;
			
			stream.addEventListener('message', function(msg:RawMessageEvent) {
				client.parse(msg.message);
			});
			
			client.addEventListener('request', function(req:RequestEvent) {
				//ch.debug(JSON.encode(req.data));
				stream.write(JSON.encode(req.data) + "\n");
			});
			return client;
		}
		
		
		private function onStreamError(e:Event):void 
		{
			// TODO: mobetta?
			dispatchEvent(e);
		}
		
		public function useMiddleware(middleware:Function):Dnode{
			stack.push(middleware);
			return this;
		}
		
		
		public function listen():void {} // TODO!

		
	}
}