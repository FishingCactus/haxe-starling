package com.greensock;
   import flash.events.Event;
   import flash.utils.getTimer;
   import flash.utils.Dictionary;
   import flash.display.Shape;
   
   class TweenNano
   {
      
      private static var _reservedProps:Dynamic = {
         "ease":1,
         "delay":1,
         "useFrames":1,
         "overwrite":1,
         "onComplete":1,
         "onCompleteParams":1,
         "runBackwards":1,
         "immediateRender":1,
         "onUpdate":1,
         "onUpdateParams":1
      };
      
      private static var _tnInitted:Bool;
      
      private static var _time:Float;
      
      private static var _frame:UInt;
      
      private static var _shape:Shape = new Shape();
      
      private static var _masterList:Dictionary = new Dictionary(false);
       
      private var _initted:Bool;
      
      public var active:Bool;
      
      private var _propTweens:Array<Int>;
      
      public var ratio:Float = 0;
      
      private var _ease:Function;
      
      public var startTime:Float;
      
      public var target:Dynamic;
      
      public var useFrames:Bool;
      
      public var duration:Float;
      
      public var gc:Bool;
      
      public var vars:Dynamic;
      
      public function new(target:Dynamic, duration:Float, vars:Dynamic)
      {
         super();
         if(!_tnInitted)
         {
            _time = getTimer() * 0.001;
            _frame = 0;
            _shape.addEventListener(Event.ENTER_FRAME,updateAll,false,0,true);
            _tnInitted = true;
         }
         this.vars = vars;
         this.duration = duration;
         this.active = cast(duration == 0 && this.vars.delay == 0 && this.vars.immediateRender != false, Bool);
         this.target = target;
         if(typeof this.vars.ease != "function")
         {
            _ease = TweenNano.easeOut;
         }
         else
         {
            _ease = this.vars.ease;
         }
         _propTweens = [];
         this.useFrames = cast(vars.useFrames == true, Bool);
         var delay:Float = "delay" in this.vars?cast(Float(this.vars.delay), Float):cast(0, Float);
         this.startTime = !!this.useFrames?cast(_frame + delay, Float):cast(_time + delay, Float);
         var a:Array<Int> = _masterList[target];
         if(cast(a == null, Bool) || cast(Int(this.vars.overwrite) == 1, Bool) || cast(this.vars.overwrite == null, Bool))
         {
            _masterList[target] = [this];
         }
         else
         {
            a[a.length] = this;
         }
         if(cast(this.vars.immediateRender == true, Bool) || cast(this.active, Bool))
         {
            renderTime(0);
         }
      }
      
      public static function delayedCall(delay:Float, onComplete:Function, onCompleteParams:Array<Int> = null, useFrames:Bool = false) : TweenNano
      {
         return new TweenNano(onComplete,0,{
            "delay":delay,
            "onComplete":onComplete,
            "onCompleteParams":onCompleteParams,
            "useFrames":useFrames,
            "overwrite":0
         });
      }
      
      public static function updateAll(e:Event = null) : Void
      {
         var a:Array<Int> = null;
         var tgt:Dynamic = null;
         var i:Int = 0;
         var t:Float = NaN;
         var tween:TweenNano = null;
         _frame = _frame + 1;
         _time = getTimer() * 0.001;
         var ml:Dictionary = _masterList;
         for(tgt in ml)
         {
            a = ml[tgt];
            i = a.length;
            while(--i > -1)
            {
               tween = a[i];
               t = !!tween.useFrames?cast(_frame, Float):cast(_time, Float);
               if(cast(tween.active, Bool) || cast(!tween.gc, Bool) && cast(t >= tween.startTime, Bool))
               {
                  tween.renderTime(t - tween.startTime);
               }
               else if(tween.gc)
               {
                  a.splice(i,1);
               }
            }
            if(a.length == 0)
            {
               ml.remove(tgt);
            }
         }
      }
      
      private static function easeOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return -1 * (t = t / d) * (t - 2);
      }
      
      public static function from(target:Dynamic, duration:Float, vars:Dynamic) : TweenNano
      {
         vars.runBackwards = true;
         if(!("immediateRender" in vars))
         {
            vars.immediateRender = true;
         }
         return new TweenNano(target,duration,vars);
      }
      
      public static function to(target:Dynamic, duration:Float, vars:Dynamic) : TweenNano
      {
         return new TweenNano(target,duration,vars);
      }
      
      public static function killTweensOf(target:Dynamic, complete:Bool = false) : Void
      {
         var a:Array<Int> = null;
         var i:Int = 0;
         if(target in _masterList)
         {
            if(complete)
            {
               a = _masterList[target];
               i = a.length;
               while(--i > -1)
               {
                  if(!cast(a[i], TweenNano).gc)
                  {
                     cast(a[i], TweenNano).complete(false);
                  }
               }
            }
            _masterList.remove(target);
         }
      }
      
      public function renderTime(time:Float) : Void
      {
         var pt:Array<Int> = null;
         if(!_initted)
         {
            init();
         }
         var i:Int = _propTweens.length;
         if(time >= this.duration)
         {
            time = this.duration;
            this.ratio = 1;
         }
         else if(time <= 0)
         {
            this.ratio = 0;
         }
         else
         {
            this.ratio = _ease(time,0,1,this.duration);
         }
         while(--i > -1)
         {
            pt = _propTweens[i];
            this.target[pt[0]] = pt[1] + this.ratio * pt[2];
         }
         if(this.vars.onUpdate)
         {
            this.vars.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         if(time == this.duration)
         {
            complete(true);
         }
      }
      
      public function init() : Void
      {
         var p:Dynamic = null;
         var pt:Array<Int> = null;
         var i:Int = 0;
         for(p in this.vars)
         {
            if(!(p in _reservedProps))
            {
               _propTweens[_propTweens.length] = [p,this.target[p],typeof this.vars[p] == "number"?this.vars[p] - this.target[p]:cast(this.vars[p], Float)];
            }
         }
         if(this.vars.runBackwards)
         {
            i = _propTweens.length;
            while(--i > -1)
            {
               pt = _propTweens[i];
               pt[1] = pt[1] + pt[2];
               pt[2] = -pt[2];
            }
         }
         _initted = true;
      }
      
      public function kill() : Void
      {
         this.gc = true;
         this.active = false;
      }
      
      public function complete(skipRender:Bool = false) : Void
      {
         if(!skipRender)
         {
            renderTime(this.duration);
            return;
         }
         kill();
         if(this.vars.onComplete)
         {
            this.vars.onComplete.apply(null,this.vars.onCompleteParams);
         }
      }
   }
