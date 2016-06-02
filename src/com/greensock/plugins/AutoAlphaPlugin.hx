package com.greensock.plugins;
   
   
   class AutoAlphaPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _target:Object;
      
      private var _ignoreVisible:Bool;
      
      public function new()
      {
         super();
         this.propName = "autoAlpha";
         this.overwriteProps = ["alpha","visible"];
      }
      
      override public function killProps(lookup:Object) : Void
      {
         super.killProps(lookup);
         _ignoreVisible = cast("visible" in lookup, Bool);
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         addTween(target,"alpha",target.alpha,value,"alpha");
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         updateTweens(n);
         if(!_ignoreVisible)
         {
            _target.visible = cast(_target.alpha != 0, Bool);
         }
      }
   }
