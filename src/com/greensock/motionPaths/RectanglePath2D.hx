package com.greensock.motionPaths;
   import flash.geom.Matrix;
   import flash.events.Event;
   import flash.display.Graphics;
   
   class RectanglePath2D extends MotionPath
   {

		public var rawHeight(get, set):Float;
		public var centerOrigin(get, set):Bool;
		public var rawWidth(get, set):Float;

       
      private var _centerOrigin:Bool;
      
      private var _rawHeight:Float;
      
      private var _rawWidth:Float;
      
      public function new(x:Float, y:Float, rawWidth:Float, rawHeight:Float, centerOrigin:Bool = false)
      {
         super();
         _rawWidth = rawWidth;
         _rawHeight = rawHeight;
         _centerOrigin = centerOrigin;
         super.x = x;
         super.y = y;
      }
      
      public  function set_rawHeight(value)
      {
         _rawHeight = value;
         _redrawLine = true;
         update();
      }
      
      override public function renderObjectAt(target:Dynamic, progress:Float, autoRotate:Bool = false, rotationOffset:Float = 0) : Void
      {
         var length:Float = NaN;
         var xFactor:Float = NaN;
         var yFactor:Float = NaN;
         if(progress > 1)
         {
            progress = progress - cast(progress, Int);
         }
         else if(progress < 0)
         {
            progress = progress - (cast(progress, Int) - 1);
         }
         var px:Float = !!_centerOrigin?cast(_rawWidth / -2, Float):cast(0, Float);
         var py:Float = !!_centerOrigin?cast(_rawHeight / -2, Float):cast(0, Float);
         if(progress < 0.5)
         {
            length = progress * (_rawWidth + _rawHeight) * 2;
            if(length > _rawWidth)
            {
               px = px + _rawWidth;
               py = py + (length - _rawWidth);
               xFactor = 0;
               yFactor = _rawHeight;
            }
            else
            {
               px = px + length;
               xFactor = _rawWidth;
               yFactor = 0;
            }
         }
         else
         {
            length = (progress - 0.5) / 0.5 * (_rawWidth + _rawHeight);
            if(length <= _rawWidth)
            {
               px = px + (_rawWidth - length);
               py = py + _rawHeight;
               xFactor = -_rawWidth;
               yFactor = 0;
            }
            else
            {
               py = py + (_rawHeight - (length - _rawWidth));
               xFactor = 0;
               yFactor = -_rawHeight;
            }
         }
         var m:Matrix = this.transform.matrix;
         target.x = px * m.a + py * m.c + m.tx;
         target.y = px * m.b + py * m.d + m.ty;
         if(autoRotate)
         {
            target.rotation = Math.atan2(xFactor * m.b + yFactor * m.d,xFactor * m.a + yFactor * m.c) * _RAD2DEG + rotationOffset;
         }
      }
      
      override public function update(event:Event = null) : Void
      {
         var length:Float = NaN;
         var px:Float = NaN;
         var py:Float = NaN;
         var xFactor:Float = NaN;
         var yFactor:Float = NaN;
         var g:Graphics = null;
         var xOffset:Float = !!_centerOrigin?cast(_rawWidth / -2, Float):cast(0, Float);
         var yOffset:Float = !!_centerOrigin?cast(_rawHeight / -2, Float):cast(0, Float);
         var m:Matrix = this.transform.matrix;
         var a:Float = m.a;
         var b:Float = m.b;
         var c:Float = m.c;
         var d:Float = m.d;
         var tx:Float = m.tx;
         var ty:Float = m.ty;
         var f:PathFollower = _rootFollower;
         while(f)
         {
            px = xOffset;
            py = yOffset;
            if(f.cachedProgress < 0.5)
            {
               length = f.cachedProgress * (_rawWidth + _rawHeight) * 2;
               if(length > _rawWidth)
               {
                  px = px + _rawWidth;
                  py = py + (length - _rawWidth);
                  xFactor = 0;
                  yFactor = _rawHeight;
               }
               else
               {
                  px = px + length;
                  xFactor = _rawWidth;
                  yFactor = 0;
               }
            }
            else
            {
               length = (f.cachedProgress - 0.5) / 0.5 * (_rawWidth + _rawHeight);
               if(length <= _rawWidth)
               {
                  px = px + (_rawWidth - length);
                  py = py + _rawHeight;
                  xFactor = -_rawWidth;
                  yFactor = 0;
               }
               else
               {
                  py = py + (_rawHeight - (length - _rawWidth));
                  xFactor = 0;
                  yFactor = -_rawHeight;
               }
            }
            f.target.x = px * a + py * c + tx;
            f.target.y = px * b + py * d + ty;
            if(f.autoRotate)
            {
               f.target.rotation = Math.atan2(xFactor * b + yFactor * d,xFactor * a + yFactor * c) * _RAD2DEG + f.rotationOffset;
            }
            f = f.cachedNext;
         }
         if(_redrawLine)
         {
            g = this.graphics;
            g.clear();
            g.lineStyle(_thickness,_color,_lineAlpha,_pixelHinting,_scaleMode,_caps,_joints,_miterLimit);
            g.drawRect(xOffset,yOffset,_rawWidth,_rawHeight);
            _redrawLine = false;
         }
      }
      
      public  function get_rawHeight()
      {
         return _rawHeight;
      }
      
      public  function set_centerOrigin(value)
      {
         _centerOrigin;
         _redrawLine = true;
         update();
      }
      
      public  function get_centerOrigin()
      {
         return _centerOrigin;
      }
      
      public  function set_rawWidth(value)
      {
         _rawWidth = value;
         _redrawLine = true;
         update();
      }
      
      public  function get_rawWidth()
      {
         return _rawWidth;
      }
   }
