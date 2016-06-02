package com.greensock.core;
   class SimpleTimeline extends com.greensock.core.TweenCore
   {

		public var rawTime(get, null):Float;


      public var autoRemoveChildren:Bool;

      private var _lastChild:com.greensock.core.TweenCore;

      private var _firstChild:com.greensock.core.TweenCore;

      public function new(vars:Dynamic = null)
      {
         super(0,vars);
      }

      public  function get_rawTime()
      {
         return this.cachedTotalTime;
      }

      public function insert(tween:com.greensock.core.TweenCore, time:Float = 0) : com.greensock.core.TweenCore
      {
         var prevTimeline:SimpleTimeline = tween.timeline;
         if(!tween.cachedOrphan && prevTimeline!=null)
         {
            prevTimeline.remove(tween,true);
         }
         tween.timeline = this;
         tween.cachedStartTime = time + tween.delay;
         if(tween.gc)
         {
            tween.setEnabled(true,true);
         }
         if(tween.cachedPaused && prevTimeline != this)
         {
            tween.cachedPauseTime = tween.cachedStartTime + (this.rawTime - tween.cachedStartTime) / tween.cachedTimeScale;
         }
         if(_lastChild != null)
         {
            _lastChild.nextNode = tween;
         }
         else
         {
            _firstChild = tween;
         }
         tween.prevNode = _lastChild;
         _lastChild = tween;
         tween.nextNode = null;
         tween.cachedOrphan = false;
         return tween;
      }

      override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) : Void
      {
         var dur:Float = Math.NaN;
         var next:com.greensock.core.TweenCore = null;
         var tween:com.greensock.core.TweenCore = _firstChild;
         this.cachedTotalTime = time;
         this.cachedTime = time;
         while(tween!=null)
         {
            next = tween.nextNode;
            if(tween.active|| time >= tween.cachedStartTime && !tween.cachedPaused && !tween.gc)
            {
               if(!tween.cachedReversed)
               {
                  tween.renderTime((time - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
               }
               else
               {
                  dur = !!tween.cacheIsDirty?cast(tween.totalDuration, Float):cast(tween.cachedTotalDuration, Float);
                  tween.renderTime(dur - (time - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
               }
            }
            tween = next;
         }
      }

      public function remove(tween:com.greensock.core.TweenCore, skipDisable:Bool = false) : Void
      {
         if(tween.cachedOrphan)
         {
            return;
         }
         if(!skipDisable)
         {
            tween.setEnabled(false,true);
         }
         if(tween.nextNode != null)
         {
            tween.nextNode.prevNode = tween.prevNode;
         }
         else if(_lastChild == tween)
         {
            _lastChild = tween.prevNode;
         }
         if(tween.prevNode != null)
         {
            tween.prevNode.nextNode = tween.nextNode;
         }
         else if(_firstChild == tween)
         {
            _firstChild = tween.nextNode;
         }
         tween.cachedOrphan = true;
      }
   }
