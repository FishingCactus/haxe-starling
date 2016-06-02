package com.greensock.loading;
   class BinaryDataLoader extends DataLoader
   {
      
      private static var _classActivated:Bool = _activateClass("BinaryDataLoader",BinaryDataLoader,"zip");
       
      public function new(urlOrRequest:Dynamic, vars:Object = null)
      {
         super(urlOrRequest,vars);
         _loader.dataFormat = "binary";
         _type = "BinaryDataLoader";
      }
   }
