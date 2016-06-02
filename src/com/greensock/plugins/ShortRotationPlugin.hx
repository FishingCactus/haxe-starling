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
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         var p:Dynamic = null;
         if(typeof value == "number")
         {
            return false;
         }
         var useRadians:Bool = cast(value.useRadians == true, Bool);
         for(p in value)
         {
            if(p != "useRadians")
            {
               initRotation(target,p,target[p],typeof value[p] == "number"?cast(Float(value[p]), Float):cast(target[p] + Float(value[p]), Float),useRadians);
            }
         }
         return true;
      }
      
      public function initRotation(target:Object, propName:String, start:Float, end:Float, useRadians:Bool = false) : Void
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
