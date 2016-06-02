package com.greensock;
   import flash.events.IEventDispatcher;
   import flash.events.Event;
   import com.greensock.core.TweenCore;
   import com.greensock.events.TweenEvent;
   import flash.events.EventDispatcher;
   
   class TimelineMax extends TimelineLite implements IEventDispatcher
   {

		public var currentLabel(get, null):String;
		public var totalProgress(get, set):Float;
		public var repeat(get, set):Int;
		public var repeatDelay(get, set):Float;
		public var totalDuration(get, null):Float;
		public var currentProgress(null, set):Float;
		public var currentTime(null, set):Float;

      
      public static inline var version:Float = 1.697;
       
      private var _cyclesComplete:Int;
      
      private var _dispatcher:EventDispatcher;
      
      private var _hasUpdateListener:Bool;
      
      public var yoyo:Bool;
      
      private var _repeatDelay:Float;
      
      private var _repeat:Int;
      
      public function new(vars:Object = null)
      {
         super(vars);
         _repeat = cast(this.vars.repeat, Bool)?cast(Float(this.vars.repeat), Int):cast(0, Int);
         _repeatDelay = cast(this.vars.repeatDelay, Bool)?cast(Float(this.vars.repeatDelay), Float):cast(0, Float);
         _cyclesComplete = 0;
         this.yoyo = cast(this.vars.yoyo == true, Bool);
         this.cacheIsDirty = true;
         if(cast(this.vars.onCompleteListener != null, Bool) || cast(this.vars.onUpdateListener != null, Bool) || cast(this.vars.onStartListener != null, Bool) || cast(this.vars.onRepeatListener != null, Bool) || cast(this.vars.onReverseCompleteListener != null, Bool))
         {
            initDispatcher();
         }
      }
      
      private static function easeNone(t:Float, b:Float, c:Float, d:Float) : Float
      {
         return t / d;
      }
      
      private static function onInitTweenTo(tween:TweenLite, timeline:TimelineMax, fromTime:Float) : Void
      {
         timeline.paused = true;
         if(!isNaN(fromTime))
         {
            timeline.currentTime = fromTime;
         }
         if(tween.vars.currentTime != timeline.currentTime)
         {
            tween.duration = Math.abs(cast(tween.vars.currentTime, Float) - timeline.currentTime) / timeline.cachedTimeScale;
         }
      }
      
      public function dispatchEvent(e:Event) : Bool
      {
         return _dispatcher == null?cast(false, Bool):cast(_dispatcher.dispatchEvent(e), Bool);
      }
      
      public  function get_currentLabel()
      {
         return getLabelBefore(this.cachedTime + 1.0e-8);
      }
      
      override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) : Void
      {
         var tween:TweenCore = null;
         var isComplete:Bool = false;
         var rendered:Bool = false;
         var repeated:Bool = false;
         var next:TweenCore = null;
         var dur:Float = NaN;
         var cycleDuration:Float = NaN;
         var prevCycles:Int = 0;
         var forward:Bool = false;
         var prevForward:Bool = false;
         var wrap:Bool = false;
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
         var prevTotalTime:Float = this.cachedTotalTime;
         var prevStart:Float = this.cachedStartTime;
         var prevTimeScale:Float = this.cachedTimeScale;
         var prevPaused:Bool = this.cachedPaused;
         if(time >= totalDur)
         {
            if(cast(prevTotalTime != totalDur, Bool) && cast(_rawPrevTime != time, Bool))
            {
               this.cachedTotalTime = totalDur;
               if(cast(!this.cachedReversed, Bool) && cast(this.yoyo, Bool) && cast(_repeat % 2 != 0, Bool))
               {
                  this.cachedTime = 0;
                  forceChildrenToBeginning(0,suppressEvents);
               }
               else
               {
                  this.cachedTime = this.cachedDuration;
                  forceChildrenToEnd(this.cachedDuration,suppressEvents);
               }
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
            if(cast(prevTotalTime != 0, Bool) && cast(_rawPrevTime != time, Bool))
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
         if(_repeat != 0)
         {
            cycleDuration = this.cachedDuration + _repeatDelay;
            prevCycles = _cyclesComplete;
            if(cast((_cyclesComplete = this.cachedTotalTime / cycleDuration >> 0) == this.cachedTotalTime / cycleDuration, Bool) && cast(_cyclesComplete != 0, Bool))
            {
               _cyclesComplete--;
            }
            repeated = cast(prevCycles != _cyclesComplete, Bool);
            if(isComplete)
            {
               if(cast(this.yoyo, Bool) && cast(_repeat % 2, Bool))
               {
                  this.cachedTime = 0;
               }
            }
            else if(time > 0)
            {
               this.cachedTime = this.cachedTotalTime - _cyclesComplete * cycleDuration;
               if(cast(this.yoyo, Bool) && cast(_cyclesComplete % 2, Bool))
               {
                  this.cachedTime = this.cachedDuration - this.cachedTime;
               }
               else if(this.cachedTime >= this.cachedDuration)
               {
                  this.cachedTime = this.cachedDuration;
               }
               if(this.cachedTime < 0)
               {
                  this.cachedTime = 0;
               }
            }
            else
            {
               _cyclesComplete = 0;
            }
            if(cast(repeated, Bool) && cast(!isComplete, Bool) && (cast(this.cachedTotalTime != prevTotalTime, Bool) || cast(force, Bool)))
            {
               forward = cast(!this.yoyo || _cyclesComplete % 2 == 0, Bool);
               prevForward = cast(!this.yoyo || prevCycles % 2 == 0, Bool);
               wrap = cast(forward == prevForward, Bool);
               if(prevCycles > _cyclesComplete)
               {
                  prevForward = !prevForward;
               }
               if(prevForward)
               {
                  prevTime = forceChildrenToEnd(this.cachedDuration,suppressEvents);
                  if(wrap)
                  {
                     prevTime = forceChildrenToBeginning(0,true);
                  }
               }
               else
               {
                  prevTime = forceChildrenToBeginning(0,suppressEvents);
                  if(wrap)
                  {
                     prevTime = forceChildrenToEnd(this.cachedDuration,true);
                  }
               }
               rendered = false;
            }
         }
         if(cast(this.cachedTime == prevTime, Bool) && cast(!force, Bool))
         {
            return;
         }
         if(!this.initted)
         {
            this.initted = true;
         }
         if(cast(prevTotalTime == 0, Bool) && cast(this.cachedTotalTime != 0, Bool) && cast(!suppressEvents, Bool))
         {
            if(this.vars.onStart)
            {
               this.vars.onStart.apply(null,this.vars.onStartParams);
            }
            if(_dispatcher)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
            }
         }
         if(!rendered)
         {
            if(this.cachedTime > prevTime)
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
         if(cast(_hasUpdateListener, Bool) && cast(!suppressEvents, Bool))
         {
            _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
         }
         if(cast(repeated, Bool) && cast(!suppressEvents, Bool))
         {
            if(this.vars.onRepeat)
            {
               this.vars.onRepeat.apply(null,this.vars.onRepeatParams);
            }
            if(_dispatcher)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
            }
         }
         if(cast(isComplete, Bool) && (cast(prevStart == this.cachedStartTime, Bool) || cast(prevTimeScale != this.cachedTimeScale, Bool)) && (cast(totalDur >= this.totalDuration, Bool) || cast(this.cachedTime == 0, Bool)))
         {
            complete(true,suppressEvents);
         }
      }
      
      public function addCallback(callback:Function, timeOrLabel:Dynamic, params:Array<Int> = null) : TweenLite
      {
         var cb:TweenLite = new TweenLite(callback,0,{
            "onComplete":callback,
            "onCompleteParams":params,
            "overwrite":0,
            "immediateRender":false
         });
         insert(cb,timeOrLabel);
         return cb;
      }
      
      public function tweenFromTo(fromTimeOrLabel:Dynamic, toTimeOrLabel:Dynamic, vars:Object = null) : TweenLite
      {
         var tl:TweenLite = tweenTo(toTimeOrLabel,vars);
         tl.vars.onInitParams[2] = parseTimeOrLabel(fromTimeOrLabel);
         tl.duration = Math.abs(cast(tl.vars.currentTime, Float) - tl.vars.onInitParams[2]) / this.cachedTimeScale;
         return tl;
      }
      
      public function removeEventListener(type:String, listener:Function, useCapture:Bool = false) : Void
      {
         if(_dispatcher != null)
         {
            _dispatcher.removeEventListener(type,listener,useCapture);
         }
      }
      
      override public  function set_currentProgress(n)
      {
         this.currentTime = this.duration * n;
      }
      
      public function addEventListener(type:String, listener:Function, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void
      {
         if(_dispatcher == null)
         {
            initDispatcher();
         }
         if(type == TweenEvent.UPDATE)
         {
            _hasUpdateListener = true;
         }
         _dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public function tweenTo(timeOrLabel:Dynamic, vars:Object = null) : TweenLite
      {
         var p:Dynamic = null;
         var tl:TweenLite = null;
         var varsCopy:Object = {
            "ease":easeNone,
            "overwrite":2,
            "useFrames":this.useFrames,
            "immediateRender":false
         };
         for(p in vars)
         {
            varsCopy[p] = vars[p];
         }
         varsCopy.onInit = onInitTweenTo;
         varsCopy.onInitParams = [null,this,NaN];
         varsCopy.currentTime = parseTimeOrLabel(timeOrLabel);
         tl = new TweenLite(this,cast(Math.abs(Float(varsCopy.currentTime) - this.cachedTime) / this.cachedTimeScale, Float) || cast(0.001, Float),varsCopy);
         tl.vars.onInitParams[0] = tl;
         return tl;
      }
      
      public function hasEventListener(type:String) : Bool
      {
         return _dispatcher == null?cast(false, Bool):cast(_dispatcher.hasEventListener(type), Bool);
      }
      
      private function initDispatcher() : Void
      {
         if(_dispatcher == null)
         {
            _dispatcher = new EventDispatcher(this);
         }
         if(Std.is(this.vars.onStartListener, Function))
         {
            _dispatcher.addEventListener(TweenEvent.START,this.vars.onStartListener,false,0,true);
         }
         if(Std.is(this.vars.onUpdateListener, Function))
         {
            _dispatcher.addEventListener(TweenEvent.UPDATE,this.vars.onUpdateListener,false,0,true);
            _hasUpdateListener = true;
         }
         if(Std.is(this.vars.onCompleteListener, Function))
         {
            _dispatcher.addEventListener(TweenEvent.COMPLETE,this.vars.onCompleteListener,false,0,true);
         }
         if(Std.is(this.vars.onRepeatListener, Function))
         {
            _dispatcher.addEventListener(TweenEvent.REPEAT,this.vars.onRepeatListener,false,0,true);
         }
         if(Std.is(this.vars.onReverseCompleteListener, Function))
         {
            _dispatcher.addEventListener(TweenEvent.REVERSE_COMPLETE,this.vars.onReverseCompleteListener,false,0,true);
         }
      }
      
      override public  function set_currentTime(n)
      {
         if(_cyclesComplete == 0)
         {
            setTotalTime(n,false);
         }
         else if(cast(this.yoyo, Bool) && cast(_cyclesComplete % 2 == 1, Bool))
         {
            setTotalTime(this.duration - n + _cyclesComplete * (this.cachedDuration + _repeatDelay),false);
         }
         else
         {
            setTotalTime(n + _cyclesComplete * (this.duration + _repeatDelay),false);
         }
      }
      
      public function getLabelBefore(time:Float = NaN) : String
      {
         if(cast(!time, Bool) && cast(time != 0, Bool))
         {
            time = this.cachedTime;
         }
         var labels:Array<Int> = getLabelsArray();
         var i:Int = labels.length;
         while(--i > -1)
         {
            if(labels[i].time < time)
            {
               return labels[i].name;
            }
         }
         return null;
      }
      
      public function willTrigger(type:String) : Bool
      {
         return _dispatcher == null?cast(false, Bool):cast(_dispatcher.willTrigger(type), Bool);
      }
      
      public  function get_totalProgress()
      {
         return this.cachedTotalTime / this.totalDuration;
      }
      
      public  function set_totalProgress(n)
      {
         setTotalTime(this.totalDuration * n,false);
      }
      
      private function getLabelsArray() : Array<Int>
      {
         var p:Dynamic = null;
         var a:Array<Int> = [];
         for(p in _labels)
         {
            a[a.length] = {
               "time":_labels[p],
               "name":p
            };
         }
         a.sortOn("time",Array<Int>.NUMERIC);
         return a;
      }
      
      public function removeCallback(callback:Function, timeOrLabel:Dynamic = null) : Bool
      {
         var a:Array<Int> = null;
         var success:Bool = false;
         var i:Int = 0;
         if(timeOrLabel == null)
         {
            return killTweensOf(callback,false);
         }
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               return false;
            }
            timeOrLabel = _labels[timeOrLabel];
         }
         a = getTweensOf(callback,false);
         i = a.length;
         while(--i > -1)
         {
            if(a[i].cachedStartTime == timeOrLabel)
            {
               remove(cast(a[i], TweenCore));
               success = true;
            }
         }
         return success;
      }
      
      public  function get_repeat()
      {
         return _repeat;
      }
      
      public  function get_repeatDelay()
      {
         return _repeatDelay;
      }
      
      public  function set_repeatDelay(n)
      {
         _repeatDelay = n;
         setDirtyCache(true);
      }
      
      public  function set_repeat(n)
      {
         _repeat = n;
         setDirtyCache(true);
      }
      
      override public  function get_totalDuration()
      {
         var temp:Float = NaN;
         if(this.cacheIsDirty)
         {
            temp = super.totalDuration;
            this.cachedTotalDuration = _repeat == -1?cast(999999999999, Float):cast(this.cachedDuration * (_repeat + 1) + _repeatDelay * _repeat, Float);
         }
         return this.cachedTotalDuration;
      }
      
      override public function complete(skipRender:Bool = false, suppressEvents:Bool = false) : Void
      {
         super.complete(skipRender,suppressEvents);
         if(cast(_dispatcher, Bool) && cast(!suppressEvents, Bool))
         {
            if(cast(this.cachedReversed, Bool) && cast(this.cachedTotalTime == 0, Bool) && cast(this.cachedDuration != 0, Bool))
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REVERSE_COMPLETE));
            }
            else
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
            }
         }
      }
      
      override public function invalidate() : Void
      {
         _repeat = cast(this.vars.repeat, Bool)?cast(Float(this.vars.repeat), Int):cast(0, Int);
         _repeatDelay = cast(this.vars.repeatDelay, Bool)?cast(Float(this.vars.repeatDelay), Float):cast(0, Float);
         this.yoyo = cast(this.vars.yoyo == true, Bool);
         if(cast(this.vars.onCompleteListener != null, Bool) || cast(this.vars.onUpdateListener != null, Bool) || cast(this.vars.onStartListener != null, Bool) || cast(this.vars.onRepeatListener != null, Bool) || cast(this.vars.onReverseCompleteListener != null, Bool))
         {
            initDispatcher();
         }
         setDirtyCache(true);
         super.invalidate();
      }
      
      public function getActive(nested:Bool = true, tweens:Bool = true, timelines:Bool = false) : Array<Int>
      {
         var i:Int = 0;
         var tween:TweenCore = null;
         var a:Array<Int> = [];
         var all:Array<Int> = getChildren(nested,tweens,timelines);
         var l:Int = all.length;
         var cnt:Int = 0;
         for( i in (0)...(l) )
         {
            tween = all[i];
            if(cast(!tween.cachedPaused, Bool) && cast(tween.timeline.cachedTotalTime >= tween.cachedStartTime, Bool) && cast(tween.timeline.cachedTotalTime < tween.cachedStartTime + tween.cachedTotalDuration / tween.cachedTimeScale, Bool) && cast(!OverwriteManager.getGlobalPaused(tween.timeline), Bool))
            {
               a[cnt++] = all[i];
            }
         }
         return a;
      }
      
      public function getLabelAfter(time:Float = NaN) : String
      {
         if(cast(!time, Bool) && cast(time != 0, Bool))
         {
            time = this.cachedTime;
         }
         var labels:Array<Int> = getLabelsArray();
         var l:Int = labels.length;
         for( i in (0)...(l) )
         {
            if(labels[i].time > time)
            {
               return labels[i].name;
            }
         }
         return null;
      }
   }
