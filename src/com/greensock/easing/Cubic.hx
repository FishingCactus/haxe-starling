package com.greensock.easing;
   class Cubic
   {

      public function new()
      {
      }

      public static function easeOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return c * ((t = t / d - 1) * t * t + 1) + b;
      }

      public static function easeIn(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return c * (t = t / d) * t * t + b;
      }

      public static function easeInOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         if((t = t / (d * 0.5)) < 1)
         {
            return c * 0.5 * t * t * t + b;
         }
         return c * 0.5 * ((t = t - 2) * t * t + 2) + b;
      }
   }
