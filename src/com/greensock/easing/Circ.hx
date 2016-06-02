package com.greensock.easing;
   class Circ
   {
       
      public function new()
      {
         super();
      }
      
      public static function easeOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return c * Math.sqrt(1 - (t = cast(t / d - 1, Float)) * t) + b;
      }
      
      public static function easeIn(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return -c * (Math.sqrt(1 - (t = cast(t / d, Float)) * t) - 1) + b;
      }
      
      public static function easeInOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         if((t = t / (d * 0.5)) < 1)
         {
            return -c * 0.5 * (Math.sqrt(1 - t * t) - 1) + b;
         }
         return c * 0.5 * (Math.sqrt(1 - (t = cast(t - 2, Float)) * t) + 1) + b;
      }
   }
