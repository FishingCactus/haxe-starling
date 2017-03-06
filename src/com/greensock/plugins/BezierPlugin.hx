package com.greensock.plugins;

    class OrientData{

    }

   class BezierPlugin extends TweenPlugin
   {

      public static inline var API:Float = 1;

      private static var _RAD2DEG:Float = 180 / Math.PI;

      private var _future:Dynamic;

      private var _orient:Bool;

      private var _orientData:Array<Array<Dynamic>>;

      private var _target:Dynamic;

      private var _beziers:Array<Array<Array<Float>>>;

      public function new()
      {
         _future = {};
         super();
         this.propName = "bezier";
         this.overwriteProps = [];
      }

      public static function parseBeziers(props:Dynamic, through:Bool = false) : Dynamic
      {
             throw ":TODO: Dynamic iteration";
         //var a:Array<Int> = null;
         //var b:Dynamic = null;
         var all:Dynamic = {};
         if(through)
         {
             /*
            for(p in props)
            {
               a = props[p];
               all[p] = b = [];
               if(a.length > 2)
               {
                  b[b.length] = [a[0],a[1] - (a[2] - a[0]) / 4,a[1]];
                  for( i in (1)...(a.length - 1) )
                  {
                     b[b.length] = [a[i],a[i] + (a[i] - b[i - 1][1]),a[i + 1]];
                  }
               }
               else
               {
                  b[b.length] = [a[0],(a[0] + a[1]) / 2,a[1]];
               }
           }*/
         }
         else
         {
             /*
            for(p in props)
            {
               a = props[p];
               all[p] = b = [];
               if(a.length > 3)
               {
                  b[b.length] = [a[0],a[1],(a[1] + a[2]) / 2];
                  for( i in (2)...(a.length - 2) )
                  {
                     b[b.length] = [b[i - 2][2],a[i],(a[i] + a[i + 1]) / 2];
                  }
                  b[b.length] = [b[b.length - 1][2],a[a.length - 2],a[a.length - 1]];
               }
               else if(a.length == 3)
               {
                  b[b.length] = [a[0],a[1],a[2]];
               }
               else if(a.length == 2)
               {
                  b[b.length] = [a[0],(a[0] + a[1]) / 2,a[1]];
               }
           }*/
         }
         return all;
      }

      override public function killProps(lookup:Dynamic) : Void
      {
          throw ":TODO:";
         /*
         var p:Dynamic = null;
         for(p in _beziers)
         {
            if(p in lookup)
            {
               _beziers.remove(p);
            }
         }
         super.killProps(lookup);
         */
      }

      private function init(tween:TweenLite, beziers:Array<Array<Int>>, through:Bool) : Void
      {
          throw ":TODO:";
          /*
         var i:Int = 0;
         var p:Dynamic = null;
         var killVarsLookup:Dynamic = null;
         _target = tween.target;
         var enumerables:Dynamic = tween.vars.isTV == true?tween.vars.exposedVars:tween.vars;
         if(enumerables.orientToBezier == true)
         {
            _orientData = [["x","y","rotation",0,0.01]];
            _orient = true;
         }
         else if(Std.is(enumerables.orientToBezier, Array))
         {
            _orientData = enumerables.orientToBezier;
            _orient = true;
         }
         var props:Dynamic = {};
         for( i in (0)...(beziers.length) )
         {
            for(p in beziers[i])
            {
               if( props[p] == undefined)
               {
                  props[p] = [tween.target[p]];
               }
               if(Std.is( beziers[i][p], Float) )
               {
                  props[p].push(cast(beziers[i][p], Float));
               }
               else
               {
                  props[p].push(tween.target[p] + cast(beziers[i][p], Float));
               }
            }
         }
         for(this.overwriteProps[this.overwriteProps.length] in props)
         {
            if(enumerables[p] != undefined)
            {
               if(Std.is( enumerables[p], Float))
               {
                  props[p].push(enumerables[p]);
               }
               else
               {
                  props[p].push(tween.target[p] + cast(enumerables[p], Float));
               }
               killVarsLookup = {};
               killVarsLookup[p] = true;
               tween.killVars(killVarsLookup,false);
               enumerables.remove(p);
            }
         }
         _beziers = parseBeziers(props,through);
         */
      }

      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!(Std.is(value, Array)))
         {
            return false;
         }
         init(tween,value,false);
         return true;
      }

      override public function set_changeFactor(n)
      {
         var i:Int = 0;
         var b:Dynamic = null;
         var t:Float = Math.NaN;
         var segments:Int = 0;
         var val:Float = Math.NaN;
         //var curVals:Dynamic = null;
         //var dx:Float = Math.NaN;
         //var dy:Float = Math.NaN;
         //var cotb:Array<Float> = null;
         //var toAdd:Float = Math.NaN;
         var oldTarget:Dynamic = null;
         var oldRound:Bool = false;
         _changeFactor = n;
         if(n == 1)
         {
            for(p in 0..._beziers.length)
            {
               i = _beziers[p].length - 1;
               _target[p] = _beziers[p][i][2];
            }
         }
         else
         {
            for(p in 0..._beziers.length)
            {
               segments = _beziers[p].length;
               if(n < 0)
               {
                  i = 0;
               }
               else if(n >= 1)
               {
                  i = segments - 1;
               }
               else
               {
                  i = Std.int(segments * n);
               }
               t = (n - i * (1 / segments)) * segments;
               b = _beziers[p][i];
               if(this.round)
               {
                  val = b[0] + t * (2 * (1 - t) * (b[1] - b[0]) + t * (b[2] - b[0]));
                  if(val > 0)
                  {
                     _target[p] = Std.int(val + 0.5);
                  }
                  else
                  {
                     _target[p] = Std.int(val - 0.5);
                  }
               }
               else
               {
                  _target[p] = b[0] + t * (2 * (1 - t) * (b[1] - b[0]) + t * (b[2] - b[0]));
               }
            }
         }
         if(_orient)
         {
            i = _orientData.length;
            //curVals = {};
            while(i-->0)
            {
                throw ":TODO:";
                /*
               cotb = _orientData[i];
               curVals[cotb[0]] = _target[cotb[0]];
               curVals[cotb[1]] = _target[cotb[1]];
               */
            }
            oldTarget = _target;
            oldRound = this.round;
            _target = _future;
            this.round = false;
            _orient = false;
            i = _orientData.length;
            while(i-->0)
            {
                throw ":TODO:";
                /*
               cotb = _orientData[i];
               var cotb4:Float;
               var cotb3:Float;

               if( cotb.length >= 5 ){
                   cotb4 = cotb[4];
               } else {
                   cotb4 = 0.01;
               }

               if( cotb.length >= 4 ){
                   cotb3 = cotb[3];
               } else {
                   cotb3 = 0;
               }

               changeFactor = n + cotb4;
               toAdd = cotb[3];
               dx = _future[cotb[0]] - curVals[cotb[0]];
               dy = _future[cotb[1]] - curVals[cotb[1]];
               oldTarget[cotb[2]] = Math.atan2(dy,dx) * _RAD2DEG + toAdd;
               */
            }
            _target = oldTarget;
            this.round = oldRound;
            _orient = true;
        }

        return n;
     }
   }
