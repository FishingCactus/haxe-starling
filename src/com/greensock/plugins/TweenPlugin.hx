package com.greensock.plugins;

   import com.greensock.core.PropTween;

   class TweenPlugin
   {

	  public var changeFactor(get, set):Float;

      public static inline var VERSION:Float = 1.4;

      public static inline var API:Float = 1;

      public var activeDisable:Bool;

      public var onInitAllProps:Dynamic->Void;

      private var _tweens:Array<PropTween>;

      public var onDisable:Void->Void;

      public var propName:String;

      public var onEnable:Void->Void;

      public var round:Bool;

      public var priority:Int = 0;

      public var overwriteProps:Array<String>;

      public var onComplete:Void->Void;

      private var _changeFactor:Float = 0;

      public function new()
      {
         _tweens = [];
      }

      public static function activate(plugins:Array<Class<Dynamic>>) : Bool
      {
         var instance:Dynamic = null;
         TweenLite.onPluginEvent = TweenPlugin.onTweenEvent;
         var i:Int = plugins.length;
         while(i-->0)
         {
            if(Reflect.hasField( plugins[i], "API"))
            {
               instance = Type.createEmptyInstance(plugins[i]);
               TweenLite.plugins[instance.propName] = plugins[i];
            }
         }
         return true;
      }

      private static function onTweenEvent(type:String, tween:TweenLite) : Bool
      {
         var changed:Bool = false;
         var tweens:Array<PropTween> = null;
         var i:Int = 0;
         var pt:PropTween = tween.cachedPT1;
         if(type == "onInitAllProps")
         {
            tweens = [];
            i = 0;
            while(pt!=null)
            {
               tweens[i++] = pt;
               pt = pt.nextNode;
            }
            throw ":TODO: sortOn";
            //tweens.sortOn("priority",Array<Int>.NUMERIC | Array<Int>.DESCENDING);
            while(--i > -1)
            {
               tweens[i].nextNode = tweens[i + 1];
               tweens[i].prevNode = tweens[i - 1];
            }
            pt = tween.cachedPT1 = tweens[0];
         }
         while(pt!= null)
         {
            if(pt.isPlugin && Reflect.hasField(pt.target, type))
            {
               if(pt.target.activeDisable)
               {
                  changed = true;
               }
               Reflect.getProperty(pt.target,type)();
            }
            pt = pt.nextNode;
         }
         return changed;
      }

      public function set_changeFactor(n:Float):Float
      {
         updateTweens(n);
         return _changeFactor = n;
      }

      private function updateTweens(changeFactor:Float) : Void
      {
         var pt:PropTween = null;
         var val:Float = Math.NaN;
         var i:Int = _tweens.length;
         if(this.round)
         {
            while(--i > -1)
            {
               pt = _tweens[i];
               val = pt.start + pt.change * changeFactor;
               if(val > 0)
               {
                  Reflect.setProperty( pt.target, pt.property, Std.int(val + 0.5));
               }
               else
               {
                  Reflect.setProperty( pt.target, pt.property, Std.int(val - 0.5));
               }
            }
         }
         else
         {
            while(--i > -1)
            {
               pt = _tweens[i];
               Reflect.setProperty( pt.target, pt.property, pt.start + pt.change * changeFactor);
            }
         }
      }

      private function addTween(object:Dynamic, propName:String, start:Float, end:Dynamic, overwriteProp:String = null) : Void
      {
         var change:Float = Math.NaN;
         if(end != null)
         {
            change = Std.is(end, Float)?(cast(end, Float) - start):cast(end, Float);
            if(change != 0)
            {
               _tweens[_tweens.length] = new PropTween(object,propName,start,change,overwriteProp != null ? overwriteProp : propName,false);
            }
         }
      }

      public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         addTween(target,this.propName,Reflect.getProperty(target, this.propName),value,this.propName);
         return true;
      }

      public  function get_changeFactor()
      {
         return _changeFactor;
      }

      public function killProps(lookup:Dynamic) : Void
      {
         var i:Int = this.overwriteProps.length;
         while(--i > -1)
         {
            if(lookup.contains(this.overwriteProps[i]))
            {
               this.overwriteProps.splice(i,1);
            }
         }
         i = _tweens.length;
         while(--i > -1)
         {
            if(lookup.contains(_tweens[i].name))
            {
               _tweens.splice(i,1);
            }
         }
      }
   }
