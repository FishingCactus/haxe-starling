package com.greensock.core;

import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.plugins.EndArrayPlugin;
import com.greensock.plugins.FramePlugin;
import com.greensock.plugins.RemoveTintPlugin;
import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.VisiblePlugin;
import com.greensock.plugins.VolumePlugin;
import com.greensock.plugins.BevelFilterPlugin;
import com.greensock.plugins.BezierPlugin;
import com.greensock.plugins.BezierThroughPlugin;
import com.greensock.plugins.BlurFilterPlugin;
import com.greensock.plugins.ColorMatrixFilterPlugin;
import com.greensock.plugins.ColorTransformPlugin;
import com.greensock.plugins.DropShadowFilterPlugin;
import com.greensock.plugins.FrameLabelPlugin;
import com.greensock.plugins.GlowFilterPlugin;
import com.greensock.plugins.HexColorsPlugin;
import com.greensock.plugins.RoundPropsPlugin;
import com.greensock.plugins.ShortRotationPlugin;

   class TweenCore
   {

		public var delay(get, set):Float;
		public var duration(get, set):Float;
		public var paused(get, set):Bool;
		public var totalTime(get, set):Float;
		public var startTime(get, set):Float;
		public var reversed(get, set):Bool;
		public var currentTime(get, set):Float;
		public var totalDuration(get, set):Float;


      public static inline var version:Float = 1.693;

      private static var _classInitted:Bool;

      public var initted:Bool;

      private var _hasUpdate:Bool;

      public var active:Bool;

      private var _delay:Float;

      public var cachedReversed:Bool;

      public var nextNode:com.greensock.core.TweenCore;

      public var cachedTime:Float;

      private var _rawPrevTime:Float = -1;

      public var vars:Dynamic;

      public var cachedTotalTime:Float;

      public var data : Dynamic;

      public var timeline:com.greensock.core.SimpleTimeline;

      public var cachedOrphan:Bool;

      public var cachedStartTime:Float;

      public var prevNode:com.greensock.core.TweenCore;

      public var cachedDuration:Float;

      public var gc:Bool;

      public var cachedPauseTime:Float;

      public var cacheIsDirty:Bool;

      public var cachedPaused:Bool;

      public var cachedTimeScale:Float;

      public var cachedTotalDuration:Float;

      private static var __initialized = false;

      public function new(duration:Float = 0, vars:Dynamic = null)
      {
          if ( !__initialized ) {
              TweenPlugin.activate([AutoAlphaPlugin,EndArrayPlugin,FramePlugin,RemoveTintPlugin,TintPlugin,VisiblePlugin,VolumePlugin,BevelFilterPlugin,BezierPlugin,BezierThroughPlugin,BlurFilterPlugin,ColorMatrixFilterPlugin,ColorTransformPlugin,DropShadowFilterPlugin,FrameLabelPlugin,GlowFilterPlugin,HexColorsPlugin,RoundPropsPlugin,ShortRotationPlugin/*,{}*/]);
              __initialized = true;
          }

         this.vars = vars != null?vars:{};
         if(this.vars.isGSVars)
         {
            this.vars = this.vars.vars;
         }
         this.cachedDuration = this.cachedTotalDuration = duration;
         _delay = this.vars.delay? this.vars.delay : 0.0;
         this.cachedTimeScale = this.vars.timeScale? this.vars.timeScale : 1;
         this.active = duration == 0 && _delay == 0 && this.vars.immediateRender != false;
         this.cachedTotalTime = this.cachedTime = 0;
         this.data = this.vars.data;
         if(!_classInitted)
         {
            if(Math.isNaN(TweenLite.rootFrame))
            {
               TweenLite.initClass();
               _classInitted = true;
            }
            else
            {
               return;
            }
         }
         var tl:com.greensock.core.SimpleTimeline =
            Std.is( this.vars.timeline, SimpleTimeline)?
                this.vars.timeline:
                this.vars.useFrames?
                    TweenLite.rootFramesTimeline:
                    TweenLite.rootTimeline;

         tl.insert(this,tl.cachedTotalTime);
         if(this.vars.reversed)
         {
            this.cachedReversed = true;
         }
         if(this.vars.paused)
         {
            this.paused = true;
         }
      }

      public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) : Void
      {
      }

      public  function get_delay()
      {
         return _delay;
      }

      public  function get_duration()
      {
         return this.cachedDuration;
      }

      public  function set_reversed(b)
      {
         if(b != this.cachedReversed)
         {
            this.cachedReversed = b;
            setTotalTime(this.cachedTotalTime,true);
         }

         return b;
      }

      public  function set_startTime(n)
      {
         if((this.timeline != null) && ((n != this.cachedStartTime) || (this.gc)))
         {
            this.timeline.insert(this,n - _delay);
         }
         else
         {
            this.cachedStartTime = n;
         }
         return n;
      }

      public function restart(includeDelay:Bool = false, suppressEvents:Bool = true) : Void
      {
         this.reversed = false;
         this.paused = false;
         this.setTotalTime(includeDelay?(-_delay):(0),suppressEvents);
      }

      public  function set_delay(n:Float):Float
      {
         this.startTime = this.startTime + (n - _delay);
         return _delay = n;
      }

      public function resume() : Void
      {
         this.paused = false;
      }

      public  function get_paused()
      {
         return this.cachedPaused;
      }

      public function play() : Void
      {
         this.reversed = false;
         this.paused = false;
      }

      public  function set_duration(n:Float):Float
      {
         var ratio:Float = n / this.cachedDuration;
         this.cachedDuration = this.cachedTotalDuration = n;
         setDirtyCache(true);
         if(this.active && !this.cachedPaused && n != 0)
         {
            this.setTotalTime(this.cachedTotalTime * ratio,true);
         }

         return n;
      }

      public function invalidate() : Void
      {
      }

      public function complete(skipRender:Bool = false, suppressEvents:Bool = false) : Void
      {
         if(!skipRender)
         {
            renderTime(this.totalDuration,suppressEvents,false);
            return;
         }
         if(this.timeline.autoRemoveChildren)
         {
            this.setEnabled(false,false);
         }
         else
         {
            this.active = false;
         }
         if(!suppressEvents)
         {
            if((this.vars.onComplete) && (this.cachedTotalTime >= this.cachedTotalDuration) && (!this.cachedReversed))
            {
               this.vars.onComplete(this.vars.onCompleteParams);
            }
            else if((this.cachedReversed) && (this.cachedTotalTime == 0) && (this.vars.onReverseComplete))
            {
               this.vars.onReverseComplete(this.vars.onReverseCompleteParams);
            }
         }
      }

      public  function get_totalTime()
      {
         return this.cachedTotalTime;
      }

      public  function get_startTime()
      {
         return this.cachedStartTime;
      }

      public  function get_reversed()
      {
         return this.cachedReversed;
      }

      public  function set_currentTime(n)
      {
         setTotalTime(n,false);

         return n;
      }

      private function setDirtyCache(includeSelf:Bool = true) : Void
      {
         var tween:com.greensock.core.TweenCore = includeSelf?this:this.timeline;
         while(tween!=null)
         {
            tween.cacheIsDirty = true;
            tween = tween.timeline;
         }
      }

      public function reverse(forceResume:Bool = true) : Void
      {
         this.reversed = true;
         if(forceResume)
         {
            this.paused = false;
         }
         else if(this.gc)
         {
            this.setEnabled(true,false);
         }
      }

      public  function set_paused(b)
      {
         if((b != this.cachedPaused) && (this.timeline != null))
         {
            if(b)
            {
               this.cachedPauseTime = this.timeline.rawTime;
            }
            else
            {
               this.cachedStartTime = this.cachedStartTime + (this.timeline.rawTime - this.cachedPauseTime);
               this.cachedPauseTime = Math.NaN;
               setDirtyCache(false);
            }
            this.cachedPaused = b;
            this.active = (!this.cachedPaused && this.cachedTotalTime > 0 && this.cachedTotalTime < this.cachedTotalDuration);
         }
         if((!b) && (this.gc))
         {
            this.setEnabled(true,false);
         }

         return b;
      }

      public function kill() : Void
      {
         setEnabled(false,false);
      }

      public  function set_totalTime(n)
      {
         setTotalTime(n,false);

         return n;
      }

      public  function get_currentTime()
      {
         return this.cachedTime;
      }

      private function setTotalTime(time:Float, suppressEvents:Bool = false) : Void
      {
         var tlTime:Float = Math.NaN;
         var dur:Float = Math.NaN;
         if(this.timeline!=null)
         {
            tlTime = this.cachedPaused?(this.cachedPauseTime):(this.timeline.cachedTotalTime);
            if(this.cachedReversed)
            {
               dur = this.cacheIsDirty?(this.totalDuration):(this.cachedTotalDuration);
               this.cachedStartTime = tlTime - (dur - time) / this.cachedTimeScale;
            }
            else
            {
               this.cachedStartTime = tlTime - time / this.cachedTimeScale;
            }
            if(!this.timeline.cacheIsDirty)
            {
               setDirtyCache(false);
            }
            if(this.cachedTotalTime != time)
            {
               renderTime(time,suppressEvents,false);
            }
         }
      }

      public function pause() : Void
      {
         this.paused = true;
      }

      public  function set_totalDuration(n)
      {
         return this.duration = n;
      }

      public  function get_totalDuration()
      {
         return this.cachedTotalDuration;
      }

      public function setEnabled(enabled:Bool, ignoreTimeline:Bool = false) : Bool
      {
         this.gc = !enabled;
         if(enabled)
         {
            this.active = (!this.cachedPaused && this.cachedTotalTime > 0 && this.cachedTotalTime < this.cachedTotalDuration);
            if((!ignoreTimeline) && (this.cachedOrphan))
            {
               this.timeline.insert(this,this.cachedStartTime - _delay);
            }
         }
         else
         {
            this.active = false;
            if((!ignoreTimeline) && (!this.cachedOrphan))
            {
               this.timeline.remove(this,true);
            }
         }
         return false;
      }
   }
