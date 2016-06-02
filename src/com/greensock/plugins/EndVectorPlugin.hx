package com.greensock.plugins;
   
   
   class EndVectorPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
       
      private var _v:Vector<Float>;
      
      private var _info:Vector<VectorInfo>;
      
      public function new()
      {
         _info = new Vector<EndVectorPlugin>();
         super();
         this.propName = "endVector";
         this.overwriteProps = ["endVector"];
      }
      
      public function init(start:Vector<Float>, end:Vector<Float>) : Void
      {
         _v = start;
         var i:Int = end.length;
         var cnt:UInt = 0;
         while(i--)
         {
            if(_v[i] != end[i])
            {
               _info[cnt++] = new VectorInfo(i,_v[i],end[i] - _v[i]);
            }
         }
      }
      
      override public  function set_changeFactor(n)
      {
         var vi:VectorInfo = null;
         var val:Float = NaN;
         var i:Int = _info.length;
         if(this.round)
         {
            while(i--)
            {
               vi = _info[i];
               val = vi.start + vi.change * n;
               if(val > 0)
               {
                  _v[vi.index] = val + 0.5 >> 0;
               }
               else
               {
                  _v[vi.index] = val - 0.5 >> 0;
               }
            }
         }
         else
         {
            while(i--)
            {
               vi = _info[i];
               _v[vi.index] = vi.start + vi.change * n;
            }
         }
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(cast(!(Std.is(target, Vector<Float>)), Bool) || cast(!(Std.is(value, Vector<Float>)), Bool))
         {
            return false;
         }
         init(cast(target, Vector<Float>),cast(value, Vector<Float>));
         return true;
      }
   }
}

class VectorInfo
{
    
   public var change:Float;
   
   public var start:Float;
   
   public var index:UInt;
   
   function new(index:UInt, start:Float, change:Float)
   {
      super();
      this.index = index;
      this.start = start;
      this.change = change;
   }
