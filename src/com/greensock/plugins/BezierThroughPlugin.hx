package com.greensock.plugins;
   
   
   class BezierThroughPlugin extends BezierPlugin
   {
      
      public static inline var API:Float = 1;
       
      public function new()
      {
         super();
         this.propName = "bezierThrough";
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!(Std.is(value, Array<Int>)))
         {
            return false;
         }
         init(tween,cast(value, Array<Int>),true);
         return true;
      }
   }
