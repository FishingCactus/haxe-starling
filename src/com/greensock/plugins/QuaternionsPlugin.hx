package com.greensock.plugins;
   
   
   class QuaternionsPlugin extends TweenPlugin
   {

		public var changeFactor(null, set):Float;

      
      public static inline var API:Float = 1;
      
      private static inline var _RAD2DEG:Float = 180 / Math.PI;
       
      private var _target:Dynamic;
      
      private var _quaternions:Array<Int>;
      
      public function new()
      {
         _quaternions = [];
         super();
         this.propName = "quaternions";
         this.overwriteProps = [];
      }
      
      override public function killProps(lookup:Dynamic) : Void
      {
         for(var i:Int = _quaternions.length - 1; i > -1; i--)
         {
            if(lookup[_quaternions[i][1]] != undefined)
            {
               _quaternions.splice(i,1);
            }
         }
         super.killProps(lookup);
      }
      
      override public  function set_changeFactor(n)
      {
         var i:Int = 0;
         var q:Array<Int> = null;
         var scale:Float = NaN;
         var invScale:Float = NaN;
         for(i = _quaternions.length - 1; i > -1; i--)
         {
            q = _quaternions[i];
            if(q[10] + 1 > 1.0e-6)
            {
               if(1 - q[10] >= 1.0e-6)
               {
                  scale = Math.sin(q[11] * (1 - n)) * q[12];
                  invScale = Math.sin(q[11] * n) * q[12];
               }
               else
               {
                  scale = 1 - n;
                  invScale = n;
               }
            }
            else
            {
               scale = Math.sin(Math.PI * (0.5 - n));
               invScale = Math.sin(Math.PI * n);
            }
            q[0].x = scale * q[2] + invScale * q[3];
            q[0].y = scale * q[4] + invScale * q[5];
            q[0].z = scale * q[6] + invScale * q[7];
            q[0].w = scale * q[8] + invScale * q[9];
         }
      }
      
      override public function onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite) : Bool
      {
         var p:Dynamic = null;
         if(value == null)
         {
            return false;
         }
         for(p in value)
         {
            initQuaternion(target[p],value[p],p);
         }
         return true;
      }
      
      public function initQuaternion(start:Dynamic, end:Dynamic, propName:String) : Void
      {
         var angle:Float = NaN;
         var q1:Dynamic = null;
         var q2:Dynamic = null;
         var x1:Float = NaN;
         var x2:Float = NaN;
         var y1:Float = NaN;
         var y2:Float = NaN;
         var z1:Float = NaN;
         var z2:Float = NaN;
         var w1:Float = NaN;
         var w2:Float = NaN;
         var theta:Float = NaN;
         q1 = start;
         q2 = end;
         x1 = q1.x;
         x2 = q2.x;
         y1 = q1.y;
         y2 = q2.y;
         z1 = q1.z;
         z2 = q2.z;
         w1 = q1.w;
         w2 = q2.w;
         angle = x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2;
         if(angle < 0)
         {
            x1 = x1 * -1;
            y1 = y1 * -1;
            z1 = z1 * -1;
            w1 = w1 * -1;
            angle = angle * -1;
         }
         if(angle + 1 < 1.0e-6)
         {
            y2 = -y1;
            x2 = x1;
            w2 = -w1;
            z2 = z1;
         }
         theta = Math.acos(angle);
         _quaternions[_quaternions.length] = [q1,propName,x1,x2,y1,y2,z1,z2,w1,w2,angle,theta,1 / Math.sin(theta)];
         this.overwriteProps[this.overwriteProps.length] = propName;
      }
   }
