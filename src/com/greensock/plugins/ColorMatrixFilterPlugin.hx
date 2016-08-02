package com.greensock.plugins;
   
   import flash.filters.ColorMatrixFilter;
   
   class ColorMatrixFilterPlugin extends FilterPlugin
   {

      public static inline var API:Float = 1;
      
      private static var _propNames:Array<String> = [];
      
      private static var _lumG:Float = 0.71516;
      
      private static var _lumR:Float = 0.212671;
      
      private static var _idMatrix:Array<Float> = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      private static var _lumB:Float = 0.072169;
       
      private var _matrix:Array<Float>;
      
      private var _matrixTween:com.greensock.plugins.EndArrayPlugin;
      
      public function new()
      {
         super();
         this.propName = "colorMatrixFilter";
         this.overwriteProps = ["colorMatrixFilter"];
      }
      
      public static function setSaturation(m:Array<Float>, n:Float) : Array<Float>
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         var inv:Float = 1 - n;
         var r:Float = inv * _lumR;
         var g:Float = inv * _lumG;
         var b:Float = inv * _lumB;
         var temp:Array<Float> = [r + n,g,b,0,0,r,g + n,b,0,0,r,g,b + n,0,0,0,0,0,1,0];
         return applyMatrix(temp,m);
      }
      
      public static function setHue(m:Array<Float>, n:Float) : Array<Float>
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         n = n * (Math.PI / 180);
         var c:Float = Math.cos(n);
         var s:Float = Math.sin(n);
         var temp:Array<Float> = [_lumR + c * (1 - _lumR) + s * -_lumR,_lumG + c * -_lumG + s * -_lumG,_lumB + c * -_lumB + s * (1 - _lumB),0,0,_lumR + c * -_lumR + s * 0.143,_lumG + c * (1 - _lumG) + s * 0.14,_lumB + c * -_lumB + s * -0.283,0,0,_lumR + c * -_lumR + s * -(1 - _lumR),_lumG + c * -_lumG + s * _lumG,_lumB + c * (1 - _lumB) + s * _lumB,0,0,0,0,0,1,0,0,0,0,0,1];
         return applyMatrix(temp,m);
      }
      
      public static function setContrast(m:Array<Float>, n:Float) : Array<Float>
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         n = n + 0.01;
         var temp:Array<Float> = [n,0,0,0,128 * (1 - n),0,n,0,0,128 * (1 - n),0,0,n,0,128 * (1 - n),0,0,0,1,0];
         return applyMatrix(temp,m);
      }
      
      public static function applyMatrix(m:Array<Float>, m2:Array<Float>) : Array<Float>
      {
         var y:Int = 0;
         var x:Int = 0;
         if(!Std.is(m, Array) || !Std.is(m2, Array))
         {
            return m2;
         }
         var temp:Array<Float> = [];
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
      
      public static function setThreshold(m:Array<Float>, n:Float) : Array<Float>
      {
         if(Math.isNaN(n))
         {
            return m;
         }
         var temp:Array<Float> = [_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,0,0,0,1,0];
         return applyMatrix(temp,m);
      }
      
      public static function colorize(m:Array<Float>, color:Int, amount:Float = 1) : Array<Float>
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
         var temp:Array<Float> = [inv + amount * r * _lumR,amount * r * _lumG,amount * r * _lumB,0,0,amount * g * _lumR,inv + amount * g * _lumG,amount * g * _lumB,0,0,amount * b * _lumR,amount * b * _lumG,inv + amount * b * _lumB,0,0,0,0,0,1,0];
         return applyMatrix(temp,m);
      }
      
      public static function setBrightness(m:Array<Float>, n:Float) : Array<Float>
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

         initFilter( map,new ColorMatrixFilter(_idMatrix.slice(0)),_propNames);
         _matrix = cast(_filter, ColorMatrixFilter).matrix;
         var endMatrix:Array<Float> = [];
         if( cmf.matrix != null && Std.is(cmf.matrix, Array))
         {
            endMatrix = cmf.matrix;
         }
         else
         {
            if(cmf.relative == true)
            {
               endMatrix = _matrix.slice(0);
            }
            else
            {
               endMatrix = _idMatrix.slice(0);
            }
            endMatrix = setBrightness(endMatrix,cmf.brightness);
            endMatrix = setContrast(endMatrix,cmf.contrast);
            endMatrix = setHue(endMatrix,cmf.hue);
            endMatrix = setSaturation(endMatrix,cmf.saturation);
            endMatrix = setThreshold(endMatrix,cmf.threshold);
            if(!Math.isNaN(cmf.colorize))
            {
               endMatrix = colorize(endMatrix,cmf.colorize,cmf.amount);
            }
         }
         _matrixTween = new com.greensock.plugins.EndArrayPlugin();
         _matrixTween.init(_matrix,endMatrix);
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         _matrixTween.changeFactor = n;
         cast(_filter, ColorMatrixFilter).matrix = _matrix;
         super.changeFactor = n;
      }
   }
