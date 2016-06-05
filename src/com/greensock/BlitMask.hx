package com.greensock;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.geom.Point;
   import flash.geom.Matrix;
   import flash.events.MouseEvent;
   import flash.events.Event;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.geom.Transform;
   
   class BlitMask extends Sprite
   {

		public var wrapOffsetX(get, set):Float;
		public var wrapOffsetY(get, set):Float;
		public var smoothing(get, set):Bool;
		public var target(get, set):DisplayObject;
		public var fillColor(get, set):UInt;
		public var height(get, set):Float;
		public var scrollX(get, set):Float;
		public var scrollY(get, set):Float;
		public var scaleY(get, set):Float;
		public var wrap(get, set):Bool;
		public var autoUpdate(get, set):Bool;
		public var width(get, set):Float;
		public var bitmapMode(get, set):Bool;
		public var y(get, set):Float;
		public var scaleX(get, set):Float;
		public var x(get, set):Float;
		public var rotation(null, set):Float;

      
      private static var _colorTransform:ColorTransform = new ColorTransform();
      
      private static var _mouseEvents:Array<Int> = [MouseEvent.CLICK,MouseEvent.DOUBLE_CLICK,MouseEvent.MOUSE_DOWN,MouseEvent.MOUSE_MOVE,MouseEvent.MOUSE_OUT,MouseEvent.MOUSE_OVER,MouseEvent.MOUSE_UP,MouseEvent.MOUSE_WHEEL,MouseEvent.ROLL_OUT,MouseEvent.ROLL_OVER];
      
      private static var _drawRect:Rectangle = new Rectangle();
      
      private static var _emptyArray:Array<Int> = [];
      
      private static var _destPoint:Point = new Point();
      
      private static var _tempMatrix:Matrix = new Matrix();
      
      private static var _sliceRect:Rectangle = new Rectangle();
      
      public static var version:Float = 0.6;
      
      private static var _tempContainer:Sprite = new Sprite();
       
      private var _bitmapMode:Bool;
      
      private var _columns:Int;
      
      private var _fillColor:UInt;
      
      private var _grid:Array<Int>;
      
      private var _wrap:Bool;
      
      private var _target:DisplayObject;
      
      private var _prevRotation:Float;
      
      private var _rows:Int;
      
      private var _clipRect:Rectangle;
      
      private var _wrapOffsetX:Float = 0;
      
      private var _wrapOffsetY:Float = 0;
      
      private var _height:Float;
      
      private var _width:Float;
      
      private var _gridSize:Int = 2879;
      
      private var _bounds:Rectangle;
      
      private var _bd:BitmapData;
      
      private var _scaleX:Float;
      
      private var _scaleY:Float;
      
      private var _prevMatrix:Matrix;
      
      private var _transform:Transform;
      
      private var _smoothing:Bool;
      
      private var _autoUpdate:Bool;
      
      public function new(target:DisplayObject, x:Float = 0, y:Float = 0, width:Float = 100, height:Float = 100, smoothing:Bool = false, autoUpdate:Bool = false, fillColor:UInt = 0, wrap:Bool = false)
      {
         super();
         if(cast(width < 0, Bool) || cast(height < 0, Bool))
         {
            throw new openfl.errors.Error("A FlexBlitMask cannot have a negative width or height.");
         }
         _width = width;
         _height = height;
         _scaleX = _scaleY = 1;
         _smoothing = smoothing;
         _fillColor = fillColor;
         _autoUpdate = autoUpdate;
         _wrap = wrap;
         _grid = [];
         _bounds = new Rectangle();
         if(_smoothing)
         {
            super.x = x;
            super.y = y;
         }
         else
         {
            super.x = x < 0?cast(x - 0.5 >> 0, Float):cast(x + 0.5 >> 0, Float);
            super.y = y < 0?cast(y - 0.5 >> 0, Float):cast(y + 0.5 >> 0, Float);
         }
         _clipRect = new Rectangle(0,0,_gridSize + 1,_gridSize + 1);
         _bd = new BitmapData(width + 1,height + 1,true,_fillColor);
         _bitmapMode = true;
         this.target = target;
      }
      
      public function disableBitmapMode(event:Event = null) : Void
      {
         this.bitmapMode = false;
      }
      
      public  function get_wrapOffsetX()
      {
         return _wrapOffsetX;
      }
      
      public function setSize(width:Float, height:Float) : Void
      {
         if(cast(_width == width, Bool) && cast(_height == height, Bool))
         {
            return;
         }
         if(cast(width < 0, Bool) || cast(height < 0, Bool))
         {
            throw new openfl.errors.Error("A BlitMask cannot have a negative width or height.");
         }
         if(_bd != null)
         {
            _bd.dispose();
         }
         _width = width;
         _height = height;
         _bd = new BitmapData(width + 1,height + 1,true,_fillColor);
         _render();
      }
      
      public  function set_wrapOffsetY(value)
      {
         if(_wrapOffsetY != value)
         {
            _wrapOffsetY = value;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      override public  function set_x(value)
      {
         if(_smoothing)
         {
            super.x = value;
         }
         else if(value >= 0)
         {
            super.x = value + 0.5 >> 0;
         }
         else
         {
            super.x = value - 0.5 >> 0;
         }
         if(_bitmapMode)
         {
            _render();
         }
      }
      
      override public  function set_y(value)
      {
         if(_smoothing)
         {
            super.y = value;
         }
         else if(value >= 0)
         {
            super.y = value + 0.5 >> 0;
         }
         else
         {
            super.y = value - 0.5 >> 0;
         }
         if(_bitmapMode)
         {
            _render();
         }
      }
      
      public  function get_wrapOffsetY()
      {
         return _wrapOffsetY;
      }
      
      public  function set_wrap(value)
      {
         if(_wrap != value)
         {
            _wrap = value;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public  function get_smoothing()
      {
         return _smoothing;
      }
      
      public  function get_target()
      {
         return _target;
      }
      
      override public  function set_width(value)
      {
         setSize(value,_height);
      }
      
      override public  function set_scaleX(value)
      {
         var oldScaleX:Float = _scaleX;
         _scaleX = value;
         setSize(_width * (_scaleX / oldScaleX),_height);
      }
      
      public function dispose() : Void
      {
         if(_bd == null)
         {
            return;
         }
         _disposeGrid();
         _bd.dispose();
         _bd = null;
         this.bitmapMode = false;
         this.autoUpdate = false;
         if(_target != null)
         {
            _target.mask = null;
         }
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         this.target = null;
      }
      
      public  function get_fillColor()
      {
         return _fillColor;
      }
      
      override public  function get_height()
      {
         return _height;
      }
      
      public  function get_scrollX()
      {
         return (super.x - _bounds.x) / (_bounds.width - _width);
      }
      
      public  function get_scrollY()
      {
         return (super.y - _bounds.y) / (_bounds.height - _height);
      }
      
      override public  function set_scaleY(value)
      {
         var oldScaleY:Float = _scaleY;
         _scaleY = value;
         setSize(_width,_height * (_scaleY / oldScaleY));
      }
      
      public  function set_target(value)
      {
         var i:Int = 0;
         if(_target != value)
         {
            i = _mouseEvents.length;
            if(_target != null)
            {
               while(--i > -1)
               {
                  _target.removeEventListener(_mouseEvents[i],_mouseEventPassthrough);
               }
            }
            _target = value;
            if(_target != null)
            {
               i = _mouseEvents.length;
               while(--i > -1)
               {
                  _target.addEventListener(_mouseEvents[i],_mouseEventPassthrough,false,0,true);
               }
               _prevMatrix = null;
               _transform = _target.transform;
               _bitmapMode = !_bitmapMode;
               this.bitmapMode = !_bitmapMode;
            }
            else
            {
               _bounds = new Rectangle();
            }
         }
      }
      
      private function _render(xOffset:Float = 0, yOffset:Float = 0, clear:Bool = true, limitRecursion:Bool = false) : Void
      {
         var xDestReset:Float = NaN;
         var xSliceReset:Float = NaN;
         var columnReset:Int = 0;
         var bd:BitmapData = null;
         if(clear)
         {
            _sliceRect.x = _sliceRect.y = 0;
            _sliceRect.width = _width + 1;
            _sliceRect.height = _height + 1;
            _bd.fillRect(_sliceRect,_fillColor);
            if(cast(_bitmapMode, Bool) && cast(_target != null, Bool))
            {
               this.filters = _target.filters;
               this.transform.colorTransform = _transform.colorTransform;
            }
            else
            {
               this.filters = _emptyArray;
               this.transform.colorTransform = _colorTransform;
            }
         }
         if(_bd == null)
         {
            return;
         }
         if(_rows == 0)
         {
            _captureTargetBitmap();
         }
         var x:Float = super.x + xOffset;
         var y:Float = super.y + yOffset;
         var wrapWidth:Int = _bounds.width + _wrapOffsetX + 0.5 >> 0;
         var wrapHeight:Int = _bounds.height + _wrapOffsetY + 0.5 >> 0;
         var g:Graphics = this.graphics;
         if(cast(_bounds.width == 0, Bool) || cast(_bounds.height == 0, Bool) || cast(_wrap, Bool) && (cast(wrapWidth == 0, Bool) || cast(wrapHeight == 0, Bool)) || cast(!_wrap, Bool) && (cast(x + _width < _bounds.x, Bool) || cast(y + _height < _bounds.y, Bool) || cast(x > _bounds.right, Bool) || cast(y > _bounds.bottom, Bool)))
         {
            g.clear();
            g.beginBitmapFill(_bd);
            g.drawRect(0,0,_width,_height);
            g.endFill();
            return;
         }
         var column:Int = cast((x - _bounds.x) / _gridSize, Int);
         if(column < 0)
         {
            column = 0;
         }
         var row:Int = cast((y - _bounds.y) / _gridSize, Int);
         if(row < 0)
         {
            row = 0;
         }
         var maxColumn:Int = cast((x + _width - _bounds.x) / _gridSize, Int);
         if(maxColumn >= _columns)
         {
            maxColumn = _columns - 1;
         }
         var maxRow:UInt = cast((y + _height - _bounds.y) / _gridSize, Int);
         if(maxRow >= _rows)
         {
            maxRow = _rows - 1;
         }
         var xNudge:Float = (_bounds.x - x) % 1;
         var yNudge:Float = (_bounds.y - y) % 1;
         if(y <= _bounds.y)
         {
            _destPoint.y = _bounds.y - y >> 0;
            _sliceRect.y = -1;
         }
         else
         {
            _destPoint.y = 0;
            _sliceRect.y = Math.ceil(y - _bounds.y) - row * _gridSize - 1;
            if(cast(clear, Bool) && cast(yNudge != 0, Bool))
            {
               yNudge = yNudge + 1;
            }
         }
         if(x <= _bounds.x)
         {
            _destPoint.x = _bounds.x - x >> 0;
            _sliceRect.x = -1;
         }
         else
         {
            _destPoint.x = 0;
            _sliceRect.x = Math.ceil(x - _bounds.x) - column * _gridSize - 1;
            if(cast(clear, Bool) && cast(xNudge != 0, Bool))
            {
               xNudge = xNudge + 1;
            }
         }
         if(cast(_wrap, Bool) && cast(clear, Bool))
         {
            _render(Math.ceil((_bounds.x - x) / wrapWidth) * wrapWidth,Math.ceil((_bounds.y - y) / wrapHeight) * wrapHeight,false,false);
         }
         else if(_rows != 0)
         {
            xDestReset = _destPoint.x;
            xSliceReset = _sliceRect.x;
            columnReset = column;
            while(row <= maxRow)
            {
               bd = _grid[row][0];
               _sliceRect.height = bd.height - _sliceRect.y;
               _destPoint.x = xDestReset;
               _sliceRect.x = xSliceReset;
               column = columnReset;
               while(column <= maxColumn)
               {
                  bd = _grid[row][column];
                  _sliceRect.width = bd.width - _sliceRect.x;
                  _bd.copyPixels(bd,_sliceRect,_destPoint);
                  _destPoint.x = _destPoint.x + (_sliceRect.width - 1);
                  _sliceRect.x = 0;
                  column++;
               }
               _destPoint.y = _destPoint.y + (_sliceRect.height - 1);
               _sliceRect.y = 0;
               row++;
            }
         }
         if(clear)
         {
            _tempMatrix.tx = xNudge - 1;
            _tempMatrix.ty = yNudge - 1;
            g.clear();
            g.beginBitmapFill(_bd,_tempMatrix,false,_smoothing);
            g.drawRect(0,0,_width,_height);
            g.endFill();
         }
         else if(_wrap)
         {
            if(x + _width > _bounds.right)
            {
               _render(xOffset - wrapWidth,yOffset,false,true);
            }
            if(cast(!limitRecursion, Bool) && cast(y + _height > _bounds.bottom, Bool))
            {
               _render(xOffset,yOffset - wrapHeight,false,false);
            }
         }
      }
      
      public  function set_autoUpdate(value)
      {
         if(_autoUpdate != value)
         {
            _autoUpdate = value;
            if(cast(_bitmapMode, Bool) && cast(_autoUpdate, Bool))
            {
               this.addEventListener(Event.ENTER_FRAME,update,false,-10,true);
            }
            else
            {
               this.removeEventListener(Event.ENTER_FRAME,update);
            }
         }
      }
      
      public  function set_fillColor(value)
      {
         if(_fillColor != value)
         {
            _fillColor = value;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      private function _captureTargetBitmap() : Void
      {
         var bd:BitmapData = null;
         var cumulativeWidth:Float = NaN;
         var column:Int = 0;
         if(cast(_bd == null, Bool) || cast(_target == null, Bool))
         {
            return;
         }
         _disposeGrid();
         var prevMask:DisplayObject = _target.mask;
         if(prevMask != null)
         {
            _target.mask = null;
         }
         var prevScrollRect:Rectangle = _target.scrollRect;
         if(prevScrollRect != null)
         {
            _target.scrollRect = null;
         }
         var prevFilters:Array<Int> = _target.filters;
         if(prevFilters.length != 0)
         {
            _target.filters = _emptyArray;
         }
         _grid = [];
         if(_target.parent == null)
         {
            _tempContainer.addChild(_target);
         }
         _bounds = _target.getBounds(_target.parent);
         var w:Float = 0;
         var h:Float = 0;
         _columns = Math.ceil(_bounds.width / _gridSize);
         _rows = Math.ceil(_bounds.height / _gridSize);
         var cumulativeHeight:Float = 0;
         var matrix:Matrix = _transform.matrix;
         var xOffset:Float = matrix.tx - _bounds.x;
         var yOffset:Float = matrix.ty - _bounds.y;
         if(!_smoothing)
         {
            xOffset = xOffset + 0.5 >> 0;
            yOffset = yOffset + 0.5 >> 0;
         }
         for( row in 0..._rows )
         {
            h = _bounds.height - cumulativeHeight > _gridSize?cast(_gridSize, Float):cast(_bounds.height - cumulativeHeight, Float);
            matrix.ty = -cumulativeHeight + yOffset;
            cumulativeWidth = 0;
            _grid[row] = [];
            for( column in 0..._columns )
            {
               w = _bounds.width - cumulativeWidth > _gridSize?cast(_gridSize, Float):cast(_bounds.width - cumulativeWidth, Float);
               _grid[row][column] = bd = new BitmapData(w + 1,h + 1,true,_fillColor);
               matrix.tx = -cumulativeWidth + xOffset;
               bd.draw(_target,matrix,null,null,_clipRect,_smoothing);
               cumulativeWidth = cumulativeWidth + w;
            }
            cumulativeHeight = cumulativeHeight + h;
         }
         if(_target.parent == _tempContainer)
         {
            _tempContainer.removeChild(_target);
         }
         if(prevMask != null)
         {
            _target.mask = prevMask;
         }
         if(prevScrollRect != null)
         {
            _target.scrollRect = prevScrollRect;
         }
         if(prevFilters.length != 0)
         {
            _target.filters = prevFilters;
         }
      }
      
      override public  function get_scaleY()
      {
         return 1;
      }
      
      public function update(event:Event = null, forceRecaptureBitmap:Bool = false) : Void
      {
         var m:Matrix = null;
         if(_bd == null)
         {
            return;
         }
         if(_target == null)
         {
            _render();
         }
         else if(_target.parent)
         {
            _bounds = _target.getBounds(_target.parent);
            if(this.parent != _target.parent)
            {
               _target.parent.addChildAt(this,_target.parent.getChildIndex(_target));
            }
         }
         if(cast(_bitmapMode, Bool) || cast(forceRecaptureBitmap, Bool))
         {
            m = _transform.matrix;
            if(cast(forceRecaptureBitmap, Bool) || cast(_prevMatrix == null, Bool) || cast(m.a != _prevMatrix.a, Bool) || cast(m.b != _prevMatrix.b, Bool) || cast(m.c != _prevMatrix.c, Bool) || cast(m.d != _prevMatrix.d, Bool))
            {
               _captureTargetBitmap();
               _render();
            }
            else if(cast(m.tx != _prevMatrix.tx, Bool) || cast(m.ty != _prevMatrix.ty, Bool))
            {
               _render();
            }
            else if(cast(_bitmapMode, Bool) && cast(_target != null, Bool))
            {
               this.filters = _target.filters;
               this.transform.colorTransform = _transform.colorTransform;
            }
            _prevMatrix = m;
         }
      }
      
      public  function get_wrap()
      {
         return _wrap;
      }
      
      private function _disposeGrid() : Void
      {
         var j:Int = 0;
         var r:Array<Int> = null;
         var i:Int = _grid.length;
         while(--i > -1)
         {
            r = _grid[i];
            j = r.length;
            while(--j > -1)
            {
               cast(r[j], BitmapData).dispose();
            }
         }
      }
      
      public function normalizePosition() : Void
      {
         var wrapWidth:Int = 0;
         var wrapHeight:Int = 0;
         var offsetX:Float = NaN;
         var offsetY:Float = NaN;
         if(cast(_target, Bool) && cast(_bounds, Bool))
         {
            wrapWidth = _bounds.width + _wrapOffsetX + 0.5 >> 0;
            wrapHeight = _bounds.height + _wrapOffsetY + 0.5 >> 0;
            offsetX = (_bounds.x - this.x) % wrapWidth;
            offsetY = (_bounds.y - this.y) % wrapHeight;
            if(offsetX > (_width + _wrapOffsetX) / 2)
            {
               offsetX = offsetX - wrapWidth;
            }
            else if(offsetX < (_width + _wrapOffsetX) / -2)
            {
               offsetX = offsetX + wrapWidth;
            }
            if(offsetY > (_height + _wrapOffsetY) / 2)
            {
               offsetY = offsetY - wrapHeight;
            }
            else if(offsetY < (_height + _wrapOffsetY) / -2)
            {
               offsetY = offsetY + wrapHeight;
            }
            _target.x = _target.x + (this.x + offsetX - _bounds.x);
            _target.y = _target.y + (this.y + offsetY - _bounds.y);
         }
      }
      
      public  function get_autoUpdate()
      {
         return _autoUpdate;
      }
      
      override public  function set_height(value)
      {
         setSize(_width,value);
      }
      
      override public  function get_width()
      {
         return _width;
      }
      
      public  function set_scrollY(value)
      {
         var dif:Float = NaN;
         if(cast(_target != null, Bool) && cast(_target.parent, Bool))
         {
            _bounds = _target.getBounds(_target.parent);
            dif = super.y - (_bounds.height - _height) * value - _bounds.y;
            _target.y = _target.y + dif;
            _bounds.y = _bounds.y + dif;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      private function _mouseEventPassthrough(event:MouseEvent) : Void
      {
         if(cast(this.mouseEnabled, Bool) && (cast(!_bitmapMode, Bool) || cast(this.hitTestPoint(event.stageX,event.stageY,false), Bool)))
         {
            dispatchEvent(event);
         }
      }
      
      public function enableBitmapMode(event:Event = null) : Void
      {
         this.bitmapMode = true;
      }
      
      public  function set_scrollX(value)
      {
         var dif:Float = NaN;
         if(cast(_target != null, Bool) && cast(_target.parent, Bool))
         {
            _bounds = _target.getBounds(_target.parent);
            dif = super.x - (_bounds.width - _width) * value - _bounds.x;
            _target.x = _target.x + dif;
            _bounds.x = _bounds.x + dif;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public  function set_smoothing(value)
      {
         if(_smoothing != value)
         {
            _smoothing = value;
            _captureTargetBitmap();
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public  function set_bitmapMode(value)
      {
         if(_bitmapMode != value)
         {
            _bitmapMode = value;
            if(_target != null)
            {
               _target.visible = !_bitmapMode;
               update(null);
               if(_bitmapMode)
               {
                  this.filters = _target.filters;
                  this.transform.colorTransform = _transform.colorTransform;
                  this.blendMode = _target.blendMode;
                  _target.mask = null;
               }
               else
               {
                  this.filters = _emptyArray;
                  this.transform.colorTransform = _colorTransform;
                  this.blendMode = "normal";
                  this.cacheAsBitmap = false;
                  _target.mask = this;
                  if(_wrap)
                  {
                     normalizePosition();
                  }
               }
               if(cast(_bitmapMode, Bool) && cast(_autoUpdate, Bool))
               {
                  this.addEventListener(Event.ENTER_FRAME,update,false,-10,true);
               }
               else
               {
                  this.removeEventListener(Event.ENTER_FRAME,update);
               }
            }
         }
      }
      
      public  function get_bitmapMode()
      {
         return _bitmapMode;
      }
      
      public  function set_wrapOffsetX(value)
      {
         if(_wrapOffsetX != value)
         {
            _wrapOffsetX = value;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      override public  function get_y()
      {
         return super.y;
      }
      
      override public  function get_scaleX()
      {
         return 1;
      }
      
      override public  function set_rotation(value)
      {
         if(value != 0)
         {
            throw new openfl.errors.Error("Cannot set the rotation of a BlitMask to a non-zero number. BlitMasks should remain unrotated.");
         }
      }
      
      override public  function get_x()
      {
         return super.x;
      }
   }
