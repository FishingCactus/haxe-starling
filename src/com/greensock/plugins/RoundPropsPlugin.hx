package com.greensock.plugins;
   import com.greensock.core.PropTween;
   
   
   class RoundPropsPlugin extends TweenPlugin
   {
      
      public static inline var API:Float = 1;
       
      private var _tween:TweenLite;
      
      public function new()
      {
         super();
         this.propName = "roundProps";
         this.overwriteProps = ["roundProps"];
         this.round = true;
         this.priority = -1;
         this.onInitAllProps = _initAllProps;
      }
      
      public function add(object:Dynamic, propName:String, start:Float, change:Float) : Void
      {
         addTween(object,propName,start,start + change,propName);
         this.overwriteProps[this.overwriteProps.length] = propName;
      }
      
      private function _removePropTween(propTween:PropTween) : Void
      {
         if(propTween.nextNode!=null)
         {
            propTween.nextNode.prevNode = propTween.prevNode;
         }
         if(propTween.prevNode!=null)
         {
            propTween.prevNode.nextNode = propTween.nextNode;
         }
         else if(_tween.cachedPT1 == propTween)
         {
            _tween.cachedPT1 = propTween.nextNode;
         }
         if(cast(propTween.isPlugin, Bool) && cast(propTween.target.onDisable, Bool))
         {
            propTween.target.onDisable();
         }
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         _tween = tween;
         this.overwriteProps = this.overwriteProps.concat(cast value);
         return true;
      }
      
      private function _initAllProps(dummy:Dynamic) : Void
      {
         var prop:String = null;
         var multiProps:String = null;
         var pt:PropTween = null;
         var rp:Array<String> = _tween.vars.roundProps;
         var i:Int = rp.length;
         while(--i > -1)
         {
            prop = rp[i];
            pt = _tween.cachedPT1;
            while(pt != null)
            {
               if(pt.name == prop)
               {
                  if(pt.isPlugin)
                  {
                     pt.target.round = true;
                  }
                  else
                  {
                     add(pt.target,prop,pt.start,pt.change);
                     _removePropTween(pt);
                     _tween.propTweenLookup[prop] = _tween.propTweenLookup["roundProps"];
                  }
               }
               else if(cast(pt.isPlugin, Bool) && cast(pt.name == "_MULTIPLE_", Bool) && cast(!pt.target.round, Bool))
               {
                  multiProps = " " + pt.target.overwriteProps.join(" ") + " ";
                  if(multiProps.indexOf(" " + prop + " ") != -1)
                  {
                     pt.target.round = true;
                  }
               }
               pt = pt.nextNode;
            }
         }
      }
   }
