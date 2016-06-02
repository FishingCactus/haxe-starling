package com.greensock.loading.display;
   import mx.core.UIComponent;
   import com.greensock.loading.core.LoaderItem;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Rectangle;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.media.Video;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   
   class FlexContentDisplay extends UIComponent
   {

		public var scaleMode(get, set):String;
		public var crop(get, set):Bool;
		public var loader(get, set):LoaderItem;
		public var fitHeight(get, set):Float;
		public var bgAlpha(get, set):Float;
		public var bgColor(get, set):UInt;
		public var centerRegistration(get, set):Bool;
		public var fitWidth(get, set):Float;
		public var vAlign(get, set):String;
		public var hAlign(get, set):String;
		public var rawContent(null, set):Dynamic;

      
      private static var _transformProps:Object = {
         "x":1,
         "y":1,
         "z":1,
         "rotationX":1,
         "rotationY":1,
         "rotationZ":1,
         "scaleX":1,
         "scaleY":1,
         "rotation":1,
         "alpha":1,
         "visible":true,
         "blendMode":"normal",
         "centerRegistration":false,
         "crop":false,
         "scaleMode":"stretch",
         "hAlign":"center",
         "vAlign":"center"
      };
       
      private var _scaleMode:String = "stretch";
      
      private var _fitWidth:Float;
      
      private var _hAlign:String = "center";
      
      private var _fitHeight:Float;
      
      public var data;
      
      private var _loader:LoaderItem;
      
      private var _nativeRect:Rectangle;
      
      private var _centerRegistration:Bool;
      
      private var _vAlign:String = "center";
      
      private var _rawContent:DisplayObject;
      
      private var _cropContainer:Sprite;
      
      public var gcProtect;
      
      private var _bgAlpha:Float = 0;
      
      private var _bgColor:UInt;
      
      private var _crop:Bool;
      
      public function new(loader:LoaderItem)
      {
         super();
         this.loader = loader;
      }
      
      public  function get_scaleMode()
      {
         return _scaleMode;
      }
      
      public  function get_crop()
      {
         return _crop;
      }
      
      public  function get_loader()
      {
         return _loader;
      }
      
      public  function get_fitHeight()
      {
         return _fitHeight;
      }
      
      public  function get_bgAlpha()
      {
         return _bgAlpha;
      }
      
      public  function get_bgColor()
      {
         return _bgColor;
      }
      
      public function dispose(unloadLoader:Bool = true, disposeLoader:Bool = true) : Void
      {
         if(this.parent != null)
         {
            if(this.parent.hasOwnProperty("removeElement"))
            {
               (cast(this.parent, Object)).removeElement(this);
            }
            else
            {
               this.parent.removeChild(this);
            }
         }
         this.rawContent = null;
         this.gcProtect = null;
         _cropContainer = null;
         if(_loader != null)
         {
            if(unloadLoader)
            {
               _loader.unload();
            }
            if(disposeLoader)
            {
               _loader.dispose(false);
               _loader = null;
            }
         }
      }
      
      public  function set_scaleMode(value)
      {
         if(_rawContent != null)
         {
            _rawContent.scaleX = _rawContent.scaleY = 1;
         }
         _scaleMode = value;
         _update();
      }
      
      public  function set_loader(value)
      {
         var type:String = null;
         var p:Dynamic = null;
         _loader = value;
         if(value == null)
         {
            return;
         }
         if(!_loader.hasOwnProperty("setContentDisplay"))
         {
            throw new Error("Incompatible loader used for a FlexContentDisplay");
         }
         this.name = _loader.name;
         for(p in _transformProps)
         {
            if(p in _loader.vars)
            {
               type = typeof _transformProps[p];
               this[p] = type == "number"?cast(_loader.vars[p], Float):type == "string"?cast(_loader.vars[p], String):cast(_loader.vars[p], Bool);
            }
         }
         _bgColor = cast(_loader.vars.bgColor, UInt);
         _bgAlpha = "bgAlpha" in _loader.vars?cast(Float(_loader.vars.bgAlpha), Float):"bgColor" in _loader.vars?cast(1, Float):cast(0, Float);
         _fitWidth = "fitWidth" in _loader.vars?cast(Float(_loader.vars.fitWidth), Float):cast(Float(_loader.vars.width), Float);
         _fitHeight = "fitHeight" in _loader.vars?cast(Float(_loader.vars.fitHeight), Float):cast(Float(_loader.vars.height), Float);
         _update();
         if(Std.is(_loader.vars.container, DisplayObjectContainer))
         {
            if(_loader.vars.container.hasOwnProperty("addElement"))
            {
               (cast(_loader.vars.container, Object)).addElement(this);
            }
            else
            {
               (cast(_loader.vars.container, DisplayObjectContainer)).addChild(this);
            }
         }
         if(_loader.content != this)
         {
            (cast(_loader, Object)).setContentDisplay(this);
         }
         this.rawContent = (cast(_loader, Object)).rawContent;
      }
      
      public  function get_centerRegistration()
      {
         return _centerRegistration;
      }
      
      public  function set_crop(value)
      {
         _crop = value;
         _update();
      }
      
      public  function set_fitHeight(value)
      {
         _fitHeight = value;
         _update();
      }
      
      public function get rawContent() : *
      {
         return _rawContent;
      }
      
      public  function get_fitWidth()
      {
         return _fitWidth;
      }
      
      public  function get_vAlign()
      {
         return _vAlign;
      }
      
      public  function set_bgColor(value)
      {
         _bgColor = value;
         _update();
      }
      
      public  function set_bgAlpha(value)
      {
         _bgAlpha = value;
         _update();
      }
      
      public  function set_centerRegistration(value)
      {
         _centerRegistration = value;
         _update();
      }
      
      public  function set_rawContent(value)
      {
         if(cast(_rawContent != null, Bool) && cast(_rawContent != value, Bool))
         {
            if(_rawContent.parent == this)
            {
               removeChild(_rawContent);
            }
            else if(cast(_cropContainer != null, Bool) && cast(_rawContent.parent == _cropContainer, Bool))
            {
               _cropContainer.removeChild(_rawContent);
               removeChild(_cropContainer);
               _cropContainer = null;
            }
         }
         _rawContent =cast( value, DisplayObject);
         if(_rawContent == null)
         {
            return;
         }
         if(cast(_rawContent.parent == null, Bool) || cast(_rawContent.parent != this, Bool) && cast(_rawContent.parent != _cropContainer, Bool))
         {
            addChildAt(cast(_rawContent, DisplayObject),0);
         }
         _nativeRect = new Rectangle(0,0,_rawContent.width,_rawContent.height);
         _update();
      }
      
      override private function measure() : Void
      {
         var bounds:Rectangle = null;
         if(this.parent)
         {
            bounds = this.getBounds(this.parent);
            this.width = bounds.width;
            this.height = bounds.height;
         }
         bounds = this.getBounds(this);
         this.explicitWidth = bounds.width;
         this.explicitHeight = bounds.height;
         super.measure();
      }
      
      private function _update() : Void
      {
         var mc:DisplayObject = null;
         var nativeBounds:Object = null;
         var contentWidth:Float = NaN;
         var contentHeight:Float = NaN;
         var w:Float = NaN;
         var h:Float = NaN;
         var wGap:Float = NaN;
         var hGap:Float = NaN;
         var displayRatio:Float = NaN;
         var contentRatio:Float = NaN;
         var left:Float = cast(_centerRegistration, Bool) && cast(_fitWidth > 0, Bool)?cast(_fitWidth / -2, Float):cast(0, Float);
         var top:Float = cast(_centerRegistration, Bool) && cast(_fitHeight > 0, Bool)?cast(_fitHeight / -2, Float):cast(0, Float);
         graphics.clear();
         if(cast(_fitWidth > 0, Bool) && cast(_fitHeight > 0, Bool))
         {
            graphics.beginFill(_bgColor,_bgAlpha);
            graphics.drawRect(left,top,_fitWidth,_fitHeight);
            graphics.endFill();
         }
         if(_rawContent == null)
         {
            measure();
            return;
         }
         mc = _rawContent;
         var m:Matrix = mc.transform.matrix;
         if(Std.is(mc, Video))
         {
            nativeBounds = _nativeRect;
            contentWidth = mc.width;
            contentHeight = mc.height;
         }
         else
         {
            if(Std.is(mc, Loader))
            {
               nativeBounds = cast(mc, Loader).contentLoaderInfo;
            }
            else if(cast(_loader != null, Bool) && cast(_loader.hasOwnProperty("getClass"), Bool))
            {
               nativeBounds = mc.loaderInfo;
            }
            else
            {
               nativeBounds = mc.getBounds(mc);
            }
            if(cast(Std.is(nativeBounds, LoaderInfo), Bool) && cast(_loader != null, Bool) && cast(_loader.progress < 1, Bool))
            {
               try
               {
                  contentWidth = nativeBounds.width;
               }
               catch(error:Error)
               {
                  nativeBounds = mc.getBounds(mc);
               }
            }
            contentWidth = nativeBounds.width * Math.abs(m.a) + nativeBounds.height * Math.abs(m.b);
            contentHeight = nativeBounds.width * Math.abs(m.c) + nativeBounds.height * Math.abs(m.d);
         }
         if(cast(_fitWidth > 0, Bool) && cast(_fitHeight > 0, Bool))
         {
            w = _fitWidth;
            h = _fitHeight;
            wGap = w - contentWidth;
            hGap = h - contentHeight;
            if(_scaleMode != "none")
            {
               displayRatio = w / h;
               contentRatio = nativeBounds.width / nativeBounds.height;
               if(cast(contentRatio < displayRatio, Bool) && cast(_scaleMode == "proportionalInside", Bool) || cast(contentRatio > displayRatio, Bool) && cast(_scaleMode == "proportionalOutside", Bool))
               {
                  w = h * contentRatio;
               }
               if(cast(contentRatio > displayRatio, Bool) && cast(_scaleMode == "proportionalInside", Bool) || cast(contentRatio < displayRatio, Bool) && cast(_scaleMode == "proportionalOutside", Bool))
               {
                  h = w / contentRatio;
               }
               if(_scaleMode != "heightOnly")
               {
                  mc.width = mc.width * (w / contentWidth);
                  wGap = _fitWidth - w;
               }
               if(_scaleMode != "widthOnly")
               {
                  mc.height = mc.height * (h / contentHeight);
                  hGap = _fitHeight - h;
               }
            }
            if(_hAlign == "left")
            {
               wGap = 0;
            }
            else if(_hAlign != "right")
            {
               wGap = wGap / 2;
            }
            if(_vAlign == "top")
            {
               hGap = 0;
            }
            else if(_vAlign != "bottom")
            {
               hGap = hGap / 2;
            }
            if(_crop)
            {
               if(cast(_cropContainer == null, Bool) || cast(mc.parent != _cropContainer, Bool))
               {
                  _cropContainer = new Sprite();
                  this.addChildAt(_cropContainer,this.getChildIndex(mc));
                  _cropContainer.addChild(mc);
               }
               _cropContainer.x = left;
               _cropContainer.y = top;
               _cropContainer.scrollRect = new Rectangle(0,0,_fitWidth,_fitHeight);
               mc.x = wGap;
               mc.y = hGap;
            }
            else
            {
               if(_cropContainer != null)
               {
                  this.addChildAt(mc,this.getChildIndex(_cropContainer));
                  _cropContainer = null;
               }
               mc.x = left + wGap;
               mc.y = top + hGap;
            }
         }
         else
         {
            mc.x = !!_centerRegistration?cast(contentWidth / -2, Float):cast(0, Float);
            mc.y = !!_centerRegistration?cast(contentHeight / -2, Float):cast(0, Float);
         }
         measure();
      }
      
      public  function set_fitWidth(value)
      {
         _fitWidth = value;
         _update();
      }
      
      public  function set_vAlign(value)
      {
         _vAlign = value;
         _update();
      }
      
      public  function set_hAlign(value)
      {
         _hAlign = value;
         _update();
      }
      
      public  function get_hAlign()
      {
         return _hAlign;
      }
   }
