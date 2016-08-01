package com.greensock.plugins;
   
   
   class BezierThroughPlugin extends BezierPlugin
   {
      
      public static inline var API:Float = 1;
       
      public function new()
      {
         super();
         this.propName = "bezierThrough";
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!Std.is(value, Array))
         {
            return false;
         }
         init(tween,cast(value, Array),true);
         return true;
      }
   }
