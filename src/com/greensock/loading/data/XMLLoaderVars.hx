package com.greensock.loading.data;
   import flash.display.DisplayObject;
   
   class XMLLoaderVars
   {

		public var vars(get, null):Object;
		public var isGSVars(get, null):Bool;

      
      public static inline var version:Float = 1.22;
       
      private var _vars:Object;
      
      public function new(vars:Object = null)
      {
         var p:Dynamic = null;
         super();
         _vars = {};
         if(vars != null)
         {
            for(p in vars)
            {
               _vars[p] = vars[p];
            }
         }
      }
      
      public function onCancel(value:Function) : XMLLoaderVars
      {
         return _set("onCancel",value);
      }
      
      public function noCache(value:Bool) : XMLLoaderVars
      {
         return _set("noCache",value);
      }
      
      public function onIOError(value:Function) : XMLLoaderVars
      {
         return _set("onIOError",value);
      }
      
      public  function get_vars()
      {
         return _vars;
      }
      
      public function recursivePrependURLs(value:String) : XMLLoaderVars
      {
         return _set("recursivePrependURLs",value);
      }
      
      public function onOpen(value:Function) : XMLLoaderVars
      {
         return _set("onOpen",value);
      }
      
      public function onChildProgress(value:Function) : XMLLoaderVars
      {
         return _set("onChildProgress",value);
      }
      
      public function requireWithRoot(value:DisplayObject) : XMLLoaderVars
      {
         return _set("requireWithRoot",value);
      }
      
      public function estimatedBytes(value:UInt) : XMLLoaderVars
      {
         return _set("estimatedBytes",value);
      }
      
      public function maxConnections(value:UInt) : XMLLoaderVars
      {
         return _set("maxConnections",value);
      }
      
      public function name(value:String) : XMLLoaderVars
      {
         return _set("name",value);
      }
      
      public function alternateURL(value:String) : XMLLoaderVars
      {
         return _set("alternateURL",value);
      }
      
      public function onChildComplete(value:Function) : XMLLoaderVars
      {
         return _set("onChildComplete",value);
      }
      
      public function onChildCancel(value:Function) : XMLLoaderVars
      {
         return _set("onChildCancel",value);
      }
      
      public function prependURLs(value:String) : XMLLoaderVars
      {
         return _set("prependURLs",value);
      }
      
      public function skipFailed(value:Bool) : XMLLoaderVars
      {
         return _set("skipFailed",value);
      }
      
      public function allowMalformedURL(value:Bool) : XMLLoaderVars
      {
         return _set("allowMalformedURL",value);
      }
      
      public function onInit(value:Function) : XMLLoaderVars
      {
         return _set("onInit",value);
      }
      
      public  function get_isGSVars()
      {
         return true;
      }
      
      private function _set(property:String, value:Dynamic) : XMLLoaderVars
      {
         if(value == null)
         {
            _vars.remove(property);
         }
         else
         {
            _vars[property] = value;
         }
         return this;
      }
      
      public function onFail(value:Function) : XMLLoaderVars
      {
         return _set("onFail",value);
      }
      
      public function onChildOpen(value:Function) : XMLLoaderVars
      {
         return _set("onChildOpen",value);
      }
      
      public function onError(value:Function) : XMLLoaderVars
      {
         return _set("onError",value);
      }
      
      public function prop(property:String, value:Dynamic) : XMLLoaderVars
      {
         return _set(property,value);
      }
      
      public function onProgress(value:Function) : XMLLoaderVars
      {
         return _set("onProgress",value);
      }
      
      public function autoDispose(value:Bool) : XMLLoaderVars
      {
         return _set("autoDispose",value);
      }
      
      public function onRawLoad(value:Function) : XMLLoaderVars
      {
         return _set("onRawLoad",value);
      }
      
      public function onComplete(value:Function) : XMLLoaderVars
      {
         return _set("onComplete",value);
      }
      
      public function onHTTPStatus(value:Function) : XMLLoaderVars
      {
         return _set("onHTTPStatus",value);
      }
      
      public function onChildFail(value:Function) : XMLLoaderVars
      {
         return _set("onChildFail",value);
      }
      
      public function integrateProgress(value:Bool) : XMLLoaderVars
      {
         return _set("integrateProgress",value);
      }
   }
