package com.greensock.plugins;

   import flash.geom.ColorTransform;
   import flash.display.DisplayObject;

   class ColorTransformPlugin extends TintPlugin
   {

      public static inline var API:Float = 1;

      public function new()
      {
         super();
         this.propName = "colorTransform";
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         var start:ColorTransform = null;
         var ratio:Float = Math.NaN;
         var end:ColorTransform = new ColorTransform();
         if(Std.is(target, DisplayObject))
         {
            _transform = cast(target, DisplayObject).transform;
            start = _transform.colorTransform;
         }
         else if(Std.is(target, ColorTransform))
         {
            start =cast( target, ColorTransform);
         }
         else
         {
            return false;
         }
         end.concat(start);
         for(p in Reflect.fields(value))
         {
            if(cast(p == "tint", Bool) || cast(p == "color", Bool))
            {
                var val = Reflect.field(value,p);
               if(val != null)
               {
                  end.color = cast(val, Int);
               }
            }
            else if(!(cast(p == "tintAmount", Bool) || cast(p == "exposure", Bool) || cast(p == "brightness", Bool)))
            {
               Reflect.setField( end, p, Reflect.field(value,p));
            }
         }
         if(!Math.isNaN(value.tintAmount))
         {
            ratio = value.tintAmount / (1 - (end.redMultiplier + end.greenMultiplier + end.blueMultiplier) / 3);
            end.redOffset = end.redOffset * ratio;
            end.greenOffset = end.greenOffset * ratio;
            end.blueOffset = end.blueOffset * ratio;
            end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1 - value.tintAmount;
         }
         else if(!Math.isNaN(value.exposure))
         {
            end.redOffset = end.greenOffset = end.blueOffset = 255 * (value.exposure - 1);
            end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1;
         }
         else if(!Math.isNaN(value.brightness))
         {
            end.redOffset = end.greenOffset = end.blueOffset = Math.max(0,(value.brightness - 1) * 255);
            end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1 - Math.abs(value.brightness - 1);
         }
         init(start,end);
         return true;
      }
   }
