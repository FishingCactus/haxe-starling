package com.greensock.plugins;
   import flash.display.MovieClip;


   class FrameForwardPlugin extends TweenPlugin
   {

      public static inline var API:Float = 1;

      private var _backward:Bool;

      private var _start:Int;

      private var _max:UInt;

      private var _change:Int;

      private var _target:MovieClip;

      public function new()
      {
         super();
         this.propName = "frameForward";
         this.overwriteProps = ["frame","frameLabel","frameForward","frameBackward"];
         this.round = true;
      }

      override public function set_changeFactor(n:Float):Float
      {
         var frame:Float = (_start + _change * n) % _max;
         if(cast(frame < 0.5, Bool) && cast(frame >= -0.5, Bool))
         {
            frame = _max;
         }
         else if(frame < 0)
         {
            frame = frame + _max;
         }
         _target.gotoAndStop(cast(frame + 0.5, Int));

         return n;
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!(Std.is(target, MovieClip)) || Math.isNaN(value))
         {
            return false;
         }
         _target = cast(target, MovieClip);
         _start = _target.currentFrame;
         _max = _target.totalFrames;
         _change = Std.is( value, Float)? cast(cast(value, Float) - _start, Int):cast(value, Int);
         if(!_backward && _change < 0)
         {
            _change = _change + _max;
         }
         else if(_backward  && _change > 0)
         {
            _change = _change - _max;
         }
         return true;
      }
   }
