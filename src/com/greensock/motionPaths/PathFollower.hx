package com.greensock.motionPaths;
   class PathFollower
   {

		public var rawProgress(get, set):Float;
		public var progress(get, set):Float;


      public var path:com.greensock.motionPaths.MotionPath;

      public var cachedProgress:Float;

      public var target:Dynamic;

      public var cachedRawProgress:Float;

      public var cachedNext:com.greensock.motionPaths.PathFollower;

      public var autoRotate:Bool;

      public var rotationOffset:Float;

      public var cachedPrev:com.greensock.motionPaths.PathFollower;

      public function new(target:Dynamic, autoRotate:Bool = false, rotationOffset:Float = 0)
      {
         this.target = target;
         this.autoRotate = autoRotate;
         this.rotationOffset = rotationOffset;
         this.cachedProgress = this.cachedRawProgress = 0;
      }

      public function set_progress(value : Float) : Float
      {
         if(value > 1)
         {
            this.cachedRawProgress = value;
            this.cachedProgress = value - cast(value, Int);
            if(this.cachedProgress == 0)
            {
               this.cachedProgress = 1;
            }
         }
         else if(value < 0)
         {
            this.cachedRawProgress = value;
            this.cachedProgress = value - (cast(value, Int) - 1);
         }
         else
         {
            this.cachedRawProgress = cast(this.cachedRawProgress, Int) + value;
            this.cachedProgress = value;
         }
         if(this.path!=null)
         {
            this.path.renderObjectAt(this.target,this.cachedProgress,this.autoRotate,this.rotationOffset);
         }
         return value;
      }

      public  function set_rawProgress(value)
      {
         return this.progress = value;
      }

      public  function get_rawProgress()
      {
         return this.cachedRawProgress;
      }

      public  function get_progress()
      {
         return this.cachedProgress;
      }
   }
