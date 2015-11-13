jref = require 'json-ref-lite'

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
  console.log JSON.stringify jref.resolve(j),null,2

jref.reftoken  = '@ref'
jref.pathtoken = '@'
json = []
json.push 
  flop: () -> "hello at world"
  foo: [{"@ref": "@/flop()"}]

for j in json
  console.log JSON.stringify j, null, 2
  console.log JSON.stringify jref.resolve(j),null,2

json = []
jref.debug = false
json.push 
  flo: {fla:"hello at world"}
  one:
    "@ref": [{"@ref": "@flo/fla"}]
    two:
      "@ref": [{"@ref": "@/flo/fla"}]

for j in json
  console.log JSON.stringify j, null, 2
  console.log "expecting next line to be error:"
  console.log JSON.stringify jref.resolve(j),null,2

if not window?
  util = require 'util'
  jref.reftoken = '$ref'
  jref.pathtoken = '#'
  json = []
  json.push
    a: { a:true }
    b: { b:true }
    "$ref": [ {"$ref":"#/a"}, {"$ref":"#/b"} ]


  #json.push                             # this works but fails when printing out (because circular)
  #  node_A:
  #    edges: [{"$ref": "#/node_B"}]
  #  node_B:
  #    edges: [{"$ref": "#/node_A"}]
  #  node_C:
  #    edges: [{"$ref": "#/node_B"}]

  for j in json
    console.log JSON.stringify j, null, 2
    console.log util.inspect jref.resolve(j), {showHidden: false, depth: 5}

  json = []
  json.push
    a:
      "$ref": [{"$ref":"#/b"}]
    b:
      "$ref": [{"$ref":"#/a"}]

  for j in json
    console.log JSON.stringify j, null, 2
    console.log util.inspect jref.resolve(j), {showHidden: false, depth: 5}


  json = []
  json.push
    a:
      {"$ref":"#/sdfb"}

  for j in json
    console.log JSON.stringify j, null, 2
    console.log util.inspect jref.resolve(j), {showHidden: false, depth: 5}

  json = []
  json.push
    a:
      {"$ref":{"foo":"bar"}}

  for j in json
    console.log JSON.stringify j, null, 2
    console.log util.inspect jref.resolve(j), {showHidden: false, depth: 5}
  
  json = 
    a:
      foo:
        bar:
          title: "foo"
    "$extend":
      "$ref": "#a.foo.bar"
      location: "skyscraper"
      sex: "male"

  console.log JSON.stringify json, null, 2
  jref.extend json
  console.log JSON.stringify json, null, 2
