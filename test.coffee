reflite = require('./index.coffee')() 

json = []

json.push 
  foo:
    id: '#/foo/bar' 
    value: 'bar' 
  example:
    '$ref': '#/foo/bar' 

json.push 
  foo:
    id: '#/foo/bar' 
    value: 'bar' 
    foo: 'flop' 
  example:
    '$ref': '#/foo/bar' 

json.push 
  foo:
    id: '#/foo/bar' 
    value: 'bar' 
    foo: 'flop' 
  example:
    ids: [{'$ref': '#/foo/bar'},{'$ref':'#/foo/bar'}]

for j in json
  console.dir reflite.resolve j
