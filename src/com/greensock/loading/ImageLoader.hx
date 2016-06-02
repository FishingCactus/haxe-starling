package com.greensock.loading;
   import com.greensock.loading.core.DisplayObjectLoader;
   import flash.events.Event;
   import flash.display.Bitmap;
   import com.greensock.loading.core.LoaderItem;
   import flash.display.DisplayObject;
   import flash.events.ProgressEvent;
   import com.greensock.events.LoaderEvent;
   
   class ImageLoader extends DisplayObjectLoader
   {
      
      private static var _classActivated:Bool = _activateClass("ImageLoader",ImageLoader,"jpg,jpeg,png,gif,bmp");
       
      public function new(urlOrRequest:Dynamic, vars:Object = null)
      {
         super(urlOrRequest,vars);
         _type = "ImageLoader";
      }
      
      override private function _initHandler(event:Event) : Void
      {
         _determineScriptAccess();
         if(!_scriptAccessDenied)
         {
            _content = cast(_loader.content, Bitmap);
            _content.smoothing = cast(this.vars.smoothing != false, Bool);
         }
         else
         {
            _content = _loader;
         }
         super._initHandler(event);
      }
      
      override private function _load() : Void
      {
         var loaders:Array<Int> = null;
         var loader:LoaderItem = null;
         var i:Int = 0;
         if(this.vars.noCache != true)
         {
            loaders = _globalRootLoader.getChildren(true,true);
            i = loaders.length;
            while(--i > -1)
            {
               loader = loaders[i];
               if(cast(loader.url == _url, Bool) && cast(loader != this, Bool) && cast(loader.status == LoaderStatus.COMPLETED, Bool) && cast(Std.is(loader, ImageLoader), Bool) && cast(Std.is(ImageLoader(loader).rawContent, Bitmap), Bool))
               {
                  _closeStream();
                  _content = new Bitmap(cast(loader, ImageLoader).rawContent.bitmapData,"auto",cast(this.vars.smoothing != false, Bool));
                  cast(_sprite, Object).rawContent =cast( _content, DisplayObject);
                  _initted = true;
                  _progressHandler(new ProgressEvent(ProgressEvent.PROGRESS,false,false,loader.bytesLoaded,loader.bytesTotal));
                  dispatchEvent(new LoaderEvent(LoaderEvent.INIT,this));
                  _completeHandler(null);
                  return;
               }
            }
         }
         super._load();
      }
   }
