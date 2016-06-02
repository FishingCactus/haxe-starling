package com.greensock.plugins;

   import flash.filters.GlowFilter;

   class GlowFilterPlugin extends FilterPlugin
   {

      public static inline var API:Float = 1;

      private static var _propNames:Array<String> = ["color","alpha","blurX","blurY","strength","quality","inner","knockout"];

      public function new()
      {
         super();
         this.propName = "glowFilter";
         this.overwriteProps = ["glowFilter"];
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _type = GlowFilter;
         throw ":TODO:";
         //initFilter(value,new GlowFilter(16777215,0,0,0,cast(value.strength, Float) || cast(1, Float),cast(value.quality, Int) || cast(2, Int),value.inner,value.knockout),_propNames);
         return true;
      }
   }
