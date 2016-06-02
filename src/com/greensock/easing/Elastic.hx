package com.greensock.easing;
   class Elastic
   {
      
      private static inline var _2PI:Float = Math.PI * 2;
       
      public function new()
      {
         super();
      }
      
      public static function easeIn(t:Float, b:Float, c:Float, d:Float, a:Float = 0, p:Float = 0) : Float
      {
         var s:Float = NaN;
         if(t == 0)
         {
            return b;
         }
         if((t = t / d) == 1)
         {
            return b + c;
         }
         if(!p)
         {
            p = d * 0.3;
         }
         if(cast(!a, Bool) || cast(c > 0, Bool) && cast(a < c, Bool) || cast(c < 0, Bool) && cast(a < -c, Bool))
         {
            a = c;
            s = p / 4;
         }
         else
         {
            s = p / _2PI * Math.asin(c / a);
         }
         return -(a * Math.pow(2,10 * (t = cast(t - 1, Float))) * Math.sin((t * d - s) * _2PI / p)) + b;
      }
      
      public static function easeInOut(t:Float, b:Float, c:Float, d:Float, a:Float = 0, p:Float = 0) : Float
      {
         var s:Float = NaN;
         if(t == 0)
         {
            return b;
         }
         if((t = t / (d * 0.5)) == 2)
         {
            return b + c;
         }
         if(!p)
         {
            p = d * (0.3 * 1.5);
         }
         if(cast(!a, Bool) || cast(c > 0, Bool) && cast(a < c, Bool) || cast(c < 0, Bool) && cast(a < -c, Bool))
         {
            a = c;
            s = p / 4;
         }
         else
         {
            s = p / _2PI * Math.asin(c / a);
         }
         if(t < 1)
         {
            return -0.5 * (a * Math.pow(2,10 * (t = cast(t - 1, Float))) * Math.sin((t * d - s) * _2PI / p)) + b;
         }
         return a * Math.pow(2,-10 * (t = cast(t - 1, Float))) * Math.sin((t * d - s) * _2PI / p) * 0.5 + c + b;
      }
      
      public static function easeOut(t:Float, b:Float, c:Float, d:Float, a:Float = 0, p:Float = 0) : Float
      {
         var s:Float = NaN;
         if(t == 0)
         {
            return b;
         }
         if((t = t / d) == 1)
         {
            return b + c;
         }
         if(!p)
         {
            p = d * 0.3;
         }
         if(cast(!a, Bool) || cast(c > 0, Bool) && cast(a < c, Bool) || cast(c < 0, Bool) && cast(a < -c, Bool))
         {
            a = c;
            s = p / 4;
         }
         else
         {
            s = p / _2PI * Math.asin(c / a);
         }
         return a * Math.pow(2,-10 * t) * Math.sin((t * d - s) * _2PI / p) + c + b;
      }
   }
