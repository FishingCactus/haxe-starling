package com.greensock.loading.data;
   import flash.display.DisplayObject;
   
   class DataLoaderVars
   {

		public var isGSVars(get, null):Bool;
		public var vars(get, null):Object;

      
      public static inline var version:Float = 1.2;
       
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
      
      public function onHTTPStatus(value:Function) : DataLoaderVars
      {
         return _set("onHTTPStatus",value);
      }
      
      public function onOpen(value:Function) : DataLoaderVars
      {
         return _set("onOpen",value);
      }
      
      public  function get_isGSVars()
      {
         return true;
      }
      
      private function _set(property:String, value:Dynamic) : DataLoaderVars
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
      
      public function allowMalformedURL(value:Bool) : DataLoaderVars
      {
         return _set("allowMalformedURL",value);
      }
      
      public function noCache(value:Bool) : DataLoaderVars
      {
         return _set("noCache",value);
      }
      
      public function onError(value:Function) : DataLoaderVars
      {
         return _set("onError",value);
      }
      
      public function prop(property:String, value:Dynamic) : DataLoaderVars
      {
         return _set(property,value);
      }
      
      public function onProgress(value:Function) : DataLoaderVars
      {
         return _set("onProgress",value);
      }
      
      public function requireWithRoot(value:DisplayObject) : DataLoaderVars
      {
         return _set("requireWithRoot",value);
      }
      
      public  function get_vars()
      {
         return _vars;
      }
      
      public function estimatedBytes(value:UInt) : DataLoaderVars
      {
         return _set("estimatedBytes",value);
      }
      
      public function autoDispose(value:Bool) : DataLoaderVars
      {
         return _set("autoDispose",value);
      }
      
      public function name(value:String) : DataLoaderVars
      {
         return _set("name",value);
      }
      
      public function alternateURL(value:String) : DataLoaderVars
      {
         return _set("alternateURL",value);
      }
      
      public function format(value:String) : DataLoaderVars
      {
         return _set("format",value);
      }
      
      public function onComplete(value:Function) : DataLoaderVars
      {
         return _set("onComplete",value);
      }
      
      public function onCancel(value:Function) : DataLoaderVars
      {
         return _set("onCancel",value);
      }
      
      public function onIOError(value:Function) : DataLoaderVars
      {
         return _set("onIOError",value);
      }
      
      public function onFail(value:Function) : DataLoaderVars
      {
         return _set("onFail",value);
      }
   }
