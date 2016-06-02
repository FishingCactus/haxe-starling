package com.greensock;
   import com.greensock.core.TweenCore;
   import com.greensock.core.SimpleTimeline;

   class OverwriteManager
   {

      public static var enabled:Bool;

      public static var mode:Int;

      public static inline var ALL_ONSTART:Int = 4;

      public static inline var CONCURRENT:Int = 3;

      public static inline var ALL_IMMEDIATE:Int = 1;

      public static inline var PREEXISTING:Int = 5;

      public static inline var AUTO:Int = 2;

      public static inline var version:Float = 6.1;

      public static inline var NONE:Int = 0;

      public function new()
      {
         super();
      }

      public static function getGlobalPaused(tween:TweenCore) : Bool
      {
         var paused:Bool = false;
         while(tween)
         {
            if(tween.cachedPaused)
            {
               paused = true;
               break;
            }
            tween = tween.timeline;
         }
         return paused;
      }

      public static function init(defaultMode:Int = 2) : Int
      {
         if(TweenLite.version < 11.6)
         {
            throw new Error("Warning: Your TweenLite class needs to be updated to work with OverwriteManager (or you may need to clear your ASO files). Please download and install the latest version from http://www.tweenlite.com.");
         }
         TweenLite.overwriteManager = OverwriteManager;
         mode = defaultMode;
         enabled = true;
         return mode;
      }

      public static function manageOverwrites(tween:TweenLite, props:Dynamic, targetTweens:Array<Int>, mode:Int) : Bool
      {
         var i:Int = 0;
         var changed:Bool = false;
         var curTween:TweenLite = null;
         var l:Int = 0;
         var combinedTimeScale:Float = NaN;
         var combinedStartTime:Float = NaN;
         var cousin:TweenCore = null;
         var cousinStartTime:Float = NaN;
         var timeline:SimpleTimeline = null;
         if(mode >= 4)
         {
            l = targetTweens.length;
            for( i in 0...l )
            {
               curTween = targetTweens[i];
               if(curTween != tween)
               {
                  if(curTween.setEnabled(false,false))
                  {
                     changed = true;
                  }
               }
               else if(mode == 5)
               {
                  break;
               }
            }
            return changed;
         }
         var startTime:Float = tween.cachedStartTime + 1.0e-10;
         var overlaps:Array<Int> = [];
         var cousins:Array<Int> = [];
         var cCount:Int = 0;
         var oCount:Int = 0;
         i = targetTweens.length;
         while(--i > -1)
         {
            curTween = targetTweens[i];
            if(!(cast(curTween == tween, Bool) || cast(curTween.gc, Bool) || cast(!curTween.initted, Bool) && cast(startTime - curTween.cachedStartTime <= 2.0e-10, Bool)))
            {
               if(curTween.timeline != tween.timeline)
               {
                  if(!getGlobalPaused(curTween))
                  {
                     cousins[cCount++] = curTween;
                  }
               }
               else if(cast(curTween.cachedStartTime <= startTime, Bool) && cast(curTween.cachedStartTime + curTween.totalDuration + 1.0e-10 > startTime, Bool) && cast(!curTween.cachedPaused, Bool) && cast(!(Bool(tween.cachedDuration == 0) && Bool(startTime - curTween.cachedStartTime <= 2.0e-10)), Bool))
               {
                  overlaps[oCount++] = curTween;
               }
            }
         }
         if(cCount != 0)
         {
            combinedTimeScale = tween.cachedTimeScale;
            combinedStartTime = startTime;
            timeline = tween.timeline;
            while(timeline)
            {
               combinedTimeScale = combinedTimeScale * timeline.cachedTimeScale;
               combinedStartTime = combinedStartTime + timeline.cachedStartTime;
               timeline = timeline.timeline;
            }
            startTime = combinedTimeScale * combinedStartTime;
            i = cCount;
            while(--i > -1)
            {
               cousin = cousins[i];
               combinedTimeScale = cousin.cachedTimeScale;
               combinedStartTime = cousin.cachedStartTime;
               timeline = cousin.timeline;
               while(timeline)
               {
                  combinedTimeScale = combinedTimeScale * timeline.cachedTimeScale;
                  combinedStartTime = combinedStartTime + timeline.cachedStartTime;
                  timeline = timeline.timeline;
               }
               cousinStartTime = combinedTimeScale * combinedStartTime;
               if(cast(cousinStartTime <= startTime, Bool) && (cast(cousinStartTime + cousin.totalDuration * combinedTimeScale + 1.0e-10 > startTime, Bool) || cast(cousin.cachedDuration == 0, Bool)))
               {
                  overlaps[oCount++] = cousin;
               }
            }
         }
         if(oCount == 0)
         {
            return changed;
         }
         i = oCount;
         if(mode == 2)
         {
            while(--i > -1)
            {
               curTween = overlaps[i];
               if(curTween.killVars(props))
               {
                  changed = true;
               }
               if(cast(curTween.cachedPT1 == null, Bool) && cast(curTween.initted, Bool))
               {
                  curTween.setEnabled(false,false);
               }
            }
         }
         else
         {
            while(--i > -1)
            {
               if(cast(overlaps[i], TweenLite).setEnabled(false,false))
               {
                  changed = true;
               }
            }
         }
         return changed;
      }
   }
