package com.greensock;
   import flash.events.IEventDispatcher;
   import com.greensock.core.SimpleTimeline;
   import flash.display.DisplayObjectContainer;
   import flash.display.DisplayObject;
   import com.greensock.core.TweenCore;
   import flash.utils.Dictionary;
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
   import flash.events.Event;
   import com.greensock.events.TweenEvent;
   import com.greensock.core.PropTween;
   import flash.events.EventDispatcher;
   
   import haxe.Constraints.IMap;

   class TweenMax extends TweenLite implements IEventDispatcher
   {

		public static var globalTimeScale(get, set):Float;
		public var totalProgress(get, set):Float;
		public var currentProgress(get, set):Float;
		public var repeat(get, set):Int;
		public var repeatDelay(get, set):Float;
		public var timeScale(get, set):Float;

      
      private static var _overwriteMode:Int = !!OverwriteManager.enabled?cast(OverwriteManager.mode, Int):cast(OverwriteManager.init(2), Int);
      
      public static inline var version:Float = 11.697;
      
      public static var killTweensOf:Dynamic = TweenLite.killTweensOf;
      
      public static var killDelayedCallsTo:Dynamic = TweenLite.killTweensOf;
      
      public static function __init__ () {
         TweenPlugin.activate([AutoAlphaPlugin,EndArrayPlugin,FramePlugin,RemoveTintPlugin,TintPlugin,VisiblePlugin,VolumePlugin,BevelFilterPlugin,BezierPlugin,BezierThroughPlugin,BlurFilterPlugin,ColorMatrixFilterPlugin,ColorTransformPlugin,DropShadowFilterPlugin,FrameLabelPlugin,GlowFilterPlugin,HexColorsPlugin,RoundPropsPlugin,ShortRotationPlugin/*,{}*/]);
      }
      
      private var _cyclesComplete:Int = 0;
      
      private var _dispatcher:EventDispatcher;
      
      private var _hasUpdateListener:Bool;
      
      private var _easeType:Int;
      
      private var _repeatDelay:Float = 0;
      
      public var yoyo:Bool;
      
      private var _easePower:Int;
      
      private var _repeat:Int = 0;
      
      public function new(target:Dynamic, duration:Float, vars:Dynamic)
      {
         super(target,duration,vars);
         if(TweenLite.version < 11.2)
         {
            throw new openfl.errors.Error("TweenMax error! Please update your TweenLite class or try deleting your ASO files. TweenMax requires a more recent version. Download updates at http://www.TweenMax.com.");
         }
         this.yoyo = cast(this.vars.yoyo, Bool);
         _repeat = cast(this.vars.repeat, UInt);
         _repeatDelay = this.vars.repeatDelay != 0?cast(this.vars.repeatDelay, Float):0;
         this.cacheIsDirty = true;
         if(cast(this.vars.onCompleteListener, Bool) || cast(this.vars.onInitListener, Bool) || cast(this.vars.onUpdateListener, Bool) || cast(this.vars.onStartListener, Bool) || cast(this.vars.onRepeatListener, Bool) || cast(this.vars.onReverseCompleteListener, Bool))
         {
            initDispatcher();
            if(cast(duration == 0, Bool) && cast(_delay == 0, Bool))
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
            }
         }
         if(cast(this.vars.timeScale, Bool) && cast(!(Std.is(this.target, TweenCore)), Bool))
         {
            this.cachedTimeScale = this.vars.timeScale;
         }
      }
      
      public  static function set_globalTimeScale(n:Float)
      {
         if(n == 0)
         {
            n = 0.0001;
         }
         if(TweenLite.rootTimeline == null)
         {
            TweenLite.to({},0,{});
         }
         var tl:SimpleTimeline = TweenLite.rootTimeline;
         var curTime:Float = flash.Lib.getTimer() * 0.001;
         tl.cachedStartTime = curTime - (curTime - tl.cachedStartTime) * tl.cachedTimeScale / n;
         tl = TweenLite.rootFramesTimeline;
         curTime = TweenLite.rootFrame;
         tl.cachedStartTime = curTime - (curTime - tl.cachedStartTime) * tl.cachedTimeScale / n;
         TweenLite.rootFramesTimeline.cachedTimeScale = TweenLite.rootTimeline.cachedTimeScale = n;
         return n;
      }
      
      public static function fromTo(target:Dynamic, duration:Float, fromVars:Dynamic, toVars:Dynamic) : TweenMax
      {
         if(toVars.isGSVars)
         {
            toVars = toVars.vars;
         }
         if(fromVars.isGSVars)
         {
            fromVars = fromVars.vars;
         }
         toVars.startAt = fromVars;
         if(fromVars.immediateRender)
         {
            toVars.immediateRender = true;
         }
         return new TweenMax(target,duration,toVars);
      }
      
      public static function allFromTo(targets:Array<Int>, duration:Float, fromVars:Dynamic, toVars:Dynamic, stagger:Float = 0, onCompleteAll:Dynamic = null, onCompleteAllParams:Array<Int> = null) : Array<TweenLite>
      {
         if(toVars.isGSVars)
         {
            toVars = toVars.vars;
         }
         if(fromVars.isGSVars)
         {
            fromVars = fromVars.vars;
         }
         toVars.startAt = fromVars;
         if(fromVars.immediateRender)
         {
            toVars.immediateRender = true;
         }
         return allTo(targets,duration,toVars,stagger,onCompleteAll,onCompleteAllParams);
      }
      
      public static function pauseAll(tweens:Bool = true, delayedCalls:Bool = true) : Void
      {
         changePause(true,tweens,delayedCalls);
      }
      
      public static function getTweensOf(target:Dynamic) : Array<TweenLite>
      {
         var i:Int = 0;
         var cnt:Int = 0;
         var a:Array<TweenLite> = TweenLite.masterList.get(target);
         var toReturn:Array<TweenLite> = [];
         if(a!=null)
         {
            i = a.length;
            cnt = 0;
            while(--i > -1)
            {
               if(!cast(a[i], TweenLite).gc)
               {
                  toReturn[cnt++] = a[i];
               }
            }
         }
         return toReturn;
      }
      
      public  static function get_globalTimeScale()
      {
         return TweenLite.rootTimeline == null?cast(1, Float):cast(TweenLite.rootTimeline.cachedTimeScale, Float);
      }
      
      public static function killChildTweensOf(parent:DisplayObjectContainer, complete:Bool = false) : Void
      {
         var curTarget:Dynamic = null;
         var curParent:DisplayObjectContainer = null;
         var a:Array<TweenLite> = getAllTweens();
         var i:Int = a.length;
         while(--i > -1)
         {
            curTarget = a[i].target;
            if(Std.is(curTarget, DisplayObject))
            {
               curParent = curTarget.parent;
               while(curParent!=null)
               {
                  if(curParent == parent)
                  {
                     if(complete)
                     {
                        a[i].complete(false);
                     }
                     else
                     {
                        a[i].setEnabled(false,false);
                     }
                  }
                  curParent = curParent.parent;
               }
               continue;
            }
         }
      }
      
      public static function delayedCall(delay:Float, onComplete:Dynamic, onCompleteParams:Array<Dynamic> = null, useFrames:Bool = false) : TweenMax
      {
         return new TweenMax(onComplete,0,{
            "delay":delay,
            "onComplete":onComplete,
            "onCompleteParams":onCompleteParams,
            "immediateRender":false,
            "useFrames":useFrames,
            "overwrite":0
         });
      }
      
      public static function isTweening(target:Dynamic) : Bool
      {
         var tween:TweenLite = null;
         var a:Array<TweenLite> = getTweensOf(target);
         var i:Int = a.length;
         while(--i > -1)
         {
            tween = a[i];
            if(cast(tween.active, Bool) || cast(tween.cachedStartTime == tween.timeline.cachedTime, Bool) && cast(tween.timeline.active, Bool))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function killAll(complete:Bool = false, tweens:Bool = true, delayedCalls:Bool = true) : Void
      {
         var isDC:Bool = false;
         var a:Array<TweenLite> = getAllTweens();
         var i:Int = a.length;
         while(--i > -1)
         {
            isDC = a[i].target == a[i].vars.onComplete;
            if(cast(isDC == delayedCalls, Bool) || cast(isDC != tweens, Bool))
            {
               if(complete)
               {
                  a[i].complete(false);
               }
               else
               {
                  a[i].setEnabled(false,false);
               }
            }
         }
      }
      
      private static function changePause(pause:Bool, tweens:Bool = true, delayedCalls:Bool = false) : Void
      {
         var isDC:Bool = false;
         var a:Array<TweenLite> = getAllTweens();
         var i:Int = a.length;
         while(--i > -1)
         {
            isDC = cast(a[i], TweenLite).target == cast(a[i], TweenLite).vars.onComplete;
            if(cast(isDC == delayedCalls, Bool) || cast(isDC != tweens, Bool))
            {
               cast(a[i], TweenCore).paused = pause;
            }
         }
      }
      
      public static function from(target:Dynamic, duration:Float, vars:Dynamic) : TweenMax
      {
         if(vars.isGSVars)
         {
            vars = vars.vars;
         }
         vars.runBackwards = true;
         if(!Reflect.hasField(vars, "immediateRender"))
         {
            vars.immediateRender = true;
         }
         return new TweenMax(target,duration,vars);
      }
      
      public static function allFrom(targets:Array<Int>, duration:Float, vars:Dynamic, stagger:Float = 0, onCompleteAll:Dynamic = null, onCompleteAllParams:Array<Int> = null) : Array<TweenLite>
      {
         if(vars.isGSVars)
         {
            vars = vars.vars;
         }
         vars.runBackwards = true;
         if(!Reflect.hasField(vars, "immediateRender"))
         {
            vars.immediateRender = true;
         }
         return allTo(targets,duration,vars,stagger,onCompleteAll,onCompleteAllParams);
      }
      
      public static function getAllTweens() : Array<TweenLite>
      {
         var a:Array<TweenLite> = null;
         var i:Int = 0;
         var ml = TweenLite.masterList;
         var cnt:Int = 0;
         var toReturn:Array<TweenLite> = [];
         for( a in ml )
         {
            i = a.length;
            while(--i > -1)
            {
               if(!a[i].gc)
               {
                  toReturn[cnt++] = a[i];
               }
            }
         }
         return toReturn;
      }
      
      public static function resumeAll(tweens:Bool = true, delayedCalls:Bool = true) : Void
      {
         changePause(false,tweens,delayedCalls);
      }
      
      public static function to(target:Dynamic, duration:Float, vars:Dynamic) : TweenMax
      {
         return new TweenMax(target,duration,vars);
      }
      
      public static function allTo(targets:Array<Int>, duration:Float, vars:Dynamic, stagger:Float = 0, onCompleteAll:Dynamic = null, onCompleteAllParams:Array<Int> = null) : Array<TweenLite>
      {
         var i:Int = 0;
         var varsDup:Dynamic = null;
         var p:String = null;
         var onCompleteProxy:Dynamic = null;
         var onCompleteParamsProxy:Array<Int> = null;
         var l:Int = targets.length;
         var a:Array<TweenLite> = [];
         if(vars.isGSVars)
         {
            var vars:Dynamic = vars.vars;
         }
         var curDelay:Float = Reflect.hasField(vars,"delay")?cast(vars.delay, Float):0;
         onCompleteProxy = vars.onComplete;
         onCompleteParamsProxy = vars.onCompleteParams;
         var lastIndex:Int = l - 1;
         for( i in (0)...(l) )
         {
            varsDup = {};
            for(p in Reflect.fields(vars))
            {
               Reflect.setField(varsDup, p, Reflect.field(vars, p));
            }
            varsDup.delay = curDelay;
            if(cast(i == lastIndex, Bool) && cast(onCompleteAll != null, Bool))
            {
               varsDup.onComplete = function():Void
               {
                  if(onCompleteProxy != null)
                  {
                     onCompleteProxy.apply(null,onCompleteParamsProxy);
                  }
                  onCompleteAll.apply(null,onCompleteAllParams);
               };
            }
            a[i] = new TweenMax(targets[i],duration,varsDup);
            curDelay = curDelay + stagger;
         }
         return a;
      }
      
      public function dispatchEvent(e:Event) : Bool
      {
         return _dispatcher == null?cast(false, Bool):cast(_dispatcher.dispatchEvent(e), Bool);
      }
      
      public  function set_timeScale(n:Float)
      {
         if(n == 0)
         {
            n = 0.0001;
         }
         var tlTime:Float = cast(this.cachedPauseTime, Bool) || cast(this.cachedPauseTime == 0, Bool)?cast(this.cachedPauseTime, Float):cast(this.timeline.cachedTotalTime, Float);
         this.cachedStartTime = tlTime - (tlTime - this.cachedStartTime) * this.cachedTimeScale / n;
         this.cachedTimeScale = n;
         setDirtyCache(false);
         return n;
      }
      
      override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) : Void
      {
         var isComplete:Bool = false;
         var repeated:Bool = false;
         var setRatio:Bool = false;
         var cycleDuration:Float = Math.NaN;
         var prevCycles:Int = 0;
         var power:Int = 0;
         var val:Float = Math.NaN;
         var totalDur:Float = !!this.cacheIsDirty?cast(this.totalDuration, Float):cast(this.cachedTotalDuration, Float);
         var prevTime:Float = this.cachedTime;
         var prevTotalTime:Float = this.cachedTotalTime;
         if(time >= totalDur)
         {
            this.cachedTotalTime = totalDur;
            this.cachedTime = this.cachedDuration;
            this.ratio = 1;
            isComplete = !this.cachedReversed;
            if(this.cachedDuration == 0)
            {
               if((cast(time == 0, Bool) || cast(_rawPrevTime < 0, Bool)) && cast(_rawPrevTime != time, Bool))
               {
                  force = true;
               }
               _rawPrevTime = time;
            }
         }
         else if(time <= 0)
         {
            if(time < 0)
            {
               this.active = false;
               if(this.cachedDuration == 0)
               {
                  if(_rawPrevTime > 0)
                  {
                     force = true;
                     isComplete = true;
                  }
                  _rawPrevTime = time;
               }
            }
            else if(cast(time == 0, Bool) && cast(!this.initted, Bool))
            {
               force = true;
            }
            this.cachedTotalTime = this.cachedTime = this.ratio = 0;
            if(cast(this.cachedReversed, Bool) && cast(prevTotalTime != 0, Bool))
            {
               isComplete = true;
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = time;
            setRatio = true;
         }
         if(_repeat != 0)
         {
            cycleDuration = this.cachedDuration + _repeatDelay;
            prevCycles = _cyclesComplete;
            if((_cyclesComplete = Math.floor(this.cachedTotalTime / cycleDuration)) == ( this.cachedTotalTime / cycleDuration ) && _cyclesComplete != 0)
            {
               _cyclesComplete--;
            }
            repeated = prevCycles != _cyclesComplete;
            if(isComplete)
            {
               if(cast(this.yoyo, Bool) && cast(_repeat % 2, Bool))
               {
                  this.cachedTime = this.ratio = 0;
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
                  this.ratio = 1;
                  setRatio = false;
               }
               if(this.cachedTime <= 0)
               {
                  this.cachedTime = this.ratio = 0;
                  setRatio = false;
               }
            }
            else
            {
               _cyclesComplete = 0;
            }
         }
         if(cast(prevTime == this.cachedTime, Bool) && cast(!force, Bool))
         {
            return;
         }
         if(!this.initted)
         {
            init();
         }
         if(cast(!this.active, Bool) && cast(!this.cachedPaused, Bool))
         {
            this.active = true;
         }
         if(setRatio)
         {
            if(_easeType!=null)
            {
               power = _easePower;
               val = this.cachedTime / this.cachedDuration;
               if(_easeType == 2)
               {
                  this.ratio = val = 1 - val;
                  while(--power > -1)
                  {
                     this.ratio = val * this.ratio;
                  }
                  this.ratio = 1 - this.ratio;
               }
               else if(_easeType == 1)
               {
                  this.ratio = val;
                  while(--power > -1)
                  {
                     this.ratio = val * this.ratio;
                  }
               }
               else if(val < 0.5)
               {
                  this.ratio = val = val * 2;
                  while(--power > -1)
                  {
                     this.ratio = val * this.ratio;
                  }
                  this.ratio = this.ratio * 0.5;
               }
               else
               {
                  this.ratio = val = (1 - val) * 2;
                  while(--power > -1)
                  {
                     this.ratio = val * this.ratio;
                  }
                  this.ratio = 1 - 0.5 * this.ratio;
               }
            }
            else
            {
               this.ratio = _ease(this.cachedTime,0,1,this.cachedDuration);
            }
         }
         if(cast(prevTotalTime == 0, Bool) && (cast(this.cachedTotalTime != 0, Bool) || cast(this.cachedDuration == 0, Bool)) && cast(!suppressEvents, Bool))
         {
            if(this.vars.onStart)
            {
               this.vars.onStart.apply(null,this.vars.onStartParams);
            }
            if(_dispatcher!=null)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
            }
         }
         var pt:PropTween = this.cachedPT1;
         while(pt!=null)
         {
            Reflect.setField(pt.target, pt.property, pt.start + this.ratio * pt.change);
            pt = pt.nextNode;
         }
         if(cast(_hasUpdate, Bool) && cast(!suppressEvents, Bool))
         {
            this.vars.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         if(cast(_hasUpdateListener, Bool) && cast(!suppressEvents, Bool))
         {
            _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
         }
         if(cast(repeated, Bool) && cast(!suppressEvents, Bool) && cast(!this.gc, Bool))
         {
            if(this.vars.onRepeat)
            {
               this.vars.onRepeat.apply(null,this.vars.onRepeatParams);
            }
            if(_dispatcher!=null)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
            }
         }
         if(cast(isComplete, Bool) && cast(!this.gc, Bool))
         {
            if(cast(_hasPlugins, Bool) && cast(this.cachedPT1, Bool))
            {
               TweenLite.onPluginEvent("onComplete",this);
            }
            complete(true,suppressEvents);
         }
      }
      
      override public  function set_totalDuration(n:Float)
      {
         if(_repeat == -1)
         {
            return 0.0;
         }
         this.duration = (n - _repeat * _repeatDelay) / (_repeat + 1);
         return n;
      }
      
      public function addEventListener(type:String, listener:Dynamic, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void
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
      
      override private function init() : Void
      {
         var startTween:TweenMax = null;
         if(this.vars.startAt)
         {
            this.vars.startAt.overwrite = 0;
            this.vars.startAt.immediateRender = true;
            startTween = new TweenMax(this.target,0,this.vars.startAt);
         }
         if(_dispatcher!=null)
         {
            _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.INIT));
         }
         super.init();
         if(TweenLite.fastEaseLookup.exists(_ease))
         {
            _easeType = TweenLite.fastEaseLookup.get(_ease)[0];
            _easePower = TweenLite.fastEaseLookup.get(_ease)[1];
         }
      }
      
      public function removeEventListener(type:String, listener:Dynamic, useCapture:Bool = false) : Void
      {
         if(_dispatcher!=null)
         {
            _dispatcher.removeEventListener(type,listener,useCapture);
         }
      }
      
      public function setDestination(property:String, value:Dynamic, adjustStartValues:Bool = true) : Void
      {
         var vars:Dynamic = {};
         Reflect.setField(vars, property, value);
         updateTo(vars,!adjustStartValues);
      }
      
      public function willTrigger(type:String) : Bool
      {
         return _dispatcher == null?cast(false, Bool):cast(_dispatcher.willTrigger(type), Bool);
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
         if(Reflect.isFunction(this.vars.onInitListener))
         {
            _dispatcher.addEventListener(TweenEvent.INIT,this.vars.onInitListener,false,0,true);
         }
         if(Reflect.isFunction(this.vars.onStartListener))
         {
            _dispatcher.addEventListener(TweenEvent.START,this.vars.onStartListener,false,0,true);
         }
         if(Reflect.isFunction(this.vars.onUpdateListener))
         {
            _dispatcher.addEventListener(TweenEvent.UPDATE,this.vars.onUpdateListener,false,0,true);
            _hasUpdateListener = true;
         }
         if(Reflect.isFunction(this.vars.onCompleteListener))
         {
            _dispatcher.addEventListener(TweenEvent.COMPLETE,this.vars.onCompleteListener,false,0,true);
         }
         if(Reflect.isFunction(this.vars.onRepeatListener))
         {
            _dispatcher.addEventListener(TweenEvent.REPEAT,this.vars.onRepeatListener,false,0,true);
         }
         if(Reflect.isFunction(this.vars.onReverseCompleteListener))
         {
            _dispatcher.addEventListener(TweenEvent.REVERSE_COMPLETE,this.vars.onReverseCompleteListener,false,0,true);
         }
      }
      
      public  function set_currentProgress(n:Float)
      {
         if(_cyclesComplete == 0)
         {
            setTotalTime(this.duration * n,false);
         }
         else
         {
            setTotalTime(this.duration * n + _cyclesComplete * this.cachedDuration,false);
         }
         return n;
      }
      
      public  function get_totalProgress()
      {
         return this.cachedTotalTime / this.totalDuration;
      }
      
      public  function set_totalProgress(n:Float)
      {
         setTotalTime(this.totalDuration * n,false);
         return n;
      }
      
      public function updateTo(vars:Dynamic, resetDuration:Bool = false) : Void
      {
         var p:Dynamic = null;
         var prevTime:Float = Math.NaN;
         var inv:Float = Math.NaN;
         var pt:PropTween = null;
         var endValue:Float = Math.NaN;
         var curRatio:Float = this.ratio;
         if(cast(resetDuration, Bool) && cast(this.timeline != null, Bool) && cast(this.cachedStartTime < this.timeline.cachedTime, Bool))
         {
            this.cachedStartTime = this.timeline.cachedTime;
            this.setDirtyCache(false);
            if(this.gc)
            {
               this.setEnabled(true,false);
            }
            else
            {
               this.timeline.insert(this,this.cachedStartTime - _delay);
            }
         }
         for(p in Reflect.fields(vars))
         {
            Reflect.setField(this.vars, p, Reflect.field(vars, p));
         }
         if(this.initted)
         {
            if(resetDuration)
            {
               this.initted = false;
            }
            else
            {
               if(cast(_notifyPluginsOfEnabled, Bool) && cast(this.cachedPT1, Bool))
               {
                  TweenLite.onPluginEvent("onDisable",this);
               }
               if(this.cachedTime / this.cachedDuration > 0.998)
               {
                  prevTime = this.cachedTime;
                  this.renderTime(0,true,false);
                  this.initted = false;
                  this.renderTime(prevTime,true,false);
               }
               else if(this.cachedTime > 0)
               {
                  this.initted = false;
                  init();
                  inv = 1 / (1 - curRatio);
                  pt = this.cachedPT1;
                  while(pt!=null)
                  {
                     endValue = pt.start + pt.change;
                     pt.change = pt.change * inv;
                     pt.start = endValue - pt.change;
                     pt = pt.nextNode;
                  }
               }
            }
         }
      }
      
      public  function get_currentProgress()
      {
         return this.cachedTime / this.duration;
      }
      
      public  function get_repeat()
      {
         return _repeat;
      }
      
      override public  function set_currentTime(n:Float)
      {
         if(_cyclesComplete != 0)
         {
            if(this.yoyo && _cyclesComplete % 2 == 1)
            {
               n = this.duration - n + _cyclesComplete * (this.cachedDuration + _repeatDelay);
            }
            else
            {
               n = n + _cyclesComplete * (this.duration + _repeatDelay);
            }
         }
         setTotalTime(n,false);
         return n;
      }
      
      public  function get_repeatDelay()
      {
         return _repeatDelay;
      }
      
      public function killProperties(names:Array<Int>) : Void
      {
         var v:Dynamic = {};
         var i:Int = names.length;
         while(--i > -1)
         {
            v[names[i]] = true;
         }
         killVars(v);
      }
      
      public  function set_repeatDelay(n)
      {
         _repeatDelay = n;
         setDirtyCache(true);
         return n;
      }
      
      public  function set_repeat(n)
      {
         _repeat = n;
         setDirtyCache(true);
         return n;
      }
      
      override public function complete(skipRender:Bool = false, suppressEvents:Bool = false) : Void
      {
         super.complete(skipRender,suppressEvents);
         if(cast(!suppressEvents, Bool) && cast(_dispatcher, Bool))
         {
            if(cast(this.cachedTotalTime == this.cachedTotalDuration, Bool) && cast(!this.cachedReversed, Bool))
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
            }
            else if(cast(this.cachedReversed, Bool) && cast(this.cachedTotalTime == 0, Bool))
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REVERSE_COMPLETE));
            }
         }
      }
      
      override public function invalidate() : Void
      {
         this.yoyo = this.vars.yoyo == true;
         _repeat = this.vars.repeat?cast(this.vars.repeat, Int):0;
         _repeatDelay = this.vars.repeatDelay?cast(this.vars.repeatDelay, Float):0;
         _hasUpdateListener = false;
         if(this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null)
         {
            initDispatcher();
         }
         setDirtyCache(true);
         super.invalidate();
      }
      
      public  function get_timeScale()
      {
         return this.cachedTimeScale;
      }
      
      override public  function get_totalDuration()
      {
         if(this.cacheIsDirty)
         {
            this.cachedTotalDuration = _repeat == -1?999999999999.0:cast(this.cachedDuration * (_repeat + 1) + _repeatDelay * _repeat, Float);
            this.cacheIsDirty = false;
         }
         return this.cachedTotalDuration;
      }
   }