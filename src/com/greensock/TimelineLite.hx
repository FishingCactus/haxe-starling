package com.greensock;
   import com.greensock.core.SimpleTimeline;
   import com.greensock.core.TweenCore;
   
   class TimelineLite extends SimpleTimeline
   {

		public var currentProgress(get, set):Float;
		public var totalDuration(get, set):Float;
		public var duration(get, set):Float;
		public var useFrames(get, null):Bool;
		public var rawTime(get, null):Float;
		public var timeScale(get, set):Float;

      
      public static inline var version:Float = 1.695;
      
      private static var _overwriteMode:Int = !!OverwriteManager.enabled?cast(OverwriteManager.mode, Int):cast(OverwriteManager.init(2), Int);
       
      private var _endCaps:Array<Int>;
      
      private var _labels:Dynamic;
      
      public function new(vars:Dynamic = null)
      {
         super(vars);
         _endCaps = [null,null];
         _labels = {};
         this.autoRemoveChildren = cast(this.vars.autoRemoveChildren == true, Bool);
         _hasUpdate = cast(typeof this.vars.onUpdate == "function", Bool);
         if(Std.is(this.vars.tweens, Array<Int>))
         {
            this.insertMultiple(this.vars.tweens,0,this.vars.align != null?this.vars.align:"normal",cast(this.vars.stagger, Bool)?cast(Float(this.vars.stagger), Float):cast(0, Float));
         }
      }
      
      public  function set_timeScale(n)
      {
         if(n == 0)
         {
            n = 0.0001;
         }
         var tlTime:Float = cast(this.cachedPauseTime, Bool) || cast(this.cachedPauseTime == 0, Bool)?cast(this.cachedPauseTime, Float):cast(this.timeline.cachedTotalTime, Float);
         this.cachedStartTime = tlTime - (tlTime - this.cachedStartTime) * this.cachedTimeScale / n;
         this.cachedTimeScale = n;
         setDirtyCache(false);
      }
      
      public function stop() : Void
      {
         this.paused = true;
      }
      
      override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) : Void
      {
         var tween:TweenCore = null;
         var isComplete:Bool = false;
         var rendered:Bool = false;
         var next:TweenCore = null;
         var dur:Float = NaN;
         if(this.gc)
         {
            this.setEnabled(true,false);
         }
         else if(cast(!this.active, Bool) && cast(!this.cachedPaused, Bool))
         {
            this.active = true;
         }
         var totalDur:Float = !!this.cacheIsDirty?cast(this.totalDuration, Float):cast(this.cachedTotalDuration, Float);
         var prevTime:Float = this.cachedTime;
         var prevStart:Float = this.cachedStartTime;
         var prevTimeScale:Float = this.cachedTimeScale;
         var prevPaused:Bool = this.cachedPaused;
         if(time >= totalDur)
         {
            if(cast(prevTime != totalDur, Bool) && cast(_rawPrevTime != time, Bool))
            {
               this.cachedTotalTime = this.cachedTime = totalDur;
               forceChildrenToEnd(totalDur,suppressEvents);
               isComplete = cast(!this.hasPausedChild(), Bool) && cast(!this.cachedReversed, Bool);
               rendered = true;
               if(cast(this.cachedDuration == 0, Bool) && cast(isComplete, Bool) && (cast(time == 0, Bool) || cast(_rawPrevTime < 0, Bool)))
               {
                  force = true;
               }
            }
         }
         else if(time <= 0)
         {
            if(time < 0)
            {
               this.active = false;
               if(cast(this.cachedDuration == 0, Bool) && cast(_rawPrevTime > 0, Bool))
               {
                  force = true;
                  isComplete = true;
               }
            }
            else if(cast(time == 0, Bool) && cast(!this.initted, Bool))
            {
               force = true;
            }
            if(cast(prevTime != 0, Bool) && cast(_rawPrevTime != time, Bool))
            {
               this.cachedTotalTime = 0;
               this.cachedTime = 0;
               forceChildrenToBeginning(0,suppressEvents);
               rendered = true;
               if(this.cachedReversed)
               {
                  isComplete = true;
               }
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = time;
         }
         _rawPrevTime = time;
         if(cast(this.cachedTime == prevTime, Bool) && cast(!force, Bool))
         {
            return;
         }
         if(!this.initted)
         {
            this.initted = true;
         }
         if(cast(prevTime == 0 && this.vars.onStart, Bool) && cast(this.cachedTime != 0, Bool) && cast(!suppressEvents, Bool))
         {
            this.vars.onStart.apply(null,this.vars.onStartParams);
         }
         if(!rendered)
         {
            if(this.cachedTime - prevTime > 0)
            {
               tween = _firstChild;
               while(tween)
               {
                  next = tween.nextNode;
                  if(cast(this.cachedPaused, Bool) && cast(!prevPaused, Bool))
                  {
                     break;
                  }
                  if(cast(tween.active, Bool) || cast(!tween.cachedPaused, Bool) && cast(tween.cachedStartTime <= this.cachedTime, Bool) && cast(!tween.gc, Bool))
                  {
                     if(!tween.cachedReversed)
                     {
                        tween.renderTime((this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        dur = !!tween.cacheIsDirty?cast(tween.totalDuration, Float):cast(tween.cachedTotalDuration, Float);
                        tween.renderTime(dur - (this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  tween = next;
               }
            }
            else
            {
               tween = _lastChild;
               while(tween)
               {
                  next = tween.prevNode;
                  if(cast(this.cachedPaused, Bool) && cast(!prevPaused, Bool))
                  {
                     break;
                  }
                  if(cast(tween.active, Bool) || cast(!tween.cachedPaused, Bool) && cast(tween.cachedStartTime <= prevTime, Bool) && cast(!tween.gc, Bool))
                  {
                     if(!tween.cachedReversed)
                     {
                        tween.renderTime((this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        dur = !!tween.cacheIsDirty?cast(tween.totalDuration, Float):cast(tween.cachedTotalDuration, Float);
                        tween.renderTime(dur - (this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  tween = next;
               }
            }
         }
         if(cast(_hasUpdate, Bool) && cast(!suppressEvents, Bool))
         {
            this.vars.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         if(cast(isComplete, Bool) && (cast(prevStart == this.cachedStartTime, Bool) || cast(prevTimeScale != this.cachedTimeScale, Bool)) && (cast(totalDur >= this.totalDuration, Bool) || cast(this.cachedTime == 0, Bool)))
         {
            complete(true,suppressEvents);
         }
      }
      
      override public function remove(tween:TweenCore, skipDisable:Bool = false) : Void
      {
         if(tween.cachedOrphan)
         {
            return;
         }
         if(!skipDisable)
         {
            tween.setEnabled(false,true);
         }
         var first:TweenCore = !!this.gc?_endCaps[0]:_firstChild;
         var last:TweenCore = !!this.gc?_endCaps[1]:_lastChild;
         if(tween.nextNode)
         {
            tween.nextNode.prevNode = tween.prevNode;
         }
         else if(last == tween)
         {
            last = tween.prevNode;
         }
         if(tween.prevNode)
         {
            tween.prevNode.nextNode = tween.nextNode;
         }
         else if(first == tween)
         {
            first = tween.nextNode;
         }
         if(this.gc)
         {
            _endCaps[0] = first;
            _endCaps[1] = last;
         }
         else
         {
            _firstChild = first;
            _lastChild = last;
         }
         tween.cachedOrphan = true;
         setDirtyCache(true);
      }
      
      public  function get_currentProgress()
      {
         return this.cachedTime / this.duration;
      }
      
      override public  function get_totalDuration()
      {
         var max:Float = NaN;
         var end:Float = NaN;
         var tween:TweenCore = null;
         var prevStart:Float = NaN;
         var next:TweenCore = null;
         if(this.cacheIsDirty)
         {
            max = 0;
            tween = !!this.gc?_endCaps[0]:_firstChild;
            prevStart = -Infinity;
            while(tween)
            {
               next = tween.nextNode;
               if(tween.cachedStartTime < prevStart)
               {
                  this.insert(tween,tween.cachedStartTime - tween.delay);
               }
               else
               {
                  prevStart = tween.cachedStartTime;
               }
               if(tween.cachedStartTime < 0)
               {
                  max = max - tween.cachedStartTime;
                  this.shiftChildren(-tween.cachedStartTime,false,-9999999999);
               }
               end = tween.cachedStartTime + tween.totalDuration / tween.cachedTimeScale;
               if(end > max)
               {
                  max = end;
               }
               tween = next;
            }
            this.cachedDuration = this.cachedTotalDuration = max;
            this.cacheIsDirty = false;
         }
         return this.cachedTotalDuration;
      }
      
      public function gotoAndPlay(timeOrLabel:Dynamic, suppressEvents:Bool = true) : Void
      {
         setTotalTime(parseTimeOrLabel(timeOrLabel),suppressEvents);
         play();
      }
      
      public function appendMultiple(tweens:Array<Int>, offset:Float = 0, align:String = "normal", stagger:Float = 0) : Array<Int>
      {
         return insertMultiple(tweens,this.duration + offset,align,stagger);
      }
      
      public  function set_currentProgress(n)
      {
         setTotalTime(this.duration * n,false);
      }
      
      public function clear(tweens:Array<Int> = null) : Void
      {
         if(tweens == null)
         {
            tweens = getChildren(false,true,true);
         }
         var i:Int = tweens.length;
         while(--i > -1)
         {
            cast(tweens[i], TweenCore).setEnabled(false,false);
         }
      }
      
      public function prepend(tween:TweenCore, adjustLabels:Bool = false) : TweenCore
      {
         shiftChildren(tween.totalDuration / tween.cachedTimeScale + tween.delay,adjustLabels,0);
         return insert(tween,0);
      }
      
      public function removeLabel(label:String) : Float
      {
         var n:Float = _labels[label];
         _labels.remove(label);
         return n;
      }
      
      private function parseTimeOrLabel(timeOrLabel:Dynamic) : Float
      {
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               throw new openfl.errors.Error("TimelineLite error: the " + timeOrLabel + " label was not found.");
            }
            return getLabelTime(cast(timeOrLabel, String));
         }
         return cast(timeOrLabel, Float);
      }
      
      public function addLabel(label:String, time:Float) : Void
      {
         _labels[label] = time;
      }
      
      public function hasPausedChild() : Bool
      {
         var tween:TweenCore = !!this.gc?_endCaps[0]:_firstChild;
         while(tween)
         {
            if(cast(tween.cachedPaused, Bool) || cast(Std.is(tween, TimelineLite), Bool) && cast((cast(tween, TimelineLite)).hasPausedChild(), Bool))
            {
               return true;
            }
            tween = tween.nextNode;
         }
         return false;
      }
      
      public function getTweensOf(target:Dynamic, nested:Bool = true) : Array<Int>
      {
         var i:Int = 0;
         var tweens:Array<Int> = getChildren(nested,true,false);
         var a:Array<Int> = [];
         var l:Int = tweens.length;
         var cnt:Int = 0;
         for( i in (0)...(l) )
         {
            if(cast(tweens[i], TweenLite).target == target)
            {
               a[cnt++] = tweens[i];
            }
         }
         return a;
      }
      
      public function gotoAndStop(timeOrLabel:Dynamic, suppressEvents:Bool = true) : Void
      {
         setTotalTime(parseTimeOrLabel(timeOrLabel),suppressEvents);
         this.paused = true;
      }
      
      public function append(tween:TweenCore, offset:Float = 0) : TweenCore
      {
         return insert(tween,this.duration + offset);
      }
      
      override public  function get_duration()
      {
         var d:Float = NaN;
         if(this.cacheIsDirty)
         {
            d = this.totalDuration;
         }
         return this.cachedDuration;
      }
      
      public  function get_useFrames()
      {
         var tl:SimpleTimeline = this.timeline;
         while(tl.timeline)
         {
            tl = tl.timeline;
         }
         return cast(tl == TweenLite.rootFramesTimeline, Bool);
      }
      
      public function shiftChildren(amount:Float, adjustLabels:Bool = false, ignoreBeforeTime:Float = 0) : Void
      {
         var p:Dynamic = null;
         var tween:TweenCore = !!this.gc?_endCaps[0]:_firstChild;
         while(tween)
         {
            if(tween.cachedStartTime >= ignoreBeforeTime)
            {
               tween.cachedStartTime = tween.cachedStartTime + amount;
            }
            tween = tween.nextNode;
         }
         if(adjustLabels)
         {
            for(p in _labels)
            {
               if(_labels[p] >= ignoreBeforeTime)
               {
                  _labels[p] = _labels[p] + amount;
               }
            }
         }
         this.setDirtyCache(true);
      }
      
      public function goto(timeOrLabel:Dynamic, suppressEvents:Bool = true) : Void
      {
         setTotalTime(parseTimeOrLabel(timeOrLabel),suppressEvents);
      }
      
      public function killTweensOf(target:Dynamic, nested:Bool = true, vars:Dynamic = null) : Bool
      {
         var tween:TweenLite = null;
         var tweens:Array<Int> = getTweensOf(target,nested);
         var i:Int = tweens.length;
         while(--i > -1)
         {
            tween = tweens[i];
            if(vars != null)
            {
               tween.killVars(vars);
            }
            if(cast(vars == null, Bool) || cast(tween.cachedPT1 == null, Bool) && cast(tween.initted, Bool))
            {
               tween.setEnabled(false,false);
            }
         }
         return cast(tweens.length > 0, Bool);
      }
      
      override public  function set_duration(n)
      {
         if(cast(this.duration != 0, Bool) && cast(n != 0, Bool))
         {
            this.timeScale = this.duration / n;
         }
      }
      
      public function insertMultiple(tweens:Array<Int>, timeOrLabel:Dynamic = 0, align:String = "normal", stagger:Float = 0) : Array<Int>
      {
         var i:Int = 0;
         var tween:TweenCore = null;
         var curTime:Float = cast(Float(timeOrLabel), Float) || cast(0, Float);
         var l:Int = tweens.length;
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               addLabel(timeOrLabel,this.duration);
            }
            curTime = _labels[timeOrLabel];
         }
         for( i in (0)...(l) )
         {
            tween =cast( tweens[i], TweenCore);
            insert(tween,curTime);
            if(align == "sequence")
            {
               curTime = tween.cachedStartTime + tween.totalDuration / tween.cachedTimeScale;
            }
            else if(align == "start")
            {
               tween.cachedStartTime = tween.cachedStartTime - tween.delay;
            }
            curTime = curTime + stagger;
         }
         return tweens;
      }
      
      public function getLabelTime(label:String) : Float
      {
         return label in _labels?cast(Float(_labels[label]), Float):cast(-1, Float);
      }
      
      override public  function get_rawTime()
      {
         if(cast(this.cachedPaused, Bool) || cast(this.cachedTotalTime != 0, Bool) && cast(this.cachedTotalTime != this.cachedTotalDuration, Bool))
         {
            return this.cachedTotalTime;
         }
         return (this.timeline.rawTime - this.cachedStartTime) * this.cachedTimeScale;
      }
      
      override public  function set_totalDuration(n)
      {
         if(cast(this.totalDuration != 0, Bool) && cast(n != 0, Bool))
         {
            this.timeScale = this.totalDuration / n;
         }
      }
      
      public function getChildren(nested:Bool = true, tweens:Bool = true, timelines:Bool = true, ignoreBeforeTime:Float = -9.999999999E9) : Array<Int>
      {
         var a:Array<Int> = [];
         var cnt:Int = 0;
         var tween:TweenCore = !!this.gc?_endCaps[0]:_firstChild;
         while(tween)
         {
            if(tween.cachedStartTime >= ignoreBeforeTime)
            {
               if(Std.is(tween, TweenLite))
               {
                  if(tweens)
                  {
                     a[cnt++] = tween;
                  }
               }
               else
               {
                  if(timelines)
                  {
                     a[cnt++] = tween;
                  }
                  if(nested)
                  {
                     a = a.concat(cast(tween, TimelineLite).getChildren(true,tweens,timelines));
                     cnt = a.length;
                  }
               }
            }
            tween = tween.nextNode;
         }
         return a;
      }
      
      private function forceChildrenToEnd(time:Float, suppressEvents:Bool = false) : Float
      {
         var next:TweenCore = null;
         var dur:Float = NaN;
         var tween:TweenCore = _firstChild;
         var prevPaused:Bool = this.cachedPaused;
         while(tween)
         {
            next = tween.nextNode;
            if(cast(this.cachedPaused, Bool) && cast(!prevPaused, Bool))
            {
               break;
            }
            if(cast(tween.active, Bool) || cast(!tween.cachedPaused, Bool) && cast(!tween.gc, Bool) && (cast(tween.cachedTotalTime != tween.cachedTotalDuration, Bool) || cast(tween.cachedDuration == 0, Bool)))
            {
               if(cast(time == this.cachedDuration, Bool) && (cast(tween.cachedDuration != 0, Bool) || cast(tween.cachedStartTime == this.cachedDuration, Bool)))
               {
                  tween.renderTime(!!tween.cachedReversed?cast(0, Float):cast(tween.cachedTotalDuration, Float),suppressEvents,false);
               }
               else if(!tween.cachedReversed)
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
         return time;
      }
      
      private function forceChildrenToBeginning(time:Float, suppressEvents:Bool = false) : Float
      {
         var next:TweenCore = null;
         var dur:Float = NaN;
         var tween:TweenCore = _lastChild;
         var prevPaused:Bool = this.cachedPaused;
         while(tween)
         {
            next = tween.prevNode;
            if(cast(this.cachedPaused, Bool) && cast(!prevPaused, Bool))
            {
               break;
            }
            if(cast(tween.active, Bool) || cast(!tween.cachedPaused, Bool) && cast(!tween.gc, Bool) && (cast(tween.cachedTotalTime != 0, Bool) || cast(tween.cachedDuration == 0, Bool)))
            {
               if(cast(time == 0, Bool) && (cast(tween.cachedDuration != 0, Bool) || cast(tween.cachedStartTime == 0, Bool)))
               {
                  tween.renderTime(!!tween.cachedReversed?cast(tween.cachedTotalDuration, Float):cast(0, Float),suppressEvents,false);
               }
               else if(!tween.cachedReversed)
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
         return time;
      }
      
      override public function insert(tween:TweenCore, timeOrLabel:Dynamic = 0) : TweenCore
      {
         var curTween:TweenCore = null;
         var st:Float = NaN;
         var tl:SimpleTimeline = null;
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               addLabel(timeOrLabel,this.duration);
            }
            timeOrLabel = cast(_labels[timeOrLabel], Float);
         }
         var prevTimeline:SimpleTimeline = tween.timeline;
         if(cast(!tween.cachedOrphan, Bool) && cast(prevTimeline, Bool))
         {
            prevTimeline.remove(tween,true);
         }
         tween.timeline = this;
         tween.cachedStartTime = cast(timeOrLabel, Float) + tween.delay;
         if(cast(tween.cachedPaused, Bool) && cast(prevTimeline != this, Bool))
         {
            tween.cachedPauseTime = tween.cachedStartTime + (this.rawTime - tween.cachedStartTime) / tween.cachedTimeScale;
         }
         if(tween.gc)
         {
            tween.setEnabled(true,true);
         }
         setDirtyCache(true);
         var first:TweenCore = !!this.gc?_endCaps[0]:_firstChild;
         var last:TweenCore = !!this.gc?_endCaps[1]:_lastChild;
         if(last == null)
         {
            first = last = tween;
            tween.nextNode = tween.prevNode = null;
         }
         else
         {
            curTween = last;
            st = tween.cachedStartTime;
            while(cast(curTween != null, Bool) && cast(st < curTween.cachedStartTime, Bool))
            {
               curTween = curTween.prevNode;
            }
            if(curTween == null)
            {
               first.prevNode = tween;
               tween.nextNode = first;
               tween.prevNode = null;
               first = tween;
            }
            else
            {
               if(curTween.nextNode)
               {
                  curTween.nextNode.prevNode = tween;
               }
               else if(curTween == last)
               {
                  last = tween;
               }
               tween.prevNode = curTween;
               tween.nextNode = curTween.nextNode;
               curTween.nextNode = tween;
            }
         }
         tween.cachedOrphan = false;
         if(this.gc)
         {
            _endCaps[0] = first;
            _endCaps[1] = last;
         }
         else
         {
            _firstChild = first;
            _lastChild = last;
         }
         if(cast(this.gc, Bool) && cast(!this.cachedPaused, Bool) && cast(this.cachedStartTime + (tween.cachedStartTime + tween.cachedTotalDuration / tween.cachedTimeScale) / this.cachedTimeScale > this.timeline.cachedTime, Bool))
         {
            if(cast(this.timeline == TweenLite.rootTimeline, Bool) || cast(this.timeline == TweenLite.rootFramesTimeline, Bool))
            {
               this.setTotalTime(this.cachedTotalTime,true);
            }
            this.setEnabled(true,false);
            tl = this.timeline;
            while(cast(tl.gc, Bool) && cast(tl.timeline, Bool))
            {
               if(tl.cachedStartTime + tl.totalDuration / tl.cachedTimeScale > tl.timeline.cachedTime)
               {
                  tl.setEnabled(true,false);
               }
               tl = tl.timeline;
            }
         }
         return tween;
      }
      
      override public function invalidate() : Void
      {
         var tween:TweenCore = !!this.gc?_endCaps[0]:_firstChild;
         while(tween)
         {
            tween.invalidate();
            tween = tween.nextNode;
         }
      }
      
      public  function get_timeScale()
      {
         return this.cachedTimeScale;
      }
      
      public function prependMultiple(tweens:Array<Int>, align:String = "normal", stagger:Float = 0, adjustLabels:Bool = false) : Array<Int>
      {
         var tl:TimelineLite = new TimelineLite({
            "tweens":tweens,
            "align":align,
            "stagger":stagger
         });
         shiftChildren(tl.duration,adjustLabels,0);
         insertMultiple(tweens,0,align,stagger);
         tl.kill();
         return tweens;
      }
      
      override public function setEnabled(enabled:Bool, ignoreTimeline:Bool = false) : Bool
      {
         var tween:TweenCore = null;
         if(enabled == this.gc)
         {
            if(enabled)
            {
               _firstChild = tween = _endCaps[0];
               _lastChild = _endCaps[1];
               _endCaps = [null,null];
            }
            else
            {
               tween = _firstChild;
               _endCaps = [_firstChild,_lastChild];
               _firstChild = _lastChild = null;
            }
            while(tween)
            {
               tween.setEnabled(enabled,true);
               tween = tween.nextNode;
            }
         }
         return super.setEnabled(enabled,ignoreTimeline);
      }
   }
