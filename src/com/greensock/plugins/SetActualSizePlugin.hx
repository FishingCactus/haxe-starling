package com.greensock.plugins;
   
   
   class SetActualSizePlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _setWidth:Bool;
      
      public var width:Float;
      
      public var height:Float;
      
      private var _hasSetSize:Bool;
      
      private var _setHeight:Bool;
      
      private var _target:Object;
      
      public function new()
      {
         super();
         this.propName = "setActualSize";
         this.overwriteProps = ["setActualSize","setSize","width","height","scaleX","scaleY"];
         this.round = true;
      }
      
      override public function killProps(lookup:Object) : Void
      {
         super.killProps(lookup);
         if(cast(_tweens.length == 0, Bool) || cast("setActualSize" in lookup, Bool))
         {
            this.overwriteProps = [];
         }
      }
      
      override public function onInitTween(target:Object, value:Dynamic, tween:TweenLite) : Bool
      {
         _target = target;
         _hasSetSize = cast("setActualSize" in _target, Bool);
         if(cast("width" in value, Bool) && cast(_target.width != value.width, Bool))
         {
            addTween(!!_hasSetSize?this:_target,"width",_target.width,value.width,"width");
            _setWidth = _hasSetSize;
         }
         if(cast("height" in value, Bool) && cast(_target.height != value.height, Bool))
         {
            addTween(!!_hasSetSize?this:_target,"height",_target.height,value.height,"height");
            _setHeight = _hasSetSize;
         }
         if(_tweens.length == 0)
         {
            _hasSetSize = false;
         }
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         updateTweens(n);
         if(_hasSetSize)
         {
            _target.setActualSize(!!_setWidth?this.width:_target.width,!!_setHeight?this.height:_target.height);
         }
      }
   }
