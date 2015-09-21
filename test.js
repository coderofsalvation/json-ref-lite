// Generated by CoffeeScript 1.10.0
(function() {
  var i, j, json, len, reflite;

  reflite = require('./index.coffee')();

  json = [];

  json.push({
    foo: {
      id: '#/foo/bar',
      value: 'bar'
    },
    example: {
      '$ref': '#/foo/bar'
    }
  });

  json.push({
    foo: {
      id: '#/foo/bar',
      value: 'bar',
      foo: 'flop'
    },
    example: {
      '$ref': '#/foo/bar'
    }
  });

  json.push({
    foo: {
      id: '#/foo/bar',
      value: 'bar',
      foo: 'flop'
    },
    example: {
      ids: [
        {
          '$ref': '#/foo/bar'
        }, {
          '$ref': '#/foo/bar'
        }
      ]
    }
  });

  for (i = 0, len = json.length; i < len; i++) {
    j = json[i];
    console.dir(reflite.resolve(j));
  }

}).call(this);