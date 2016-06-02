package com.greensock.plugins;
   import flash.display.MovieClip;


   class FramePlugin extends TweenPlugin
   {

      public static inline var API:Float = 1;

      private var _target:MovieClip;

      public var frame:Int;

      public function new()
      {
         super();
         this.propName = "frame";
         this.overwriteProps = ["frame","frameLabel"];
         this.round = true;
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!(Std.is(target, MovieClip)) || Math.isNaN(value))
         {
            return false;
         }
         _target =cast( target, MovieClip);
         this.frame = _target.currentFrame;
         addTween(this,"frame",this.frame,value,"frame");
         return true;
      }

      override public function set_changeFactor(n:Float):Float
      {
         updateTweens(n);
         _target.gotoAndStop(this.frame);

         return n;
      }
   }
