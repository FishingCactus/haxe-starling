Std.is(
, suggested that you update to at least version 11.4 of TweenLite in order for TweenLiteVars to work properly. http://www.greensock.com/tweenlite/");
         }
      }
      
      public function delay(delay:Float) : TweenLiteVars
      {
         return _set("delay",delay);
      }
      
      public function frameLabel(label:String) : TweenLiteVars
      {
         return _set("frameLabel",label,true);
      }
      
      public function onUpdate(func:Function, params:Array<Int> = null) : TweenLiteVars
      {
         _set("onUpdateParams",params);
         return _set("onUpdate",func);
      }
      
      public function setSize(width:Float = NaN, height:Float = NaN) : TweenLiteVars
      {
         var values:Dynamic = {};
         if(!isNaN(width))
         {
            values.width = width;
         }
         if(!isNaN(height))
         {
            values.height = height;
         }
         return _set("setSize",values,true);
      }
      
      public function useFrames(value:Bool) : TweenLiteVars
      {
         return _set("useFrames",value,false);
      }
      
      public function transformAroundCenter(props:Dynamic) : TweenLiteVars
      {
         return _set("transformAroundCenter",props,true);
      }
      
      public function onInit(func:Function, params:Array<Int> = null) : TweenLiteVars
      {
         _set("onInitParams",params);
         return _set("onInit",func);
      }
      
      public function overwrite(value:Int) : TweenLiteVars
      {
         return _set("overwrite",value,false);
      }
      
      public function quaternions(values:Dynamic) : TweenLiteVars
      {
         return _set("quaternions",values,true);
      }
      
      public function frameForward(frame:Int) : TweenLiteVars
      {
         return _set("frameForward",frame,true);
      }
      
      public function bevelFilter(distance:Float = 4, angle:Float = 45, highlightColor:UInt = 16777215, highlightAlpha:Float = 0.5, shadowColor:UInt = 0, shadowAlpha:Float = 0.5, blurX:Float = 4, blurY:Float = 4, strength:Float = 1, quality:Int = 2, remove:Bool = false, addFilter:Bool = false, index:Int = -1) : TweenLiteVars
      {
         var filter:Dynamic = {
            "distance":distance,
            "angle":angle,
            "highlightColor":highlightColor,
            "highlightAlpha":highlightAlpha,
            "shadowColor":shadowColor,
            "shadowAlpha":shadowAlpha,
            "blurX":blurX,
            "blurY":blurY,
            "strength":strength,
            "quality":quality,
            "addFilter":addFilter,
            "remove":remove
         };
         if(index > -1)
         {
            filter.index = index;
         }
         return _set("bevelFilter",filter,true);
      }
      
      public function shortRotation(values:Dynamic) : TweenLiteVars
      {
         if(typeof values == "number")
         {
            values = {"rotation":values};
         }
         return _set("shortRotation",values,true);
      }
      
      public function colorMatrixFilter(colorize:UInt = 16777215, amount:Float = 1, saturation:Float = 1, contrast:Float = 1, brightness:Float = 1, hue:Float = 0, threshold:Float = -1, remove:Bool = false, addFilter:Bool = false, index:Int = -1) : TweenLiteVars
      {
         var filter:Dynamic = {
            "saturation":saturation,
            "contrast":contrast,
            "brightness":brightness,
            "hue":hue,
            "addFilter":addFilter,
            "remove":remove
         };
         if(colorize != 16777215)
         {
            filter.colorize = colorize;
            filter.amount = amount;
         }
         if(threshold > -1)
         {
            filter.threshold = threshold;
         }
         if(index > -1)
         {
            filter.index = index;
         }
         return _set("colorMatrixFilter",filter,true);
      }
      
      public function soundTransform(volume:Float = 1, pan:Float = 0, leftToLeft:Float = 1, leftToRight:Float = 0, rightToLeft:Float = 0, rightToRight:Float = 1) : TweenLiteVars
      {
         return _set("soundTransform",{
            "volume":volume,
            "pan":pan,
            "leftToLeft":leftToLeft,
            "leftToRight":leftToRight,
            "rightToLeft":rightToLeft,
            "rightToRight":rightToRight
         },true);
      }
      
      public function removeTint(remove:Bool = true) : TweenLiteVars
      {
         return _set("removeTint",remove,true);
      }
      
      public function stageQuality(stage:Stage, during:String = "medium", after:String = null) : TweenLiteVars
      {
         if(after == null)
         {
            after = stage.quality;
         }
         return _set("stageQuality",{
            "stage":stage,
            "during":during,
            "after":after
         },true);
      }
      
      private function _set(property:String, value:Dynamic, requirePlugin:Bool = false) : TweenLiteVars
      {
         if(value == null)
         {
            _vars.remove(property);
         }
         else
         {
            _vars[property] = value;
         }
         if(cast(requirePlugin, Bool) && cast(!(property in TweenLite.plugins), Bool))
         {
            trace("WARNING: you must activate() the " + property + " plugin in order for the feature to work in TweenLite. See http://www.greensock.com/tweenlite/#plugins for details.");
         }
         return this;
      }
      
      public function runBackwards(value:Bool) : TweenLiteVars
      {
         return _set("runBackwards",value,false);
      }
      
      public function orientToBezier(values:Dynamic = null) : TweenLiteVars
      {
         return _set("orientToBezier",values == null?true:values,false);
      }
      
      public function circlePath2D(path:MotionPath, startAngle:Float, endAngle:Float, autoRotate:Bool = false, direction:String = "clockwise", extraRevolutions:UInt = 0, rotationOffset:Float = 0, useRadians:Bool = false) : TweenLiteVars
      {
         return _set("circlePath2D",{
            "path":path,
            "startAngle":startAngle,
            "endAngle":endAngle,
            "autoRotate":autoRotate,
            "direction":direction,
            "extraRevolutions":extraRevolutions,
            "rotationOffset":rotationOffset,
            "useRadians":useRadians
         },true);
      }
      
      public function volume(volume:Float) : TweenLiteVars
      {
         return _set("volume",volume,true);
      }
      
      public function data(data:Dynamic) : TweenLiteVars
      {
         return _set("data",data);
      }
      
      public  function get_vars()
      {
         return _vars;
      }
      
      public function immediateRender(value:Bool) : TweenLiteVars
      {
         return _set("immediateRender",value,false);
      }
      
      public function throwProps(props:Dynamic) : TweenLiteVars
      {
         return _set("throwProps",props,true);
      }
      
      public function paused(value:Bool) : TweenLiteVars
      {
         return _set("paused",value,false);
      }
      
      public function height(value:Float, relative:Bool = false) : TweenLiteVars
      {
         return prop("height",value,relative);
      }
      
      public function transformAroundPoint(point:Point, props:Dynamic) : TweenLiteVars
      {
         props.point = point;
         return _set("transformAroundPoint",props,true);
      }
      
      public function onComplete(func:Function, params:Array<Int> = null) : TweenLiteVars
      {
         _set("onCompleteParams",params);
         return _set("onComplete",func);
      }
      
      public function motionBlur(strength:Float = 1, fastMode:Bool = false, quality:Int = 2, padding:Int = 10) : TweenLiteVars
      {
         return _set("motionBlur",{
            "strength":strength,
            "fastMode":fastMode,
            "quality":quality,
            "padding":padding
         },true);
      }
      
      public function endArray(values:Array<Int>) : TweenLiteVars
      {
         return _set("endArray",values,true);
      }
      
      public function blurFilter(blurX:Float, blurY:Float, quality:Int = 2, remove:Bool = false, addFilter:Bool = false, index:Int = -1) : TweenLiteVars
      {
         var filter:Dynamic = {
            "blurX":blurX,
            "blurY":blurY,
            "quality":quality,
            "addFilter":addFilter,
            "remove":remove
         };
         if(index > -1)
         {
            filter.index = index;
         }
         return _set("blurFilter",filter,true);
      }
      
      public function onStart(func:Function, params:Array<Int> = null) : TweenLiteVars
      {
         _set("onStartParams",params);
         return _set("onStart",func);
      }
      
      public function width(value:Float, relative:Bool = false) : TweenLiteVars
      {
         return prop("width",value,relative);
      }
      
      public function dropShadowFilter(distance:Float = 4, blurX:Float = 4, blurY:Float = 4, alpha:Float = 1, angle:Float = 45, color:UInt = 0, strength:Float = 2, inner:Bool = false, knockout:Bool = false, hideObject:Bool = false, quality:UInt = 2, remove:Bool = false, addFilter:Bool = false, index:Int = -1) : TweenLiteVars
      {
         var filter:Dynamic = {
            "distance":distance,
            "blurX":blurX,
            "blurY":blurY,
            "alpha":alpha,
            "angle":angle,
            "color":color,
            "strength":strength,
            "inner":inner,
            "knockout":knockout,
            "hideObject":hideObject,
            "quality":quality,
            "addFilter":addFilter,
            "remove":remove
         };
         if(index > -1)
         {
            filter.index = index;
         }
         return _set("dropShadowFilter",filter,true);
      }
      
      public function colorTransform(tint:Float = NaN, tintAmount:Float = NaN, exposure:Float = NaN, brightness:Float = NaN, redMultiplier:Float = NaN, greenMultiplier:Float = NaN, blueMultiplier:Float = NaN, alphaMultiplier:Float = NaN, redOffset:Float = NaN, greenOffset:Float = NaN, blueOffset:Float = NaN, alphaOffset:Float = NaN) : TweenLiteVars
      {
         var p:Dynamic = null;
         var values:Dynamic = {
            "tint":tint,
            "tintAmount":(!!isNaN(tint)?NaN:tintAmount),
            "exposure":exposure,
            "brightness":brightness,
            "redMultiplier":redMultiplier,
            "greenMultiplier":greenMultiplier,
            "blueMultiplier":blueMultiplier,
            "alphaMultiplier":alphaMultiplier,
            "redOffset":redOffset,
            "greenOffset":greenOffset,
            "blueOffset":blueOffset,
            "alphaOffset":alphaOffset
         };
         for(p in values)
         {
            if(isNaN(values[p]))
            {
               values.remove(p);
            }
         }
         return _set("colorTransform",values,true);
      }
      
      public function scale(value:Float, relative:Bool = false) : TweenLiteVars
      {
         prop("scaleX",value,relative);
         return prop("scaleY",value,relative);
      }
      
      public function transformMatrix(properties:Dynamic) : TweenLiteVars
      {
         return _set("transformMatrix",properties,true);
      }
      
      public function scaleX(value:Float, relative:Bool = false) : TweenLiteVars
      {
         return prop("scaleX",value,relative);
      }
      
      public function scaleY(value:Float, relative:Bool = false) : TweenLiteVars
      {
         return prop("scaleY",value,relative);
      }
      
      public function move(x:Float, y:Float, relative:Bool = false) : TweenLiteVars
      {
         prop("x",x,relative);
         return prop("y",y,relative);
      }
      
      public function scrollRect(props:Dynamic) : TweenLiteVars
      {
         return _set("scrollRect",props,true);
      }
      
      public function physics2D(velocity:Float, angle:Float, acceleration:Float = 0, accelerationAngle:Float = 90, friction:Float = 0) : TweenLiteVars
      {
         return _set("physics2D",{
            "velocity":velocity,
            "angle":angle,
            "acceleration":acceleration,
            "accelerationAngle":accelerationAngle,
            "friction":friction
         },true);
      }
      
      public function onReverseComplete(func:Function, params:Array<Int> = null) : TweenLiteVars
      {
         _set("onReverseCompleteParams",params);
         return _set("onReverseComplete",func);
      }
      
      public function bezier(values:Array<Int>) : TweenLiteVars
      {
         return _set("bezier",values,true);
      }
      
      public  function get_isGSVars()
      {
         return true;
      }
      
      public function prop(property:String, value:Float, relative:Bool = false) : TweenLiteVars
      {
         return _set(property,!!relative?cast(value, String):value);
      }
      
      public function glowFilter(blurX:Float = 10, blurY:Float = 10, color:UInt = 16777215, alpha:Float = 1, strength:Float = 2, inner:Bool = false, knockout:Bool = false, quality:UInt = 2, remove:Bool = false, addFilter:Bool = false, index:Int = -1) : TweenLiteVars
      {
         var filter:Dynamic = {
            "blurX":blurX,
            "blurY":blurY,
            "color":color,
            "alpha":alpha,
            "strength":strength,
            "inner":inner,
            "knockout":knockout,
            "quality":quality,
            "addFilter":addFilter,
            "remove":remove
         };
         if(index > -1)
         {
            filter.index = index;
         }
         return _set("glowFilter",filter,true);
      }
      
      public function bezierThrough(values:Array<Int>) : TweenLiteVars
      {
         return _set("bezierThrough",values,true);
      }
      
      public function physicsProps(values:Dynamic) : TweenLiteVars
      {
         return _set("physicsProps",values,true);
      }
      
      public function hexColors(values:Dynamic) : TweenLiteVars
      {
         return _set("hexColors",values,true);
      }
      
      public function frame(value:Int, relative:Bool = false) : TweenLiteVars
      {
         return _set("frame",!!relative?cast(value, String):value,true);
      }
      
      public function ease(ease:Function, easeParams:Array<Int> = null) : TweenLiteVars
      {
         _set("easeParams",easeParams);
         return _set("ease",ease);
      }
      
      public function autoAlpha(alpha:Float) : TweenLiteVars
      {
         return _set("autoAlpha",alpha,true);
      }
      
      public function frameBackward(frame:Int) : TweenLiteVars
      {
         return _set("frameBackward",frame,true);
      }
      
      public function dynamicProps(props:Dynamic, params:Dynamic = null) : TweenLiteVars
      {
         if(params != null)
         {
            props.params = params;
         }
         return _set("dynamicProps",props,true);
      }
      
      public function visible(value:Bool) : TweenLiteVars
      {
         return _set("visible",value,true);
      }
      
      public function x(value:Float, relative:Bool = false) : TweenLiteVars
      {
         return prop("x",value,relative);
      }
      
      public function y(value:Float, relative:Bool = false) : TweenLiteVars
      {
         return prop("y",value,relative);
      }
      
      public function tint(color:UInt) : TweenLiteVars
      {
         return _set("tint",color,true);
      }
      
      public function rotation(value:Float, relative:Bool = false) : TweenLiteVars
      {
         return prop("rotation",value,relative);
      }
   }
)