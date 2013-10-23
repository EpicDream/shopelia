// The MIT License (MIT)
// Copyright (c) 2013 Aadit M Shah
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://github.com/javascript/sorted-array

(function () {
  "usestrict";

  // Default string compare
  function defaultComp(a, b) {
      if (a <= b)
        return a >= b ? 0 : -1;
      return 1;
  }

  // new SortedArray(elem1, elem2, ... [, compareFunction])
  // new SortedArray([elem1, elem2, ...] [, compareFunction])
  // 
  // Warning : if you want/may add a single element has an Array,
  // or if you want/may add a single element has a Function.
  function SortedArray() {
      this.array = [];
      this.comp = defaultComp;
      // Handle constructor arguments.
      var index = 0,
        length = arguments.length;
      if (length > 0) {
        // Set compare function
        if (typeof arguments[length-1] === 'function', arguments[length-1].length === 2)
          this.comp = arguments[--length];
        // If there is only one arg and it is an Array.
        if (length === 1 && arguments[0] instanceof Array) {
          length = arguments[0].length;
          while (index < length) this.insert(arguments[0][index++]);
        // Else
        } else
          while (index < length) this.insert(arguments[index++]);
      }
  }

  SortedArray.prototype.insert = function (element) {
    var array = this.array,
      index = array.length,
      i, j, temp;

    array.push(element);

    while (index) {
      i = index, j = --index;

      if (this.comp(array[i], array[j]) < 0) {
        temp = array[i];
        array[i] = array[j];
        array[j] = temp;
      }
    }

    return this;
  };

  SortedArray.prototype.search = function (element) {
    var low = 0,
      array = this.array,
      high = array.length,
      index, cursor;

    while (high > low) {
      index = (high + low) / 2 >>> 0;
      cursor = array[index];

      if (this.comp(cursor, element) < 0) low = index + 1;
      else if (this.comp(cursor, element) > 0) high = index;
      else break;//return index;
    }
    if (high > low) {
      while (index > 0 && this.comp(array[index-1], element) === 0)
        index--;
      return index;
    }

    return -1;
  };

  SortedArray.prototype.remove = function (element) {
    var index = this.search(element);
    if (index >= 0) return this.array.splice(index, 1);
    return undefined;
  };

  SortedArray.prototype.shift = function () {
    return this.array.shift();
  };

  SortedArray.prototype.trunc = function (element) {
    var index = this.search(element);
    if (index >= 0) return new SortedArray(this.array.splice(index, this.array.length - index), this.comp);
    return undefined;
  };

  if ("object" == typeof module && module && "object" == typeof module.exports)
    module.exports = SortedArray;
  else if ("object" == typeof exports)
    exports = SortedArray;
  else if ("function" == typeof define && define.amd)
    define("sorted_array", [], function(){return SortedArray;});
  else
    window.SortedArray = SortedArray;

})();
