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
 
package ca.aaronfay.dnode.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Aaron Fay
	 */
	public class PayloadDataEvent extends Event 
	{
		private var _data:Array;
		public static const PAYLOAD_DATA:String = 'payload data';
		
		public function PayloadDataEvent(type:String, data:Array) 
		{
			super(type);
			_data = data;
			
		}
		
		public function get data():Array 
		{
			return _data;
		}
		
		public function set data(value:Array):void 
		{
			_data = value;
		}
		
	}

}