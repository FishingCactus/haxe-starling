package com.greensock.plugins;
   import flash.display.DisplayObject;
   import flash.geom.Rectangle;
   
   
   class ScrollRectPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _target:DisplayObject;
      
      private var _rect:Rectangle;
      
      public function new()
      {
         super();
         this.propName = "scrollRect";
         this.overwriteProps = ["scrollRect"];
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         var p:Dynamic = null;
         var r:Rectangle = null;
         if(!(Std.is(target, DisplayObject)))
         {
            return false;
         }
         _target =cast( target, DisplayObject);
         if(_target.scrollRect != null)
         {
            _rect = _target.scrollRect;
         }
         else
         {
            r = _target.getBounds(_target);
            _rect = new Rectangle(0,0,r.width + r.x,r.height + r.y);
         }
         for(p in value)
         {
            addTween(_rect,p,_rect[p],value[p],p);
         }
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         updateTweens(n);
         _target.scrollRect = _rect;
      }
   }
