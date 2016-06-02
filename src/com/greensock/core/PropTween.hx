package com.greensock.core;
   class PropTween
   {

      public var priority:Int;

      public var start:Float;

      public var prevNode:com.greensock.core.PropTween;

      public var change:Float;

      public var target:Dynamic;

      public var name:String;

      public var property:String;

      public var nextNode:com.greensock.core.PropTween;

      public var isPlugin:Bool;


      public function new(target:Dynamic, property:String, start:Float, change:Float, name:String, isPlugin:Bool, nextNode:com.greensock.core.PropTween = null, priority:Int = 0)
      {
         this.target = target;
         this.property = property;
         this.start = start;
         this.change = change;
         this.name = name;
         this.isPlugin = isPlugin;
         if(nextNode != null)
         {
            nextNode.prevNode = this;
            this.nextNode = nextNode;
         }
         this.priority = priority;
      }
   }
