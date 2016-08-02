package com.greensock.plugins;
   
   
   class ShortRotationPlugin extends TweenPlugin
   {
      
      public static inline var API:Float = 1;
       
      public function new()
      {
         super();
         this.propName = "shortRotation";
         this.overwriteProps = [];
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         var p:Dynamic = null;
         if(Std.is(value, Int) || Std.is(value, Float))
         {
            return false;
         }
         var useRadians:Bool = cast(value.useRadians == true, Bool);
         for(p in Reflect.fields(value))
         {
            if(p != "useRadians")
            {
               initRotation(target,p,Reflect.field(target,p), ( Std.is(Reflect.field(value, p), Int) || Std.is(Reflect.field(value, p), Float) ) ? cast(Reflect.field(value, p), Float):cast(Reflect.field(target, p) + cast(Reflect.field(value,p), Float), Float),useRadians);
            }
         }
         return true;
      }
      
      public function initRotation(target:Dynamic, propName:String, start:Float, end:Float, useRadians:Bool = false) : Void
      {
         var cap:Float = !!useRadians?cast(Math.PI * 2, Float):cast(360, Float);
         var dif:Float = (end - start) % cap;
         if(dif != dif % (cap / 2))
         {
            dif = dif < 0?cast(dif + cap, Float):cast(dif - cap, Float);
         }
         addTween(target,propName,start,start + dif,propName);
         this.overwriteProps[this.overwriteProps.length] = propName;
      }
   }
