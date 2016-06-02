package com.greensock.easing;
   class SteppedEase
   {

		public var steps(get, null):Int;

       
      private var _steps:Int;
      
      private var _stepAmount:Float;
      
      public function new(steps:Int)
      {
         super();
         _stepAmount = 1 / steps;
         _steps = steps + 1;
      }
      
      public static function create(steps:Int) : Function
      {
         var se:SteppedEase = new SteppedEase(steps);
         return se.ease;
      }
      
      public  function get_steps()
      {
         return _steps - 1;
      }
      
      public function ease(t:Float, b:Float, c:Float, d:Float) : Float
      {
         var ratio:Float = t / d;
         if(ratio < 0)
         {
            ratio = 0;
         }
         else if(ratio >= 1)
         {
            ratio = 0.999999999;
         }
         return (_steps * ratio >> 0) * _stepAmount;
      }
   }
