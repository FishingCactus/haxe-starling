package com.greensock.loading.core;
   import flash.events.EventDispatcher;
   import com.greensock.loading.LoaderMax;
   import flash.utils.Dictionary;
   import flash.events.Event;
   import com.greensock.events.LoaderEvent;
   import com.greensock.loading.LoaderStatus;
   import flash.utils.getTimer;
   import flash.events.ProgressEvent;
   import flash.system.Capabilities;
   import flash.net.LocalConnection;
   import flash.display.DisplayObject;
   
   [cast(name="unload",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="error",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="fail",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="cancel",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="complete",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="progress",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="open",type="com.greensock.events.LoaderEvent", Event)]
   class LoaderCore extends EventDispatcher
   {

		public var rootLoader(get, null):LoaderMax;
		public var bytesTotal(get, null):UInt;
		public var paused(get, set):Bool;
		public var progress(get, null):Float;
		public var bytesLoaded(get, null):UInt;
		public var loadTime(get, null):Float;
		public var auditedSize(get, null):Bool;
		public var status(get, null):Int;

      
      private static var _types:Object = {};
      
      private static var _listenerTypes:Object = {
         "onOpen":"open",
         "onInit":"init",
         "onComplete":"complete",
         "onProgress":"progress",
         "onCancel":"cancel",
         "onFail":"fail",
         "onError":"error",
         "onSecurityError":"securityError",
         "onHTTPStatus":"httpStatus",
         "onIOError":"ioError",
         "onScriptAccessDenied":"scriptAccessDenied",
         "onChildOpen":"childOpen",
         "onChildCancel":"childCancel",
         "onChildComplete":"childComplete",
         "onChildProgress":"childProgress",
         "onChildFail":"childFail",
         "onRawLoad":"rawLoad",
         "onUncaughtError":"uncaughtError"
      };
      
      private static var _isLocal:Bool;
      
      private static var _extensions:Object = {};
      
      private static var _globalRootLoader:LoaderMax;
      
      public static inline var version:Float = 1.87;
      
      private static var _rootLookup:Dictionary = new Dictionary(false);
      
      private static var _loaderCount:UInt = 0;
       
      private var _prePauseStatus:Int;
      
      public var name:String;
      
      private var _dispatchChildProgress:Bool;
      
      private var _status:Int;
      
      private var _type:String;
      
      private var _auditedSize:Bool;
      
      private var _dispatchProgress:Bool;
      
      public var vars:Object;
      
      private var _cachedBytesTotal:UInt;
      
      private var _time:UInt;
      
      private var _content;
      
      private var _rootLoader:LoaderMax;
      
      private var _cacheIsDirty:Bool;
      
      private var _cachedBytesLoaded:UInt;
      
      public var autoDispose:Bool;
      
      public function new(vars:Object = null)
      {
         var p:Dynamic = null;
         super();
         this.vars = vars != null?vars:{};
         if(this.vars.isGSVars)
         {
            this.vars = this.vars.vars;
         }
         this.name = cast(this.vars.name != undefined, Bool) && cast(String(this.vars.name) != "", Bool)?this.vars.name:"loader" + _loaderCount++;
         _cachedBytesLoaded = 0;
         _cachedBytesTotal = cast(this.vars.estimatedBytes, UInt) != 0?cast(UInt(this.vars.estimatedBytes), UInt):cast(LoaderMax.defaultEstimatedBytes, UInt);
         this.autoDispose = cast(this.vars.autoDispose == true, Bool);
         _status = this.vars.paused == true?cast(LoaderStatus.PAUSED, Int):cast(LoaderStatus.READY, Int);
         _auditedSize = cast(UInt(this.vars.estimatedBytes) != 0 && this.vars.auditSize != true, Bool);
         if(_globalRootLoader == null)
         {
            if(this.vars.__isRoot == true)
            {
               return;
            }
            _globalRootLoader = new LoaderMax({
               "name":"root",
               "__isRoot":true
            });
            _isLocal = cast(Capabilities.playerType == "Desktop" || new LocalConnection().domain == "localhost", Bool);
         }
         _rootLoader =Std.is( this.vars.requireWithRoot, DisplayObject?_rootLookup[this.vars.requireWithRoot]:_globalRootLoader);
         if(_rootLoader == null)
         {
            _rootLookup[this.vars.requireWithRoot] = _rootLoader = new LoaderMax();
            _rootLoader.name = "subloaded_swf_" + (this.vars.requireWithRoot.loaderInfo != null?this.vars.requireWithRoot.loaderInfo.url:cast(_loaderCount, String));
            _rootLoader.skipFailed = false;
         }
         for(p in _listenerTypes)
         {
            if(cast(p in this.vars, Bool) && cast(Std.is(this.vars[p], Function), Bool))
            {
               this.addEventListener(_listenerTypes[p],this.vars[p],false,0,true);
            }
         }
         _rootLoader.append(this);
      }
      
      private static function _activateClass(type:String, loaderClass:Class, extensions:String) : Bool
      {
         if(type != "")
         {
            _types[type.toLowerCase()] = loaderClass;
         }
         var a:Array<Int> = extensions.split(",");
         var i:Int = a.length;
         while(--i > -1)
         {
            _extensions[a[i]] = loaderClass;
         }
         return true;
      }
      
      private function _errorHandler(event:Event) : Void
      {
         var target:Object = event.target;
         target = cast(Std.is(event, LoaderEvent), Bool) && cast(this.hasOwnProperty("getChildren"), Bool)?event.target:this;
         var text:String = "";
         if(cast(event.hasOwnProperty("error"), Bool) && cast(Std.is(Object(event).error, Error), Bool))
         {
            text = cast(event, Object).error.message;
         }
         else if(event.hasOwnProperty("text"))
         {
            text = cast(event, Object).text;
         }
         if(cast(event.type != LoaderEvent.ERROR, Bool) && cast(event.type != LoaderEvent.FAIL, Bool) && cast(this.hasEventListener(event.type), Bool))
         {
            dispatchEvent(new LoaderEvent(event.type,target,text,event));
         }
         if(event.type != "uncaughtError")
         {
            trace("----\nError on " + this.toString() + ": " + text + "\n----");
            if(this.hasEventListener(LoaderEvent.ERROR))
            {
               dispatchEvent(new LoaderEvent(LoaderEvent.ERROR,target,this.toString() + " > " + text,event));
            }
         }
      }
      
      private function _failHandler(event:Event, dispatchError:Bool = true) : Void
      {
         var target:Object = null;
         _dump(0,LoaderStatus.FAILED);
         if(dispatchError)
         {
            _errorHandler(event);
         }
         else
         {
            target = event.target;
         }
         dispatchEvent(new LoaderEvent(LoaderEvent.FAIL,cast(Std.is(event, LoaderEvent), Bool) && cast(this.hasOwnProperty("getChildren"), Bool)?event.target:this,this.toString() + " > " + (cast(event, Object)).text,event));
      }
      
      private function _completeHandler(event:Event = null) : Void
      {
         _cachedBytesLoaded = _cachedBytesTotal;
         if(_status != LoaderStatus.COMPLETED)
         {
            dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
            _status = LoaderStatus.COMPLETED;
            _time = getTimer() - _time;
         }
         dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE,this));
         if(this.autoDispose)
         {
            dispose();
         }
      }
      
      public  function get_rootLoader()
      {
         return _rootLoader;
      }
      
      private function _progressHandler(event:Event) : Void
      {
         if(Std.is(event, ProgressEvent))
         {
            _cachedBytesLoaded = (cast(event, ProgressEvent)).bytesLoaded;
            _cachedBytesTotal = (cast(event, ProgressEvent)).bytesTotal;
            if(!_auditedSize)
            {
               _auditedSize = true;
               dispatchEvent(new Event("auditedSize"));
            }
         }
         if(cast(_dispatchProgress, Bool) && cast(_status == LoaderStatus.LOADING, Bool) && cast(_cachedBytesLoaded != _cachedBytesTotal, Bool))
         {
            dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
         }
      }
      
      public function dispose(flushContent:Bool = false) : Void
      {
         _dump(!!flushContent?cast(3, Int):cast(2, Int),LoaderStatus.DISPOSED);
      }
      
      public  function get_bytesTotal()
      {
         if(_cacheIsDirty)
         {
            _calculateProgress();
         }
         return _cachedBytesTotal;
      }
      
      public function resume() : Void
      {
         this.paused = false;
         load(false);
      }
      
      public  function get_paused()
      {
         return cast(_status == LoaderStatus.PAUSED, Bool);
      }
      
      private function _calculateProgress() : Void
      {
      }
      
      public  function get_progress()
      {
         return this.bytesTotal != 0?cast(_cachedBytesLoaded / _cachedBytesTotal, Float):_status == LoaderStatus.COMPLETED?cast(1, Float):cast(0, Float);
      }
      
      public function prioritize(loadNow:Bool = true) : Void
      {
         dispatchEvent(new Event("prioritize"));
         if(cast(loadNow, Bool) && cast(_status != LoaderStatus.COMPLETED, Bool) && cast(_status != LoaderStatus.LOADING, Bool))
         {
            load(false);
         }
      }
      
      override public function addEventListener(type:String, listener:Function, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void
      {
         if(type == LoaderEvent.PROGRESS)
         {
            _dispatchProgress = true;
         }
         else if(cast(type == LoaderEvent.CHILD_PROGRESS, Bool) && cast(Std.is(this, LoaderMax), Bool))
         {
            _dispatchChildProgress = true;
         }
         super.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public  function get_bytesLoaded()
      {
         if(_cacheIsDirty)
         {
            _calculateProgress();
         }
         return _cachedBytesLoaded;
      }
      
      private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         var p:Dynamic = null;
         _content = null;
         var isLoading:Bool = cast(_status == LoaderStatus.LOADING, Bool);
         if(cast(_status == LoaderStatus.PAUSED, Bool) && cast(newStatus != LoaderStatus.PAUSED, Bool) && cast(newStatus != LoaderStatus.FAILED, Bool))
         {
            _prePauseStatus = newStatus;
         }
         else if(_status != LoaderStatus.DISPOSED)
         {
            _status = newStatus;
         }
         if(isLoading)
         {
            _time = getTimer() - _time;
         }
         _cachedBytesLoaded = 0;
         if(_status < LoaderStatus.FAILED)
         {
            if(Std.is(this, LoaderMax))
            {
               _calculateProgress();
            }
            if(cast(_dispatchProgress, Bool) && cast(!suppressEvents, Bool))
            {
               dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
            }
         }
         if(!suppressEvents)
         {
            if(isLoading)
            {
               dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL,this));
            }
            if(scrubLevel != 2)
            {
               dispatchEvent(new LoaderEvent(LoaderEvent.UNLOAD,this));
            }
         }
         if(newStatus == LoaderStatus.DISPOSED)
         {
            if(!suppressEvents)
            {
               dispatchEvent(new Event("dispose"));
            }
            for(p in _listenerTypes)
            {
               if(cast(p in this.vars, Bool) && cast(Std.is(this.vars[p], Function), Bool))
               {
                  this.removeEventListener(_listenerTypes[p],this.vars[p]);
               }
            }
         }
      }
      
      private function _load() : Void
      {
      }
      
      public  function get_loadTime()
      {
         if(_status == LoaderStatus.READY)
         {
            return 0;
         }
         if(_status == LoaderStatus.LOADING)
         {
            return (getTimer() - _time) / 1000;
         }
         return _time / 1000;
      }
      
      public  function get_auditedSize()
      {
         return _auditedSize;
      }
      
      public  function set_paused(value)
      {
         if(cast(value, Bool) && cast(_status != LoaderStatus.PAUSED, Bool))
         {
            _prePauseStatus = _status;
            if(_status == LoaderStatus.LOADING)
            {
               _dump(0,LoaderStatus.PAUSED);
            }
            _status = LoaderStatus.PAUSED;
         }
         else if(cast(!value, Bool) && cast(_status == LoaderStatus.PAUSED, Bool))
         {
            if(_prePauseStatus == LoaderStatus.LOADING)
            {
               load(false);
            }
            else
            {
               _status = cast(_prePauseStatus, Int) || cast(LoaderStatus.READY, Int);
            }
         }
      }
      
      private function _passThroughEvent(event:Event) : Void
      {
         var type:String = event.type;
         var target:Object = this;
         if(this.hasOwnProperty("getChildren"))
         {
            if(Std.is(event, LoaderEvent))
            {
               target = event.target;
            }
            if(type == "complete")
            {
               type = "childComplete";
            }
            else if(type == "open")
            {
               type = "childOpen";
            }
            else if(type == "cancel")
            {
               type = "childCancel";
            }
            else if(type == "fail")
            {
               type = "childFail";
            }
         }
         if(this.hasEventListener(type))
         {
            dispatchEvent(new LoaderEvent(type,target,!!event.hasOwnProperty("text")?cast(event, Object).text:"",cast(Std.is(event, LoaderEvent), Bool) && cast(LoaderEvent(event).data != null, Bool)?cast(event, LoaderEvent).data:event));
         }
      }
      
      public function load(flushContent:Bool = false) : Void
      {
         var time:UInt = getTimer();
         if(this.status == LoaderStatus.PAUSED)
         {
            _status = _prePauseStatus <= LoaderStatus.LOADING?cast(LoaderStatus.READY, Int):cast(_prePauseStatus, Int);
            if(cast(_status == LoaderStatus.READY, Bool) && cast(Std.is(this, LoaderMax), Bool))
            {
               time = time - _time;
            }
         }
         if(cast(flushContent, Bool) || cast(_status == LoaderStatus.FAILED, Bool))
         {
            _dump(1,LoaderStatus.READY);
         }
         if(_status == LoaderStatus.READY)
         {
            _status = LoaderStatus.LOADING;
            _time = time;
            _load();
            if(this.progress < 1)
            {
               dispatchEvent(new LoaderEvent(LoaderEvent.OPEN,this));
            }
         }
         else if(_status == LoaderStatus.COMPLETED)
         {
            _completeHandler(null);
         }
      }
      
      override public function toString() : String
      {
         return _type + " \'" + this.name + "\'" + (Std.is(this, LoaderItem?" (" + (cast(this, LoaderItem)).url + ")":""));
      }
      
      public  function get_status()
      {
         return _status;
      }
      
      public function pause() : Void
      {
         this.paused = true;
      }
      
      public function get content() : *
      {
         return _content;
      }
      
      public function cancel() : Void
      {
         if(_status == LoaderStatus.LOADING)
         {
            _dump(0,LoaderStatus.READY);
         }
      }
      
      public function auditSize() : Void
      {
      }
      
      public function unload() : Void
      {
         _dump(1,LoaderStatus.READY);
      }
   }
