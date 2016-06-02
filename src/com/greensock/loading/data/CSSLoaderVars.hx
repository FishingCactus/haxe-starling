package com.greensock.loading.data;
   import flash.display.DisplayObject;
   
   class CSSLoaderVars
   {

		public var isGSVars(get, null):Bool;
		public var vars(get, null):Dynamic;

      
      public static inline var version:Float = 1.2;
       
      private var _vars:Dynamic;
      
      public function new(vars:Dynamic = null)
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
      
      public function onHTTPStatus(value:Function) : CSSLoaderVars
      {
         return _set("onHTTPStatus",value);
      }
      
      public function onOpen(value:Function) : CSSLoaderVars
      {
         return _set("onOpen",value);
      }
      
      public  function get_isGSVars()
      {
         return true;
      }
      
      private function _set(property:String, value:Dynamic) : CSSLoaderVars
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
      
      public function allowMalformedURL(value:Bool) : CSSLoaderVars
      {
         return _set("allowMalformedURL",value);
      }
      
      public function noCache(value:Bool) : CSSLoaderVars
      {
         return _set("noCache",value);
      }
      
      public function onError(value:Function) : CSSLoaderVars
      {
         return _set("onError",value);
      }
      
      public function prop(property:String, value:Dynamic) : CSSLoaderVars
      {
         return _set(property,value);
      }
      
      public function onProgress(value:Function) : CSSLoaderVars
      {
         return _set("onProgress",value);
      }
      
      public function requireWithRoot(value:DisplayObject) : CSSLoaderVars
      {
         return _set("requireWithRoot",value);
      }
      
      public  function get_vars()
      {
         return _vars;
      }
      
      public function estimatedBytes(value:UInt) : CSSLoaderVars
      {
         return _set("estimatedBytes",value);
      }
      
      public function autoDispose(value:Bool) : CSSLoaderVars
      {
         return _set("autoDispose",value);
      }
      
      public function name(value:String) : CSSLoaderVars
      {
         return _set("name",value);
      }
      
      public function alternateURL(value:String) : CSSLoaderVars
      {
         return _set("alternateURL",value);
      }
      
      public function onComplete(value:Function) : CSSLoaderVars
      {
         return _set("onComplete",value);
      }
      
      public function onCancel(value:Function) : CSSLoaderVars
      {
         return _set("onCancel",value);
      }
      
      public function onIOError(value:Function) : CSSLoaderVars
      {
         return _set("onIOError",value);
      }
      
      public function onFail(value:Function) : CSSLoaderVars
      {
         return _set("onFail",value);
      }
   }
