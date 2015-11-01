reflite = require 'json-ref-lite'
clone   = (obj) -> JSON.parse( JSON.stringify obj )

processNode = (node,data) ->
  result = node.process data
  ( processNode edge, clone data for edge in node.edges ) if result

# create the graph: b<->a<-c

json =
  a:
    edges: [{"$ref": "#/b"}]
    process: (data) -> 
      data.a = true
      console.dir data
  b:
    edges: [{"$ref": "#/a"}]
    process: (data) ->
      return undefined if data.b? # stops flow if already processed
      data.b = true
  c:
    edges: [{"$ref": "#/a"}]
    process: (data) ->
      data.c = true 

graph = reflite.resolve json

processNode graph.b, {foo:"bar"} # take b as startnode
processNode graph.c, {foo:"bar"} # take c as startnode
