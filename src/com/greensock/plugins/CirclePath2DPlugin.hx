package com.greensock.plugins;
   import flash.geom.Matrix;
   import com.greensock.motionPaths.CirclePath2D;
   
   import com.greensock.motionPaths.PathFollower;
   
   class CirclePath2DPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      private static inline var _RAD2DEG:Float = 180 / Math.PI;
      
      public static inline var API:Float = 1;
      
      private static inline var _2PI:Float = Math.PI * 2;
       
      private var _start:Float;
      
      private var _autoRotate:Bool;
      
      private var _circle:CirclePath2D;
      
      private var _target:Dynamic;
      
      private var _autoRemove:Bool;
      
      private var _change:Float;
      
      private var _rotationOffset:Float;
      
      public function new()
      {
         super();
         this.propName = "circlePath2D";
         this.overwriteProps = ["x","y"];
      }
      
      override public function killProps(lookup:Dynamic) : Void
      {
         super.killProps(lookup);
         if(cast("x" in lookup, Bool) || cast("y" in lookup, Bool))
         {
            this.overwriteProps = [];
         }
      }
      
      override public  function set_changeFactor(n)
      {
         var angle:Float = (_start + _change * n) * _2PI;
         var radius:Float = _circle.radius;
         var m:Matrix = _circle.transform.matrix;
         var px:Float = Math.cos(angle) * radius;
         var py:Float = Math.sin(angle) * radius;
         _target.x = px * m.a + py * m.c + m.tx;
         _target.y = px * m.b + py * m.d + m.ty;
         if(_autoRotate)
         {
            angle = angle + Math.PI / 2;
            px = Math.cos(angle) * _circle.radius;
            py = Math.sin(angle) * _circle.radius;
            _target.rotation = Math.atan2(px * m.b + py * m.d,px * m.a + py * m.c) * _RAD2DEG + _rotationOffset;
         }
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(cast(!("path" in value), Bool) || cast(!(Std.is(value.path, CirclePath2D)), Bool))
         {
            trace("CirclePath2DPlugin error: invalid \'path\' property. Please define a CirclePath2D instance.");
            return false;
         }
         _target = target;
         _circle =cast( value.path, CirclePath2D);
         _autoRotate = cast(value.autoRotate == true, Bool);
         _rotationOffset = cast(value.rotationOffset, Float) || cast(0, Float);
         var f:PathFollower = _circle.getFollower(target);
         if(cast(f != null, Bool) && cast(!("startAngle" in value), Bool))
         {
            _start = f.progress;
         }
         else
         {
            _start = _circle.angleToProgress(cast(value.startAngle, Float) || cast(0, Float),value.useRadians);
            _circle.renderObjectAt(_target,_start);
         }
         _change = cast(_circle.anglesToProgressChange(_circle.progressToAngle(_start),Float(value.endAngle) || Float(0),value.direction || "clockwise",UInt(value.extraRevolutions) || UInt(0),Bool(value.useRadians)), Float);
         return true;
      }
   }
