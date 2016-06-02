package com.greensock.plugins;
   
   
   class VisiblePlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _target:Dynamic;
      
      private var _initVal:Bool;
      
      private var _visible:Bool;
      
      private var _tween:TweenLite;
      
      public function new()
      {
         super();
         this.propName = "visible";
         this.overwriteProps = ["visible"];
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _tween = tween;
         _initVal = _target.visible;
         _visible = cast(value, Bool);
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         if(cast(n == 1, Bool) && (cast(_tween.cachedDuration == _tween.cachedTime, Bool) || cast(_tween.cachedTime == 0, Bool)))
         {
            _target.visible = _visible;
         }
         else
         {
            _target.visible = _initVal;
         }
      }
   }
