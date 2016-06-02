package com.greensock.plugins;
   class FrameBackwardPlugin extends FrameForwardPlugin
   {
      
      public static inline var API:Float = 1;
       
      public function new()
      {
         super();
         this.propName = "frameBackward";
         _backward = true;
      }
   }
