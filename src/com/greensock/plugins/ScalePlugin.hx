package com.greensock.plugins;
   
   
   class ScalePlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _changeX:Float;
      
      private var _changeY:Float;
      
      private var _target:Object;
      
      private var _startX:Float;
      
      private var _startY:Float;
      
      public function new()
      {
         super();
         this.propName = "scale";
         this.overwriteProps = ["scaleX","scaleY","width","height"];
      }
      
      override public function killProps(lookup:Object) : Void
      {
         var i:Int = this.overwriteProps.length;
         while(i--)
         {
            if(this.overwriteProps[i] in lookup)
            {
               this.overwriteProps = [];
               return;
            }
         }
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!target.hasOwnProperty("scaleX"))
         {
            return false;
         }
         _target = target;
         _startX = _target.scaleX;
         _startY = _target.scaleY;
         if(typeof value == "number")
         {
            _changeX = value - _startX;
            _changeY = value - _startY;
         }
         else
         {
            _changeX = _changeY = cast(value, Float);
         }
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         _target.scaleX = _startX + n * _changeX;
         _target.scaleY = _startY + n * _changeY;
      }
   }
