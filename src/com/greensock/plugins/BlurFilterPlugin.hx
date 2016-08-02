package com.greensock.plugins;
   
   import flash.filters.BlurFilter;
   
   class BlurFilterPlugin extends FilterPlugin
   {
      
      public static inline var API:Float = 1;
      
      private static var _propNames:Array<String> = ["blurX","blurY","quality"];
       
      public function new()
      {
         super();
         this.propName = "blurFilter";
         this.overwriteProps = ["blurFilter"];
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _type = BlurFilter;
         return true;
         initFilter(value,new BlurFilter(0,0,cast(value.quality, Int) > 0 ? cast( value.quality, Int) : 2 ),_propNames);
      }
   }
