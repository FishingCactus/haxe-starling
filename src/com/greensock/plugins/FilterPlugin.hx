package com.greensock.plugins;
   import flash.filters.BitmapFilter;
   import com.greensock.core.PropTween;

   class FilterPlugin extends TweenPlugin
   {

      public static inline var VERSION:Float = 2.03;

      public static inline var API:Float = 1;

      private var _remove:Bool;

      private var _target:Dynamic;

      private var _index:Int;

      private var _filter:BitmapFilter;

      private var _type:Class<Dynamic>;

      public function new()
      {
         super();
      }

      public function onCompleteTween() : Void
      {
         var filters:Array<Int> = null;
         var i:Int = 0;
         if(_remove)
         {
            filters = _target.filters;
            if(!(Std.is(filters[_index], _type)))
            {
               i = filters.length;
               while(i-->0)
               {
                  if(Std.is(filters[i], _type))
                  {
                     filters.splice(i,1);
                     break;
                  }
               }
            }
            else
            {
               filters.splice(_index,1);
            }
            _target.filters = filters;
         }
      }

      private function initFilter(props:Map<String, Dynamic>, defaultFilter:BitmapFilter, propNames:Array<String>) : Void
      {
         var p:String = null;
         var i:Int = 0;
         var colorTween:HexColorsPlugin = null;
         var filters:Array<BitmapFilter> = _target.filters;
         var extras:Dynamic = Std.is(props, BitmapFilter)?{}:props;
         _index = -1;
         if(extras.index != null)
         {
            _index = extras.index;
         }
         else
         {
            i = filters.length;
            while(i-->0)
            {
               if(Std.is(filters[i], _type))
               {
                  _index = i;
                  break;
               }
            }
         }
         if(cast(_index == -1, Bool) || cast(filters[_index] == null, Bool) || cast(extras.addFilter == true, Bool))
         {
            _index = extras.index != null?cast(extras.index, Int):cast(filters.length, Int);
            filters[_index] = defaultFilter;
            _target.filters = filters;
         }
         _filter = filters[_index];
         if(extras.remove == true)
         {
            _remove = true;
            this.onComplete = onCompleteTween;
         }
         i = propNames.length;
         while(i-->0)
         {
            p = propNames[i];
            if(props.exists(p) && Reflect.getProperty(_filter,p) != props[p])
            {
               if(cast(p == "color", Bool) || cast(p == "highlightColor", Bool) || cast(p == "shadowColor", Bool))
               {
                  colorTween = new HexColorsPlugin();
                  colorTween.initColor(_filter,p,Reflect.getProperty(_filter,p),props[p]);
                  _tweens[_tweens.length] = new PropTween(colorTween,"changeFactor",0,1,p,false);
               }
               else if(cast(p == "quality", Bool) || cast(p == "inner", Bool) || cast(p == "knockout", Bool) || cast(p == "hideObject", Bool))
               {
                  Reflect.setProperty(_filter,p, props[p]);
               }
               else
               {
                  addTween(_filter,p,Reflect.getProperty(_filter,p),props[p],p);
               }
            }
         }
      }

      override public  function set_changeFactor(n:Float):Float
      {
         var ti:PropTween = null;
         var i:Int = _tweens.length;
         var filters:Array<BitmapFilter> = _target.filters;
         while(i-->0)
         {
            ti = _tweens[i];
            Reflect.setProperty( ti.target, ti.property, ti.start + ti.change * n);
         }
         if(!(Std.is(filters[_index], _type)))
         {
            i = _index = filters.length;
            while(i-->0)
            {
               if(Std.is(filters[i], _type))
               {
                  _index = i;
                  break;
               }
            }
         }
         filters[_index] = _filter;
         _target.filters = filters;
         return n;
      }
   }
