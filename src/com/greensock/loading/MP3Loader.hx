package com.greensock.loading;
   import com.greensock.loading.core.LoaderItem;
   import flash.display.Shape;
   import flash.media.SoundChannel;
   import flash.events.Event;
   import flash.media.SoundLoaderContext;
   import com.greensock.events.LoaderEvent;
   import flash.media.SoundTransform;
   import flash.media.Sound;
   import flash.events.ProgressEvent;
   
   class MP3Loader extends LoaderItem
   {

		public var duration(get, null):Float;
		public var soundPaused(get, set):Bool;
		public var soundTime(get, set):Float;
		public var playProgress(get, set):Float;
		public var volume(get, set):Float;

      
      private static var _shape:Shape = new Shape();
      
      public static inline var SOUND_PAUSE:String = "soundPause";
      
      public static inline var SOUND_COMPLETE:String = "soundComplete";
      
      public static inline var SOUND_PLAY:String = "soundPlay";
      
      private static var _classActivated:Bool = _activateClass("MP3Loader",MP3Loader,"mp3");
      
      public static inline var PLAY_PROGRESS:String = "playProgress";
       
      private var _dispatchPlayProgress:Bool;
      
      public var channel:SoundChannel;
      
      private var _position:Float;
      
      private var _soundTransform:SoundTransform;
      
      private var _initPhase:Int;
      
      private var _sound:Sound;
      
      private var _soundPaused:Bool;
      
      private var _soundComplete:Bool;
      
      private var _context:SoundLoaderContext;
      
      private var _repeatCount:UInt;
      
      private var _duration:Float;
      
      public var initThreshold:UInt;
      
      public function new(urlOrRequest:Dynamic, vars:Object = null)
      {
         super(urlOrRequest,vars);
         _type = "MP3Loader";
         _position = 0;
         _duration = 0;
         _soundPaused = true;
         _soundTransform = new SoundTransform("volume" in this.vars?cast(this.vars.volume, Float):cast(1, Float));
         this.initThreshold = "initThreshold" in this.vars?cast(UInt(this.vars.initThreshold), UInt):cast(102400, UInt);
         _initSound();
      }
      
      public function playSound(event:Event = null) : SoundChannel
      {
         this.soundPaused = false;
         return this.channel;
      }
      
      override private function _load() : Void
      {
         _context =Std.is( this.vars.context, SoundLoaderContext?this.vars.context:new SoundLoaderContext(3000));
         _prepRequest();
         _soundComplete = false;
         _initPhase = -1;
         _position = 0;
         _duration = 0;
         try
         {
            _sound.load(_request,_context);
            if(this.vars.autoPlay != false)
            {
               playSound();
            }
         }
         catch(error:Error)
         {
            _errorHandler(new LoaderEvent(LoaderEvent.ERROR,this,error.message));
         }
      }
      
      public  function set_soundTime(value)
      {
         gotoSoundTime(value,!_soundPaused);
      }
      
      public  function set_soundPaused(value)
      {
         var changed:Bool = cast(value != _soundPaused, Bool);
         _soundPaused = value;
         if(!changed)
         {
            return;
         }
         if(_soundPaused)
         {
            if(this.channel != null)
            {
               _position = this.channel.position;
               this.channel.removeEventListener(Event.SOUND_COMPLETE,_soundCompleteHandler);
               _shape.removeEventListener(Event.ENTER_FRAME,_enterFrameHandler);
               this.channel.stop();
            }
         }
         else
         {
            _playSound(_position);
            if(this.channel == null)
            {
               return;
            }
         }
         dispatchEvent(new LoaderEvent(!!_soundPaused?SOUND_PAUSE:SOUND_PLAY,this));
      }
      
      override public function addEventListener(type:String, listener:Function, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void
      {
         if(type == PLAY_PROGRESS)
         {
            _dispatchPlayProgress = true;
         }
         super.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      private function _id3Handler(event:Event) : Void
      {
         if(_sound.bytesLoaded > this.initThreshold)
         {
            _initPhase = 1;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT,this));
         }
         else
         {
            _initPhase = 0;
         }
      }
      
      override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         this.pauseSound();
         _initSound();
         _position = 0;
         _duration = 0;
         _repeatCount = 0;
         _soundComplete = false;
         super._dump(scrubLevel,newStatus);
         _content = _sound;
      }
      
      private function _playSound(position:Float) : Void
      {
         if(this.channel != null)
         {
            this.channel.removeEventListener(Event.SOUND_COMPLETE,_soundCompleteHandler);
            this.channel.stop();
         }
         _position = position;
         this.channel = _sound.play(_position,1,_soundTransform);
         if(this.channel != null)
         {
            this.channel.addEventListener(Event.SOUND_COMPLETE,_soundCompleteHandler);
            _shape.addEventListener(Event.ENTER_FRAME,_enterFrameHandler,false,0,true);
         }
      }
      
      private function _enterFrameHandler(event:Event) : Void
      {
         if(_dispatchPlayProgress)
         {
            dispatchEvent(new LoaderEvent(PLAY_PROGRESS,this));
         }
      }
      
      public function gotoSoundTime(time:Float, forcePlay:Bool = false, resetRepeatCount:Bool = true) : Void
      {
         if(time > _duration)
         {
            time = _duration;
         }
         _position = time * 1000;
         _soundComplete = false;
         if(resetRepeatCount)
         {
            _repeatCount = 0;
         }
         if(cast(!_soundPaused, Bool) || cast(forcePlay, Bool))
         {
            _playSound(_position);
            if(_soundPaused)
            {
               _soundPaused = false;
               dispatchEvent(new LoaderEvent(SOUND_PLAY,this));
            }
         }
      }
      
      public  function set_playProgress(value)
      {
         if(this.duration != 0)
         {
            gotoSoundTime(value * _duration,!_soundPaused);
         }
      }
      
      public  function get_duration()
      {
         if(_sound.bytesLoaded < _sound.bytesTotal)
         {
            _duration = _sound.length / 1000 / (_sound.bytesLoaded / _sound.bytesTotal);
         }
         return _duration;
      }
      
      public  function get_soundPaused()
      {
         return _soundPaused;
      }
      
      public  function get_soundTime()
      {
         return cast(!_soundPaused, Bool) && cast(this.channel != null, Bool)?cast(this.channel.position / 1000, Float):cast(_position / 1000, Float);
      }
      
      private function _soundCompleteHandler(event:Event) : Void
      {
         if(cast(UInt(this.vars.repeat) > _repeatCount, Bool) || cast(Int(this.vars.repeat) == -1, Bool))
         {
            _repeatCount++;
            _playSound(0);
         }
         else
         {
            _repeatCount = 0;
            _soundComplete = true;
            this.soundPaused = true;
            _position = _duration * 1000;
            _enterFrameHandler(null);
            dispatchEvent(new LoaderEvent(SOUND_COMPLETE,this));
         }
      }
      
      public  function get_playProgress()
      {
         return !!_soundComplete?cast(1, Float):cast(this.soundTime / this.duration, Float);
      }
      
      override private function _progressHandler(event:Event) : Void
      {
         if(cast(_initPhase == 0, Bool) && cast(_sound.bytesLoaded > this.initThreshold, Bool))
         {
            _initPhase = 1;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT,this));
         }
         super._progressHandler(event);
      }
      
      public  function set_volume(value)
      {
         _soundTransform.volume = value;
         if(this.channel != null)
         {
            this.channel.soundTransform = _soundTransform;
         }
      }
      
      private function _initSound() : Void
      {
         if(_sound != null)
         {
            try
            {
               _sound.close();
            }
            catch(error:Error)
            {
            }
            _sound.removeEventListener(ProgressEvent.PROGRESS,_progressHandler);
            _sound.removeEventListener(Event.COMPLETE,_completeHandler);
            _sound.removeEventListener("ioError",_failHandler);
            _sound.removeEventListener(Event.ID3,_id3Handler);
         }
         _initPhase = -1;
         _sound = _content = new Sound();
         _sound.addEventListener(ProgressEvent.PROGRESS,_progressHandler,false,0,true);
         _sound.addEventListener(Event.COMPLETE,_completeHandler,false,0,true);
         _sound.addEventListener("ioError",_failHandler,false,0,true);
         _sound.addEventListener(Event.ID3,_id3Handler,false,0,true);
      }
      
      public  function get_volume()
      {
         return _soundTransform.volume;
      }
      
      public function pauseSound(event:Event = null) : Void
      {
         this.soundPaused = true;
      }
      
      override private function _completeHandler(event:Event = null) : Void
      {
         _duration = _sound.length / 1000;
         if(_initPhase != 1)
         {
            _initPhase = 1;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT,this));
         }
         super._completeHandler(event);
      }
   }
