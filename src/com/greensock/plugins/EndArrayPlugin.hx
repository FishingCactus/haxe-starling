package com.greensock.plugins;
   
    class ArrayTweenInfo
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
}
      
   class EndArrayPlugin extends TweenPlugin
   {
      public static inline var API:Float = 1;
       
      private var _a:Array<Int>;
      
      private var _info:Array<Int>;
      
      public function new()
      {
         _info = [];
         super();
         this.propName = "endArray";
         this.overwriteProps = ["endArray"];
      }
      
      public function init(start:Array<Int>, end:Array<Int>) : Void
      {
         _a = start;
         var i:Int = end.length;
         while(i--)
         {
            if(cast(start[i] != end[i], Bool) && cast(start[i] != null, Bool))
            {
               _info[_info.length] = new ArrayTweenInfo(i,_a[i],end[i] - _a[i]);
            }
         }
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         if(!Std.is(target, Array) || !Std.is(value, Array))
         {
            return false;
         }
         init(cast(target, Array),value);
         return true;
      }
      
      override public  function set_changeFactor(n)
      {
         var ti:ArrayTweenInfo = null;
         var val:Float = NaN;
         var i:Int = _info.length;
         if(this.round)
         {
            while(i--)
            {
               ti = _info[i];
               val = ti.start + ti.change * n;
               if(val > 0)
               {
                  _a[ti.index] = val + 0.5 >> 0;
               }
               else
               {
                  _a[ti.index] = val - 0.5 >> 0;
               }
            }
         }
         else
         {
            while(i--)
            {
               ti = _info[i];
               _a[ti.index] = ti.start + ti.change * n;
            }
         }
      }
   }
