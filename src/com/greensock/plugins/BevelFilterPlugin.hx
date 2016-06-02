package com.greensock.plugins;
   
   import flash.filters.BevelFilter;
   
   class BevelFilterPlugin extends FilterPlugin
   {
      
      public static inline var API:Float = 1;
      
      private static var _propNames:Array<Int> = ["distance","angle","highlightColor","highlightAlpha","shadowColor","shadowAlpha","blurX","blurY","strength","quality"];
       
      public function new()
      {
         super();
         this.propName = "bevelFilter";
         this.overwriteProps = ["bevelFilter"];
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _type = BevelFilter;
         initFilter(value,new BevelFilter(0,0,16777215,0.5,0,0.5,2,2,0,cast(value.quality, Int) || cast(2, Int)),_propNames);
         return true;
      }
   }
