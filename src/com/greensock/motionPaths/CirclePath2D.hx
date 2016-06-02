package com.greensock.motionPaths;
   import flash.geom.Matrix;
   import flash.events.Event;
   import flash.display.Graphics;
   
   class CirclePath2D extends MotionPath
   {

		public var radius(get, set):Float;

       
      private var _radius:Float;
      
      public function new(x:Float, y:Float, radius:Float)
      {
         super();
         _radius = radius;
         super.x = x;
         super.y = y;
      }
      
      public  function get_radius()
      {
         return _radius;
      }
      
      override public function renderObjectAt(target:Dynamic, progress:Float, autoRotate:Bool = false, rotationOffset:Float = 0) : Void
      {
         var angle:Float = progress * Math.PI * 2;
         var m:Matrix = this.transform.matrix;
         var px:Float = Math.cos(angle) * _radius;
         var py:Float = Math.sin(angle) * _radius;
         target.x = px * m.a + py * m.c + m.tx;
         target.y = px * m.b + py * m.d + m.ty;
         if(autoRotate)
         {
            angle = angle + Math.PI / 2;
            px = Math.cos(angle) * _radius;
            py = Math.sin(angle) * _radius;
            target.rotation = Math.atan2(px * m.b + py * m.d,px * m.a + py * m.c) * _RAD2DEG + rotationOffset;
         }
      }
      
      override public function update(event:Event = null) : Void
      {
         var angle:Float = NaN;
         var px:Float = NaN;
         var py:Float = NaN;
         var g:Graphics = null;
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
            angle = f.cachedProgress * Math.PI * 2;
            px = Math.cos(angle) * _radius;
            py = Math.sin(angle) * _radius;
            f.target.x = px * a + py * c + tx;
            f.target.y = px * b + py * d + ty;
            if(f.autoRotate)
            {
               angle = angle + Math.PI / 2;
               px = Math.cos(angle) * _radius;
               py = Math.sin(angle) * _radius;
               f.target.rotation = Math.atan2(px * m.b + py * m.d,px * m.a + py * m.c) * _RAD2DEG + f.rotationOffset;
            }
            f = f.cachedNext;
         }
         if(_redrawLine)
         {
            g = this.graphics;
            g.clear();
            g.lineStyle(_thickness,_color,_lineAlpha,_pixelHinting,_scaleMode,_caps,_joints,_miterLimit);
            g.drawCircle(0,0,_radius);
            _redrawLine = false;
         }
      }
      
      public function progressToAngle(progress:Float, useRadians:Bool = false) : Float
      {
         var revolution:Float = !!useRadians?cast(Math.PI * 2, Float):cast(360, Float);
         return progress * revolution;
      }
      
      public function angleToProgress(angle:Float, useRadians:Bool = false) : Float
      {
         var revolution:Float = !!useRadians?cast(Math.PI * 2, Float):cast(360, Float);
         if(angle < 0)
         {
            angle = angle + (cast(-angle / revolution, Int) + 1) * revolution;
         }
         else if(angle > revolution)
         {
            angle = angle - cast(angle / revolution, Int) * revolution;
         }
         return angle / revolution;
      }
      
      public  function set_radius(value)
      {
         _radius = value;
         _redrawLine = true;
         update();
      }
      
      public function followerTween(follower:Dynamic, endAngle:Float, direction:String = "clockwise", extraRevolutions:UInt = 0, useRadians:Bool = false) : String
      {
         var revolution:Float = !!useRadians?cast(Math.PI * 2, Float):cast(360, Float);
         return cast(anglesToProgressChange(getFollower(follower).progress * revolution,endAngle,direction,extraRevolutions,useRadians), String);
      }
      
      public function anglesToProgressChange(startAngle:Float, endAngle:Float, direction:String = "clockwise", extraRevolutions:UInt = 0, useRadians:Bool = false) : Float
      {
         var revolution:Float = !!useRadians?cast(Math.PI * 2, Float):cast(360, Float);
         var dif:Float = endAngle - startAngle;
         if(cast(dif < 0, Bool) && cast(direction == "clockwise", Bool))
         {
            dif = dif + (cast(-dif / revolution, Int) + 1) * revolution;
         }
         else if(cast(dif > 0, Bool) && cast(direction == "counterClockwise", Bool))
         {
            dif = dif - (cast(dif / revolution, Int) + 1) * revolution;
         }
         else if(direction == "shortest")
         {
            dif = dif % revolution;
            if(dif != dif % (revolution * 0.5))
            {
               dif = dif < 0?cast(dif + revolution, Float):cast(dif - revolution, Float);
            }
         }
         if(dif < 0)
         {
            dif = dif - extraRevolutions * revolution;
         }
         else
         {
            dif = dif + extraRevolutions * revolution;
         }
         return dif / revolution;
      }
   }
