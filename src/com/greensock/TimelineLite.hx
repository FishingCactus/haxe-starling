package com.greensock;
   import com.greensock.core.SimpleTimeline;
   import com.greensock.core.TweenCore;

   class TimelineLite extends SimpleTimeline
   {

		public var currentProgress(get, set):Float;
		public var useFrames(get, null):Bool;
		public var timeScale(get, set):Float;


      public static inline var version:Float = 1.695;

      private static var _overwriteMode:Int = !!OverwriteManager.enabled?cast(OverwriteManager.mode, Int):cast(OverwriteManager.init(2), Int);

      private var _endCaps:Array<TweenCore>;

      private var _labels:Dynamic;

      public function new(vars:Dynamic = null)
      {
         super(vars);
         _endCaps = [null,null];
         _labels = {};
         this.autoRemoveChildren = this.vars.autoRemoveChildren == true;
         _hasUpdate = Reflect.isFunction( this.vars.onUpdate );
         if(Std.is(this.vars.tweens, Array))
         {
            this.insertMultiple(this.vars.tweens,0,this.vars.align != null?this.vars.align:"normal", this.vars.stagger != null ? this.vars.stagger: 0);
         }
      }

      public  function set_timeScale(n:Float):Float
      {
         if(n == 0)
         {
            n = 0.0001;
         }
         var tlTime:Float = this.cachedPauseTime != null ? this.cachedPauseTime : this.timeline.cachedTotalTime;
         this.cachedStartTime = tlTime - (tlTime - this.cachedStartTime) * this.cachedTimeScale / n;
         this.cachedTimeScale = n;
         setDirtyCache(false);

         return n;
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
         var dur:Float = Math.NaN;
         if(this.gc)
         {
            this.setEnabled(true,false);
         }
         else if(!this.active && !this.cachedPaused)
         {
            this.active = true;
         }
         var totalDur:Float = !!this.cacheIsDirty?this.totalDuration:this.cachedTotalDuration;
         var prevTime:Float = this.cachedTime;
         var prevStart:Float = this.cachedStartTime;
         var prevTimeScale:Float = this.cachedTimeScale;
         var prevPaused:Bool = this.cachedPaused;
         if(time >= totalDur)
         {
            if(prevTime != totalDur && _rawPrevTime != time)
            {
               this.cachedTotalTime = this.cachedTime = totalDur;
               forceChildrenToEnd(totalDur,suppressEvents);
               isComplete = !this.hasPausedChild() && !this.cachedReversed;
               rendered = true;
               if(this.cachedDuration == 0 && isComplete && (time == 0 || _rawPrevTime < 0))
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
               if(this.cachedDuration == 0 && _rawPrevTime > 0)
               {
                  force = true;
                  isComplete = true;
               }
            }
            else if(time == 0 && !this.initted)
            {
               force = true;
            }
            if(prevTime != 0 && _rawPrevTime != time)
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
         if(this.cachedTime == prevTime && !force)
         {
            return;
         }
         if(!this.initted)
         {
            this.initted = true;
         }
         if(prevTime == 0 && this.vars.onStart && this.cachedTime != 0 && !suppressEvents)
         {
            this.vars.onStart.apply(null,this.vars.onStartParams);
         }
         if(!rendered)
         {
            if(this.cachedTime - prevTime > 0)
            {
               tween = _firstChild;
               while(tween != null)
               {
                  next = tween.nextNode;
                  if(this.cachedPaused && !prevPaused)
                  {
                     break;
                  }
                  if(tween.active || !tween.cachedPaused && tween.cachedStartTime <= this.cachedTime && !tween.gc)
                  {
                     if(!tween.cachedReversed)
                     {
                        tween.renderTime((this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        dur = !!tween.cacheIsDirty?tween.totalDuration:tween.cachedTotalDuration;
                        tween.renderTime(dur - (this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  tween = next;
               }
            }
            else
            {
               tween = _lastChild;
               while(tween != null)
               {
                  next = tween.prevNode;
                  if(this.cachedPaused && !prevPaused)
                  {
                     break;
                  }
                  if(tween.active || !tween.cachedPaused && tween.cachedStartTime <= prevTime && !tween.gc)
                  {
                     if(!tween.cachedReversed)
                     {
                        tween.renderTime((this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        dur = !!tween.cacheIsDirty?tween.totalDuration:tween.cachedTotalDuration;
                        tween.renderTime(dur - (this.cachedTime - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  tween = next;
               }
            }
         }
         if(_hasUpdate && !suppressEvents)
         {
            this.vars.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         if(isComplete && (prevStart == this.cachedStartTime || prevTimeScale != this.cachedTimeScale) && (totalDur >= this.totalDuration || this.cachedTime == 0))
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
         var first:TweenCore = this.gc?_endCaps[0]:_firstChild;
         var last:TweenCore = this.gc?_endCaps[1]:_lastChild;
         if(tween.nextNode != null)
         {
            tween.nextNode.prevNode = tween.prevNode;
         }
         else if(last == tween)
         {
            last = tween.prevNode;
         }
         if(tween.prevNode != null)
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
         var max:Float = Math.NaN;
         var end:Float = Math.NaN;
         var tween:TweenCore = null;
         var prevStart:Float = Math.NaN;
         var next:TweenCore = null;
         if(this.cacheIsDirty)
         {
            max = 0;
            tween = !!this.gc?_endCaps[0]:_firstChild;
            prevStart = Math.NEGATIVE_INFINITY;
            while(tween != null)
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

      public  function set_currentProgress(n:Float) :Float
      {
         setTotalTime(this.duration * n,false);
         return n;
      }

      public function clear(tweens:Array<TweenCore> = null) : Void
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
         var n:Float = Reflect.field(_labels, label);
         _labels.remove(label);
         return n;
      }

      private function parseTimeOrLabel(timeOrLabel:Dynamic) : Float
      {
         if( Type.getClassName( Type.getClass(timeOrLabel) ) == "String")
         {
            if(!_labels.hasField(timeOrLabel))
            {
               throw new openfl.errors.Error("TimelineLite error: the " + timeOrLabel + " label was not found.");
            }
            return getLabelTime(timeOrLabel);
         }
         return timeOrLabel;
      }

      public function addLabel(label:String, time:Float) : Void
      {
         Reflect.setField(_labels, label, time);
      }

      public function hasPausedChild() : Bool
      {
         var tween:TweenCore = this.gc?_endCaps[0]:_firstChild;
         while(tween != null)
         {
            if(tween.cachedPaused || Std.is(tween, TimelineLite) && cast(tween, TimelineLite).hasPausedChild())
            {
               return true;
            }
            tween = tween.nextNode;
         }
         return false;
      }

      public function getTweensOf(target:Dynamic, nested:Bool = true) : Array<TweenLite>
      {
         var i:Int = 0;
         var tweens:Array<TweenCore> = getChildren(nested,true,false);
         var a:Array<TweenLite> = [];
         var l:Int = tweens.length;
         var cnt:Int = 0;
         for( i in (0)...(l) )
         {
            if(cast(tweens[i], TweenLite).target == target)
            {
               a[cnt++] = cast(tweens[i], TweenLite);
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
         var d:Float = Math.NaN;
         if(this.cacheIsDirty)
         {
            d = this.totalDuration;
         }
         return this.cachedDuration;
      }

      public  function get_useFrames()
      {
         var tl:SimpleTimeline = this.timeline;
         while(tl.timeline != null)
         {
            tl = tl.timeline;
         }
         return tl == TweenLite.rootFramesTimeline;
      }

      public function shiftChildren(amount:Float, adjustLabels:Bool = false, ignoreBeforeTime:Float = 0) : Void
      {
         var p:Dynamic = null;
         var tween:TweenCore = !!this.gc?_endCaps[0]:_firstChild;
         while(tween != null)
         {
            if(tween.cachedStartTime >= ignoreBeforeTime)
            {
               tween.cachedStartTime = tween.cachedStartTime + amount;
            }
            tween = tween.nextNode;
         }
         if(adjustLabels)
         {
            for(p in Reflect.fields(_labels))
            {
                var value = Reflect.field(_labels, p);
               if( value >= ignoreBeforeTime)
               {
                  Reflect.setField(_labels, p, value + amount);
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
         var tweens:Array<TweenLite> = getTweensOf(target,nested);
         var i:Int = tweens.length;
         while(--i > -1)
         {
            tween = tweens[i];
            if(vars != null)
            {
               tween.killVars(vars);
            }
            if(vars == null || tween.cachedPT1 == null && tween.initted)
            {
               tween.setEnabled(false,false);
            }
         }
         return tweens.length > 0;
      }

      override public function set_duration(n:Float):Float
      {
         if(this.duration != 0 && n != 0)
         {
            this.timeScale = this.duration / n;
         }

         return n;
      }

      public function insertMultiple(tweens:Array<Int>, timeOrLabel:Dynamic = 0, align:String = "normal", stagger:Float = 0) : Array<Int>
      {
         var i:Int = 0;
         var tween:TweenCore = null;
         var curTime:Float = Std.parseFloat(timeOrLabel);
         if( Math.isNaN( curTime )) curTime = 0;
         var l:Int = tweens.length;
         if( Type.getClassName( Type.getClass( timeOrLabel ) ) == "String")
         {
            if(!Reflect.hasField(_labels, timeOrLabel))
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
         return Reflect.hasField(_labels, label)? Reflect.field(_labels,label):-1;
      }

      override public  function get_rawTime()
      {
         if(this.cachedPaused || this.cachedTotalTime != 0 && this.cachedTotalTime != this.cachedTotalDuration)
         {
            return this.cachedTotalTime;
         }
         return (this.timeline.rawTime - this.cachedStartTime) * this.cachedTimeScale;
      }

      override public  function set_totalDuration(n:Float):Float
      {
         if(this.totalDuration != 0 && n != 0)
         {
            this.timeScale = this.totalDuration / n;
         }

         return n;
      }

      public function getChildren(nested:Bool = true, tweens:Bool = true, timelines:Bool = true, ignoreBeforeTime:Float = -9.999999999E9) : Array<TweenCore>
      {
         var a:Array<TweenCore> = [];
         var cnt:Int = 0;
         var tween:TweenCore = this.gc?_endCaps[0]:_firstChild;
         while(tween != null)
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
         var dur:Float = Math.NaN;
         var tween:TweenCore = _firstChild;
         var prevPaused:Bool = this.cachedPaused;
         while(tween != null)
         {
            next = tween.nextNode;
            if(this.cachedPaused && !prevPaused)
            {
               break;
            }
            if(tween.active || !tween.cachedPaused && !tween.gc && (tween.cachedTotalTime != tween.cachedTotalDuration || tween.cachedDuration == 0))
            {
               if(time == this.cachedDuration && (tween.cachedDuration != 0 || tween.cachedStartTime == this.cachedDuration))
               {
                  tween.renderTime(!!tween.cachedReversed?0.0:tween.cachedTotalDuration,suppressEvents,false);
               }
               else if(!tween.cachedReversed)
               {
                  tween.renderTime((time - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
               }
               else
               {
                  dur = !!tween.cacheIsDirty?tween.totalDuration:tween.cachedTotalDuration;
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
         var dur:Float = Math.NaN;
         var tween:TweenCore = _lastChild;
         var prevPaused:Bool = this.cachedPaused;
         while(tween != null)
         {
            next = tween.prevNode;
            if(this.cachedPaused && !prevPaused)
            {
               break;
            }
            if(tween.active || !tween.cachedPaused && !tween.gc && (tween.cachedTotalTime != 0 || tween.cachedDuration == 0))
            {
               if(time == 0 && (tween.cachedDuration != 0 || tween.cachedStartTime == 0))
               {
                  tween.renderTime(!!tween.cachedReversed?tween.cachedTotalDuration:0.0,suppressEvents,false);
               }
               else if(!tween.cachedReversed)
               {
                  tween.renderTime((time - tween.cachedStartTime) * tween.cachedTimeScale,suppressEvents,false);
               }
               else
               {
                  dur = !!tween.cacheIsDirty?tween.totalDuration:tween.cachedTotalDuration;
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
         var st:Float = Math.NaN;
         var tl:SimpleTimeline = null;
         if(Type.getClassName( Type.getClass( timeOrLabel ) )  == "String")
         {
            if(!Reflect.hasField(timeOrLabel, _labels))
            {
               addLabel(timeOrLabel,this.duration);
            }
            timeOrLabel = cast(_labels[timeOrLabel], Float);
         }
         var prevTimeline:SimpleTimeline = tween.timeline;
         if(!tween.cachedOrphan && prevTimeline!=null)
         {
            prevTimeline.remove(tween,true);
         }
         tween.timeline = this;
         tween.cachedStartTime = timeOrLabel + tween.delay;
         if(tween.cachedPaused && prevTimeline != this)
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
            while(curTween != null && st < curTween.cachedStartTime)
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
               if(curTween.nextNode != null)
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
         if(this.gc && !this.cachedPaused && this.cachedStartTime + (tween.cachedStartTime + tween.cachedTotalDuration / tween.cachedTimeScale) / this.cachedTimeScale > this.timeline.cachedTime)
         {
            if(this.timeline == TweenLite.rootTimeline || this.timeline == TweenLite.rootFramesTimeline)
            {
               this.setTotalTime(this.cachedTotalTime,true);
            }
            this.setEnabled(true,false);
            tl = this.timeline;
            while(tl.gc && tl.timeline!=null)
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
         var tween:TweenCore = this.gc?_endCaps[0]:_firstChild;
         while(tween != null)
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
            while(tween != null)
            {
               tween.setEnabled(enabled,true);
               tween = tween.nextNode;
            }
         }
         return super.setEnabled(enabled,ignoreTimeline);
      }
   }
