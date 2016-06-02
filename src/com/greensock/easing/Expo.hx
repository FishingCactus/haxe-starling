package com.greensock.easing;
   class Expo
   {
       
      public function new()
      {
         super();
      }
      
      public static function easeOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return t == d?cast(b + c, Float):cast(c * (-Math.pow(2,-10 * t / d) + 1) + b, Float);
      }
      
      public static function easeIn(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return t == 0?cast(b, Float):cast(c * Math.pow(2,10 * (t / d - 1)) + b - c * 0.001, Float);
      }
      
      public static function easeInOut(t:Float, b:Float, c:Float, d:Float) : Float
      {
         if(t == 0)
         {
            return b;
         }
         if(t == d)
         {
            return b + c;
         }
         if((t = t / (d * 0.5)) < 1)
         {
            return c * 0.5 * Math.pow(2,10 * (t - 1)) + b;
         }
         return c * 0.5 * (-Math.pow(2,-10 * --t) + 2) + b;
      }
   }
