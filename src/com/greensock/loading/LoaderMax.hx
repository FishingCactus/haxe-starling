package com.greensock.loading;
   import com.greensock.loading.core.LoaderCore;
   import flash.system.LoaderContext;
   import flash.net.URLRequest;
   import com.greensock.events.LoaderEvent;
   import flash.events.Event;
   import com.greensock.loading.core.LoaderItem;
   import flash.display.DisplayObject;
   import flash.utils.Dictionary;
   
   [cast(name="securityError",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="ioError",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="httpStatus",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="scriptAccessDenied",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childCancel",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childFail",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childComplete",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childProgress",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childOpen",type="com.greensock.events.LoaderEvent", Event)]
   class LoaderMax extends LoaderCore
   {

		public var rawProgress(get, null):Float;
		public var numChildren(get, null):UInt;
		public var auditedSize(get, null):Bool;
		public var status(get, null):Int;

      
      public static var defaultContext:LoaderContext;
      
      public static var contentDisplayClass:Class;
      
      public static var defaultEstimatedBytes:UInt = 20000;
      
      public static inline var version:Float = 1.8993;
      
      public static var defaultAuditSize:Bool = true;
       
      private var _loaders:Array<Int>;
      
      public var skipPaused:Bool;
      
      public var maxConnections:UInt;
      
      private var _activeLoaders:Dictionary;
      
      public var skipFailed:Bool;
      
      public var autoLoad:Bool;
      
      public function new(vars:Dynamic = null)
      {
         var i:Int = 0;
         super(vars);
         _type = "LoaderMax";
         _loaders = [];
         _activeLoaders = new Dictionary();
         this.skipFailed = cast(this.vars.skipFailed != false, Bool);
         this.skipPaused = cast(this.vars.skipPaused != false, Bool);
         this.autoLoad = cast(this.vars.autoLoad == true, Bool);
         this.maxConnections = "maxConnections" in this.vars?cast(UInt(this.vars.maxConnections), UInt):cast(2, UInt);
         if(Std.is(this.vars.loaders, Array<Int>))
         {
            for( i in 0...this.vars.loaders.length )
            {
               insert(this.vars.loaders[i],i);
            }
         }
      }
      
      public static function getContent(nameOrURL:String) : *
      {
         return _globalRootLoader != null?_globalRootLoader.getContent(nameOrURL):null;
      }
      
      public static function getLoader(nameOrURL:String) : *
      {
         return _globalRootLoader != null?_globalRootLoader.getLoader(nameOrURL):null;
      }
      
      public static function parse(data:Dynamic, vars:Dynamic = null, childrenVars:Dynamic = null) : *
      {
         var queue:LoaderMax = null;
         var l:Int = 0;
         var i:Int = 0;
         var s:String = null;
         if(Std.is(data, Array<Int>))
         {
            queue = new LoaderMax(vars);
            l = data.length;
            for( i in 0...l )
            {
               queue.append(LoaderMax.parse(data[i],childrenVars));
            }
            return queue;
         }
         if(cast(Std.is(data, String), Bool) || cast(Std.is(data, URLRequest), Bool))
         {
            s =Std.is( data, String?data:cast(data, URLRequest).url);
            s = s.toLowerCase().split("?")[0];
            s =cast( s.substr(s.lastIndexOf(".") + 1);
            if(s in _extensions)
            {
               return new _extensions[s](data,vars);
            }
         }
         else if(Std.is(data, LoaderCore))
         {
            return data, LoaderCore);
         }
         throw new Error("LoaderMax could not parse " + data + ". Don\'t forget to use LoaderMax.activate() to activate the necessary types of loaders.");
      }
      
      public static function registerFileType(extensions:String, loaderClass:Class) : Void
      {
         _activateClass("",loaderClass,extensions);
      }
      
      public static function activate(loaderClasses:Array<Int>) : Void
      {
      }
      
      public static function prioritize(nameOrURL:String, loadNow:Bool = true) : LoaderCore
      {
         var loader:LoaderCore = getLoader(nameOrURL);
         if(loader != null)
         {
            loader.prioritize(loadNow);
         }
         return loader;
      }
      
      public function getChildAt(index:Int) : *
      {
         return _loaders[index];
      }
      
      public function getContent(nameOrURL:String) : *
      {
         var loader:LoaderCore = this.getLoader(nameOrURL);
         return loader != null?loader.content:null;
      }
      
      public function remove(loader:LoaderCore) : Void
      {
         _removeLoader(loader,true);
      }
      
      override private function _load() : Void
      {
         _loadNext(null);
      }
      
      private function _cancelActiveLoaders() : Void
      {
         var loader:LoaderCore = null;
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            loader = _loaders[i];
            if(loader.status == LoaderStatus.LOADING)
            {
               _activeLoaders.remove(loader);
               _removeLoaderListeners(loader,false);
               loader.cancel();
            }
         }
      }
      
      private function _removeLoaderListeners(loader:LoaderCore, all:Bool) : Void
      {
         var p:Dynamic = null;
         loader.removeEventListener(LoaderEvent.COMPLETE,_loadNext);
         loader.removeEventListener(LoaderEvent.CANCEL,_loadNext);
         if(all)
         {
            loader.removeEventListener(LoaderEvent.PROGRESS,_progressHandler);
            loader.removeEventListener("prioritize",_prioritizeHandler);
            loader.removeEventListener("dispose",_disposeHandler);
            for(p in _listenerTypes)
            {
               if(cast(p != "onProgress", Bool) && cast(p != "onInit", Bool))
               {
                  loader.removeEventListener(_listenerTypes[p],_passThroughEvent);
               }
            }
         }
      }
      
      private function _disposeHandler(event:Event) : Void
      {
         _removeLoader(cast(event.target, LoaderCore),false);
      }
      
      override public function auditSize() : Void
      {
         if(!this.auditedSize)
         {
            _auditSize(null);
         }
      }
      
      public function getChildIndex(loader:LoaderCore) : UInt
      {
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            if(_loaders[i] == loader)
            {
               return i;
            }
         }
         return 999999999;
      }
      
      public function prepend(loader:LoaderCore) : LoaderCore
      {
         return insert(loader,0);
      }
      
      public function getLoader(nameOrURL:String) : *
      {
         var loader:LoaderCore = null;
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            loader = _loaders[i];
            if(cast(loader.name == nameOrURL, Bool) || cast(Std.is(loader, LoaderItem), Bool) && cast((cast(loader, LoaderItem)).url == nameOrURL, Bool))
            {
               return loader;
            }
            if(loader.hasOwnProperty("getLoader"))
            {
               loader = (cast(loader, Object)cast(
, LoaderCore);
               if(loader != null)
               {
                  return loader;
               }
            }
         }
         return null;
      }
      
      public function prependURLs(prependText:String, includeNested:Bool = false) : Void
      {
         var loaders:Array<Int> = getChildren(includeNested,true);
         var i:Int = loaders.length;
         while(--i > -1)
         {
            cast(loaders[i], LoaderItem).url = prependText + cast(loaders[i], LoaderItem).url;
         }
      }
      
      override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         var i:Int = 0;
         if(newStatus == LoaderStatus.DISPOSED)
         {
            _status = LoaderStatus.DISPOSED;
            empty(true,cast(scrubLevel == 3, Bool));
            if(Std.is(this.vars.requireWithRoot, DisplayObject))
            {
               delete _rootLookup[this.vars.requireWithRoot];
            }
            _activeLoaders = null;
         }
         if(scrubLevel <= 1)
         {
            _cancelActiveLoaders();
         }
         if(scrubLevel == 1)
         {
            i = _loaders.length;
            while(--i > -1)
            {
               cast(_loaders[i], LoaderCore).unload();
            }
         }
         super._dump(scrubLevel,newStatus,suppressEvents);
         _cacheIsDirty = true;
      }
      
      public function empty(disposeChildren:Bool = true, unloadAllContent:Bool = false) : Void
      {
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            if(disposeChildren)
            {
               cast(_loaders[i], LoaderCore).dispose(unloadAllContent);
            }
            else if(unloadAllContent)
            {
               cast(_loaders[i], LoaderCore).unload();
            }
            else
            {
               _removeLoader(_loaders[i],true);
            }
         }
      }
      
      private function _removeLoader(loader:LoaderCore, rootLoaderAppend:Bool) : Void
      {
         if(loader == null)
         {
            return;
         }
         if(cast(rootLoaderAppend, Bool) && cast(this != loader.rootLoader, Bool))
         {
            loader.rootLoader.append(loader);
         }
         _removeLoaderListeners(loader,true);
         _loaders.splice(getChildIndex(loader),1);
         if(loader in _activeLoaders)
         {
            _activeLoaders.remove(loader);
            loader.cancel();
            if(_status == LoaderStatus.LOADING)
            {
               _loadNext(null);
            }
         }
         _cacheIsDirty = true;
         _progressHandler(null);
      }
      
      public  function get_rawProgress()
      {
         var status:Int = 0;
         var loaded:Float = 0;
         var total:UInt = 0;
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            status = cast(_loaders[i], LoaderCore).status;
            if(cast(status != LoaderStatus.DISPOSED, Bool) && cast(!(Bool(status == LoaderStatus.PAUSED) && Bool(this.skipPaused)), Bool) && cast(!(Bool(status == LoaderStatus.FAILED) && Bool(this.skipFailed)), Bool))
            {
               total++;
               loaded = loaded + (Std.is(_loaders[i], LoaderMax?cast(_loaders[i], LoaderMax).rawProgress:cast(_loaders[i], LoaderCore).progress));
            }
         }
         return total == 0?cast(0, Float):cast(loaded / total, Float);
      }
      
      private function _loadNext(event:Event = null) : Void
      {
         var audit:Bool = false;
         var loader:LoaderCore = null;
         var loaders:Array<Int> = null;
         var l:Int = 0;
         var activeCount:UInt = 0;
         var i:Int = 0;
         if(cast(event != null, Bool) && cast(_activeLoaders != null, Bool))
         {
            delete _activeLoaders[event.target];
            _removeLoaderListeners(cast(event.target, LoaderCore),false);
         }
         if(_status == LoaderStatus.LOADING)
         {
            audit = "auditSize" in this.vars?cast(Bool(this.vars.auditSize), Bool):cast(LoaderMax.defaultAuditSize, Bool);
            if(cast(audit, Bool) && cast(!this.auditedSize, Bool))
            {
               _auditSize(null);
               return;
            }
            loaders = _loaders.concat();
            l = loaders.length;
            activeCount = 0;
            _calculateProgress();
            i = 0;
            while(true)
            {
               if(i < l)
               {
                  loader = loaders[i];
                  if(cast(!this.skipPaused, Bool) && cast(loader.status == LoaderStatus.PAUSED, Bool))
                  {
                     break;
                  }
                  if(cast(!this.skipFailed, Bool) && cast(loader.status == LoaderStatus.FAILED, Bool))
                  {
                     super._failHandler(new LoaderEvent(LoaderEvent.FAIL,this,"Did not complete LoaderMax because skipFailed was false and " + loader.toString() + " failed."),false);
                     return;
                  }
                  if(loader.status <= LoaderStatus.LOADING)
                  {
                     activeCount++;
                     if(!(loader in _activeLoaders))
                     {
                        _activeLoaders[loader] = true;
                        loader.addEventListener(LoaderEvent.COMPLETE,_loadNext,false,-100,true);
                        loader.addEventListener(LoaderEvent.CANCEL,_loadNext,false,-100,true);
                        loader.load(false);
                     }
                     if(activeCount == this.maxConnections)
                     {
                     }
                  }
                  i++;
                  continue;
               }
               if(cast(activeCount == 0, Bool) && cast(_cachedBytesLoaded == _cachedBytesTotal, Bool))
               {
                  _completeHandler(null);
               }
            }
            super._failHandler(new LoaderEvent(LoaderEvent.FAIL,this,"Did not complete LoaderMax because skipPaused was false and " + loader.toString() + " was paused."),false);
            return;
         }
      }
      
      public function append(loader:LoaderCore) : LoaderCore
      {
         return insert(loader,_loaders.length);
      }
      
      override private function _progressHandler(event:Event) : Void
      {
         var bl:UInt = 0;
         var bt:UInt = 0;
         if(cast(_dispatchChildProgress, Bool) && cast(event != null, Bool))
         {
            dispatchEvent(new LoaderEvent(LoaderEvent.CHILD_PROGRESS,event.target));
         }
         if(cast(_dispatchProgress, Bool) && cast(_status != LoaderStatus.DISPOSED, Bool))
         {
            bl = _cachedBytesLoaded;
            bt = _cachedBytesTotal;
            _calculateProgress();
            if(!(cast(bl == 0, Bool) && cast(_cachedBytesLoaded == 0, Bool)))
            {
               if((cast(_cachedBytesLoaded != _cachedBytesTotal, Bool) || cast(_status != LoaderStatus.LOADING, Bool)) && (cast(bl != _cachedBytesLoaded, Bool) || cast(bt != _cachedBytesTotal, Bool)))
               {
                  dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
               }
            }
         }
         else
         {
            _cacheIsDirty = true;
         }
      }
      
      private function _prioritizeHandler(event:Event) : Void
      {
         var prevMaxConnections:UInt = 0;
         var loader:LoaderCore =cast( event.target, LoaderCore);
         _loaders.splice(getChildIndex(loader),1);
         _loaders.unshift(loader);
         if(cast(_status == LoaderStatus.LOADING, Bool) && cast(loader.status <= LoaderStatus.LOADING, Bool) && cast(!(loader in _activeLoaders), Bool))
         {
            _cancelActiveLoaders();
            prevMaxConnections = this.maxConnections;
            this.maxConnections = 1;
            _loadNext(null);
            this.maxConnections = prevMaxConnections;
         }
      }
      
      public  function get_numChildren()
      {
         return _loaders.length;
      }
      
      override public function get content() : *
      {
         var a:Array<Int> = [];
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            a[i] = cast(_loaders[i], LoaderCore).content;
         }
         return a;
      }
      
      public function replaceURLText(fromText:String, toText:String, includeNested:Bool = false) : Void
      {
         var loader:LoaderItem = null;
         var loaders:Array<Int> = getChildren(includeNested,true);
         var i:Int = loaders.length;
         while(--i > -1)
         {
            loader = loaders[i];
            loader.url = loader.url.split(fromText).join(toText);
            if("alternateURL" in loader.vars)
            {
               loader.vars.alternateURL = loader.vars.alternateURL.split(fromText).join(toText);
            }
         }
      }
      
      override public  function get_auditedSize()
      {
         var maxStatus:Int = !!this.skipPaused?cast(LoaderStatus.COMPLETED, Int):cast(LoaderStatus.PAUSED, Int);
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            if(cast(!LoaderCore(_loaders[i]).auditedSize, Bool) && cast(LoaderCore(_loaders[i]).status <= maxStatus, Bool))
            {
               return false;
            }
         }
         return true;
      }
      
      override public  function get_status()
      {
         var statusCounts:Array<Int> = null;
         var i:Int = 0;
         if(_status == LoaderStatus.COMPLETED)
         {
            statusCounts = [0,0,0,0,0,0];
            i = _loaders.length;
            while(--i > -1)
            {
               statusCounts[cast(_loaders[i], LoaderCore).status]++;
            }
            if(cast(!this.skipFailed, Bool) && cast(statusCounts[4] != 0, Bool) || cast(!this.skipPaused, Bool) && cast(statusCounts[3] != 0, Bool))
            {
               _status = LoaderStatus.FAILED;
            }
            else if(statusCounts[0] + statusCounts[1] != 0)
            {
               _status = LoaderStatus.READY;
               _cacheIsDirty = true;
            }
         }
         return _status;
      }
      
      override private function _calculateProgress() : Void
      {
         var loader:LoaderCore = null;
         var s:Int = 0;
         _cachedBytesLoaded = 0;
         _cachedBytesTotal = 0;
         var i:Int = _loaders.length;
         while(--i > -1)
         {
            loader = _loaders[i];
            s = loader.status;
            if(cast(s <= LoaderStatus.COMPLETED, Bool) || cast(!this.skipPaused, Bool) && cast(s == LoaderStatus.PAUSED, Bool) || cast(!this.skipFailed, Bool) && cast(s == LoaderStatus.FAILED, Bool))
            {
               _cachedBytesLoaded = _cachedBytesLoaded + loader.bytesLoaded;
               _cachedBytesTotal = _cachedBytesTotal + loader.bytesTotal;
            }
         }
         _cacheIsDirty = false;
      }
      
      public function insert(loader:LoaderCore, index:UInt = 999999999) : LoaderCore
      {
         var p:Dynamic = null;
         if(cast(loader == null, Bool) || cast(loader == this, Bool) || cast(_status == LoaderStatus.DISPOSED, Bool))
         {
            return null;
         }
         if(this != loader.rootLoader)
         {
            _removeLoader(loader,false);
         }
         if(loader.rootLoader == _globalRootLoader)
         {
            loader.rootLoader.remove(loader);
         }
         if(index > _loaders.length)
         {
            index = _loaders.length;
         }
         _loaders.splice(index,0,loader);
         if(this != _globalRootLoader)
         {
            for(p in _listenerTypes)
            {
               if(cast(p != "onProgress", Bool) && cast(p != "onInit", Bool))
               {
                  loader.addEventListener(_listenerTypes[p],_passThroughEvent,false,-100,true);
               }
            }
            loader.addEventListener(LoaderEvent.PROGRESS,_progressHandler,false,-100,true);
            loader.addEventListener("prioritize",_prioritizeHandler,false,-100,true);
         }
         loader.addEventListener("dispose",_disposeHandler,false,-100,true);
         _cacheIsDirty = true;
         if(_status != LoaderStatus.LOADING)
         {
            if(_status != LoaderStatus.PAUSED)
            {
               _status = LoaderStatus.READY;
            }
            else if(_prePauseStatus == LoaderStatus.COMPLETED)
            {
               _prePauseStatus = LoaderStatus.READY;
            }
         }
         if(cast(this.autoLoad, Bool) && cast(loader.status == LoaderStatus.READY, Bool))
         {
            if(_status != LoaderStatus.LOADING)
            {
               this.load(false);
            }
            else
            {
               _loadNext(null);
            }
         }
         return loader;
      }
      
      public function getChildren(includeNested:Bool = false, omitLoaderMaxes:Bool = false) : Array<Int>
      {
         var a:Array<Int> = [];
         var l:Int = _loaders.length;
         for( i in 0...l )
         {
            if(cast(!omitLoaderMaxes, Bool) || cast(!(Std.is(_loaders[i], LoaderMax)), Bool))
            {
               a.push(_loaders[i]);
            }
            if(cast(includeNested, Bool) && cast(_loaders[i].hasOwnProperty("getChildren"), Bool))
            {
               a = a.concat(_loaders[i].getChildren(true,omitLoaderMaxes));
            }
         }
         return a;
      }
      
      private function _auditSize(event:Event = null) : Void
      {
         var loader:LoaderCore = null;
         var found:Bool = false;
         if(event != null)
         {
            event.target.removeEventListener("auditedSize",_auditSize);
            event.target.removeEventListener(LoaderEvent.FAIL,_auditSize);
         }
         var l:UInt = _loaders.length;
         var maxStatus:Int = !!this.skipPaused?cast(LoaderStatus.COMPLETED, Int):cast(LoaderStatus.PAUSED, Int);
         for( i in 0...l )
         {
            loader = _loaders[i];
            if(cast(!loader.auditedSize, Bool) && cast(loader.status <= maxStatus, Bool))
            {
               if(!found)
               {
                  loader.addEventListener("auditedSize",_auditSize,false,-100,true);
                  loader.addEventListener(LoaderEvent.FAIL,_auditSize,false,-100,true);
               }
               found = true;
               loader.auditSize();
            }
         }
         if(!found)
         {
            if(_status == LoaderStatus.LOADING)
            {
               _loadNext(null);
            }
            dispatchEvent(new Event("auditedSize"));
         }
      }
      
      public function getChildrenByStatus(status:Int, includeNested:Bool = false) : Array<Int>
      {
         var a:Array<Int> = [];
         var loaders:Array<Int> = getChildren(includeNested,false);
         var l:Int = loaders.length;
         for( i in 0...l )
         {
            if(cast(loaders[i], LoaderCore).status == status)
            {
               a.push(loaders[i]);
            }
         }
         return a;
      }
   }
