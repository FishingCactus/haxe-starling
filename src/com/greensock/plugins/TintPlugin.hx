package com.greensock.plugins;
   import flash.geom.ColorTransform;
   import com.greensock.core.PropTween;
   
   import flash.display.DisplayObject;
   import flash.geom.Transform;
   
   class TintPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      private static var _props:Array<Int> = ["redMultiplier","greenMultiplier","blueMultiplier","alphaMultiplier","redOffset","greenOffset","blueOffset","alphaOffset"];
      
      public static inline var API:Float = 1;
       
      private var _transform:Transform;
      
      public function new()
      {
         super();
         this.propName = "tint";
         this.overwriteProps = ["tint"];
      }
      
      public function init(start:ColorTransform, end:ColorTransform) : Void
      {
         var p:String = null;
         var i:Int = _props.length;
         var cnt:Int = _tweens.length;
         while(i--)
         {
            p = _props[i];
            if(start[p] != end[p])
            {
               _tweens[cnt++] = new PropTween(start,p,start[p],end[p] - start[p],"tint",false);
            }
         }
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!(Std.is(target, DisplayObject)))
         {
            return false;
         }
         var end:ColorTransform = new ColorTransform();
         if(cast(value != null, Bool) && cast(tween.vars.removeTint != true, Bool))
         {
            end.color = cast(value, UInt);
         }
         _transform = cast(target, DisplayObject).transform;
         var start:ColorTransform = _transform.colorTransform;
         end.alphaMultiplier = start.alphaMultiplier;
         end.alphaOffset = start.alphaOffset;
         init(start,end);
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         var ct:ColorTransform = null;
         var pt:PropTween = null;
         var i:Int = 0;
         if(_transform)
         {
            ct = _transform.colorTransform;
            i = _tweens.length;
            while(--i > -1)
            {
               pt = _tweens[i];
               ct[pt.property] = pt.start + pt.change * n;
            }
            _transform.colorTransform = ct;
         }
      }
   }
