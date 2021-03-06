// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.animation;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.events.Event;
import starling.events.EventDispatcher;

/** The Juggler takes objects that implement IAnimatable (like Tweens) and executes them.
 * 
 *  <p>A juggler is a simple object. It does no more than saving a list of objects implementing 
 *  "IAnimatable" and advancing their time if it is told to do so (by calling its own 
 *  "advanceTime"-method). When an animation is completed, it throws it away.</p>
 *  
 *  <p>There is a default juggler available at the Starling class:</p>
 *  
 *  <pre>
 *  var juggler:Juggler = Starling.Juggler;
 *  </pre>
 *  
 *  <p>You can create juggler objects yourself, just as well. That way, you can group 
 *  your game into logical components that handle their animations independently. All you have
 *  to do is call the "advanceTime" method on your custom juggler once per frame.</p>
 *  
 *  <p>Another handy feature of the juggler is the "delayCall"-method. Use it to 
 *  execute a function at a later time. Different to conventional approaches, the method
 *  will only be called when the juggler is advanced, giving you perfect control over the 
 *  call.</p>
 *  
 *  <pre>
 *  juggler.delayCall(object.removeFromParent, 1.0);
 *  juggler.delayCall(object.addChild, 2.0, theChild);
 *  juggler.delayCall(function():Void { doSomethingFunny(); }, 3.0);
 *  </pre>
 * 
 *  @see Tween
 *  @see DelayedCall 
 */
class Juggler implements IAnimatable
{
	private var mObjects:Vector<IAnimatable>;
	private var mElapsedTime:Float;
	
	public var elapsedTime(get, null):Float;
	private var objects(get, null):Array<IAnimatable>;
	
	private static var tweenSetters:Array<String> = null;

	/** Create an empty juggler. */
	public function new()
	{
		mElapsedTime = 0;
		mObjects = new Vector<IAnimatable>();
		mObjects.fixed = false;

		if (tweenSetters == null) {
			// Get all of the setters in the Tween class.
			tweenSetters = new Array<String>();
			for (field in Type.getInstanceFields(Tween)) {
				if (field.indexOf("set_") == 0) {
					tweenSetters.push(field.substr(4));
				}
			}
			tweenSetters.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
			//trace(tweenSetters);
		}
	}

	/** Adds an object to the juggler. */
	public function add(object:IAnimatable):Void
	{
		if (object != null && indexOf(mObjects, object) == -1) 
		{
			mObjects[mObjects.length] = object;
		
			if (Std.is(object, EventDispatcher)){
				var dispatcher:EventDispatcher = cast(object, EventDispatcher);
				if (dispatcher != null) dispatcher.addEventListener(Event.REMOVE_FROM_JUGGLER, onRemove);
			}
		}
	}
	
	function indexOf(vec:Vector<IAnimatable>, obj:IAnimatable) 
	{
		for (i in 0...vec.length) 
		{
			if (vec[i] == obj) return i;
		}
		return -1;
	}
	
	/** Determines if an object has been added to the juggler. */
	public function contains(object:IAnimatable):Bool
	{
		return indexOf(mObjects, object) != -1;
	}
	
	/** Removes an object from the juggler. */
	public function remove(object:IAnimatable):Void
	{
		if (object == null) return;
		
		var dispatcher:EventDispatcher = cast object;
		if (dispatcher != null) dispatcher.removeEventListener(Event.REMOVE_FROM_JUGGLER, onRemove);

		var index:Int = indexOf(mObjects, object);
		if (index != -1) mObjects[index] = null;
	}
	
	/** Removes all tweens with a certain target. */
	public function removeTweens(target:Dynamic):Void
	{
		if (target == null) return;
		
		var i:Int = mObjects.length - 1;
		while (i >= 0)
		{
			var tween:Tween = cast mObjects[i];
			if (tween != null && tween.target == target)
			{
				tween.removeEventListener(Event.REMOVE_FROM_JUGGLER, onRemove);
				mObjects[i] = null;
			}
			--i;
		}
	}
	
	/** Figures out if the juggler contains one or more tweens with a certain target. */
	public function containsTweens(target:Dynamic):Bool
	{
		if (target == null) return false;
		
		var i:Int = mObjects.length - 1;
		while (i >= 0)
		{
			var tween:Tween = cast mObjects[i];
			if (tween != null && tween.target == target) return true;
			--i;
		}
		
		return false;
	}
	
	/** Removes all objects at once. */
	public function purge():Void
	{
		// the object vector is not purged right away, because if this method is called 
		// from an 'advanceTime' call, this would make the loop crash. Instead, the
		// vector is filled with 'null' values. They will be cleaned up on the next call
		// to 'advanceTime'.
		
		var i:Int = mObjects.length - 1;
		while (i >= 0)
		{
			var dispatcher:EventDispatcher = cast mObjects[i];
			if (dispatcher != null) dispatcher.removeEventListener(Event.REMOVE_FROM_JUGGLER, onRemove);
			mObjects[i] = null;
			--i;
		}
	}
	
	/** Delays the execution of a function until <code>delay</code> seconds have passed.
	 *  This method provides a convenient alternative for creating and adding a DelayedCall
	 *  manually.
	 *
	 *  <p>To cancel the call, pass the returned 'IAnimatable' instance to 'Juggler.remove()'.
	 *  Do not use the returned IAnimatable otherwise; it is taken from a pool and will be
	 *  reused.</p> */
	public function delayCall(call:EDFunction, delay:Float, args:Array<Dynamic>=null):IAnimatable
	{
		if (call == null) return null;
		
		var delayedCall:DelayedCall = DelayedCall.fromPool(call, delay, args);
		delayedCall.addEventListener(Event.REMOVE_FROM_JUGGLER, onPooledDelayedCallComplete);
		add(delayedCall);

		return delayedCall; 
	}

