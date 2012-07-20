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
	import flash.events.Event;
	/**
	 * ...
	 * @author Aaron Fay
	 */
	dynamic public class Traverse 
	{
		private var value:Object;
		private var ch:ConsoleChannel;
		private var _preventGc:Array = [];
		
		public function Traverse(obj:Object) 
		{
			
			ch = new ConsoleChannel('Traverse');
			value = obj;
		}

		public function map(cb) {
			return walk(value, cb, true);
		}
		
		public function forEach(cb) {
			value = walk(value, cb, false);
			return value;
		}
		private function walk(root, cb, immutable) {
			
			
			var path:Array = [];
			var parents:Array = [];
			var alive:Boolean = true;
			return (function walker(node_) {
				var node = immutable ? copy(node_) : node_;
				var modifiers = { };
				var keepGoing = true;
				var state = {
					node: node,
					node_: node_,
					path: new Array().concat(path),
					parent: parents[parents.length - 1],
					parents: parents,
					key: path.slice( -1)[0],
					isRoot: path.length == 0,
					level: path.length,
					circular: null,
					update: function (x, stopHere) {
						if (!state.isRoot) {
							state.parent.node[state.key] = x;
						}
						state.node = x;
						if (stopHere) keepGoing = false;
					},
					'delete': function (stopHere) {
						delete state.parent.node[state.key];
						if (stopHere) keepGoing = false;
					}, 
					remove: function (stopHere) {
						if (Array_isArray(state.parent.node)) {
							state.parent.node.splice(state.key, 1);
						}
						else {
							delete state.parent.node[state.key];
						} 
						if (stopHere) keepGoing = false;
					},
					keys: null,
					before: function (f) { modifiers.before = f },
					after : function (f) { modifiers.after = f },
					pre : function (f) { modifiers.pre = f },
					post : function (f) { modifiers.post = f },
					stop : function () { alive = false },
					block : function () { keepGoing = false }
				};
				
				if (!alive) return state;
				
				if (typeof node == 'object' && node != null) {
					state.keys = Object_keys(node);
					
					state.isLeaf = state.keys.length == 0;
					
					for (var i = 0; i < parents.length; i ++) {
						if (parents[i].node_ === node) {
							state.circular = parents[i];
							break;
						}
					}
				}
				else {
					state.isLeaf = true;
				}
				
				state.notLeaf = !state.isLeaf;
				state.notRoot = !state.isRoot;
				
				var ret = cb.call(state, state.node);

				if (ret != undefined && state.update) {
					state.update(ret);
				}
				if (modifiers.before) {
					modifiers.before.call(state, state.node);
				}
				
				if (!keepGoing) {
					return state;
				}

				if (typeof state.node == 'object' && state.node != null && !state.circular) {
					parents.push(state);
					if (state.keys) {
						_forEach(state.keys, function(key, i) {
							
							path.push(key);
							
							if (modifiers.pre) {
								modifiers.pre.call(state, state.node[key], key);
							}
							
							var child = walker(state.node[key]);

							if (immutable && Object.prototype.hasOwnProperty.call(state.node, key)) {
								state.node[key] = child.node;
							}
							if (child != undefined){
								child.isLast = i == state.keys.length - 1;
								child.isFirst = i == 0;
								
								if (modifiers.post) {
									modifiers.post.call(state, child);
								}
							}
							
							path.pop();
						});
						parents.pop();
					}
				}
				if (modifiers.after) {
					modifiers.after.call(state, state.node);
				}
				
				return state;
				
				
			})(root).node;
		}
		
		private function copy(src:*) {
			
			if (typeof src == 'object' && src != null) {
				var dst;
				
				
				
				if (Array_isArray(src)) {
					dst = [];
				}
				else if (isDate(src)) {
					dst = new Date(src);
				}
				else if (isRegExp(src)) {
					dst = new RegExp(src);
				}
				else if (isError(src)) {
					dst = { message: src.message };
				}
				else if (isBoolean(src)) {
					dst = new Boolean(src);
				}
				else if (isNumber(src)) {
					dst = new Number(src);
				}
				else if (isString(src)) {
					dst = new String(src);
				}
				//else if ( GET PROTOTYPE OF ?? how to do this?
				
				
				
				else if (src.constructor) {
					
					function noop(e:Event) {
						//pass
					}
					
					// TODO: will this work?
					//dst = new src.constructor();
					//dst.addEventListener('no-op', noop)
					
					//dst = src.clone();
					//dst.addEventListener('no-op', _noop)
					dst = src
					
					//src('called this here !!!!!!!!!')
					//dst('called this here !!!!!!!!!')
					
					//return src
					//ch.debug('a new constructor');
					//ch.debug(dst)
				}
				
				//ch.debug('prototype: ' + src.constructor);
				//ch.debug('Copying keys.. ')
				
				_forEach(Object_keys(src), function (key) {
					//ch.debug('  ---> ' + key + ' ' + src[key])
					dst[key] = src[key];
				});
				
				//ch.inspect(dst)
				return dst;
			}
			else {
				return src;
			}
		}
		
		private function _noop(e:Event):void {
			// pass
		}
	
		private function Object_keys(obj:Object):Array {
			var res:Array = [];
			for (var key in obj) {
				res.push(key);
			}
			return res;
		}
		
		private function Array_isArray(xs) {
			// TODO
			return Object.prototype.toString.call(xs) == '[object Array]';
		}
		
		private function toS(o:*):String {
			return Object.prototype.toString.call(o);
		}
		private function isDate (obj) { return toS(obj) === '[object Date]' }
		private function isRegExp (obj) { return toS(obj) === '[object RegExp]' }
		private function isError (obj) { return toS(obj) === '[object Error]' }
		private function isBoolean (obj) { return toS(obj) === '[object Boolean]' }
		private function isNumber (obj) { return toS(obj) === '[object Number]' }
		private function isString (obj) { return toS(obj) === '[object String]' }
		
		private function _forEach(xs, fn) {

			if (xs.forEach) {
				return xs.forEach(fn);
			}
			else {
				for (var i:int = 0; i < xs.length; i ++) {
					fn(xs[i], i, xs);
				}
			}


		}
		
	}

}

























