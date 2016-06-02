package com.greensock.loading.core;
   import flash.net.URLStream;
   import flash.events.Event;
   import flash.net.URLRequest;
   import com.greensock.events.LoaderEvent;
   import flash.events.ProgressEvent;
   import com.greensock.loading.LoaderStatus;
   import flash.net.URLVariables;
   
   [cast(name="ioError",type="com.greensock.events.LoaderEvent", Event)]
   class LoaderItem extends LoaderCore
   {

		public var scriptAccessDenied(get, null):Bool;
		public var request(get, null):URLRequest;
		public var httpStatus(get, null):Int;
		public var url(get, set):String;

      
      private static var _cacheID:Float = new Date().getTime();
       
      private var _auditStream:URLStream;
      
      private var _request:URLRequest;
      
      private var _skipAlternateURL:Bool;
      
      private var _scriptAccessDenied:Bool;
      
      private var _url:String;
      
      private var _preferEstimatedBytesInAudit:Bool;
      
      private var _httpStatus:Int;
      
      public function new(urlOrRequest:Dynamic, vars:Object = null)
      {
         super(vars);
         _request =cast(Std.is( urlOrRequest, URLRequest?urlOrRequest), URLRequest:new URLRequest(urlOrRequest));
         _url = _request.url;
         _setRequestURL(_request,_url);
      }
      
      public  function get_scriptAccessDenied()
      {
         return _scriptAccessDenied;
      }
      
      override private function _failHandler(event:Event, dispatchError:Bool = true) : Void
      {
         if(cast(this.vars.alternateURL != undefined, Bool) && cast(this.vars.alternateURL != "", Bool) && cast(!_skipAlternateURL, Bool))
         {
            _errorHandler(event);
            _skipAlternateURL = true;
            _url = "temp" + Math.random();
            this.url = this.vars.alternateURL;
         }
         else
         {
            super._failHandler(event,dispatchError);
         }
      }
      
      public  function get_request()
      {
         return _request;
      }
      
      private function _httpStatusHandler(event:Event) : Void
      {
         _httpStatus = (cast(event, Object)).status;
         dispatchEvent(new LoaderEvent(LoaderEvent.HTTP_STATUS,this));
      }
      
      override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         _closeStream();
         super._dump(scrubLevel,newStatus,suppressEvents);
      }
      
      private function _closeStream() : Void
      {
         if(_auditStream != null)
         {
            _auditStream.removeEventListener(ProgressEvent.PROGRESS,_auditStreamHandler);
            _auditStream.removeEventListener(Event.COMPLETE,_auditStreamHandler);
            _auditStream.removeEventListener("ioError",_auditStreamHandler);
            _auditStream.removeEventListener("securityError",_auditStreamHandler);
            try
            {
               _auditStream.close();
            }
            catch(error:Error)
            {
            }
            _auditStream = null;
         }
      }
      
      public  function set_url(value)
      {
         var isLoading:Bool = false;
         if(_url != value)
         {
            _url = value;
            _setRequestURL(_request,_url);
            isLoading = cast(_status == LoaderStatus.LOADING, Bool);
            _dump(1,LoaderStatus.READY,true);
            if(isLoading)
            {
               _load();
            }
         }
      }
      
      public  function get_httpStatus()
      {
         return _httpStatus;
      }
      
      private function _prepRequest() : Void
      {
         _scriptAccessDenied = false;
         _httpStatus = 0;
         _closeStream();
         if(cast(this.vars.noCache, Bool) && (cast(!_isLocal, Bool) || cast(_url.substr(0,4) == "http", Bool)))
         {
            _setRequestURL(_request,_url,"gsCacheBusterID=" + _cacheID++);
         }
      }
      
      private function _setRequestURL(request:URLRequest, url:String, extraParams:String = "") : Void
      {
         var data:URLVariables = null;
         var pair:Array<Int> = null;
         var a:Array<Int> = cast(this.vars.allowMalformedURL, Bool)?[url]:url.split("?");
         var s:String = a[0];
         var parsedURL:String = "";
         for( i in 0...s.length )
         {
            parsedURL = parsedURL + s.charAt(i);
         }
         request.url = parsedURL;
         if(a.length >= 2)
         {
            extraParams = extraParams + (extraParams == ""?a[1]:"&" + a[1]);
         }
         if(extraParams != "")
         {
            data =cast(Std.is( request.data, URLVariables?request.data), URLVariables:new URLVariables());
            a = extraParams.split("&");
            i = a.length;
            while(--i > -1)
            {
               pair = a[i].split("=");
               data[pair.shift()] = pair.join("=");
            }
            request.data = data;
         }
      }
      
      private function _auditStreamHandler(event:Event) : Void
      {
         var request:URLRequest = null;
         if(Std.is(event, ProgressEvent))
         {
            _cachedBytesTotal = (cast(event, ProgressEvent)).bytesTotal;
            if(cast(_preferEstimatedBytesInAudit, Bool) && cast(UInt(this.vars.estimatedBytes) > _cachedBytesTotal, Bool))
            {
               _cachedBytesTotal = cast(this.vars.estimatedBytes, UInt);
            }
         }
         else if(cast(event.type == "ioError", Bool) || cast(event.type == "securityError", Bool))
         {
            if(cast(this.vars.alternateURL != undefined, Bool) && cast(this.vars.alternateURL != "", Bool) && cast(this.vars.alternateURL != _url, Bool))
            {
               _errorHandler(event);
               if(_status != LoaderStatus.DISPOSED)
               {
                  _url = this.vars.alternateURL;
                  _setRequestURL(_request,_url);
                  request = new URLRequest();
                  request.data = _request.data;
                  request.method = _request.method;
                  _setRequestURL(request,_url,cast(!_isLocal, Bool) || cast(_url.substr(0,4) == "http", Bool)?"gsCacheBusterID=" + _cacheID++ + "&purpose=audit":"");
                  _auditStream.load(request);
               }
               return;
            }
            super._failHandler(event);
         }
         _auditedSize = true;
         _closeStream();
         dispatchEvent(new Event("auditedSize"));
      }
      
      public  function get_url()
      {
         return _url;
      }
      
      override public function auditSize() : Void
      {
         var request:URLRequest = null;
         if(_auditStream == null)
         {
            _auditStream = new URLStream();
            _auditStream.addEventListener(ProgressEvent.PROGRESS,_auditStreamHandler,false,0,true);
            _auditStream.addEventListener(Event.COMPLETE,_auditStreamHandler,false,0,true);
            _auditStream.addEventListener("ioError",_auditStreamHandler,false,0,true);
            _auditStream.addEventListener("securityError",_auditStreamHandler,false,0,true);
            request = new URLRequest();
            request.data = _request.data;
            request.method = _request.method;
            _setRequestURL(request,_url,cast(!_isLocal, Bool) || cast(_url.substr(0,4) == "http", Bool)?"gsCacheBusterID=" + _cacheID++ + "&purpose=audit":"");
            _auditStream.load(request);
         }
      }
   }