	/** Runs a function at a specified interval (in seconds). A 'repeatCount' of zero
	 *  means that it runs indefinitely.
	 *
	 *  <p>To cancel the call, pass the returned 'IAnimatable' instance to 'Juggler.remove()'.
	 *  Do not use the returned IAnimatable otherwise; it is taken from a pool and will be
	 *  reused.</p> */
	public function repeatCall(call:EDFunction, interval:Float, repeatCount:Int=0, args:Array<Dynamic>):IAnimatable
	{
		if (call == null) return null;
		
		var delayedCall:DelayedCall = DelayedCall.fromPool(call, interval, args);
		delayedCall.repeatCount = repeatCount;
		delayedCall.addEventListener(Event.REMOVE_FROM_JUGGLER, onPooledDelayedCallComplete);
		add(delayedCall);
		
		return delayedCall;
	}
	
	private function onPooledDelayedCallComplete(event:Event):Void
	{
		DelayedCall.toPool(cast event.target);
	}
	
	/** Utilizes a tween to animate the target object over <code>time</code> seconds. Internally,
	 *  this method uses a tween instance (taken from an object pool) that is added to the
	 *  juggler right away. This method provides a convenient alternative for creating 
	 *  and adding a tween manually.
	 *  
	 *  <p>Fill 'properties' with key-value pairs that describe both the 
	 *  tween and the animation target. Here is an example:</p>
	 *  
	 *  <pre>
	 *  juggler.tween(object, 2.0, {
	 *      transition: Transitions.EASE_IN_OUT,
	 *      delay: 20, // -> tween.delay = 20
	 *      x: 50      // -> tween.animate("x", 50)
	 *  });
	 *  </pre> 
	 *
	 *  <p>To cancel the tween, call 'Juggler.removeTweens' with the same target, or pass
	 *  the returned 'IAnimatable' instance to 'Juggler.remove()'. Do not use the returned
	 *  IAnimatable otherwise; it is taken from a pool and will be reused.</p>
	 *
	 *  <p>Note that some property types may be animated in a special way:</p>
	 *  <ul>
	 *    <li>If the property contains the string <code>color</code> or <code>Color</code>,
	 *        it will be treated as an unsigned integer with a color value
	 *        (e.g. <code>0xff0000</code> for red). Each color channel will be animated
	 *        individually.</li>
	 *    <li>The same happens if you append the string <code>#rgb</code> to the name.</li>
	 *    <li>If you append <code>#rad</code>, the property is treated as an angle in radians,
	 *        making sure it always uses the shortest possible arc for the rotation.</li>
	 *    <li>The string <code>#deg</code> does the same for angles in degrees.</li>
	 *  </ul>
	 */
	public function tween(target:Dynamic, time:Float, properties:Dynamic):IAnimatable
	{
		if (target == null) throw new ArgumentError("target must not be null");

		var tween:Tween = Tween.fromPool(target, time);

		var fields = Reflect.fields (properties);
		for (property in fields)
		{
			var value:Dynamic = Reflect.getProperty(properties, property);
			if (tweenSetters.indexOf(property) >= 0) {
				Reflect.setProperty(tween, property, value);
			} else {
				var currentValue:Dynamic = Reflect.getProperty(target, property);
				if (currentValue == null) {
					throw new ArgumentError("Invalid property: " + property);
				}
				tween.animate(property, cast value);
			}
		}
		
		tween.addEventListener(Event.REMOVE_FROM_JUGGLER, onPooledTweenComplete);
		add(tween);

		return tween;
	}
	
	private function onPooledTweenComplete(event:Event):Void
	{
		Tween.toPool(cast event.target);
	}
	
	/** Advances all objects by a certain time (in seconds). */
	public function advanceTime(time:Float):Void
	{   
		var numObjects:Int = mObjects.length;
		var currentIndex:Int = 0;
		
		mElapsedTime += time;
		if (numObjects == 0) return;
		
		// there is a high probability that the "advanceTime" function modifies the list 
		// of animatables. we must not process new objects right now (they will be processed
		// in the next frame), and we need to clean up any empty slots in the list.
		
		for (i in 0...numObjects)
		{
			var object:IAnimatable = mObjects[i];
			if (object != null)
			{
				// shift objects into empty slots along the way
				if (currentIndex != i) 
				{
					mObjects[currentIndex] = object;
					mObjects[i] = null;
				}
				
				object.advanceTime(time);
				++currentIndex;
			}
		}
		
		// FIX
		/*if (currentIndex != i)
		{
			numObjects = mObjects.length; // count might have changed!
			
			while (i < numObjects) {
				mObjects[currentIndex] = mObjects[i];
				currentIndex += 1;
				i += 1;
			}
			mObjects.length = currentIndex - 1;
		}*/
	}
	
	private function onRemove(event:Event):Void
	{
		remove(cast event.target);
		
		var tween:Tween = null;
		try { tween = cast event.target; }
		catch (e:Error) { }
		
		if (tween != null){
			if (tween.isComplete) {
				var nextTween = Reflect.getProperty(tween, "nextTween");
				if (nextTween != null) add(cast nextTween);
			}
		}
	}
	
	/** The total life time of the juggler (in seconds). */
	private function get_elapsedTime():Float { return mElapsedTime; }

	/** The actual vector that contains all objects that are currently being animated. */
	private function get_objects():Array<IAnimatable> { return mObjects; }
}

//typedef Function = Dynamic -> Void;
