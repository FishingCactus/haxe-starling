package com.greensock.layout;
   import flash.display.Shape;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   import flash.geom.Matrix;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   
   class AutoFitArea extends Shape
   {

		public var previewColor(get, set):UInt;
		public var preview(get, set):Bool;
		public var width(null, set):Float;
		public var height(null, set):Float;
		public var scaleX(null, set):Float;
		public var scaleY(null, set):Float;
		public var x(null, set):Float;
		public var y(null, set):Float;
		public var rotation(null, set):Float;

      
      private static var _bd:BitmapData;
      
      private static var _rect:Rectangle = new Rectangle(0,0,2800,2800);
      
      private static var _matrix:Matrix = new Matrix();
      
      public static inline var version:Float = 2.54;
       
      private var _height:Float;
      
      private var _width:Float;
      
      private var _preview:Bool;
      
      private var _parent:DisplayObjectContainer;
      
      private var _previewColor:UInt;
      
      private var _tweenMode:Bool;
      
      private var _hasListener:Bool;
      
      private var _rootItem:AutoFitItem;
      
      public function new(parent:DisplayObjectContainer, x:Float = 0, y:Float = 0, width:Float = 100, height:Float = 100, previewColor:UInt = 16711680)
      {
         super();
         super.x = x;
         super.y = y;
         if(parent == null)
         {
            throw new Error("AutoFitArea parent cannot be null");
         }
         _parent = parent;
         _width = width;
         _height = height;
         _redraw(previewColor);
      }
      
      public static function createAround(target:DisplayObject, vars:Object = null, ... args) : AutoFitArea
      {
         if(cast(vars == null, Bool) || cast(typeof vars == "string", Bool))
         {
            vars = {
               "scaleMode":vars || "proportionalInside",
               "hAlign":args[0] || "center",
               "vAlign":args[1] || "center",
               "crop":cast(args[2], Bool),
               "minWidth":args[3] || 0,
               "maxWidth":(!!isNaN(args[4])?999999999:args[4]),
               "minHeight":args[5] || 0,
               "maxHeight":(!!isNaN(args[6])?999999999:args[6]),
               "calculateVisible":cast(args[8], Bool)
            };
         }
         var boundsTarget:DisplayObject =Std.is( vars.customBoundsTarget, DisplayObject?vars.customBoundsTarget:target);
         var previewColor:UInt = !!isNaN(args[7])?"previewColor" in vars?cast(UInt(vars.previewColor), UInt):cast(16711680, UInt):cast(args[7], UInt);
         var bounds:Rectangle = vars.calculateVisible == true?getVisibleBounds(boundsTarget,target.parent):boundsTarget.getBounds(target.parent);
         var afa:AutoFitArea = new AutoFitArea(target.parent,bounds.x,bounds.y,bounds.width,bounds.height,previewColor);
         afa.attach(target,vars);
         return afa;
      }
      
      private static function getVisibleBounds(target:DisplayObject, targetCoordinateSpace:DisplayObject) : Rectangle
      {
         if(_bd == null)
         {
            _bd = new BitmapData(2800,2800,true,16777215);
         }
         var msk:DisplayObject = target.mask;
         target.mask = null;
         _bd.fillRect(_rect,16777215);
         _matrix.tx = _matrix.ty = 0;
         var offset:Rectangle = target.getBounds(targetCoordinateSpace);
         var m:Matrix = targetCoordinateSpace == target?_matrix:target.transform.matrix;
         m.tx = m.tx - offset.x;
         m.ty = m.ty - offset.y;
         _bd.draw(target,m,null,"normal",_rect,false);
         var bounds:Rectangle = _bd.getColorBoundsRect(4278190080,0,false);
         bounds.x = bounds.x + offset.x;
         bounds.y = bounds.y + offset.y;
         target.mask = msk;
         return bounds;
      }
      
      public  function get_previewColor()
      {
         return _previewColor;
      }
      
      public function attach(target:DisplayObject, vars:Object = null, ... args) : Void
      {
         var shape:Shape = null;
         var bounds:Rectangle = null;
         if(target.parent != _parent)
         {
            throw new Error("The parent of the DisplayObject " + target.name + " added to AutoFitArea " + this.name + " doesn\'t share the same parent.");
         }
         if(cast(vars == null, Bool) || cast(typeof vars == "string", Bool))
         {
            vars = {
               "scaleMode":vars || "proportionalInside",
               "hAlign":args[0] || "center",
               "vAlign":args[1] || "center",
               "crop":cast(args[2], Bool),
               "minWidth":args[3] || 0,
               "maxWidth":(!!isNaN(args[4])?999999999:args[4]),
               "minHeight":args[5] || 0,
               "maxHeight":(!!isNaN(args[6])?999999999:args[6]),
               "calculateVisible":cast(args[7], Bool),
               "customAspectRatio":cast(args[8], Float),
               "roundPosition":cast(args[9], Bool)
            };
         }
         release(target);
         _rootItem = new AutoFitItem(target,vars,_rootItem);
         if(cast(vars != null, Bool) && cast(vars.crop == true, Bool))
         {
            shape = new Shape();
            bounds = this.getBounds(this);
            shape.graphics.beginFill(_previewColor,1);
            shape.graphics.drawRect(bounds.x,bounds.y,bounds.width,bounds.height);
            shape.graphics.endFill();
            shape.visible = false;
            _parent.addChild(shape);
            _rootItem.mask = shape;
            target.mask = shape;
         }
         if(_preview)
         {
            this.preview = true;
         }
         update(null);
      }
      
      public  function get_preview()
      {
         return _preview;
      }
      
      override public function addEventListener(type:String, listener:Function, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void
      {
         _hasListener = true;
         super.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public function update(event:Event = null) : Void
      {
         var w:Float = NaN;
         var h:Float = NaN;
         var tx:Float = NaN;
         var ty:Float = NaN;
         var target:DisplayObject = null;
         var innerBounds:Rectangle = null;
         var outerBounds:Rectangle = null;
         var tRatio:Float = NaN;
         var scaleMode:String = null;
         var ratio:Float = NaN;
         var angle:Float = NaN;
         var sin:Float = NaN;
         var cos:Float = NaN;
         var m:Matrix = null;
         var wScale:Float = NaN;
         var hScale:Float = NaN;
         var mPrev:Matrix = null;
         var width:Float = this.width;
         var height:Float = this.height;
         var x:Float = this.x;
         var y:Float = this.y;
         var matrix:Matrix = this.transform.matrix;
         var item:AutoFitItem = _rootItem;
         while(item)
         {
            target = item.target;
            scaleMode = item.scaleMode;
            if(scaleMode != ScaleMode.NONE)
            {
               if(cast(scaleMode != ScaleMode.HEIGHT_ONLY, Bool) && cast(target.width == 0, Bool))
               {
                  target.width = 1;
               }
               if(cast(scaleMode != ScaleMode.WIDTH_ONLY, Bool) && cast(target.height == 0, Bool))
               {
                  target.height = 1;
               }
               if(item.calculateVisible)
               {
                  innerBounds = item.bounds = getVisibleBounds(item.boundsTarget,target);
                  outerBounds = getVisibleBounds(item.boundsTarget,_parent);
               }
               else
               {
                  innerBounds = item.boundsTarget.getBounds(target);
                  outerBounds = item.boundsTarget.getBounds(_parent);
               }
               tRatio = !!item.hasCustomRatio?cast(item.aspectRatio, Float):cast(innerBounds.width / innerBounds.height, Float);
               m = target.transform.matrix;
               if(cast(m.b != 0, Bool) || cast(m.a == 0, Bool) || cast(m.d == 0, Bool))
               {
                  if(cast(m.a == 0, Bool) || cast(m.d == 0, Bool))
                  {
                     m = target.transform.matrix = item.matrix;
                  }
                  else
                  {
                     mPrev = item.matrix;
                     mPrev.a = m.a;
                     mPrev.b = m.b;
                     mPrev.c = m.c;
                     mPrev.d = m.d;
                     mPrev.tx = m.tx;
                     mPrev.ty = m.ty;
                  }
                  angle = Math.atan2(m.b,m.a);
                  if(cast(m.a < 0, Bool) && cast(m.d >= 0, Bool))
                  {
                     if(angle <= 0)
                     {
                        angle = angle + Math.PI;
                     }
                     else
                     {
                        angle = angle - Math.PI;
                     }
                  }
                  sin = Math.sin(angle);
                  if(sin < 0)
                  {
                     sin = -sin;
                  }
                  cos = Math.cos(angle);
                  if(cos < 0)
                  {
                     cos = -cos;
                  }
                  tRatio = (tRatio * cos + sin) / (tRatio * sin + cos);
               }
               w = width > item.maxWidth?cast(item.maxWidth, Float):width < item.minWidth?cast(item.minWidth, Float):cast(width, Float);
               h = height > item.maxHeight?cast(item.maxHeight, Float):height < item.minHeight?cast(item.minHeight, Float):cast(height, Float);
               ratio = w / h;
               if(cast(tRatio < ratio, Bool) && cast(scaleMode == ScaleMode.PROPORTIONAL_INSIDE, Bool) || cast(tRatio > ratio, Bool) && cast(scaleMode == ScaleMode.PROPORTIONAL_OUTSIDE, Bool))
               {
                  w = h * tRatio;
                  if(w == 0)
                  {
                     h = 0;
                  }
                  else if(w > item.maxWidth)
                  {
                     w = item.maxWidth;
                     h = w / tRatio;
                  }
                  else if(w < item.minWidth)
                  {
                     w = item.minWidth;
                     h = w / tRatio;
                  }
               }
               if(cast(tRatio > ratio, Bool) && cast(scaleMode == ScaleMode.PROPORTIONAL_INSIDE, Bool) || cast(tRatio < ratio, Bool) && cast(scaleMode == ScaleMode.PROPORTIONAL_OUTSIDE, Bool))
               {
                  h = w / tRatio;
                  if(h > item.maxHeight)
                  {
                     h = item.maxHeight;
                     w = h * tRatio;
                  }
                  else if(h < item.minHeight)
                  {
                     h = item.minHeight;
                     w = h * tRatio;
                  }
               }
               if(cast(w != 0, Bool) && cast(h != 0, Bool))
               {
                  wScale = w / outerBounds.width;
                  hScale = h / outerBounds.height;
               }
               else
               {
                  wScale = hScale = 0;
               }
               if(scaleMode != ScaleMode.HEIGHT_ONLY)
               {
                  if(item.calculateVisible)
                  {
                     item.scaleVisibleWidth(wScale);
                  }
                  else if(m.b != 0)
                  {
                     m.a = m.a * wScale;
                     m.c = m.c * wScale;
                     target.transform.matrix = m;
                  }
                  else
                  {
                     target.width = target.width * wScale;
                  }
               }
               if(scaleMode != ScaleMode.WIDTH_ONLY)
               {
                  if(item.calculateVisible)
                  {
                     item.scaleVisibleHeight(hScale);
                  }
                  else if(m.b != 0)
                  {
                     m.d = m.d * hScale;
                     m.b = m.b * hScale;
                     target.transform.matrix = m;
                  }
                  else
                  {
                     target.height = target.height * hScale;
                  }
               }
            }
            if(item.hasDrawNow)
            {
               cast(target, Object).drawNow();
            }
            if(cast(scaleMode != ScaleMode.NONE, Bool) && cast(innerBounds.x == 0, Bool) && cast(innerBounds.y == 0, Bool))
            {
               if(scaleMode != ScaleMode.HEIGHT_ONLY)
               {
                  outerBounds.width = w;
               }
               if(scaleMode != ScaleMode.WIDTH_ONLY)
               {
                  outerBounds.height = h;
               }
            }
            else
            {
               outerBounds = !!item.calculateVisible?getVisibleBounds(item.boundsTarget,_parent):item.boundsTarget.getBounds(_parent);
            }
            tx = target.x;
            ty = target.y;
            if(item.hAlign == AlignMode.LEFT)
            {
               tx = tx + (x - outerBounds.x);
            }
            else if(item.hAlign == AlignMode.CENTER)
            {
               tx = tx + (x - outerBounds.x + (width - outerBounds.width) * 0.5);
            }
            else if(item.hAlign == AlignMode.RIGHT)
            {
               tx = tx + (x - outerBounds.x + (width - outerBounds.width));
            }
            if(item.vAlign == AlignMode.TOP)
            {
               ty = ty + (y - outerBounds.y);
            }
            else if(item.vAlign == AlignMode.CENTER)
            {
               ty = ty + (y - outerBounds.y + (height - outerBounds.height) * 0.5);
            }
            else if(item.vAlign == AlignMode.BOTTOM)
            {
               ty = ty + (y - outerBounds.y + (height - outerBounds.height));
            }
            if(item.roundPosition)
            {
               tx = tx + 0.5 >> 0;
               ty = ty + 0.5 >> 0;
            }
            target.x = tx;
            target.y = ty;
            if(item.mask)
            {
               item.mask.transform.matrix = matrix;
            }
            item = item.next;
         }
         if(_hasListener)
         {
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      override public  function set_width(value)
      {
         super.width = value;
         if(!_tweenMode)
         {
            update();
         }
      }
      
      override public  function set_height(value)
      {
         super.height = value;
         if(!_tweenMode)
         {
            update();
         }
      }
      
      public function release(target:DisplayObject) : Bool
      {
         var item:AutoFitItem = getItem(target);
         if(item == null)
         {
            return false;
         }
         if(item.mask != null)
         {
            if(item.mask.parent)
            {
               item.mask.parent.removeChild(item.mask);
            }
            target.mask = null;
            item.mask = null;
         }
         if(item.next)
         {
            item.next.prev = item.prev;
         }
         if(item.prev)
         {
            item.prev.next = item.next;
         }
         else if(item == _rootItem)
         {
            _rootItem = item.next;
         }
         item.next = item.prev = null;
         item.boundsTarget = null;
         item.target = null;
         return true;
      }
      
      public  function set_preview(value)
      {
         var level:UInt = 0;
         var index:UInt = 0;
         var item:AutoFitItem = null;
         _preview = value;
         if(this.parent == _parent)
         {
            _parent.removeChild(this);
         }
         if(value)
         {
            level = _rootItem == null?cast(0, UInt):cast(999999999, UInt);
            item = _rootItem;
            while(item)
            {
               if(item.target.parent == _parent)
               {
                  index = _parent.getChildIndex(item.target);
                  if(index < level)
                  {
                     level = index;
                  }
               }
               item = item.next;
            }
            _parent.addChildAt(this,level);
            this.visible = true;
         }
      }
      
      public function getAttachedObjects() : Array<Int>
      {
         var a:Array<Int> = [];
         var cnt:UInt = 0;
         var item:AutoFitItem = _rootItem;
         while(item)
         {
            a[cnt++] = item.target;
            item = item.next;
         }
         return a;
      }
      
      override public  function set_scaleX(value)
      {
         super.scaleX = value;
         update();
      }
      
      private function _redraw(color:UInt) : Void
      {
         _previewColor = color;
         var g:Graphics = this.graphics;
         g.clear();
         g.beginFill(_previewColor,1);
         g.drawRect(0,0,_width,_height);
         g.endFill();
      }
      
      private function getItem(target:DisplayObject) : AutoFitItem
      {
         var item:AutoFitItem = _rootItem;
         while(item)
         {
            if(item.target == target)
            {
               return item;
            }
            item = item.next;
         }
         return null;
      }
      
      public function disableTweenMode() : Void
      {
         _tweenMode = false;
      }
      
      public function enableTweenMode() : Void
      {
         _tweenMode = true;
      }
      
      override public  function set_scaleY(value)
      {
         super.scaleY = value;
         update();
      }
      
      override public  function set_x(value)
      {
         super.x = value;
         if(!_tweenMode)
         {
            update();
         }
      }
      
      override public  function set_y(value)
      {
         super.y = value;
         if(!_tweenMode)
         {
            update();
         }
      }
      
      public function destroy() : Void
      {
         var nxt:AutoFitItem = null;
         if(_preview)
         {
            this.preview = false;
         }
         var item:AutoFitItem = _rootItem;
         while(item)
         {
            nxt = item.next;
            release(item.target);
            item = nxt;
         }
         if(_bd != null)
         {
            _bd.dispose();
            _bd = null;
         }
         _parent = null;
      }
      
      override public  function set_rotation(value)
      {
         trace("Warning: AutoFitArea instances should not be rotated.");
      }
      
      public  function set_previewColor(value)
      {
         _redraw(value);
      }
   }
}

import flash.geom.Matrix;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.geom.Rectangle;

class AutoFitItem
{
    
   public var matrix:Matrix;
   
   public var maxWidth:Float;
   
   public var prev:AutoFitItem;
   
   public var scaleMode:String;
   
   public var target:DisplayObject;
   
   public var aspectRatio:Float;
   
   public var minWidth:Float;
   
   public var roundPosition:Bool;
   
   public var minHeight:Float;
   
   public var hasCustomRatio:Bool;
   
   public var maxHeight:Float;
   
   public var mask:Shape;
   
   public var vAlign:String;
   
   public var next:AutoFitItem;
   
   public var hasDrawNow:Bool;
   
   public var calculateVisible:Bool;
   
   public var bounds:Rectangle;
   
   public var hAlign:String;
   
   public var boundsTarget:DisplayObject;
   
   function new(target:DisplayObject, vars:Object, next:AutoFitItem)
   {
      super();
      this.target = target;
      if(vars == null)
      {
         vars = {};
      }
      this.scaleMode = vars.scaleMode || "proportionalInside";
      this.hAlign = vars.hAlign || "center";
      this.vAlign = vars.vAlign || "center";
      this.minWidth = cast(Float(vars.minWidth), Float) || cast(0, Float);
      this.maxWidth = !!isNaN(vars.maxWidth)?cast(999999999, Float):cast(Float(vars.maxWidth), Float);
      this.minHeight = cast(Float(vars.minHeight), Float) || cast(0, Float);
      this.maxHeight = !!isNaN(vars.maxHeight)?cast(999999999, Float):cast(Float(vars.maxHeight), Float);
      this.roundPosition = cast(vars.roundPosition, Bool);
      this.boundsTarget =Std.is( vars.customBoundsTarget, DisplayObject?vars.customBoundsTarget:this.target);
      this.matrix = target.transform.matrix;
      this.calculateVisible = cast(vars.calculateVisible, Bool);
      this.hasDrawNow = this.target.hasOwnProperty("drawNow");
      if(this.hasDrawNow)
      {
         cast(this.target, Object).drawNow();
      }
      if(!isNaN(vars.customAspectRatio))
      {
         this.aspectRatio = vars.customAspectRatio;
         this.hasCustomRatio = true;
      }
      if(next)
      {
         next.prev = this;
         this.next = next;
      }
   }
   
   public function scaleVisibleHeight(value:Float) : Void
   {
      var m:Matrix = this.target.transform.matrix;
      m.b = m.b * value;
      m.d = m.d * value;
      this.target.transform.matrix = m;
      if(value != 0)
      {
         this.matrix = m;
      }
   }
   
   public function scaleVisibleWidth(value:Float) : Void
   {
      var m:Matrix = this.target.transform.matrix;
      m.a = m.a * value;
      m.c = m.c * value;
      this.target.transform.matrix = m;
      if(value != 0)
      {
         this.matrix = m;
      }
   }
   
   public function setVisibleWidth(value:Float) : Void
   {
      var scale:Float = NaN;
      var m:Matrix = this.target.transform.matrix;
      if(cast(m.a == 0, Bool) && cast(m.c == 0, Bool) || cast(m.d == 0, Bool) && cast(m.b == 0, Bool))
      {
         m.a = this.matrix.a;
         m.c = this.matrix.c;
      }
      var curWidth:Float = m.a < 0?cast(-m.a * this.bounds.width, Float):cast(m.a * this.bounds.width, Float);
      curWidth = curWidth + (m.c < 0?-m.c * this.bounds.height:m.c * this.bounds.height);
      if(curWidth != 0)
      {
         scale = value / curWidth;
         m.a = m.a * scale;
         m.c = m.c * scale;
         this.target.transform.matrix = m;
         if(value != 0)
         {
            this.matrix = m;
         }
      }
   }
   
   public function setVisibleHeight(value:Float) : Void
   {
      var scale:Float = NaN;
      var m:Matrix = this.target.transform.matrix;
      if(cast(m.a == 0, Bool) && cast(m.c == 0, Bool) || cast(m.d == 0, Bool) && cast(m.b == 0, Bool))
      {
         m.b = this.matrix.b;
         m.d = this.matrix.d;
      }
      var curHeight:Float = m.b < 0?cast(-m.b * this.bounds.width, Float):cast(m.b * this.bounds.width, Float);
      curHeight = curHeight + (m.d < 0?-m.d * this.bounds.height:m.d * this.bounds.height);
      if(curHeight != 0)
      {
         scale = value / curHeight;
         m.b = m.b * scale;
         m.d = m.d * scale;
         this.target.transform.matrix = m;
         if(value != 0)
         {
            this.matrix = m;
         }
      }
   }
