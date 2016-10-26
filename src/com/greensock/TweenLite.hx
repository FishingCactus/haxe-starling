package com.greensock;
   import com.greensock.core.TweenCore;
   import com.greensock.core.SimpleTimeline;
   import com.greensock.core.FunctionMap;
   import flash.utils.Dictionary;
   import flash.events.Event;
   import flash.display.Stage;
   import com.greensock.core.PropTween;
   import lime.app.Application;

   class TweenLite extends TweenCore
   {

       private static function easeOut(t:Float, b:Float, c:Float, d:Float) : Float
       {
          return 1 - (t = 1 - t / d) * t;
       }

      public static var rootTimeline:SimpleTimeline;

      public static var fastEaseLookup:FunctionMap<TweenFunction,Array<Int>> = new FunctionMap();

      public static var onPluginEvent:String->TweenLite->Bool;

      public static var rootFramesTimeline:SimpleTimeline;

      public static var defaultEase:TweenFunction = TweenLite.easeOut;

      public static inline var version:Float = 11.696;

      public static var plugins:Map<String,Class<Dynamic>> = new Map();

      public static var masterList: haxe.ds.ObjectMap<Dynamic,Array<TweenLite>> = new haxe.ds.ObjectMap();

      public static var overwriteManager:Dynamic;

      public static var rootFrame:Float = Math.NaN;

      public static var killDelayedCallsTo: Dynamic -> ?Bool -> ?Dynamic -> Void  = TweenLite.killTweensOf;

      private static var _reservedProps:Array<String> = [
         "ease",
         "delay",
         "overwrite",
         "onComplete",
         "onCompleteParams",
         "useFrames",
         "runBackwards",
         "startAt",
         "onUpdate",
         "onUpdateParams",
         "onStart",
         "onStartParams",
         "onInit",
         "onInitParams",
         "onReverseComplete",
         "onReverseCompleteParams",
         "onRepeat",
         "onRepeatParams",
         "proxiedEase",
         "easeParams",
         "yoyo",
         "onCompleteListener",
         "onUpdateListener",
         "onStartListener",
         "onReverseCompleteListener",
         "onRepeatListener",
         "orientToBezier",
         "timeScale",
         "immediateRender",
         "repeat",
         "repeatDelay",
         "timeline",
         "data",
         "paused",
         "reversed"
      ];

      private var _hasPlugins:Bool;

      public var propTweenLookup:Map<String,PropTween>;

      public var cachedPT1:PropTween;

      private var _overwrite:Int;

      private var _ease:TweenFunction;

      public var target:Dynamic;

      public var ratio:Float = 0;

      private var _overwrittenProps:Dynamic;

      private var _notifyPluginsOfEnabled:Bool;

      public function new(target:Dynamic, duration:Float, vars:Dynamic)
      {
         var sibling:TweenLite = null;

         super(duration,vars);
         if(target == null)
         {
            throw new openfl.errors.Error("Cannot tween a null object.");
         }
         this.target = target;
         if( Std.is(this.target, TweenCore) && this.vars.timeScale)
         {
            this.cachedTimeScale = 1;
         }
         propTweenLookup = new Map();
         _ease = defaultEase;
         _overwrite = (vars.overwrite <= -1) || !overwriteManager.enabled && (vars.overwrite > 1)
            ? Std.int(overwriteManager.mode)
            :  Std.int(vars.overwrite);
         var a:Array<TweenLite> = masterList.get(target);
         if(a == null)
         {
            masterList.set(target, [this]);
         }
         else if(_overwrite == 1)
         {
             throw ":TODO:";
             /*
            for( sibling in a )
            {
               if(!sibling.gc)
               {
                  sibling.setEnabled(false,false);
               }
            }
            masterList[target] = [this];
            */
         }
         else
         {
            a[a.length] = this;
         }
         if(this.active || this.vars.immediateRender)
         {
            renderTime(0,false,true);
         }
      }

      public static function initClass() : Void
      {
         rootFrame = 0;
         rootTimeline = new SimpleTimeline(null);
         rootFramesTimeline = new SimpleTimeline(null);
         rootTimeline.cachedStartTime = haxe.Timer.stamp();
         rootFramesTimeline.cachedStartTime = rootFrame;
         rootTimeline.autoRemoveChildren = true;
         rootFramesTimeline.autoRemoveChildren = true;
         Application.current.window.stage.addEventListener(Event.ENTER_FRAME,updateAll);
         if(overwriteManager == null)
         {
            overwriteManager = {
               "mode":1,
               "enabled":false
            };
         }
      }

      public static function killTweensOf(target:Dynamic, complete:Bool = false, vars:Dynamic = null) : Void
      {
         var a:Array<TweenLite> = null;
         var i:Int = 0;
         var tween:TweenLite = null;

         if(masterList.exists(target))
         {
            a = masterList.get(target);
            i = a.length;
            while(--i > -1)
            {
               tween = a[i];
               if(!tween.gc)
               {
                  if(complete)
                  {
                     tween.complete(false,false);
                  }
                  if(vars != null)
                  {
                     tween.killVars(vars);
                  }
                  if((vars == null) || (tween.cachedPT1 == null) && (tween.initted))
                  {
                     tween.setEnabled(false,false);
                  }
               }
            }
            if(vars == null)
            {
               masterList.remove(target);
           }
       }
      }

      public static function from(target:Dynamic, duration:Float, vars:Dynamic) : TweenLite
      {
         if(vars.isGSVars)
         {
            vars = vars.vars;
         }
         vars.runBackwards = true;

throw ":TODO:";
         /*if(!("immediateRender" in vars))
         {
            vars.immediateRender = true;
        }*/
         return new TweenLite(target,duration,vars);
      }

      public static function delayedCall(delay:Float, onComplete:Array<Dynamic>->Void, onCompleteParams:Array<Dynamic> = null, useFrames:Bool = false) : TweenLite
      {
         return new TweenLite(onComplete,0,{
            "delay":delay,
            "onComplete":onComplete,
            "onCompleteParams":onCompleteParams,
            "immediateRender":false,
            "useFrames":useFrames,
            "overwrite":0
         });
      }

      private static function updateAll(e:Event = null) : Void
      {
         var ml:haxe.ds.ObjectMap<Dynamic, Array<com.greensock.TweenLite>> = null;
         var tgt:Dynamic = null;
         var a:Array<TweenLite> = null;
         var i:Int = 0;
         rootTimeline.renderTime((haxe.Timer.stamp() - rootTimeline.cachedStartTime) * rootTimeline.cachedTimeScale,false,false);
         rootFrame = rootFrame + 1;
         rootFramesTimeline.renderTime((rootFrame - rootFramesTimeline.cachedStartTime) * rootFramesTimeline.cachedTimeScale,false,false);
         if((rootFrame % 60) == 0)
         {
            ml = masterList;

            for(tgt in ml.keys())
            {
               a = ml.get(tgt);

               i = a.length;

               while(--i > -1)
               {
                  if(a[i].gc)
                  {
                     a.splice(i,1);
                  }
               }
               if(a.length == 0)
               {
                  ml.remove(tgt);
               }
            }
         }
      }

      public static function to(target:Dynamic, duration:Float, vars:Dynamic) : TweenLite
      {
         return new TweenLite(target,duration,vars);
      }

      private function easeProxy(t:Float, b:Float, c:Float, d:Float) : Float
      {
        return this.vars.proxiedEase.apply(null,this.vars.easeParams);
      }

      override public function renderTime(time:Float, suppressEvents:Bool = false, force:Bool = false) : Void
      {
         var isComplete:Bool = false;
         var prevTime:Float = this.cachedTime;
         if(time >= this.cachedDuration)
         {
            this.cachedTotalTime = this.cachedTime = this.cachedDuration;
            this.ratio = 1;
            isComplete = !this.cachedReversed;
            if(this.cachedDuration == 0)
            {
               if(((time == 0) || (_rawPrevTime < 0)) && (_rawPrevTime != time))
               {
                  force = true;
               }
               _rawPrevTime = time;
            }
         }
         else if(time <= 0)
         {
            this.cachedTotalTime = this.cachedTime = this.ratio = 0;
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
            if((this.cachedReversed) && (prevTime != 0))
            {
               isComplete = true;
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = time;
            this.ratio = _ease(time,0,1,this.cachedDuration);
         }
         if((this.cachedTime == prevTime) && (!force))
         {
            return;
         }
         if(!this.initted)
         {
            init();
            if((!isComplete) && (this.cachedTime != 0))
            {
               this.ratio = _ease(this.cachedTime,0,1,this.cachedDuration);
            }
         }
         if((!this.active) && (!this.cachedPaused))
         {
            this.active = true;
         }
         if((prevTime == 0 && this.vars.onStart) && ((this.cachedTime != 0 || this.cachedDuration == 0)) && (!suppressEvents))
         {
            this.vars.onStart.apply(null,this.vars.onStartParams);
         }
         var pt:PropTween = this.cachedPT1;
         while(pt != null)
         {
            Reflect.setProperty(pt.target, pt.property, pt.start + this.ratio * pt.change);
            pt = pt.nextNode;
         }
         if((_hasUpdate) && (!suppressEvents))
         {
            this.vars.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         if((isComplete) && (!this.gc))
         {
            if((_hasPlugins) && (this.cachedPT1 != null ))
            {
               onPluginEvent("onComplete",this);
            }
            complete(true,suppressEvents);
         }
      }

      override public function setEnabled(enabled:Bool, ignoreTimeline:Bool = false)
      {
         var a:Array<TweenLite> = null;
         if(enabled)
         {
            a = TweenLite.masterList.get(this.target);
            if(a == null)
            {
               TweenLite.masterList.set(this.target, [this]);
            }
            else if(a.indexOf(this) == -1)
            {
               a[a.length] = this;
            }
         }
         super.setEnabled(enabled,ignoreTimeline);
         if((_notifyPluginsOfEnabled) && (this.cachedPT1 != null))
         {
            return onPluginEvent(!!enabled?"onEnable":"onDisable",this);
         }
         return false;
      }

      private function init() : Void
      {
         var p:Dynamic = null;
         var i:Int = 0;
         var plugin:Dynamic = null;
         var prioritize:Bool = false;
         var siblings:Array<TweenLite> = null;
         var pt:PropTween = null;
         if(this.vars.onInit)
         {
            this.vars.onInit.apply(null,this.vars.onInitParams);
         }
         if(this.vars.ease != null)
         {
            _ease = this.vars.ease;
         }
         if(this.vars.easeParams != null)
         {
            this.vars.proxiedEase = _ease;
            _ease = easeProxy;
         }
         this.cachedPT1 = null;
         this.propTweenLookup = new Map();

         for(p in Reflect.fields(this.vars))
         {
            if(
                !(_reservedProps.indexOf(p) != -1)
                && !( p == "timeScale" && Std.is(this.target, TweenCore) )
                )
            {
               if( plugins.exists(p)
                    && ( (plugin = Type.createInstance(plugins.get(p), new Array<Dynamic>())).onInitTween(this.target, Reflect.field(this.vars,p),this))
                    )
               {
                  this.cachedPT1 = new PropTween(plugin,"changeFactor",0,1,plugin.overwriteProps.length == 1?plugin.overwriteProps[0]:"_MULTIPLE_",true,this.cachedPT1);
                  if(this.cachedPT1.name == "_MULTIPLE_")
                  {
                     i = plugin.overwriteProps.length;
                     while(--i > -1)
                     {
                        this.propTweenLookup[plugin.overwriteProps[i]] = this.cachedPT1;
                     }
                  }
                  else
                  {
                     this.propTweenLookup[this.cachedPT1.name] = this.cachedPT1;
                  }
                  if(plugin.priority)
                  {
                     this.cachedPT1.priority = plugin.priority;
                     prioritize = true;
                  }
                  if((plugin.onDisable) || (plugin.onEnable))
                  {
                     _notifyPluginsOfEnabled = true;
                  }
                  _hasPlugins = true;
               }
               else
               {
                    var value = Reflect.getProperty(this.target, p);
                    this.cachedPT1 =
                        new PropTween(
                            this.target,
                            p,
                            value,
                            Std.is(value, Float)? Reflect.field(this.vars,p) - value: Reflect.field(this.vars,p ),
                            p,
                            false,
                            this.cachedPT1
                        );

                  this.propTweenLookup[p] = this.cachedPT1;
               }
            }
        }
         if(prioritize)
         {
            onPluginEvent("onInitAllProps",this);
         }
         if(this.vars.runBackwards)
         {
            pt = this.cachedPT1;
            while(pt!=null)
            {
               pt.start = pt.start + pt.change;
               pt.change = -pt.change;
               pt = pt.nextNode;
            }
         }
         _hasUpdate = (this.vars.onUpdate != null);
         if(_overwrittenProps)
         {
            killVars(_overwrittenProps);
            if(this.cachedPT1 == null)
            {
               this.setEnabled(false,false);
            }
         }
         if((_overwrite > 1 && this.cachedPT1 != null) && (siblings = masterList.get(this.target))!= null && (siblings.length > 1))
         {
            if(overwriteManager.manageOverwrites(this,this.propTweenLookup,siblings,_overwrite))
            {
               init();
            }
         }
         this.initted = true;
      }

      public function killVars(vars:Dynamic, permanent:Bool = true)
      {
         var p:Dynamic = null;
         var pt:PropTween = null;
         var changed:Bool = false;
         if(_overwrittenProps == null)
         {
            _overwrittenProps = {};
         }
         throw ":TODO:";
         /*
         for(p in vars)
         {
            if(p in propTweenLookup)
            {
               pt = propTweenLookup[p];
               if((pt.isPlugin) && (pt.name == "_MULTIPLE_"))
               {
                  pt.target.killProps(vars);
                  if(pt.target.overwriteProps.length == 0)
                  {
                     pt.name = "";
                  }
                  if((p != pt.target.propName) || (pt.name == ""))
                  {
                     propTweenLookup.remove(p);
                  }
               }
               if(pt.name != "_MULTIPLE_")
               {
                  if(pt.nextNode)
                  {
                     pt.nextNode.prevNode = pt.prevNode;
                  }
                  if(pt.prevNode)
                  {
                     pt.prevNode.nextNode = pt.nextNode;
                  }
                  else if(this.cachedPT1 == pt)
                  {
                     this.cachedPT1 = pt.nextNode;
                  }
                  if((pt.isPlugin) && (pt.target.onDisable))
                  {
                     pt.target.onDisable();
                     if(pt.target.activeDisable)
                     {
                        changed = true;
                     }
                  }
                  propTweenLookup.remove(p);
               }
            }
            if((permanent) && (vars != _overwrittenProps))
            {
               _overwrittenProps[p] = 1;
            }
        }*/
         return changed;
      }

      override public function invalidate() : Void
      {
         if( _notifyPluginsOfEnabled &&  this.cachedPT1 != null )
         {
            onPluginEvent("onDisable",this);
         }
         this.cachedPT1 = null;
         _overwrittenProps = null;
         _hasUpdate = this.initted = this.active = _notifyPluginsOfEnabled = false;
         this.propTweenLookup = new Map();
      }
   }
