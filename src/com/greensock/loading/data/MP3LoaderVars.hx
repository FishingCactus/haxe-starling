package com.greensock.loading.data;
   import flash.display.DisplayObject;
   import flash.media.SoundLoaderContext;
   
   class MP3LoaderVars
   {

		public var vars(get, null):Object;
		public var isGSVars(get, null):Bool;

      
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
      
      public function onCancel(value:Function) : MP3LoaderVars
      {
         return _set("onCancel",value);
      }
      
      public function noCache(value:Bool) : MP3LoaderVars
      {
         return _set("noCache",value);
      }
      
      public function autoPlay(value:Bool) : MP3LoaderVars
      {
         return _set("autoPlay",value);
      }
      
      public  function get_vars()
      {
         return _vars;
      }
      
      public function onOpen(value:Function) : MP3LoaderVars
      {
         return _set("onOpen",value);
      }
      
      public function onIOError(value:Function) : MP3LoaderVars
      {
         return _set("onIOError",value);
      }
      
      public function requireWithRoot(value:DisplayObject) : MP3LoaderVars
      {
         return _set("requireWithRoot",value);
      }
      
      public function estimatedBytes(value:UInt) : MP3LoaderVars
      {
         return _set("estimatedBytes",value);
      }
      
      public function name(value:String) : MP3LoaderVars
      {
         return _set("name",value);
      }
      
      public function alternateURL(value:String) : MP3LoaderVars
      {
         return _set("alternateURL",value);
      }
      
      public function volume(value:Float) : MP3LoaderVars
      {
         return _set("volume",value);
      }
      
      public function repeat(value:Int) : MP3LoaderVars
      {
         return _set("repeat",value);
      }
      
      public function allowMalformedURL(value:Bool) : MP3LoaderVars
      {
         return _set("allowMalformedURL",value);
      }
      
      public  function get_isGSVars()
      {
         return true;
      }
      
      private function _set(property:String, value:Dynamic) : MP3LoaderVars
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
      
      public function onFail(value:Function) : MP3LoaderVars
      {
         return _set("onFail",value);
      }
      
      public function onError(value:Function) : MP3LoaderVars
      {
         return _set("onError",value);
      }
      
      public function prop(property:String, value:Dynamic) : MP3LoaderVars
      {
         return _set(property,value);
      }
      
      public function onProgress(value:Function) : MP3LoaderVars
      {
         return _set("onProgress",value);
      }
      
      public function context(value:SoundLoaderContext) : MP3LoaderVars
      {
         return _set("context",value);
      }
      
      public function autoDispose(value:Bool) : MP3LoaderVars
      {
         return _set("autoDispose",value);
      }
      
      public function onComplete(value:Function) : MP3LoaderVars
      {
         return _set("onComplete",value);
      }
      
      public function onHTTPStatus(value:Function) : MP3LoaderVars
      {
         return _set("onHTTPStatus",value);
      }
      
      public function initThreshold(value:UInt) : MP3LoaderVars
      {
         return _set("initThreshold",value);
      }
   }
