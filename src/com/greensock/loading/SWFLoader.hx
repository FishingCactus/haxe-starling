package com.greensock.loading;
   import com.greensock.loading.core.DisplayObjectLoader;
   import flash.events.Event;
   import flash.display.DisplayObject;
   import com.greensock.events.LoaderEvent;
   import flash.display.AVM1Movie;
   import com.greensock.loading.core.LoaderCore;
   import flash.utils.getTimer;
   import flash.display.MovieClip;
   import flash.media.SoundTransform;
   import flash.utils.getQualifiedClassName;
   import flash.display.DisplayObjectContainer;
   
   [cast(name="securityError",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="httpStatus",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="scriptAccessDenied",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childCancel",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childFail",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childComplete",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childProgress",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childOpen",type="com.greensock.events.LoaderEvent", Event)]
   class SWFLoader extends DisplayObjectLoader
   {

		public var url(null, set):String;

      
      private static var _classActivated:Bool = _activateClass("SWFLoader",SWFLoader,"swf");
       
      private var _queue:com.greensock.loading.LoaderMax;
      
      private var _loaderFailed:Bool;
      
      private var _rslAddedCount:UInt;
      
      private var _loadOnExitStealth:Bool;
      
      private var _hasRSL:Bool;
      
      private var _loaderCompleted:Bool;
      
      private var _lastPTUncaughtError:Event;
      
      public function new(urlOrRequest:Dynamic, vars:Object = null)
      {
         super(urlOrRequest,vars);
         _preferEstimatedBytesInAudit = true;
         _type = "SWFLoader";
      }
      
      override public  function set_url(value)
      {
         if(_url != value)
         {
            if(cast(_status == LoaderStatus.LOADING, Bool) && cast(!_initted, Bool) && cast(!_loaderFailed, Bool))
            {
               _loadOnExitStealth = true;
            }
            super.url = value;
         }
      }
      
      override private function _errorHandler(event:Event) : Void
      {
         if(!_suppressUncaughtError(event))
         {
            super._errorHandler(event);
         }
      }
      
      override private function _determineScriptAccess() : Void
      {
         var mc:DisplayObject = null;
         try
         {
            mc = _loader.content;
         }
         catch(error:Error)
         {
            _scriptAccessDenied = true;
            dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED,this,error.message));
            return;
         }
         if(Std.is(_loader.content, AVM1Movie))
         {
            _scriptAccessDenied = true;
            dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED,this,"AVM1Movie denies script access"));
         }
      }
      
      override private function _load() : Void
      {
         if(_stealthMode)
         {
            _stealthMode = _loadOnExitStealth;
         }
         else if(!_initted)
         {
            _loader.visible = false;
            _sprite.addChild(_loader);
            super._load();
         }
         else if(_queue != null)
         {
            _changeQueueListeners(true);
            _queue.load(false);
         }
      }
      
      public function getClass(className:String) : Class
      {
         var result:Object = null;
         var loaders:Array<Int> = null;
         var i:Int = 0;
         if(cast(_content == null, Bool) || cast(_scriptAccessDenied, Bool))
         {
            return null;
         }
         if(_content.loaderInfo.applicationDomain.hasDefinition(className))
         {
            return _content.loaderInfo.applicationDomain.getDefinition(className);
         }
         if(_queue != null)
         {
            loaders = _queue.getChildren(true,true);
            i = loaders.length;
            while(--i > -1)
            {
               if(Std.is(loaders[i], SWFLoader))
               {
                  result = (cast(loaders[i], SWFLoader)cast(
, Class);
                  }
               }
            }
         }
         return null;
      }
      
      public function getContent(nameOrURL:String) : *
      {
         if(cast(nameOrURL == this.name, Bool) || cast(nameOrURL == _url, Bool))
         {
            return this.content;
         }
         var loader:LoaderCore = this.getLoader(nameOrURL);
         return loader != null?loader.content:null;
      }
      
      override private function _failHandler(event:Event, dispatchError:Bool = true) : Void
      {
         if((cast(event.type == "ioError", Bool) || cast(event.type == "securityError", Bool)) && cast(event.target == _loader.contentLoaderInfo, Bool))
         {
            _loaderFailed = true;
            if(_loadOnExitStealth)
            {
               _dump(1,_status,true);
               _load();
               return;
            }
         }
         if(event.target == _queue)
         {
            _status = LoaderStatus.FAILED;
            _time = getTimer() - _time;
            dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL,this));
            dispatchEvent(new LoaderEvent(LoaderEvent.FAIL,this,this.toString() + " > " + (cast(event, Object)).text));
            return;
         }
         super._failHandler(event,dispatchError);
      }
      
      override private function _refreshLoader(unloadContent:Bool = true) : Void
      {
         super._refreshLoader(unloadContent);
         _loaderCompleted = false;
      }
      
      public function getLoader(nameOrURL:String) : *
      {
         return _queue != null?_queue.getLoader(nameOrURL):null;
      }
      
      override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         var content:Dynamic = undefined;
         _loaderCompleted = false;
         if(cast(_status == LoaderStatus.LOADING, Bool) && cast(!_initted, Bool) && cast(!_loaderFailed, Bool))
         {
            _stealthMode = true;
            super._dump(scrubLevel,newStatus,suppressEvents);
            return;
         }
         if(cast(_initted, Bool) && cast(!_scriptAccessDenied, Bool) && cast(scrubLevel != 2, Bool))
         {
            _stopMovieClips(_loader.content);
            if(_loader.content in _rootLookup)
            {
               _queue = cast(_rootLookup[_loader.content], LoaderMax);
               _changeQueueListeners(false);
               if(scrubLevel == 0)
               {
                  _queue.cancel();
               }
               else
               {
                  delete _rootLookup[_loader.content];
                  _queue.dispose(cast(scrubLevel != 2, Bool));
               }
            }
         }
         if(_stealthMode)
         {
            try
            {
               _loader.close();
            }
            catch(error:Error)
            {
            }
         }
         _loadOnExitStealth = false;
         _stealthMode = _hasRSL = _loaderFailed = false;
         _cacheIsDirty = true;
         if(scrubLevel >= 1)
         {
            _queue = null;
            _initted = false;
            super._dump(scrubLevel,newStatus,suppressEvents);
         }
         else
         {
            content = _content;
            super._dump(scrubLevel,newStatus,suppressEvents);
            _content = content;
         }
      }
      
      private function _stopMovieClips(obj:DisplayObject) : Void
      {
         var mc:MovieClip =cast( obj, MovieClip);
         if(mc == null)
         {
            return;
         }
         mc.stop();
         var i:Int = mc.numChildren;
         while(--i > -1)
         {
            _stopMovieClips(mc.getChildAt(i));
         }
      }
      
      private function _checkRequiredLoaders() : Void
      {
         if(cast(_queue == null, Bool) && cast(this.vars.integrateProgress != false, Bool) && cast(!_scriptAccessDenied, Bool) && cast(_content != null, Bool))
         {
            _queue = _rootLookup[_content];
            if(_queue != null)
            {
               _changeQueueListeners(true);
               _queue.load(false);
               _cacheIsDirty = true;
            }
         }
      }
      
      override private function _completeHandler(event:Event = null) : Void
      {
         var st:SoundTransform = null;
         _loaderCompleted = true;
         _checkRequiredLoaders();
         _calculateProgress();
         if(this.progress == 1)
         {
            if(cast(!_scriptAccessDenied, Bool) && cast(this.vars.autoPlay == false, Bool) && cast(Std.is(_content, MovieClip), Bool))
            {
               st = _content.soundTransform;
               st.volume = 1;
               _content.soundTransform = st;
            }
            _changeQueueListeners(false);
            super._determineScriptAccess();
            super._completeHandler(event);
         }
      }
      
      private function _changeQueueListeners(add:Bool) : Void
      {
         var p:Dynamic = null;
         if(_queue != null)
         {
            if(cast(add, Bool) && cast(this.vars.integrateProgress != false, Bool))
            {
               for(p in _listenerTypes)
               {
                  if(cast(p != "onProgress", Bool) && cast(p != "onInit", Bool))
                  {
                     _queue.addEventListener(_listenerTypes[p],_passThroughEvent,false,-100,true);
                  }
               }
               _queue.addEventListener(LoaderEvent.COMPLETE,_completeHandler,false,-100,true);
               _queue.addEventListener(LoaderEvent.PROGRESS,_progressHandler,false,-100,true);
               _queue.addEventListener(LoaderEvent.FAIL,_failHandler,false,-100,true);
            }
            else
            {
               _queue.removeEventListener(LoaderEvent.COMPLETE,_completeHandler);
               _queue.removeEventListener(LoaderEvent.PROGRESS,_progressHandler);
               _queue.removeEventListener(LoaderEvent.FAIL,_failHandler);
               for(p in _listenerTypes)
               {
                  if(cast(p != "onProgress", Bool) && cast(p != "onInit", Bool))
                  {
                     _queue.removeEventListener(_listenerTypes[p],_passThroughEvent);
                  }
               }
            }
         }
      }
      
      override private function _initHandler(event:Event) : Void
      {
         var awaitingLoad:Bool = false;
         var tempContent:DisplayObject = null;
         var className:String = null;
         var rslPreloader:Object = null;
         if(_stealthMode)
         {
            _initted = true;
            awaitingLoad = _loadOnExitStealth;
            _dump(_status == LoaderStatus.DISPOSED?cast(3, Int):cast(1, Int),_status,true);
            if(awaitingLoad)
            {
               _load();
            }
            return;
         }
         _hasRSL = false;
         try
         {
            tempContent = _loader.content;
            className = getQualifiedClassName(tempContent);
            if(className.substr(-13) == "__Preloader__")
            {
               rslPreloader = tempContent["__rslPreloader"];
               if(rslPreloader != null)
               {
                  className = getQualifiedClassName(rslPreloader);
                  if(className == "fl.rsl::RSLPreloader")
                  {
                     _hasRSL = true;
                     _rslAddedCount = 0;
                     tempContent.addEventListener(Event.ADDED,_rslAddedHandler);
                  }
               }
            }
         }
         catch(error:Error)
         {
         }
         if(!_hasRSL)
         {
            _init();
         }
      }
      
      private function _rslAddedHandler(event:Event) : Void
      {
         if(cast(Std.is(event.target, DisplayObject), Bool) && cast(Std.is(event.currentTarget, DisplayObjectContainer), Bool) && cast(event.target.parent == event.currentTarget, Bool))
         {
            _rslAddedCount++;
         }
         if(_rslAddedCount > 1)
         {
            event.currentTarget.removeEventListener(Event.ADDED,_rslAddedHandler);
            if(_status == LoaderStatus.LOADING)
            {
               _content = event.target;
               _init();
               _calculateProgress();
               dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
               _completeHandler(null);
            }
         }
      }
      
      override private function _passThroughEvent(event:Event) : Void
      {
         if(cast(!(Bool(event.type == "uncaughtError") && Bool(_suppressUncaughtError(event))), Bool) && cast(event.target != _queue, Bool))
         {
            super._passThroughEvent(event);
         }
      }
      
      override private function _progressHandler(event:Event) : Void
      {
         var bl:UInt = 0;
         var bt:UInt = 0;
         if(_status == LoaderStatus.LOADING)
         {
            if(cast(_queue == null, Bool) && cast(_initted, Bool))
            {
               _checkRequiredLoaders();
            }
            if(_dispatchProgress)
            {
               bl = _cachedBytesLoaded;
               bt = _cachedBytesTotal;
               _calculateProgress();
               if(cast(_cachedBytesLoaded != _cachedBytesTotal, Bool) && (cast(bl != _cachedBytesLoaded, Bool) || cast(bt != _cachedBytesTotal, Bool)))
               {
                  dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
               }
            }
            else
            {
               _cacheIsDirty = true;
            }
         }
      }
      
      private function _init() : Void
      {
         var st:SoundTransform = null;
         _determineScriptAccess();
         if(!_scriptAccessDenied)
         {
            if(!_hasRSL)
            {
               _content = _loader.content;
            }
            if(_content != null)
            {
               if(cast(this.vars.autoPlay == false, Bool) && cast(Std.is(_content, MovieClip), Bool))
               {
                  st = _content.soundTransform;
                  st.volume = 0;
                  _content.soundTransform = st;
                  _content.stop();
               }
               _checkRequiredLoaders();
            }
            if(_loader.parent == _sprite)
            {
               if(cast(_sprite.stage != null, Bool) && cast(this.vars.suppressInitReparentEvents == true, Bool))
               {
                  _sprite.addEventListener(Event.ADDED_TO_STAGE,_captureFirstEvent,true,1000,true);
                  _loader.addEventListener(Event.REMOVED_FROM_STAGE,_captureFirstEvent,true,1000,true);
               }
               _sprite.removeChild(_loader);
            }
         }
         else
         {
            _content = _loader;
            _loader.visible = true;
         }
         super._initHandler(null);
      }
      
      private function _captureFirstEvent(event:Event) : Void
      {
         event.stopImmediatePropagation();
         event.currentTarget.removeEventListener(event.type,_captureFirstEvent);
      }
      
      override private function _calculateProgress() : Void
      {
         _cachedBytesLoaded = !!_stealthMode?cast(0, UInt):cast(_loader.contentLoaderInfo.bytesLoaded, UInt);
         if(_loader.contentLoaderInfo.bytesTotal != 0)
         {
            _cachedBytesTotal = _loader.contentLoaderInfo.bytesTotal;
         }
         if(cast(_cachedBytesTotal < _cachedBytesLoaded, Bool) || cast(_loaderCompleted, Bool))
         {
            _cachedBytesTotal = _cachedBytesLoaded;
         }
         if(this.vars.integrateProgress != false)
         {
            if(cast(_queue != null, Bool) && (cast(UInt(this.vars.estimatedBytes) < _cachedBytesLoaded, Bool) || cast(_queue.auditedSize, Bool)))
            {
               if(_queue.status <= LoaderStatus.COMPLETED)
               {
                  _cachedBytesLoaded = _cachedBytesLoaded + _queue.bytesLoaded;
                  _cachedBytesTotal = _cachedBytesTotal + _queue.bytesTotal;
               }
            }
            else if(cast(UInt(this.vars.estimatedBytes) > _cachedBytesLoaded, Bool) && (cast(!_initted, Bool) || cast(_queue != null, Bool) && cast(_queue.status <= LoaderStatus.COMPLETED, Bool) && cast(!_queue.auditedSize, Bool)))
            {
               _cachedBytesTotal = cast(this.vars.estimatedBytes, UInt);
            }
         }
         if(cast(_hasRSL, Bool) && cast(_content == null, Bool) || cast(!_initted, Bool) && cast(_cachedBytesLoaded == _cachedBytesTotal, Bool))
         {
            _cachedBytesLoaded = cast(_cachedBytesLoaded * 0.99, Int);
         }
         _cacheIsDirty = false;
      }
      
      public function getChildren(includeNested:Bool = false, omitLoaderMaxes:Bool = false) : Array<Int>
      {
         return _queue != null?_queue.getChildren(includeNested,omitLoaderMaxes):[];
      }
      
      public function getSWFChild(name:String) : DisplayObject
      {
         return cast(!_scriptAccessDenied, Bool) && cast(Std.is(_content, DisplayObjectContainer), Bool)?cast(_content, DisplayObjectContainer).getChildByName(name):null;
      }
      
      private function _suppressUncaughtError(event:Event) : Bool
      {
         if(cast(Std.is(event, LoaderEvent), Bool) && cast(Std.is(LoaderEvent(event).data, Event), Bool))
         {
            event =cast( cast(event, LoaderEvent).data, Event);
         }
         if(event.type == "uncaughtError")
         {
            if(_lastPTUncaughtError == (_lastPTUncaughtError = event))
            {
               return true;
            }
            if(this.vars.suppressUncaughtErrors == true)
            {
               event.preventDefault();
               event.stopImmediatePropagation();
               return true;
            }
         }
         return false;
      }
   }
