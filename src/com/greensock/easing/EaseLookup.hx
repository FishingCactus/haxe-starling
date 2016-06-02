package com.greensock.easing;
   class EaseLookup
   {
      
      private static var _lookup:Dynamic;
       
      public function new()
      {
         super();
      }
      
      public static function find(name:String) : Function
      {
         if(_lookup == null)
         {
            buildLookup();
         }
         return _lookup[name.toLowerCase()];
      }
      
      private static function addInOut(easeClass:Class, names:Array<Int>) : Void
      {
         var name:String = null;
         var i:Int = names.length;
         while(i-- > 0)
         {
            name = names[i].toLowerCase();
            _lookup[name + ".easein"] = _lookup[name + "easein"] = easeClass.easeIn;
            _lookup[name + ".easeout"] = _lookup[name + "easeout"] = easeClass.easeOut;
            _lookup[name + ".easeinout"] = _lookup[name + "easeinout"] = easeClass.easeInOut;
         }
      }
      
      private static function buildLookup() : Void
      {
         _lookup = {};
         addInOut(Back,["back"]);
         addInOut(Bounce,["bounce"]);
         addInOut(Circ,["circ","circular"]);
         addInOut(Cubic,["cubic"]);
         addInOut(Elastic,["elastic"]);
         addInOut(Expo,["expo","exponential"]);
         addInOut(Linear,["linear"]);
         addInOut(Quad,["quad","quadratic"]);
         addInOut(Quart,["quart","quartic"]);
         addInOut(Quint,["quint","quintic","strong"]);
         addInOut(Sine,["sine"]);
         _lookup["linear.easenone"] = _lookup["lineareasenone"] = Linear.easeNone;
      }
   }
