package com.greensock.plugins;
   import flash.media.SoundTransform;
   
   
   class VolumePlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _target:Object;
      
      private var _st:SoundTransform;
      
      public function new()
      {
         super();
         this.propName = "volume";
         this.overwriteProps = ["volume"];
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         if(cast(isNaN(value), Bool) || cast(target.hasOwnProperty("volume"), Bool) || cast(!target.hasOwnProperty("soundTransform"), Bool))
         {
            return false;
         }
         _target = target;
         _st = _target.soundTransform;
         addTween(_st,"volume",_st.volume,value,"volume");
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         updateTweens(n);
         _target.soundTransform = _st;
      }
   }
