package com.greensock.plugins;
   
   import flash.filters.BlurFilter;
   
   class BlurFilterPlugin extends FilterPlugin
   {
      
      public static inline var API:Float = 1;
      
      private static var _propNames:Array<Int> = ["blurX","blurY","quality"];
       
      public function new()
      {
         super();
         this.propName = "blurFilter";
         this.overwriteProps = ["blurFilter"];
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _type = BlurFilter;
         initFilter(value,new BlurFilter(0,0,cast(value.quality, Int) || cast(2, Int)),_propNames);
         return true;
      }
   }
