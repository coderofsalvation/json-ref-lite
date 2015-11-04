reflite = require 'json-ref-lite'

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

json.push 
  bar: ["one","two"]
  foo:
    "$ref": "#/bar[1]"

json.push 
  bar: ["one","two"]
  length:
    "$ref": "#/bar.length"

json.push 
  flop: () -> "hello world"
  foo:
    "$ref": "#/flop()"

for j in json
  console.log JSON.stringify j, null, 2
  console.log JSON.stringify reflite.resolve(j),null,2

json.push
  a: { a:true }
  b: { b:true }
  "$ref": [ {"$ref":"#/a"}, {"$ref":"#/b"} ]

json.push
  a:
    "$ref": [{"$ref":"#/b"}]
  b:
    "$ref": [{"$ref":"#/a"}]

#json.push                             # this works but fails when printing out (because circular)
#  node_A:
#    edges: [{"$ref": "#/node_B"}]
#  node_B:
#    edges: [{"$ref": "#/node_A"}]
#  node_C:
#    edges: [{"$ref": "#/node_B"}]
util = require 'util'

for j in json
  console.log JSON.stringify j, null, 2
  console.log util.inspect reflite.resolve(j), {showHidden: false, depth: 5}
