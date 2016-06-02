package com.greensock.plugins;
   
   import flash.geom.Transform;
   import flash.geom.Matrix;
   
   class TransformMatrixPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
      
      private static inline var _DEG2RAD:Float = Math.PI / 180;
       
      private var _dChange:Float;
      
      private var _txStart:Float;
      
      private var _cStart:Float;
      
      private var _matrix:Matrix;
      
      private var _tyStart:Float;
      
      private var _aStart:Float;
      
      private var _angleChange:Float = 0;
      
      private var _transform:Transform;
      
      private var _aChange:Float;
      
      private var _bChange:Float;
      
      private var _tyChange:Float;
      
      private var _txChange:Float;
      
      private var _cChange:Float;
      
      private var _dStart:Float;
      
      private var _bStart:Float;
      
      public function new()
      {
         super();
         this.propName = "transformMatrix";
         this.overwriteProps = ["x","y","scaleX","scaleY","rotation","transformMatrix","transformAroundPoint","transformAroundCenter","shortRotation"];
      }
      
      override public  function set_changeFactor(n)
      {
         var cos:Float = NaN;
         var sin:Float = NaN;
         var a:Float = NaN;
         var c:Float = NaN;
         _matrix.a = _aStart + n * _aChange;
         _matrix.b = _bStart + n * _bChange;
         _matrix.c = _cStart + n * _cChange;
         _matrix.d = _dStart + n * _dChange;
         if(_angleChange)
         {
            cos = Math.cos(_angleChange * n);
            sin = Math.sin(_angleChange * n);
            a = _matrix.a;
            c = _matrix.c;
            _matrix.a = a * cos - _matrix.b * sin;
            _matrix.b = a * sin + _matrix.b * cos;
            _matrix.c = c * cos - _matrix.d * sin;
            _matrix.d = c * sin + _matrix.d * cos;
         }
         _matrix.tx = _txStart + n * _txChange;
         _matrix.ty = _tyStart + n * _tyChange;
         _transform.matrix = _matrix;
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         var ratioX:Float = NaN;
         var ratioY:Float = NaN;
         var scaleX:Float = NaN;
         var scaleY:Float = NaN;
         var angle:Float = NaN;
         var skewX:Float = NaN;
         var finalAngle:Float = NaN;
         var finalSkewX:Float = NaN;
         var dif:Float = NaN;
         var skewY:Float = NaN;
         _transform =cast( target.transform, Transform);
         _matrix = _transform.matrix;
         var matrix:Matrix = _matrix.clone();
         _txStart = matrix.tx;
         _tyStart = matrix.ty;
         _aStart = matrix.a;
         _bStart = matrix.b;
         _cStart = matrix.c;
         _dStart = matrix.d;
         if("x" in value)
         {
            _txChange = typeof value.x == "number"?cast(value.x - _txStart, Float):cast(Float(value.x), Float);
         }
         else if("tx" in value)
         {
            _txChange = value.tx - _txStart;
         }
         else
         {
            _txChange = 0;
         }
         if("y" in value)
         {
            _tyChange = typeof value.y == "number"?cast(value.y - _tyStart, Float):cast(Float(value.y), Float);
         }
         else if("ty" in value)
         {
            _tyChange = value.ty - _tyStart;
         }
         else
         {
            _tyChange = 0;
         }
         _aChange = "a" in value?cast(value.a - _aStart, Float):cast(0, Float);
         _bChange = "b" in value?cast(value.b - _bStart, Float):cast(0, Float);
         _cChange = "c" in value?cast(value.c - _cStart, Float):cast(0, Float);
         _dChange = "d" in value?cast(value.d - _dStart, Float):cast(0, Float);
         if(cast("rotation" in value, Bool) || cast("shortRotation" in value, Bool) || cast("scale" in value, Bool) && cast(!(Std.is(value, Matrix)), Bool) || cast("scaleX" in value, Bool) || cast("scaleY" in value, Bool) || cast("skewX" in value, Bool) || cast("skewY" in value, Bool) || cast("skewX2" in value, Bool) || cast("skewY2" in value, Bool))
         {
            scaleX = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b);
            if(cast(matrix.a < 0, Bool) && cast(matrix.d > 0, Bool))
            {
               scaleX = -scaleX;
            }
            scaleY = Math.sqrt(matrix.c * matrix.c + matrix.d * matrix.d);
            if(cast(matrix.d < 0, Bool) && cast(matrix.a > 0, Bool))
            {
               scaleY = -scaleY;
            }
            angle = Math.atan2(matrix.b,matrix.a);
            if(cast(matrix.a < 0, Bool) && cast(matrix.d >= 0, Bool))
            {
               angle = angle + (angle <= 0?Math.PI:-Math.PI);
            }
            skewX = Math.atan2(-_matrix.c,_matrix.d) - angle;
            finalAngle = angle;
            if("shortRotation" in value)
            {
               dif = (value.shortRotation * _DEG2RAD - angle) % (Math.PI * 2);
               if(dif > Math.PI)
               {
                  dif = dif - Math.PI * 2;
               }
               else if(dif < -Math.PI)
               {
                  dif = dif + Math.PI * 2;
               }
               finalAngle = finalAngle + dif;
            }
            else if("rotation" in value)
            {
               finalAngle = typeof value.rotation == "number"?cast(value.rotation * _DEG2RAD, Float):cast(Float(value.rotation) * _DEG2RAD + angle, Float);
            }
            finalSkewX = "skewX" in value?typeof value.skewX == "number"?cast(Float(value.skewX) * _DEG2RAD, Float):cast(Float(value.skewX) * _DEG2RAD + skewX, Float):cast(0, Float);
            if("skewY" in value)
            {
               skewY = typeof value.skewY == "number"?cast(value.skewY * _DEG2RAD, Float):cast(Float(value.skewY) * _DEG2RAD - skewX, Float);
               finalAngle = finalAngle + (skewY + skewX);
               finalSkewX = finalSkewX - skewY;
            }
            if(finalAngle != angle)
            {
               if(cast("rotation" in value, Bool) || cast("shortRotation" in value, Bool))
               {
                  _angleChange = finalAngle - angle;
                  finalAngle = angle;
               }
               else
               {
                  matrix.rotate(finalAngle - angle);
               }
            }
            if("scale" in value)
            {
               ratioX = cast(value.scale, Float) / scaleX;
               ratioY = cast(value.scale, Float) / scaleY;
               if(typeof value.scale != "number")
               {
                  ratioX = ratioX + 1;
                  ratioY = ratioY + 1;
               }
            }
            else
            {
               if("scaleX" in value)
               {
                  ratioX = cast(value.scaleX, Float) / scaleX;
                  if(typeof value.scaleX != "number")
                  {
                     ratioX = ratioX + 1;
                  }
               }
               if("scaleY" in value)
               {
                  ratioY = cast(value.scaleY, Float) / scaleY;
                  if(typeof value.scaleY != "number")
                  {
                     ratioY = ratioY + 1;
                  }
               }
            }
            if(finalSkewX != skewX)
            {
               matrix.c = -scaleY * Math.sin(finalSkewX + finalAngle);
               matrix.d = scaleY * Math.cos(finalSkewX + finalAngle);
            }
            if("skewX2" in value)
            {
               if(typeof value.skewX2 == "number")
               {
                  matrix.c = Math.tan(0 - value.skewX2 * _DEG2RAD);
               }
               else
               {
                  matrix.c = matrix.c + Math.tan(0 - cast(value.skewX2, Float) * _DEG2RAD);
               }
            }
            if("skewY2" in value)
            {
               if(typeof value.skewY2 == "number")
               {
                  matrix.b = Math.tan(value.skewY2 * _DEG2RAD);
               }
               else
               {
                  matrix.b = matrix.b + Math.tan(cast(value.skewY2, Float) * _DEG2RAD);
               }
            }
            if(cast(ratioX, Bool) || cast(ratioX == 0, Bool))
            {
               matrix.a = matrix.a * ratioX;
               matrix.b = matrix.b * ratioX;
            }
            if(cast(ratioY, Bool) || cast(ratioY == 0, Bool))
            {
               matrix.c = matrix.c * ratioY;
               matrix.d = matrix.d * ratioY;
            }
            _aChange = matrix.a - _aStart;
            _bChange = matrix.b - _bStart;
            _cChange = matrix.c - _cStart;
            _dChange = matrix.d - _dStart;
         }
         return true;
      }
   }
