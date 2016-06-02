package com.greensock.easing;
   
   
   class FastEase
   {
       
      public function new()
      {
         super();
      }
      
      public static function activateEase(ease:Function, type:Int, power:UInt) : Void
      {
         TweenLite.fastEaseLookup[ease] = [type,power];
      }
      
      public static function activate(easeClasses:Array<Int>) : Void
      {
         var easeClass:Dynamic = null;
         var i:Int = easeClasses.length;
         while(i--)
         {
            easeClass = easeClasses[i];
            if(easeClass.hasOwnProperty("power"))
            {
               activateEase(easeClass.easeIn,1,easeClass.power);
               activateEase(easeClass.easeOut,2,easeClass.power);
               activateEase(easeClass.easeInOut,3,easeClass.power);
               if(easeClass.hasOwnProperty("easeNone"))
               {
                  activateEase(easeClass.easeNone,1,0);
               }
            }
         }
      }
   }
