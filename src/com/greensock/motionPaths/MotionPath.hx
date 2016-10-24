package com.greensock.motionPaths;
   import flash.display.Shape;
   import flash.events.Event;

   import com.greensock.motionPaths.PathFollower;

   class MotionPath extends Shape
   {

		public var targets(get, null):Array<Dynamic>;
		public var rawProgress(get, set):Float;
		public var followers(get, null):Array<PathFollower>;
		public var progress(get, set):Float;

      private static var _RAD2DEG:Float = 180 / Math.PI;

      private static var _DEG2RAD:Float = Math.PI / 180;

      private var _progress:Float;

      private var _scaleMode:String;

      private var _redrawLine:Bool;

      private var _rawProgress:Float;

      private var _caps:String;

      private var _lineAlpha:Float;

      private var _joints:String;

      private var _miterLimit:Float;

      private var _color:UInt;

      private var _pixelHinting:Bool;

      private var _thickness:Float;

      private var _rootFollower:com.greensock.motionPaths.PathFollower;

      public function new()
      {
         super();
         _progress = _rawProgress = 0;
         lineStyle(1,6710886,1,false,"none",null,null,3,true);
         this.addEventListener(Event.ADDED_TO_STAGE,onAddedToStage,false,0,true);
      }

      public override function set_y(value:Float):Float
      {
         super.y = value;
         update();
         return value;
      }

      public  function get_targets() : Array<Dynamic>
      {
         var a:Array<Dynamic> = [];
         var cnt:UInt = 0;
         var f:com.greensock.motionPaths.PathFollower = _rootFollower;
         while(f!=null)
         {
            a[cnt++] = f.target;
            f = f.cachedNext;
         }
         return a;
      }

      public  function get_rawProgress()
      {
         return _rawProgress;
      }

      public function renderObjectAt(target:Dynamic, progress:Float, autoRotate:Bool = false, rotationOffset:Float = 0) : Void
      {
      }

      public override function set_width(value:Float):Float
      {
         super.width = value;
         update();
         return value;
      }

      public function getFollower(target:Dynamic) : com.greensock.motionPaths.PathFollower
      {
         if(Std.is(target, PathFollower))
         {
            return cast(target, PathFollower);
         }
         var f:com.greensock.motionPaths.PathFollower = _rootFollower;
         while(f!=null)
         {
            if(f.target == target)
            {
               return f;
            }
            f = f.cachedNext;
         }
         return null;
      }

      private function _normalize(num:Float) : Float
      {
         if(num > 1)
         {
            num = num - cast(num, Int);
         }
         else if(num < 0)
         {
            num = num - (cast(num, Int) - 1);
         }
         return num;
      }

      public function lineStyle(thickness:Float = 1, color:UInt = 6710886, alpha:Float = 1, pixelHinting:Bool = false, scaleMode:String = "none", caps:String = null, joints:String = null, miterLimit:Float = 3, skipRedraw:Bool = false) : Void
      {
         _thickness = thickness;
         _color = color;
         _lineAlpha = alpha;
         _pixelHinting = pixelHinting;
         _scaleMode = scaleMode;
         _caps = caps;
         _joints = joints;
         _miterLimit = miterLimit;
         _redrawLine = true;
         if(!skipRedraw)
         {
            update();
         }
      }

      public override function set_scaleY(value:Float):Float
      {
         super.scaleY = value;
         update();
         return value;
      }

      public function removeAllFollowers() : Void
      {
         var next:com.greensock.motionPaths.PathFollower = null;
         var f:com.greensock.motionPaths.PathFollower = _rootFollower;
         while(f!=null)
         {
            next = f.cachedNext;
            f.cachedNext = f.cachedPrev = null;
            f.path = null;
            f = next;
         }
         _rootFollower = null;
      }

      private function onAddedToStage(event:Event) : Void
      {
         update();
      }

      public override function set_scaleX(value:Float):Float
      {
         super.scaleX = value;
         update();
         return value;
      }

      public  function get_followers() :Array<PathFollower>
      {
         var a:Array<PathFollower> = [];
         var cnt:UInt = 0;
         var f:PathFollower = _rootFollower;
         while(f!=null)
         {
            a[cnt++] = f;
            f = f.cachedNext;
         }
         return a;
      }

      public  function get_progress()
      {
         return _progress;
      }

      public function removeFollower(target:Dynamic) : Void
      {
         var f:com.greensock.motionPaths.PathFollower = getFollower(target);
         if(f == null)
         {
            return;
         }
         if(f.cachedNext!=null)
         {
            f.cachedNext.cachedPrev = f.cachedPrev;
         }
         if(f.cachedPrev!=null)
         {
            f.cachedPrev.cachedNext = f.cachedNext;
         }
         else if(_rootFollower == f)
         {
            _rootFollower = f.cachedNext;
         }
         f.cachedNext = f.cachedPrev = null;
         f.path = null;
      }

      public function update(event:Event = null) : Void
      {
      }

      public  function set_progress(value:Float) : Float
      {
         if(value > 1)
         {
            _rawProgress = value;
            value = value - cast(value, Int);
            if(value == 0)
            {
               value = 1;
            }
         }
         else if(value < 0)
         {
            _rawProgress = value;
            value = value - (cast(value, Int) - 1);
         }
         else
         {
            _rawProgress = cast(_rawProgress, Int) + value;
         }
         var dif:Float = value - _progress;
         var f:com.greensock.motionPaths.PathFollower = _rootFollower;
         while(f!=null)
         {
            f.cachedProgress = f.cachedProgress + dif;
            f.cachedRawProgress = f.cachedRawProgress + dif;
            if(f.cachedProgress > 1)
            {
               f.cachedProgress = f.cachedProgress - cast(f.cachedProgress, Int);
               if(f.cachedProgress == 0)
               {
                  f.cachedProgress = 1;
               }
            }
            else if(f.cachedProgress < 0)
            {
               f.cachedProgress = f.cachedProgress - (cast(f.cachedProgress, Int) - 1);
            }
            f = f.cachedNext;
         }
         _progress = value;
         update();
         return value;
      }

      public override function set_height(value:Float) : Float
      {
         super.height = value;
         update();
         return value;
      }

      public function addFollower(target:Dynamic, progress:Float = 0, autoRotate:Bool = false, rotationOffset:Float = 0) : com.greensock.motionPaths.PathFollower
      {
         var f:com.greensock.motionPaths.PathFollower = getFollower(target);
         if(f == null)
         {
            f = new com.greensock.motionPaths.PathFollower(target);
         }
         f.autoRotate = autoRotate;
         f.rotationOffset = rotationOffset;
         if(f.path != this)
         {
            if(_rootFollower!=null)
            {
               _rootFollower.cachedPrev = f;
            }
            f.cachedNext = _rootFollower;
            _rootFollower = f;
            f.path = this;
            f.progress = progress;
         }
         return f;
      }

      public function distribute(targets:Array<PathFollower> = null, min:Float = 0, max:Float = 1, autoRotate:Bool = false, rotationOffset:Float = 0) : Void
      {
         var f:com.greensock.motionPaths.PathFollower = null;
         if(targets == null)
         {
            targets = this.followers;
         }
         min = _normalize(min);
         max = _normalize(max);
         var i:Int = targets.length;
         var space:Float = i > 1?cast((max - min) / (i - 1), Float):cast(1, Float);
         while(--i > -1)
         {
            f = getFollower(targets[i]);
            if(f == null)
            {
               f = this.addFollower(targets[i],0,autoRotate,rotationOffset);
            }
            f.cachedProgress = f.cachedRawProgress = min + space * i;
            this.renderObjectAt(f.target,f.cachedProgress,autoRotate,rotationOffset);
         }
      }

      public override function set_visible(value:Bool) : Bool
      {
         super.visible = value;
         _redrawLine = true;
         update();
         return value;
      }

      public override function set_x(value:Float):Float
      {
         super.x = value;
         update();
         return value;
      }

      public function set_rawProgress(value)
      {
         return this.progress = value;
      }

      public override function set_rotation(value:Float):Float
      {
         super.rotation = value;
         update();
         return value;
      }
   }
