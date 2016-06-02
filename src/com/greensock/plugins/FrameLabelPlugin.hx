package com.greensock.plugins;

   import flash.display.MovieClip;

   class FrameLabelPlugin extends FramePlugin
   {

      public static inline var API:Float = 1;

      public function new()
      {
         super();
         this.propName = "frameLabel";
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(Std.is(!tween.target, MovieClip))
         {
            return false;
         }
         _target =cast( target, MovieClip);
         this.frame = _target.currentFrame;
         var labels:Array<openfl.display.FrameLabel> = _target.currentLabels;
         var label:String = value;
         var endFrame:Int = _target.currentFrame;
         var i:Int = labels.length;
         while(i-- > 0)
         {
            if(labels[i].name == label)
            {
               endFrame = labels[i].frame;
               break;
            }
         }
         if(this.frame != endFrame)
         {
            addTween(this,"frame",this.frame,endFrame,"frame");
         }
         return true;
      }
   }
