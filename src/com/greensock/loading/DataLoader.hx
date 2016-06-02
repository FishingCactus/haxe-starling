package com.greensock.loading;
   import com.greensock.loading.core.LoaderItem;
   import flash.net.URLLoader;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   
   [cast(name="securityError",type="com.greensock.events.LoaderEvent", Event)]
   [cast(name="httpStatus",type="com.greensock.events.LoaderEvent", Event)]
   class DataLoader extends LoaderItem
   {
      
      private static var _classActivated:Bool = _activateClass("DataLoader",DataLoader,"txt,js");
       
      private var _loader:URLLoader;
      
      public function new(urlOrRequest:Dynamic, vars:Dynamic = null)
      {
         super(urlOrRequest,vars);
         _type = "DataLoader";
         _loader = new URLLoader(null);
         if("format" in this.vars)
         {
            _loader.dataFormat = cast(this.vars.format, String);
         }
         _loader.addEventListener(ProgressEvent.PROGRESS,_progressHandler,false,0,true);
         _loader.addEventListener(Event.COMPLETE,_receiveDataHandler,false,0,true);
         _loader.addEventListener("ioError",_failHandler,false,0,true);
         _loader.addEventListener("securityError",_failHandler,false,0,true);
         _loader.addEventListener("httpStatus",_httpStatusHandler,false,0,true);
      }
      
      override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         if(_status == LoaderStatus.LOADING)
         {
            try
            {
               _loader.close();
            }
            catch(error:Error)
            {
            }
         }
         super._dump(scrubLevel,newStatus,suppressEvents);
      }
      
      override private function _load() : Void
      {
         _prepRequest();
         _loader.load(_request);
      }
      
      private function _receiveDataHandler(event:Event) : Void
      {
         _content = _loader.data;
         super._completeHandler(event);
      }
   }
