package com.greensock.easing;
   class RoughEase
   {

		public var name(get, set):String;

      
      private static var _count:UInt = 0;
      
      private static var _lookup:Dynamic = {};
       
      private var _first:EasePoint;
      
      private var _last:EasePoint;
      
      private var _name:String;
      
      public function new(strength:Float = 1, points:UInt = 20, restrictMaxAndMin:Bool = false, templateEase:Function = null, taper:String = "none", randomize:Bool = true, name:String = "")
      {
         var x:Float = NaN;
         var y:Float = NaN;
         var bump:Float = NaN;
         var invX:Float = NaN;
         var obj:Dynamic = null;
         super();
         if(name == "")
         {
            _name = "roughEase" + _count++;
         }
         else
         {
            _name = name;
            _lookup[_name] = this;
         }
         if(cast(taper == "", Bool) || cast(taper == null, Bool))
         {
            taper = "none";
         }
         var a:Array<Int> = [];
         var cnt:Int = 0;
         strength = strength * 0.4;
         var i:Int = points;
         while(--i > -1)
         {
            x = !!randomize?cast(Math.random(), Float):cast(1 / points * i, Float);
            y = templateEase != null?cast(templateEase(x,0,1,1), Float):cast(x, Float);
            if(taper == "none")
            {
               bump = strength;
            }
            else if(taper == "out")
            {
               invX = 1 - x;
               bump = invX * invX * strength;
            }
            else if(taper == "in")
            {
               bump = x * x * strength;
            }
            else if(x < 0.5)
            {
               invX = x * 2;
               bump = invX * invX * 0.5 * strength;
            }
            else
            {
               invX = (1 - x) * 2;
               bump = invX * invX * 0.5 * strength;
            }
            if(randomize)
            {
               y = y + (Math.random() * bump - bump * 0.5);
            }
            else if(i % 2)
            {
               y = y + bump * 0.5;
            }
            else
            {
               y = y - bump * 0.5;
            }
            if(restrictMaxAndMin)
            {
               if(y > 1)
               {
                  y = 1;
               }
               else if(y < 0)
               {
                  y = 0;
               }
            }
            a[cnt++] = {
               "x":x,
               "y":y
            };
         }
         a.sortOn("x",Array<Int>.NUMERIC);
         _first = _last = new EasePoint(1,1,null);
         i = points;
         while(--i > -1)
         {
            obj = a[i];
            _first = new EasePoint(obj.x,obj.y,_first);
         }
         _first = new EasePoint(0,0,_first.time != 0?_first:_first.next);
      }
      
      public static function byName(name:String) : Function
      {
         return _lookup[name].ease;
      }
      
      public static function create(strength:Float = 1, points:UInt = 20, restrictMaxAndMin:Bool = false, templateEase:Function = null, taper:String = "none", randomize:Bool = true, name:String = "") : Function
      {
         var re:RoughEase = new RoughEase(strength,points,restrictMaxAndMin,templateEase,taper,randomize,name);
         return re.ease;
      }
      
      public  function set_name(value)
      {
         _lookup.remove(_name);
         _name = value;
         _lookup[_name] = this;
      }
      
      public  function get_name()
      {
         return _name;
      }
      
      public function ease(t:Float, b:Float, c:Float, d:Float) : Float
      {
         var p:EasePoint = null;
         var time:Float = t / d;
         if(time < 0.5)
         {
            p = _first;
            while(p.time <= time)
            {
               p = p.next;
            }
            p = p.prev;
         }
         else
         {
            p = _last;
            while(p.time >= time)
            {
               p = p.prev;
            }
         }
         return b + (p.value + (time - p.time) / p.gap * p.change) * c;
      }
      
      public function dispose() : Void
      {
         _lookup.remove(_name);
      }
   }
}

class EasePoint
{
    
   public var prev:EasePoint;
   
   public var time:Float;
   
   public var change:Float;
   
   public var value:Float;
   
   public var next:EasePoint;
   
   public var gap:Float;
   
   function new(time:Float, value:Float, next:EasePoint)
   {
      super();
      this.time = time;
      this.value = value;
      if(next)
      {
         this.next = next;
         next.prev = this;
         this.change = next.value - value;
         this.gap = next.time - time;
      }
   }
