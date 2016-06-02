package com.greensock.loading;
   import com.greensock.loading.core.LoaderCore;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.events.Event;
   import flash.utils.getTimer;
   import com.greensock.events.LoaderEvent;
   
   [cast(name="securityError",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="httpStatus",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="scriptAccessDenied",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childCancel",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childFail",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childComplete",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childProgress",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="childOpen",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="init",type="com.greensock.events.LoaderEvent", Event)]
   class XMLLoader extends DataLoader
   {

		public var progress(get, null):Float;

      
      private static var _varTypes:Dynamic = {
         "skipFailed":true,
         "skipPaused":true,
         "autoLoad":false,
         "paused":false,
         "load":false,
         "noCache":false,
         "maxConnections":2,
         "autoPlay":false,
         "autoDispose":false,
         "smoothing":false,
         "autoDetachNetStream":false,
         "estimatedBytes":1,
         "x":1,
         "y":1,
         "z":1,
         "rotationX":1,
         "rotationY":1,
         "rotationZ":1,
         "width":1,
         "height":1,
         "scaleX":1,
         "scaleY":1,
         "rotation":1,
         "alpha":1,
         "visible":true,
         "bgColor":0,
         "bgAlpha":0,
         "deblocking":1,
         "repeat":1,
         "checkPolicyFile":false,
         "centerRegistration":false,
         "bufferTime":5,
         "volume":1,
         "bufferMode":false,
         "estimatedDuration":200,
         "crop":false,
         "autoAdjustBuffer":true,
         "suppressInitReparentEvents":true
      };
      
      private static var _classActivated:Bool = _activateClass("XMLLoader",XMLLoader,"xml,php,jsp,asp,cfm,cfml,aspx");
      
      public static var RAW_LOAD:String = "rawLoad";
       
      private var _initted:Bool;
      
      private var _parsed:com.greensock.loading.LoaderMax;
      
      private var _loadingQueue:com.greensock.loading.LoaderMax;
      
      public function new(urlOrRequest:Dynamic, vars:Dynamic = null)
      {
         super(urlOrRequest,vars);
         _preferEstimatedBytesInAudit = true;
         _type = "XMLLoader";
         _loader.dataFormat = "text";
      }
      
      public static function parseLoaders(xml:Xml, all:com.greensock.loading.LoaderMax, toLoad:com.greensock.loading.LoaderMax = null) : Void
      {
         var node:Xml = null;
         var queue:com.greensock.loading.LoaderMax = null;
         var replaceText:Array<Int> = null;
         var i:Int = 0;
         var loaderClass:Class = null;
         var parsedVars:Dynamic = null;
         var loader:LoaderCore = null;
         var p:Dynamic = null;
         var nodeName:String = cast(xml.name(), String).toLowerCase();
         if(nodeName == "loadermax")
         {
            queue =cast( all.append(new com.greensock.loading.cast(_parseVars(xml), LoaderMax)), LoaderMax);
            if(cast(toLoad != null, Bool) && cast(queue.vars.load, Bool))
            {
               toLoad.append(queue);
            }
            if(cast(queue.vars.childrenVars != null, Bool) && cast(queue.vars.childrenVars.indexOf(":") != -1, Bool))
            {
               queue.vars.childrenVars = _parseVars(new Xml("<childrenVars " + queue.vars.childrenVars.split(",").join("\" ").split(":").join("=\"") + "\" />"));
            }
            for( node in xml.children ())
            {
               parseLoaders(node,queue,toLoad);
            }
            if("replaceURLText" in queue.vars)
            {
               replaceText = queue.vars.replaceURLText.split(",");
               for(i = 0; i < replaceText.length; i = i + 2)
               {
                  queue.replaceURLText(replaceText[i],replaceText[i + 1],false);
               }
            }
            if("prependURLs" in queue.vars)
            {
               queue.prependURLs(queue.vars.prependURLs,false);
            }
         }
         else
         {
            if(nodeName in _types)
            {
               loaderClass = _types[nodeName];
               parsedVars = _parseVars(xml);
               if(typeof all.vars.childrenVars == "object")
               {
                  for(p in all.vars.childrenVars)
                  {
                     if(!(p in parsedVars))
                     {
                        parsedVars[p] = all.vars.childrenVars[p];
                     }
                  }
               }
               loader = all.append(new loaderClass(xml.@url,parsedVars));
               if(cast(toLoad != null, Bool) && cast(loader.vars.load, Bool))
               {
                  toLoad.append(loader);
               }
            }
            for( node in xml.children ())
            {
               parseLoaders(node,all,toLoad);
            }
         }
      }
      
      private static function _parseVars(xml:Xml) : Object
      {
         var s:String = null;
         var type:String = null;
         var value:String = null;
         var domain:ApplicationDomain = null;
         var attribute:Xml = null;
         var v:Dynamic = {"rawXML":xml};
         var list:XMLList = xml.attributes();
         for( attribute in list )
         {
            s = attribute.name();
            value = attribute.toString();
            if(s != "url")
            {
               if(s == "context")
               {
                  v.context = new LoaderContext(true,value == "own"?ApplicationDomain.currentDomain:value == "separate"?new ApplicationDomain():new ApplicationDomain(ApplicationDomain.currentDomain),!_isLocal?SecurityDomain.currentDomain:null);
               }
               else
               {
                  type = typeof _varTypes[s];
                  if(type == "boolean")
                  {
                     v[s] = cast(value == "true" || value == "1", Bool);
                  }
                  else if(type == "number")
                  {
                     v[s] = cast(value, Float);
                  }
                  else
                  {
                     v[s] = value;
                  }
               }
            }
         }
         return v;
      }
      
      public function getContent(nameOrURL:String) : *
      {
         if(cast(nameOrURL == this.name, Bool) || cast(nameOrURL == _url, Bool))
         {
            return _content;
         }
         var loader:LoaderCore = this.getLoader(nameOrURL);
         return loader != null?loader.content:null;
      }
      
      override private function _load() : Void
      {
         if(!_initted)
         {
            _prepRequest();
            _loader.load(_request);
         }
         else if(_loadingQueue != null)
         {
            _changeQueueListeners(true);
            _loadingQueue.load(false);
         }
      }
      
      override public  function get_progress()
      {
         return this.bytesTotal != 0?cast(_cachedBytesLoaded / _cachedBytesTotal, Float):cast(_status == LoaderStatus.COMPLETED, Bool) || cast(_initted, Bool)?cast(1, Float):cast(0, Float);
      }
      
      public function getLoader(nameOrURL:String) : *
      {
         return _parsed != null?_parsed.getLoader(nameOrURL):null;
      }
      
      override private function _passThroughEvent(event:Event) : Void
      {
         if(event.target != _loadingQueue)
         {
            super._passThroughEvent(event);
         }
      }
      
      override private function _failHandler(event:Event, dispatchError:Bool = true) : Void
      {
         if(event.target == _loadingQueue)
         {
            _status = LoaderStatus.FAILED;
            _time = getTimer() - _time;
            dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL,this));
            dispatchEvent(new LoaderEvent(LoaderEvent.FAIL,this,this.toString() + " > " + (cast(event, Object)).text));
         }
         else
         {
            super._failHandler(event,dispatchError);
         }
      }
      
      override private function _completeHandler(event:Event = null) : Void
      {
         _calculateProgress();
         if(this.progress == 1)
         {
            _changeQueueListeners(false);
            super._completeHandler(event);
         }
      }
      
      public function getChildren(includeNested:Bool = false, omitLoaderMaxes:Bool = false) : Array<Int>
      {
         return _parsed != null?_parsed.getChildren(includeNested,omitLoaderMaxes):[];
      }
      
      override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         if(_loadingQueue != null)
         {
            _changeQueueListeners(false);
            if(scrubLevel == 0)
            {
               _loadingQueue.cancel();
            }
            else
            {
               _loadingQueue.dispose(cast(scrubLevel == 3, Bool));
               _loadingQueue = null;
            }
         }
         if(scrubLevel >= 1)
         {
            if(_parsed != null)
            {
               _parsed.dispose(cast(scrubLevel == 3, Bool));
               _parsed = null;
            }
            _initted = false;
         }
         _cacheIsDirty = true;
         var content:Dynamic = _content;
         super._dump(scrubLevel,newStatus,suppressEvents);
         if(scrubLevel == 0)
         {
            _content = content;
         }
      }
      
      override private function _calculateProgress() : Void
      {
         _cachedBytesLoaded = _loader.bytesLoaded;
         if(_loader.bytesTotal != 0)
         {
            _cachedBytesTotal = _loader.bytesTotal;
         }
         if(cast(_cachedBytesTotal < _cachedBytesLoaded, Bool) || cast(_initted, Bool))
         {
            _cachedBytesTotal = _cachedBytesLoaded;
         }
         var estimate:UInt = cast(this.vars.estimatedBytes, UInt);
         if(this.vars.integrateProgress != false)
         {
            if(cast(_loadingQueue != null, Bool) && (cast(UInt(this.vars.estimatedBytes) < _cachedBytesLoaded, Bool) || cast(_loadingQueue.auditedSize, Bool)))
            {
               if(_loadingQueue.status <= LoaderStatus.COMPLETED)
               {
                  _cachedBytesLoaded = _cachedBytesLoaded + _loadingQueue.bytesLoaded;
                  _cachedBytesTotal = _cachedBytesTotal + _loadingQueue.bytesTotal;
               }
            }
            else if(cast(UInt(this.vars.estimatedBytes) > _cachedBytesLoaded, Bool) && (cast(!_initted, Bool) || cast(_loadingQueue != null, Bool) && cast(_loadingQueue.status <= LoaderStatus.COMPLETED, Bool) && cast(!_loadingQueue.auditedSize, Bool)))
            {
               _cachedBytesTotal = cast(this.vars.estimatedBytes, UInt);
            }
         }
         if(cast(!_initted, Bool) && cast(_cachedBytesLoaded == _cachedBytesTotal, Bool))
         {
            _cachedBytesLoaded = cast(_cachedBytesLoaded * 0.99, Int);
         }
         _cacheIsDirty = false;
      }
      
      override private function _receiveDataHandler(event:Event) : Void
      {
         var loaders:Array<Int> = null;
         var i:Int = 0;
         try
         {
            _content = new Xml(_loader.data);
         }
         catch(error:Error)
         {
            _content = _loader.data;
            _failHandler(new LoaderEvent(LoaderEvent.ERROR,this,error.message));
            return;
         }
         dispatchEvent(new LoaderEvent(RAW_LOAD,this,"",_content));
         _initted = true;
         _loadingQueue = new com.greensock.loading.cast({
            "name":this.name + "_Queue",
            "maxConnections":UInt(this.vars.maxConnections) || 2,
            "skipFailed":Bool(this.vars.skipFailed != false),
            "skipPaused":Bool(this.vars.skipPaused != false)
         }, LoaderMax);
         _parsed = new com.greensock.loading.cast({
            "name":this.name + "_ParsedLoaders",
            "paused":true
         }, LoaderMax);
         parseLoaders(cast(_content, Xml),_parsed,_loadingQueue);
         if(_parsed.numChildren == 0)
         {
            _parsed.dispose(false);
            _parsed = null;
         }
         else if("recursivePrependURLs" in this.vars)
         {
            _parsed.prependURLs(this.vars.recursivePrependURLs,true);
            loaders = _parsed.getChildren(true,true);
            i = loaders.length;
            while(--i > -1)
            {
               if(Std.is(loaders[i], XMLLoader))
               {
                  loaders[i].vars.recursivePrependURLs = this.vars.recursivePrependURLs;
               }
            }
         }
         else if("prependURLs" in this.vars)
         {
            _parsed.prependURLs(this.vars.prependURLs,true);
         }
         if(_loadingQueue.getChildren(true,true).length == 0)
         {
            _loadingQueue.empty(false);
            _loadingQueue.dispose(false);
            _loadingQueue = null;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT,this,"",_content));
         }
         else
         {
            _cacheIsDirty = true;
            _changeQueueListeners(true);
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT,this,"",_content));
            _loadingQueue.load(false);
         }
         if(cast(_loadingQueue == null, Bool) || cast(this.vars.integrateProgress == false, Bool))
         {
            _completeHandler(event);
         }
      }
      
      private function _changeQueueListeners(add:Bool) : Void
      {
         var p:Dynamic = null;
         if(_loadingQueue != null)
         {
            if(cast(add, Bool) && cast(this.vars.integrateProgress != false, Bool))
            {
               for(p in _listenerTypes)
               {
                  if(cast(p != "onProgress", Bool) && cast(p != "onInit", Bool))
                  {
                     _loadingQueue.addEventListener(_listenerTypes[p],_passThroughEvent,false,-100,true);
                  }
               }
               _loadingQueue.addEventListener(LoaderEvent.COMPLETE,_completeHandler,false,-100,true);
               _loadingQueue.addEventListener(LoaderEvent.PROGRESS,_progressHandler,false,-100,true);
               _loadingQueue.addEventListener(LoaderEvent.FAIL,_failHandler,false,-100,true);
            }
            else
            {
               _loadingQueue.removeEventListener(LoaderEvent.COMPLETE,_completeHandler);
               _loadingQueue.removeEventListener(LoaderEvent.PROGRESS,_progressHandler);
               _loadingQueue.removeEventListener(LoaderEvent.FAIL,_failHandler);
               for(p in _listenerTypes)
               {
                  if(cast(p != "onProgress", Bool) && cast(p != "onInit", Bool))
                  {
                     _loadingQueue.removeEventListener(_listenerTypes[p],_passThroughEvent);
                  }
               }
            }
         }
      }
      
      override private function _progressHandler(event:Event) : Void
      {
         var bl:UInt = 0;
         var bt:UInt = 0;
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
