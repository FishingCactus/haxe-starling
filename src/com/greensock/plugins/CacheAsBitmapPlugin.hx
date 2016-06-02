package com.greensock.plugins;
   import flash.display.DisplayObject;
   
   
   class CacheAsBitmapPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _target:DisplayObject;
      
      private var _initVal:Bool;
      
      private var _cacheAsBitmap:Bool;
      
      private var _tween:TweenLite;
      
      public function new()
      {
         super();
         this.propName = "cacheAsBitmap";
         this.overwriteProps = ["cacheAsBitmap"];
      }
      
      override public  function set_changeFactor(n)
      {
         if(cast(_tween.cachedDuration == _tween.cachedTime, Bool) || cast(_tween.cachedTime == 0, Bool))
         {
            _target.cacheAsBitmap = _initVal;
         }
         else if(_target.cacheAsBitmap != _cacheAsBitmap)
         {
            _target.cacheAsBitmap = _cacheAsBitmap;
         }
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         _target =cast( target, DisplayObject);
         _tween = tween;
         _initVal = _target.cacheAsBitmap;
         _cacheAsBitmap = cast(value, Bool);
         return true;
      }
   }
