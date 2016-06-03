package com.greensock.easing;
   class Quad
   {

      public static inline var power:UInt = 1;

      public function new()
      {
      }

      public static function easeOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return -c * (t = t / d) * (t - 2) + b;
      }

      public static function easeIn(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return c * (t = t / d) * t + b;
      }

      public static function easeInOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         if((t = t / (d * 0.5)) < 1)
         {
            return c * 0.5 * t * t + b;
         }
         return -c * 0.5 * (--t * (t - 2) - 1) + b;
      }
   }
