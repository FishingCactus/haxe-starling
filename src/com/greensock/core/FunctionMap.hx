package com.greensock.core;

import haxe.Constraints;

class FunctionMap<K:Function,V> implements IMap<K,V> {
  private var _keys : Array<K>;
  private var _values : Array<V>;

  public function new () {
    _keys = [];
    _values = [];
  }

  public function get(k:K):Null<V> {
    var keyIndex = index(k);
    if (keyIndex < 0) {
        return null;
    } else {
        return _values[keyIndex];
    }
  }

  public function set(k:K, v:V):Void {
    var keyIndex = index(k);
    if (keyIndex < 0) {
        _keys.push(k);
        _values.push(v);
    } else {
        _values[keyIndex] = v;
    }
  }

  public function exists(k:K):Bool {
    return index(k) >= 0;
  }

  public function remove(k:K):Bool {
    var keyIndex = index(k);
    if (keyIndex < 0) {
        return false;
    } else {
        _keys.splice(keyIndex, 1);
        _values.splice(keyIndex, 1);
        return true;
    }
  }

  public function keys():Iterator<K> {
    return _keys.iterator();
  }

  public function iterator():Iterator<V> {
    return _values
        .iterator();
  }

  public function toString():String {
    var s = new StringBuf();
    s.add("{");
    for( i in 0..._keys.length ) {
        s.add('<function>');
        s.add(" => ");
        s.add(Std.string(_values[i]));
        if( i < _keys.length - 1 )
            s.add(", ");
    }
    s.add("}");
    return s.toString();
  }


  private function index(key:K) : Int {
    for (i in 0..._keys.length) {
        if (Reflect.compareMethods(key, _keys[i])) {
            return i;
        }
    }
    return -1;
  }}
