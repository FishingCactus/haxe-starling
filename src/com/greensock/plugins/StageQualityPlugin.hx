package com.greensock.plugins;
   
   import flash.display.Stage;
   import flash.display.StageQuality;
   
   class StageQualityPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _during:String;
      
      private var _tween:TweenLite;
      
      private var _after:String;
      
      private var _stage:Stage;
      
      public function new()
      {
         super();
         this.propName = "stageQuality";
         this.overwriteProps = ["stageQuality"];
      }
      
      override public  function set_changeFactor(n)
      {
         if(cast(_tween.cachedDuration == _tween.cachedTime, Bool) || cast(_tween.cachedTime == 0, Bool))
         {
            _stage.quality = _after;
         }
         else if(_stage.quality != _during)
         {
            _stage.quality = _during;
         }
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!(Std.is(value.stage, Stage)))
         {
            trace("You must define a \'stage\' property for the stageQuality object in your tween.");
            return false;
         }
         _stage =cast( value.stage, Stage);
         _tween = tween;
         _during = "during" in value?value.during:StageQuality.MEDIUM;
         _after = "after" in value?value.after:_stage.quality;
         return true;
      }
   }
