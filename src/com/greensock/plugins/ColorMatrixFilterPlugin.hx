package com.greensock.plugins;

   import flash.filters.ColorMatrixFilter;
   import lime.utils.Float32Array;

   class ColorMatrixFilterPlugin extends FilterPlugin
   {
/*
      public static inline var API:Float = 1;

      private static var _propNames:Array<String> = [];

      private static var _lumG:Float = 0.71516;

      private static var _lumR:Float = 0.212671;

      private static var _idMultipliersMatrix:Float32Array = new Float32Array([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]);
      private static var _idOffsetsMatrix:Float32Array = new Float32Array([0,0,0,0]);

      private static var _lumB:Float = 0.072169;

      private var _multipliers:Float32Array;
      private var _offsets:Float32Array;

      private var _matrixTween:com.greensock.plugins.EndFloat32ArrayPlugin;
*/
      public function new()
      {
          super();
          throw ":TODO: Fix with Float32Array instead of Array<Float>";
         /*this.propName = "colorMatrixFilter";
         this.overwriteProps = ["colorMatrixFilter"];*/
      }

     /* public static function setSaturation(m:Float32Array, n:Float) : Float32Array
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         var inv:Float = 1 - n;
         var r:Float = inv * _lumR;
         var g:Float = inv * _lumG;
         var b:Float = inv * _lumB;
         var temp:Float32Array = [r + n,g,b,0,0,r,g + n,b,0,0,r,g,b + n,0,0,0,0,0,1,0];
         return applyMatrix(temp,m);
      }

      public static function setHue(m:Float32Array, n:Float) : Float32Array
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         n = n * (Math.PI / 180);
         var c:Float = Math.cos(n);
         var s:Float = Math.sin(n);
         var temp:Float32Array = [_lumR + c * (1 - _lumR) + s * -_lumR,_lumG + c * -_lumG + s * -_lumG,_lumB + c * -_lumB + s * (1 - _lumB),0,0,_lumR + c * -_lumR + s * 0.143,_lumG + c * (1 - _lumG) + s * 0.14,_lumB + c * -_lumB + s * -0.283,0,0,_lumR + c * -_lumR + s * -(1 - _lumR),_lumG + c * -_lumG + s * _lumG,_lumB + c * (1 - _lumB) + s * _lumB,0,0,0,0,0,1,0,0,0,0,0,1];
         return applyMatrix(temp,m);
      }

      public static function setContrast(m:Float32Array, n:Float) : Float32Array
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         n = n + 0.01;
         var temp:Float32Array = [n,0,0,0,128 * (1 - n),0,n,0,0,128 * (1 - n),0,0,n,0,128 * (1 - n),0,0,0,1,0];
         return applyMatrix(temp,m);
      }

      public static function applyMatrix(m:Float32Array, m2:Float32Array) : Float32Array
      {
         var y:Int = 0;
         var x:Int = 0;
         if(!Std.is(m, Array) || !Std.is(m2, Array))
         {
            return m2;
         }
         var temp:Float32Array = [];
         var i:Int = 0;
         var z:Float = 0;
         for( y in (0)...(4) )
         {
            for( x in (0)...(5) )
            {
               if(x == 4)
               {
                  z = m[i + 4];
               }
               else
               {
                  z = 0;
               }
               temp[i + x] = m[i] * m2[x] + m[i + 1] * m2[x + 5] + m[i + 2] * m2[x + 10] + m[i + 3] * m2[x + 15] + z;
            }
            i = i + 5;
         }
         return temp;
      }

      public static function setThreshold(m:Float32Array, n:Float) : Float32Array
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         var temp:Float32Array = [_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,0,0,0,1,0];
         return applyMatrix(temp,m);
      }

      public static function colorize(m:Float32Array, color:Int, amount:Float = 1) : Float32Array
      {
         if(Math.isNaN(color))
         {
            return m;
         }
         if(Math.isNaN(amount))
         {
            amount = 1;
         }
         var r:Float = (color >> 16 & 255) / 255;
         var g:Float = (color >> 8 & 255) / 255;
         var b:Float = (color & 255) / 255;
         var inv:Float = 1 - amount;
         var temp:Float32Array = [inv + amount * r * _lumR,amount * r * _lumG,amount * r * _lumB,0,0,amount * g * _lumR,inv + amount * g * _lumG,amount * g * _lumB,0,0,amount * b * _lumR,amount * b * _lumG,inv + amount * b * _lumB,0,0,0,0,0,1,0];
         return applyMatrix(temp,m);
      }

      public static function setBrightness(m:Float32Array, n:Float) : Float32Array
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         n = n * 100 - 100;
         return applyMatrix([1,0,0,0,n,0,1,0,0,n,0,0,1,0,n,0,0,0,1,0,0,0,0,0,1],m);
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _type = ColorMatrixFilter;
         var cmf:Dynamic = value;
         var map = new Map<String,Dynamic>();
         map.set( "remove",value.remove );
         map.set( "index",value.index);
         map.set( "addFilter",value.addFilter);

         initFilter( map,new ColorMatrixFilter(new Float32Array(_idMultipliersMatrix), new Float32Array(_idOffsetsMatrix)),_propNames);
         _multipliers = cast(_filter, ColorMatrixFilter).multipliers;
         _offsets = cast(_filter, ColorMatrixFilter).offsets;
         var endMultipliersMatrix:Float32Array;
         var endOffsetsMatrix:Float32Array;
         if( cmf.matrix != null && Std.is(cmf.matrix, Array))
         {
             throw ":TODO:";
             // split matrix into multipliers and offsets
            //endMatrix = cmf.matrix;
         }
         else
         {
            if(cmf.relative == true)
            {
               endMultipliersMatrix = new Float32Array(_multipliers);
               endOffsetsMatrix = new Float32Array(_offsets);
            }
            else
            {
                endMultipliersMatrix = new Float32Array(_idMultipliersMatrix);
                endOffsetsMatrix = new Float32Array(_idOffsetsMatrix);
            }
            endMultipliersMatrix = setBrightness(endMultipliersMatrix,cmf.brightness);
            endMultipliersMatrix = setContrast(endMultipliersMatrix,cmf.contrast);
            endMultipliersMatrix = setHue(endMultipliersMatrix,cmf.hue);
            endMultipliersMatrix = setSaturation(endMultipliersMatrix,cmf.saturation);
            endMultipliersMatrix = setThreshold(endMultipliersMatrix,cmf.threshold);

            endOffsetsMatrix = setBrightness(endOffsetsMatrix,cmf.brightness);
            endOffsetsMatrix = setContrast(endOffsetsMatrix,cmf.contrast);
            endOffsetsMatrix = setHue(endOffsetsMatrix,cmf.hue);
            endOffsetsMatrix = setSaturation(endOffsetsMatrix,cmf.saturation);
            endOffsetsMatrix = setThreshold(endOffsetsMatrix,cmf.threshold);

            if(!Math.isNaN(cmf.colorize))
            {
               endMultipliersMatrix = colorize(endMultipliersMatrix,cmf.colorize,cmf.amount);
               endOffsetsMatrix = colorize(endOffsetsMatrix,cmf.colorize,cmf.amount);
            }
         }
         _matrixMultipliersTween = new com.greensock.plugins.EndFloat32ArrayPlugin();
         _matrixOffsetsTween = new com.greensock.plugins.EndFloat32ArrayPlugin();
         _matrixMultipliersTween.init(_multipliers,endMultipliersMatrix);
         _matrixOffsetsTween.init(_offsets,endOffsetsMatrix);
         return true;
      }

      override public  function set_changeFactor(n:Float)
      {
         _matrixTween.changeFactor = n;
         cast(_filter, ColorMatrixFilter).matrix = _matrix;
         super.changeFactor = n;
         return n;
     }*/
   }
