package com.greensock.plugins;
   import flash.media.SoundTransform;
   
   
   class SoundTransformPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _target:Object;
      
      private var _st:SoundTransform;
      
      public function new()
      {
         super();
         this.propName = "soundTransform";
         this.overwriteProps = ["soundTransform","volume"];
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         var p:Dynamic = null;
         if(!target.hasOwnProperty("soundTransform"))
         {
            return false;
         }
         _target = target;
         _st = _target.soundTransform;
         for(p in value)
         {
            addTween(_st,p,_st[p],value[p],p);
         }
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         updateTweens(n);
         _target.soundTransform = _st;
      }
   }
