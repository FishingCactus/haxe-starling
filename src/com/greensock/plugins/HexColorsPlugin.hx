package com.greensock.plugins;


   class HexColorsPlugin extends TweenPlugin
   {

      public static inline var API:Float = 1;

      private var _colors:Array<Array<Dynamic>>;

      public function new()
      {
         super();
         this.propName = "hexColors";
         this.overwriteProps = [];
         _colors = [];
      }

      override public function killProps(lookup:Dynamic) : Void
      {
         var i:Int = _colors.length - 1;

         while( (--i) > -1)
         {
            if(Reflect.hasField( lookup, cast(_colors[i][1], String) ))
            {
               _colors.splice(i,1);
            }
         }
         super.killProps(lookup);
      }

      public function initColor(target:Dynamic, propName:String, start:UInt, end:UInt) : Void
      {
         var r:Float = Math.NaN;
         var g:Float = Math.NaN;
         var b:Float = Math.NaN;
         if(start != end)
         {
            r = start >> 16;
            g = start >> 8 & 255;
            b = start & 255;
            _colors[_colors.length] = [target,propName,r,(end >> 16) - r,g,(end >> 8 & 255) - g,b,(end & 255) - b];
            this.overwriteProps[this.overwriteProps.length] = propName;
         }
      }

      override public  function set_changeFactor(n:Float):Float
      {
         var a:Array<Dynamic> = null;
         var i:Int = _colors.length;
         while(--i > -1)
         {
            a = _colors[i];
            a[0][a[1]] = a[2] + n * a[3] << 16 | a[4] + n * a[5] << 8 | a[6] + n * a[7];
         }

         return n;
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         throw ":TODO:";
         /*
         for(p in value)
         {
            initColor(target,p,cast(target[p], UInt),cast(value[p], UInt));
         }
         */
         return true;
      }
   }
