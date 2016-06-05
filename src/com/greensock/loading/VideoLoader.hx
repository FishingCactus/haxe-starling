package com.greensock.loading;
   import com.greensock.loading.core.LoaderItem;
   import flash.events.Event;
   import flash.display.Sprite;
   import flash.utils.getTimer;
   import com.greensock.events.LoaderEvent;
   import flash.media.SoundTransform;
   import flash.media.Video;
   import flash.events.ProgressEvent;
   import flash.events.NetStatusEvent;
   import flash.net.NetStream;
   import flash.net.NetConnection;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   import flash.events.TimerEvent;
   import com.greensock.loading.display.ContentDisplay;

   class VideoLoader extends LoaderItem
   {

		public var bufferMode(get, set):Bool;
		public var volume(get, set):Float;
		public var rawContent(get, null):Video;
		public var autoDetachNetStream(get, set):Bool;
		public var netStream(get, null):NetStream;
		public var playProgress(get, set):Float;
		public var videoPaused(get, set):Bool;
		public var bufferProgress(get, null):Float;
		public var duration(get, null):Float;
		public var videoTime(get, set):Float;


      public static inline var VIDEO_CUE_POINT:String = "videoCuePoint";

      public static inline var PLAY_PROGRESS:String = "playProgress";

      public static inline var VIDEO_BUFFER_FULL:String = "videoBufferFull";

      public static inline var VIDEO_BUFFER_EMPTY:String = "videoBufferEmpty";

      public static inline var VIDEO_PLAY:String = "videoPlay";

      public static inline var VIDEO_PAUSE:String = "videoPause";

      public static inline var VIDEO_COMPLETE:String = "videoComplete";

      private static var _classActivated:Bool = _activateClass("VideoLoader",VideoLoader,"flv,f4v,mp4,mov");

      private var _dispatchPlayProgress:Bool;

      public var autoAdjustBuffer:Bool;

      private var _sound:SoundTransform;

      private var _prevCueTime:Float;

      private var _volume:Float;

      public var metaData:Dynamic;

      private var _nc:NetConnection;

      private var _ns:NetStream;

      private var _repeatCount:UInt;

      private var _video:Video;

      private var _bufferFull:Bool;

      private var _renderTimer:Timer;

      private var _pausePending:Bool;

      private var _auditNS:NetStream;

      private var _bufferMode:Bool;

      private var _renderedOnce:Bool;

      private var _autoDetachNetStream:Bool;

      private var _initted:Bool;

      private var _videoPaused:Bool;

      private var _videoComplete:Bool;

      private var _forceTime:Float;

      private var _sprite:Sprite;

      private var _playStarted:Bool;

      private var _duration:Float;

      private var _firstCuePoint:CuePoint;

      private var _prevTime:Float;

      public function new(urlOrRequest:Dynamic, vars:Dynamic = null)
      {
         super(urlOrRequest,vars);
         _type = "VideoLoader";
         _nc = new NetConnection();
         _nc.connect(null);
         _nc.addEventListener("asyncError",_failHandler,false,0,true);
         _nc.addEventListener("securityError",_failHandler,false,0,true);
         _renderTimer = new Timer(80,0);
         _renderTimer.addEventListener(TimerEvent.TIMER,_renderHandler,false,0,true);
         _video = new Video(cast(this.vars.width, Int) || cast(320, Int),cast(this.vars.height, Int) || cast(240, Int));
         _video.smoothing = cast(this.vars.smoothing != false, Bool);
         _video.deblocking = cast(this.vars.deblocking, UInt);
         _video.addEventListener(Event.ADDED_TO_STAGE,_videoAddedToStage,false,0,true);
         _video.addEventListener(Event.REMOVED_FROM_STAGE,_videoRemovedFromStage,false,0,true);
         _autoDetachNetStream = cast(this.vars.autoDetachNetStream == true, Bool);
         _refreshNetStream();
         _duration = !!isNaN(this.vars.estimatedDuration)?cast(200, Float):cast(Float(this.vars.estimatedDuration), Float);
         _bufferMode = _preferEstimatedBytesInAudit = cast(this.vars.bufferMode == true, Bool);
         _videoPaused = _pausePending = cast(this.vars.autoPlay == false, Bool);
         this.autoAdjustBuffer = this.vars.autoAdjustBuffer != false;
         this.volume = "volume" in this.vars?cast(Float(this.vars.volume), Float):cast(1, Float);
         if(Std.is(LoaderMax.contentDisplayClass, Class))
         {
            _sprite = new LoaderMax.contentDisplayClass(this);
            if(!_sprite.hasOwnProperty("rawContent"))
            {
               throw new openfl.errors.Error("LoaderMax.contentDisplayClass must be set to a class with a \'rawContent\' property, like com.greensock.loading.display.ContentDisplay");
            }
         }
         else
         {
            _sprite = new ContentDisplay(this);
         }
         cast(_sprite, Object).rawContent = null;
      }

      public function getCuePointTime(name:String) : Float
      {
         var i:Int = 0;
         if(cast(this.metaData != null, Bool) && cast(Std.is(this.metaData.cuePoints, Array<Int>), Bool))
         {
            i = this.metaData.cuePoints.length;
            while(--i > -1)
            {
               if(name == this.metaData.cuePoints[i].name)
               {
                  return cast(this.metaData.cuePoints[i].time, Float);
               }
            }
         }
         var cp:CuePoint = _firstCuePoint;
         while(cp)
         {
            if(cp.name == name)
            {
               return cp.time;
            }
            cp = cp.next;
         }
         return NaN;
      }

      public  function set_playProgress(value)
      {
         if(_duration != 0)
         {
            gotoVideoTime(value * _duration,!_videoPaused,true);
         }
      }

      public  function get_bufferMode()
      {
         return _bufferMode;
      }

      public  function set_bufferMode(value)
      {
         _bufferMode = value;
         _preferEstimatedBytesInAudit = _bufferMode;
         _calculateProgress();
         if(cast(_cachedBytesLoaded < _cachedBytesTotal, Bool) && cast(_status == LoaderStatus.COMPLETED, Bool))
         {
            _status = LoaderStatus.LOADING;
            _sprite.addEventListener(Event.ENTER_FRAME,_loadingProgressCheck);
         }
      }

      public function setContentDisplay(contentDisplay:Sprite) : Void
      {
         _sprite = contentDisplay;
      }

      private function _onBufferFull() : Void
      {
         if(cast(!_renderedOnce, Bool) && cast(!_renderTimer.running, Bool))
         {
            _waitForRender();
            return;
         }
         if(_pausePending)
         {
            if(cast(!_initted, Bool) && cast(getTimer() - _time < 10000, Bool))
            {
               _video.attachNetStream(null);
            }
            else if(_renderedOnce)
            {
               _applyPendingPause();
            }
         }
         else if(!_bufferFull)
         {
            _bufferFull = true;
            dispatchEvent(new LoaderEvent(VIDEO_BUFFER_FULL,this));
         }
      }

      public  function set_videoPaused(value)
      {
         var changed:Bool = cast(value != _videoPaused, Bool);
         _videoPaused = value;
         if(_videoPaused)
         {
            if(!_renderedOnce)
            {
               _setForceTime(0);
               _pausePending = true;
               _sound.volume = 0;
               _ns.soundTransform = _sound;
            }
            else
            {
               _pausePending = false;
               this.volume = _volume;
               _ns.pause();
            }
            if(changed)
            {
               dispatchEvent(new LoaderEvent(VIDEO_PAUSE,this));
            }
         }
         else
         {
            if(cast(_pausePending, Bool) || cast(!_bufferFull, Bool))
            {
               if(_video.stage != null)
               {
                  _video.attachNetStream(_ns);
               }
               if(cast(_initted, Bool) && cast(_renderedOnce, Bool))
               {
                  _seek(this.videoTime);
               }
               _pausePending = false;
            }
            this.volume = _volume;
            _ns.resume();
            if(cast(changed, Bool) && cast(_playStarted, Bool))
            {
               dispatchEvent(new LoaderEvent(VIDEO_PLAY,this));
            }
         }
      }

      public function gotoVideoCuePoint(name:String, forcePlay:Bool = false, skipCuePoints:Bool = true) : Float
      {
         return gotoVideoTime(getCuePointTime(name),forcePlay,skipCuePoints);
      }

      public  function get_volume()
      {
         return _volume;
      }

      private function _forceInit() : Void
      {
         if(_ns.bufferTime >= _duration)
         {
            _ns.bufferTime = cast(_duration - 1, UInt);
         }
         _initted = true;
         if(cast(!_bufferFull, Bool) && cast(_ns.bufferLength >= _ns.bufferTime, Bool))
         {
            _onBufferFull();
         }
         cast(_sprite, Object).rawContent = _video;
         if(cast(!_bufferFull, Bool) && cast(_pausePending, Bool) && cast(_renderedOnce, Bool) && cast(_video.stage != null, Bool))
         {
            _video.attachNetStream(null);
         }
         else if(cast(!_autoDetachNetStream, Bool) || cast(_video.stage != null, Bool))
         {
            _video.attachNetStream(_ns);
         }
      }

      public function pauseVideo(event:Event = null) : Void
      {
         this.videoPaused = true;
      }

      public  function get_rawContent()
      {
         return _video;
      }

      override private function _calculateProgress() : Void
      {
         _cachedBytesLoaded = _ns.bytesLoaded;
         if(_cachedBytesLoaded > 1)
         {
            if(_bufferMode)
            {
               _cachedBytesTotal = _ns.bytesTotal * (_ns.bufferTime / _duration);
               if(_ns.bufferLength > 0)
               {
                  _cachedBytesLoaded = _ns.bufferLength / _ns.bufferTime * _cachedBytesTotal;
               }
            }
            else
            {
               _cachedBytesTotal = _ns.bytesTotal;
            }
            if(_cachedBytesTotal <= _cachedBytesLoaded)
            {
               _cachedBytesTotal = cast(this.metaData != null, Bool) && cast(_renderedOnce, Bool) && cast(_initted, Bool) || cast(getTimer() - _time >= 10000, Bool)?cast(_cachedBytesLoaded, UInt):cast(Int(1.01 * _cachedBytesLoaded) + 1, UInt);
            }
            if(!_auditedSize)
            {
               _auditedSize = true;
               dispatchEvent(new Event("auditedSize"));
            }
         }
         _cacheIsDirty = false;
      }

      private function _cuePointHandler(info:Dynamic) : Void
      {
         if(!_videoPaused)
         {
            dispatchEvent(new LoaderEvent(VIDEO_CUE_POINT,this,"",info));
         }
      }

      public  function set_volume(value)
      {
         _sound.volume = _volume = value;
         _ns.soundTransform = _sound;
      }

      override private function _auditStreamHandler(event:Event) : Void
      {
         if(cast(Std.is(event, ProgressEvent), Bool) && cast(_bufferMode, Bool))
         {
            (cast(event, ProgressEvent)).bytesTotal = (cast(event, ProgressEvent)).bytesTotal * (_ns.bufferTime / _duration);
         }
         super._auditStreamHandler(event);
      }

      private function _refreshNetStream() : Void
      {
         if(_ns != null)
         {
            _ns.pause();
            try
            {
               _ns.close();
            }
            catch(error:Error)
            {
            }
            _sprite.removeEventListener(Event.ENTER_FRAME,_playProgressHandler);
            _video.attachNetStream(null);
            _video.clear();
            _ns.client = {};
            _ns.removeEventListener(NetStatusEvent.NET_STATUS,_statusHandler);
            _ns.removeEventListener("ioError",_failHandler);
            _ns.removeEventListener("asyncError",_failHandler);
            _ns.removeEventListener(Event.RENDER,_renderHandler);
         }
         _prevTime = _prevCueTime = 0;
         _ns = (Std.is(this.vars.netStream, NetStream))?this.vars.netStream:new NetStream(_nc);
         _ns.checkPolicyFile = cast(this.vars.checkPolicyFile == true, Bool);
         _ns.client = {
            "onMetaData":_metaDataHandler,
            "onCuePoint":_cuePointHandler
         };
         _ns.addEventListener(NetStatusEvent.NET_STATUS,_statusHandler,false,0,true);
         _ns.addEventListener("ioError",_failHandler,false,0,true);
         _ns.addEventListener("asyncError",_failHandler,false,0,true);
         _ns.bufferTime = !!isNaN(this.vars.bufferTime)?cast(5, Float):cast(Float(this.vars.bufferTime), Float);
         if(cast(!_autoDetachNetStream, Bool) || cast(_video.stage != null, Bool))
         {
            _video.attachNetStream(_ns);
         }
         _sound = _ns.soundTransform;
      }

      override public function addEventListener(type:String, listener:Function, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void
      {
         if(type == PLAY_PROGRESS)
         {
            _dispatchPlayProgress = true;
         }
         super.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }

      private function _seek(time:Float) : Void
      {
         _ns.seek(time);
         _setForceTime(time);
         if(_bufferFull)
         {
            _bufferFull = false;
            dispatchEvent(new LoaderEvent(VIDEO_BUFFER_EMPTY,this));
         }
      }

      override public function get content() : *
      {
         return _sprite;
      }

      public  function get_autoDetachNetStream()
      {
         return _autoDetachNetStream;
      }

      override public function auditSize() : Void
      {
         var request:URLRequest = null;
         if(cast(_url.substr(0,4) == "http", Bool) && cast(_url.indexOf("://") != -1, Bool))
         {
            super.auditSize();
         }
         else if(_auditNS == null)
         {
            _auditNS = new NetStream(_nc);
            _auditNS.bufferTime = !!isNaN(this.vars.bufferTime)?cast(5, Float):cast(Float(this.vars.bufferTime), Float);
            _auditNS.client = {
               "onMetaData":_auditHandler,
               "onCuePoint":_auditHandler
            };
            _auditNS.addEventListener(NetStatusEvent.NET_STATUS,_auditHandler,false,0,true);
            _auditNS.addEventListener("ioError",_auditHandler,false,0,true);
            _auditNS.addEventListener("asyncError",_auditHandler,false,0,true);
            _auditNS.soundTransform = new SoundTransform(0);
            request = new URLRequest();
            request.data = _request.data;
            _setRequestURL(request,_url,cast(!_isLocal, Bool) || cast(_url.substr(0,4) == "http", Bool)?"gsCacheBusterID=" + _cacheID++ + "&purpose=audit":"");
            _auditNS.play(request.url);
         }
      }

      public  function get_netStream()
      {
         return _ns;
      }

      public  function get_playProgress()
      {
         return !!_videoComplete?cast(1, Float):cast(this.videoTime / _duration, Float);
      }

      public  function get_videoPaused()
      {
         return _videoPaused;
      }

      public  function get_bufferProgress()
      {
         if(cast(_ns.bytesTotal, UInt) < 5)
         {
            return 0;
         }
         return _ns.bufferLength > _ns.bufferTime?cast(1, Float):cast(_ns.bufferLength / _ns.bufferTime, Float);
      }

      private function _videoRemovedFromStage(event:Event) : Void
      {
         if(_autoDetachNetStream)
         {
            _video.attachNetStream(null);
            _video.clear();
         }
      }

      public  function get_duration()
      {
         return _duration;
      }

      public function playVideo(event:Event = null) : Void
      {
         this.videoPaused = false;
      }

      private function _applyPendingPause() : Void
      {
         _pausePending = false;
         this.volume = _volume;
         _seek(cast(_forceTime, Float) || cast(0, Float));
         if(cast(!_autoDetachNetStream, Bool) || cast(_video.stage != null, Bool))
         {
            _video.cacheAsBitmap = false;
            _video.attachNetStream(_ns);
            _ns.pause();
         }
      }

      private function _videoAddedToStage(event:Event) : Void
      {
         if(_autoDetachNetStream)
         {
            if(!_pausePending)
            {
               _seek(this.videoTime);
            }
            _video.attachNetStream(_ns);
         }
      }

      private function _metaDataHandler(info:Dynamic) : Void
      {
         if(cast(this.metaData == null, Bool) || cast(this.metaData.cuePoints == null, Bool))
         {
            this.metaData = info;
         }
         _duration = info.duration;
         if("width" in info)
         {
            _video.width = cast(info.width, Float);
            _video.height = cast(info.height, Float);
         }
         if("framerate" in info)
         {
            _renderTimer.delay = cast(1000 / Float(info.framerate) + 1, Int);
         }
         if(!_initted)
         {
            _forceInit();
         }
         else
         {
            (cast(_sprite, Object)).rawContent = _video;
         }
         dispatchEvent(new LoaderEvent(LoaderEvent.INIT,this,"",info));
      }

      override private function _load() : Void
      {
         var concatChar:String = null;
         _prepRequest();
         _repeatCount = 0;
         _prevTime = _prevCueTime = 0;
         _bufferFull = _playStarted = _renderedOnce = false;
         this.metaData = null;
         _pausePending = _videoPaused;
         if(_videoPaused)
         {
            _setForceTime(0);
            _sound.volume = 0;
            _ns.soundTransform = _sound;
         }
         else
         {
            this.volume = _volume;
         }
         _sprite.addEventListener(Event.ENTER_FRAME,_playProgressHandler);
         _sprite.addEventListener(Event.ENTER_FRAME,_loadingProgressCheck);
         _waitForRender();
         _videoComplete = _initted = false;
         if(cast(this.vars.noCache, Bool) && (cast(!_isLocal || _url.substr(0,4) == "http", Bool)) && cast(_request.data != null, Bool))
         {
            concatChar = _request.url.indexOf("?") != -1?"&":"?";
            _ns.play(_request.url + concatChar + _request.data.toString());
         }
         else
         {
            _ns.play(_request.url);
         }
      }

      private function _waitForRender() : Void
      {
         _ns.addEventListener(Event.RENDER,_renderHandler,false,0,true);
         _renderTimer.reset();
         _renderTimer.start();
      }

      public function gotoVideoTime(time:Float, forcePlay:Bool = false, skipCuePoints:Bool = true) : Float
      {
         if(isNaN(time))
         {
            return NaN;
         }
         if(time > _duration)
         {
            time = _duration;
         }
         var changed:Bool = time != this.videoTime;
         if(cast(_initted, Bool) && cast(_renderedOnce, Bool) && cast(changed, Bool))
         {
            _seek(time);
         }
         else
         {
            _setForceTime(time);
         }
         _videoComplete = false;
         if(changed)
         {
            if(skipCuePoints)
            {
               _prevCueTime = time;
            }
            else
            {
               _playProgressHandler(null);
            }
         }
         if(forcePlay)
         {
            playVideo();
         }
         return time;
      }

      private function _auditHandler(event:Event = null) : Void
      {
         var request:URLRequest = null;
         var type:String = event == null?"":event.type;
         var code:String = cast(event == null, Bool) || cast(!(Std.is( event, NetStatusEvent)) , Bool)?"":cast(event, NetStatusEvent).info.code;
         if(cast(event != null, Bool) && cast("duration" in event, Bool))
         {
            _duration = cast(event, Object).duration;
         }
         if(_auditNS != null)
         {
            _cachedBytesTotal = _auditNS.bytesTotal;
            if(cast(_bufferMode, Bool) && cast(_duration != 0, Bool))
            {
               _cachedBytesTotal = _cachedBytesTotal * (_auditNS.bufferTime / _duration);
            }
         }
         if(cast(type == "ioError", Bool) || cast(type == "asyncError", Bool) || cast(code == "NetStream.Play.StreamNotFound", Bool) || cast(code == "NetConnection.Connect.Failed", Bool) || cast(code == "NetStream.Play.Failed", Bool) || cast(code == "NetStream.Play.FileStructureInvalid", Bool) || cast(code == "The MP4 doesn\'t contain any supported tracks", Bool))
         {
            if(cast(this.vars.alternateURL != undefined, Bool) && cast(this.vars.alternateURL != "", Bool) && cast(this.vars.alternateURL != _url, Bool))
            {
               _errorHandler(new LoaderEvent(LoaderEvent.ERROR,this,code));
               if(_status != LoaderStatus.DISPOSED)
               {
                  _url = this.vars.alternateURL;
                  _setRequestURL(_request,_url);
                  request = new URLRequest();
                  request.data = _request.data;
                  _setRequestURL(request,_url,cast(!_isLocal, Bool) || cast(_url.substr(0,4) == "http", Bool)?"gsCacheBusterID=" + _cacheID++ + "&purpose=audit":"");
                  _auditNS.play(request.url);
               }
               return;
            }
            super._failHandler(new LoaderEvent(LoaderEvent.ERROR,this,code));
         }
         _auditedSize = true;
         _closeStream();
         dispatchEvent(new Event("auditedSize"));
      }

      public function addASCuePoint(time:Float, name:String = "", parameters:Dynamic = null) : Object
      {
         var prev:CuePoint = _firstCuePoint;
         if(cast(prev != null, Bool) && cast(prev.time > time, Bool))
         {
            prev = null;
         }
         else
         {
            while(cast(prev && prev.time <= time, Bool) && cast(prev.next, Bool) && cast(prev.next.time <= time, Bool))
            {
               prev = prev.next;
            }
         }
         var cp:CuePoint = new CuePoint(time,name,parameters,prev);
         if(prev == null)
         {
            if(_firstCuePoint != null)
            {
               _firstCuePoint.prev = cp;
               cp.next = _firstCuePoint;
            }
            _firstCuePoint = cp;
         }
         return cp;
      }

      private function _playProgressHandler(event:Event) : Void
      {
         var prevTime:Float = NaN;
         var prevCueTime:Float = NaN;
         var next:CuePoint = null;
         var cp:CuePoint = null;
         if(cast(!_bufferFull, Bool) && cast(!_videoComplete, Bool) && (cast(_ns.bufferLength >= _ns.bufferTime, Bool) || cast(this.duration - this.videoTime - _ns.bufferLength < 0.1, Bool)))
         {
            _onBufferFull();
         }
         if(cast(_bufferFull, Bool) && (cast(_firstCuePoint, Bool) || cast(_dispatchPlayProgress, Bool)))
         {
            prevTime = _prevTime;
            prevCueTime = _prevCueTime;
            _prevTime = _prevCueTime = (cast(_forceTime, Bool) || cast(_forceTime == 0, Bool)) && cast(_ns.time <= _duration, Bool)?cast(_ns.time, Float):cast(this.videoTime, Float);
            cp = _firstCuePoint;
            while(cp)
            {
               next = cp.next;
               if(cast(cp.time > prevCueTime, Bool) && cast(cp.time <= _prevCueTime, Bool) && cast(!cp.gc, Bool))
               {
                  dispatchEvent(new LoaderEvent(VIDEO_CUE_POINT,this,"",cp));
               }
               cp = next;
            }
            if(cast(_dispatchPlayProgress, Bool) && cast(prevTime != _prevTime, Bool))
            {
               dispatchEvent(new LoaderEvent(PLAY_PROGRESS,this));
            }
         }
      }

      override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false) : Void
      {
         if(_sprite == null)
         {
            return;
         }
         _sprite.removeEventListener(Event.ENTER_FRAME,_loadingProgressCheck);
         _sprite.removeEventListener(Event.ENTER_FRAME,_playProgressHandler);
         _sprite.removeEventListener(Event.ENTER_FRAME,_detachNS);
         _ns.removeEventListener(Event.RENDER,_renderHandler);
         _renderTimer.stop();
         _forceTime = NaN;
         _prevTime = _prevCueTime = 0;
         _initted = false;
         _renderedOnce = false;
         _videoComplete = false;
         this.metaData = null;
         if(scrubLevel != 2)
         {
            _refreshNetStream();
            (cast(_sprite, Object)).rawContent = null;
            if(_video.parent != null)
            {
               _video.parent.removeChild(_video);
            }
         }
         if(scrubLevel >= 2)
         {
            if(scrubLevel == 3)
            {
               (cast(_sprite, Object)).dispose(false,false);
            }
            _renderTimer.removeEventListener(TimerEvent.TIMER,_renderHandler);
            _nc.removeEventListener("asyncError",_failHandler);
            _nc.removeEventListener("securityError",_failHandler);
            _ns.removeEventListener(NetStatusEvent.NET_STATUS,_statusHandler);
            _ns.removeEventListener("ioError",_failHandler);
            _ns.removeEventListener("asyncError",_failHandler);
            _video.removeEventListener(Event.ADDED_TO_STAGE,_videoAddedToStage);
            _video.removeEventListener(Event.REMOVED_FROM_STAGE,_videoRemovedFromStage);
            _firstCuePoint = null;
            (cast(_sprite, Object)).gcProtect = scrubLevel == 3?null:_ns;
            _ns.client = {};
            _video = null;
            _ns = null;
            _nc = null;
            _sound = null;
            (cast(_sprite, Object)).loader = null;
            _sprite = null;
            _renderTimer = null;
         }
         else
         {
            _duration = !!isNaN(this.vars.estimatedDuration)?cast(200, Float):cast(Float(this.vars.estimatedDuration), Float);
            _videoPaused = _pausePending = cast(this.vars.autoPlay == false, Bool);
         }
         super._dump(scrubLevel,newStatus,suppressEvents);
      }

      public  function set_videoTime(value)
      {
         gotoVideoTime(value,!_videoPaused,true);
      }

      private function _loadingProgressCheck(event:Event) : Void
      {
         var bl:UInt = _cachedBytesLoaded;
         var bt:UInt = _cachedBytesTotal;
         if(cast(!_bufferFull, Bool) && cast(_ns.bufferLength >= _ns.bufferTime, Bool))
         {
            _onBufferFull();
         }
         _calculateProgress();
         if(_cachedBytesLoaded == _cachedBytesTotal)
         {
            _sprite.removeEventListener(Event.ENTER_FRAME,_loadingProgressCheck);
            if(!_bufferFull)
            {
               _onBufferFull();
            }
            if(!_initted)
            {
               _forceInit();
               _errorHandler(new LoaderEvent(LoaderEvent.ERROR,this,"No metaData was received."));
            }
            _completeHandler(event);
         }
         else if(cast(_dispatchProgress, Bool) && cast(_cachedBytesLoaded / _cachedBytesTotal != bl / bt, Bool))
         {
            dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
         }
      }

      override private function _closeStream() : Void
      {
         if(_auditNS != null)
         {
            _auditNS.client = {};
            _auditNS.removeEventListener(NetStatusEvent.NET_STATUS,_auditHandler);
            _auditNS.removeEventListener("ioError",_auditHandler);
            _auditNS.removeEventListener("asyncError",_auditHandler);
            _auditNS.pause();
            try
            {
               _auditNS.close();
            }
            catch(error:Error)
            {
            }
            _auditNS = null;
         }
         else
         {
            super._closeStream();
         }
      }

      public  function get_videoTime()
      {
         if(cast(_forceTime, Bool) || cast(_forceTime == 0, Bool))
         {
            return _forceTime;
         }
         if(_videoComplete)
         {
            return _duration;
         }
         if(_ns.time > _duration)
         {
            return _duration * 0.995;
         }
         return _ns.time;
      }

      private function _renderHandler(event:Event) : Void
      {
         _renderedOnce = true;
         if(cast(!_videoPaused, Bool) || cast(_initted, Bool))
         {
            _forceTime = NaN;
            _renderTimer.stop();
            _ns.removeEventListener(Event.RENDER,_renderHandler);
         }
         if(_pausePending)
         {
            if(_bufferFull)
            {
               _applyPendingPause();
            }
            else if(_video.stage != null)
            {
               _sprite.addEventListener(Event.ENTER_FRAME,_detachNS,false,100,true);
            }
         }
         else if(cast(_videoPaused, Bool) && cast(_initted, Bool))
         {
            _ns.pause();
         }
      }

      public function removeASCuePoint(timeNameOrCuePoint:Dynamic) : Object
      {
         var cp:CuePoint = _firstCuePoint;
         while(cp)
         {
            if(cast(cp == timeNameOrCuePoint, Bool) || cast(cp.time == timeNameOrCuePoint, Bool) || cast(cp.name == timeNameOrCuePoint, Bool))
            {
               if(cp.next)
               {
                  cp.next.prev = cp.prev;
               }
               if(cp.prev)
               {
                  cp.prev.next = cp.next;
               }
               else if(cp == _firstCuePoint)
               {
                  _firstCuePoint = cp.next;
               }
               cp.next = cp.prev = null;
               cp.gc = true;
               return cp;
            }
            cp = cp.next;
         }
         return null;
      }

      private function _setForceTime(time:Float) : Void
      {
         if(!(_forceTime || _forceTime == 0))
         {
            _waitForRender();
         }
         _forceTime = time;
      }

      public  function set_autoDetachNetStream(value)
      {
         _autoDetachNetStream = value;
         if(cast(_autoDetachNetStream, Bool) && cast(_video.stage == null, Bool))
         {
            _video.attachNetStream(null);
            _video.clear();
         }
         else
         {
            _video.attachNetStream(_ns);
         }
      }

      private function _detachNS(event:Event) : Void
      {
         _sprite.removeEventListener(Event.ENTER_FRAME,_detachNS);
         if(cast(!_bufferFull, Bool) && cast(_pausePending, Bool))
         {
            _video.attachNetStream(null);
         }
      }

      private function _statusHandler(event:NetStatusEvent) : Void
      {
         var videoRemaining:Float = NaN;
         var loadRemaining:Float = NaN;
         var revisedBufferTime:Float = NaN;
         var code:String = event.info.code;
         if(cast(code == "NetStream.Play.Start", Bool) && cast(!_playStarted, Bool))
         {
            _playStarted = true;
            if(!_pausePending)
            {
               dispatchEvent(new LoaderEvent(VIDEO_PLAY,this));
            }
         }
         dispatchEvent(new LoaderEvent(NetStatusEvent.NET_STATUS,this,code,event.info));
         if(code == "NetStream.Play.Stop")
         {
            if(_videoPaused)
            {
               return;
            }
            if(cast(this.vars.repeat == -1, Bool) || cast(UInt(this.vars.repeat) > _repeatCount, Bool))
            {
               _repeatCount++;
               dispatchEvent(new LoaderEvent(VIDEO_COMPLETE,this));
               gotoVideoTime(0,true,true);
            }
            else
            {
               _videoComplete = true;
               this.videoPaused = true;
               _playProgressHandler(null);
               dispatchEvent(new LoaderEvent(VIDEO_COMPLETE,this));
            }
         }
         else if(code == "NetStream.Buffer.Full")
         {
            _onBufferFull();
         }
         else if(code == "NetStream.Seek.Notify")
         {
            if(cast(!_autoDetachNetStream, Bool) && cast(!isNaN(_forceTime), Bool))
            {
               _renderHandler(null);
            }
         }
         else if(cast(code == "NetStream.Seek.InvalidTime", Bool) && cast("details" in event.info, Bool))
         {
            _seek(event.info.details);
         }
         else if(cast(code == "NetStream.Buffer.Empty", Bool) && cast(!_videoComplete, Bool))
         {
            videoRemaining = this.duration - this.videoTime;
            loadRemaining = 1 / this.progress * this.loadTime;
            revisedBufferTime = videoRemaining * (1 - videoRemaining / loadRemaining) * 0.9;
            if(revisedBufferTime < _ns.bufferTime)
            {
               return;
            }
            if(cast(this.autoAdjustBuffer, Bool) && cast(loadRemaining > videoRemaining, Bool))
            {
               _ns.bufferTime = revisedBufferTime;
            }
            _bufferFull = false;
            dispatchEvent(new LoaderEvent(VIDEO_BUFFER_EMPTY,this));
         }
         else if(cast(code == "NetStream.Play.StreamNotFound", Bool) || cast(code == "NetConnection.Connect.Failed", Bool) || cast(code == "NetStream.Play.Failed", Bool) || cast(code == "NetStream.Play.FileStructureInvalid", Bool) || cast(code == "The MP4 doesn\'t contain any supported tracks", Bool))
         {
            _failHandler(new LoaderEvent(LoaderEvent.ERROR,this,code));
         }
      }
   }
}

class CuePoint
{

   public var time:Float;

   public var parameters:Dynamic;

   public var name:String;

   public var next:CuePoint;

   public var prev:CuePoint;

   public var gc:Bool;

   function new(time:Float, name:String, params:Dynamic, prev:CuePoint)
   {
      super();
      this.time = time;
      this.name = name;
      this.parameters = params;
      if(prev)
      {
         this.prev = prev;
         if(prev.next)
         {
            prev.next.prev = this;
            this.next = prev.next;
         }
         prev.next = this;
      }
   }
