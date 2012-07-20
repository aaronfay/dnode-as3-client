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
	import ca.aaronfay.dnode.events.RawMessageEvent;
	import ca.aaronfay.dnode.events.RequestEvent;
	import ca.aaronfay.dnode.events.StreamEvent;
	import com.adobe.serialization.json.JSON;
	import com.esign.Player;
	import com.junkbyte.console.ConsoleChannel;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.XMLSocket;
	import flash.desktop.NativeApplication;
	/**
	 * ...
	 * @author Aaron Fay
	 */
	public class Stream extends EventDispatcher 
	{
		private var ch:ConsoleChannel;
		private var cxn:XMLSocket;
		private var _host:String;
		private var _port:int;
		
		/*
		 * Implements a similar interface (as seen by dnode) to the 
		 * node.js stream object.  
		 */

		
		public function Stream(host:String, port:int) 
		{

			// fire away
			ch = new ConsoleChannel('Stream');
			ch.debug('Started');
			//ch.info('Connecting to local Dnode instance...');
			
			// TODO: hook this into the root later
			Player.STAGE.addEventListener('shutting-down', closeApplication)
			
			_host = host;
			_port = port;
			
			cxn = new XMLSocket();
			cxn.addEventListener(DataEvent.DATA, onIncomingData);
			cxn.addEventListener(Event.CLOSE, onClose);
			cxn.addEventListener(Event.CONNECT, onConnect);
			cxn.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			cxn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			

			cxn.connect(_host, _port);
			// emits events: 
			// connect
			// error
			// end
			// message (dnode.js uses Lazy)
			//NativeApplication.nativeWindow
			

		}
		
		private function closeApplication(e:Event):void 
		{
			trace('closing here too...')
			try{
				end();
			}
			catch(e){}
		}
		
		public function end():void {
			cxn.close()
			
		}
		
		public function write(msg:String):void 
		{
			cxn.send(msg);
		}
		
		private function onIncomingData(e:DataEvent):void 
		{
			dispatchEvent(new RawMessageEvent('message', e.data));
		}

		
		private function onConnect(e:Event):void 
		{
			
			ch.log("Connected!");
			
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void 
		{
			// emit "error"
			ch.error('Security error ' + e);
			
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
			// emit "error"
			ch.error('IO error ' + e);
			dispatchEvent(new StreamEvent(StreamEvent.IO_ERROR));
		}

		
		private function onClose(e:Event):void 
		{
			// emit "end"
			ch.error('closed connection')
			dispatchEvent(new StreamEvent(StreamEvent.CONNECTION_CLOSED));
		}
	}

}