jref = require 'json-ref-lite'
expr = require 'property-expr'

data = 
  boss: {name:"John"}
  employee: {name:"Matt"}

template = jref.resolve 
  boss:
    name: "{boss.name}"
  employee:
    name: "{#/employee/name}"
  names: [{"$ref":"#/boss/name"},{"$ref":"#/employee/name"}]

# (optional) override evaluator
# graph = jref.evaluate graph, data, (k,v) -> return v

graph = jref.evaluate template, data

console.log JSON.stringify graph, null, 2
