reflite = require('./index.coffee')() 

json = []

json.push 
  foo:
    id: 'foobar' 
    value: 'bar' 
  example:
    '$ref': 'foobar' 

json.push 
  foo:
    id: 'foobar' 
    value: 'bar' 
    foo: 'flop' 
  example:
    '$ref': 'foobar' 

json.push 
  foo:
    id: 'foobar' 
    value: 'bar' 
    foo: 'flop' 
  example:
    ids: [{'$ref': 'foobar'},{'$ref':'foobar'}]

json.push 
  foo:
    value: 'bar' 
    foo: 'flop' 
  example:
    ids: [{'$ref': '#/foo/value'},{'$ref':'#/foo/foo'}]

json.push 
  foo:
    value: 'bar' 
    foo: 'flop' 
  example:
    ids: {'$ref': '#/foo/value/this/does/not/resolve'}

json.push 
  foo:
    "$ref": "./test.json" 

json.push 
  foo:
    "$ref": "/this/does/not/exist/test.json" 

json.push 
  foo:
    "$ref": "http://json-schema.org/address" 

json.push 
  foo:
    "$ref": "http://json-schema.org/address" 

json.push 
  foo:
    "$ref": "http://json-schema.org/address#/properties/region" 

for j in json
  console.log JSON.stringify reflite.resolve(j), null, 2
