package com.greensock.plugins;
   
   import flash.filters.DropShadowFilter;
   
   class DropShadowFilterPlugin extends FilterPlugin
   {
      
      public static inline var API:Float = 1;
      
      private static var _propNames:Array<Int> = ["distance","angle","color","alpha","blurX","blurY","strength","quality","inner","knockout","hideObject"];
       
      public function new()
      {
         super();
         this.propName = "dropShadowFilter";
         this.overwriteProps = ["dropShadowFilter"];
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _type = DropShadowFilter;
         initFilter(value,new DropShadowFilter(0,45,0,0,0,0,1,cast(value.quality, Int) || cast(2, Int),value.inner,value.knockout,value.hideObject),_propNames);
         return true;
      }
   }
