jref = require 'json-ref-lite'

graph = jref.resolve
  searchquery:
    type: "object"
    properties:
      category: { type: "string" }
      query:    { type: "string" }
  items:
    type: "array"
    items: [{"$ref":"#/item"}]
    data:
      get:
        config:
          method: 'get'
          url: '/json/books.json'
          payload:
            category: '{#/searchquery/properties/category/value}'
            query: '{#/searchquery/properties/query/value}'
        data: "{response.data}"
  item:
    type: "object"
    properties:
      id: { type:"number", default: 12 }
      name: { type: "string", default: 'John Doe' }
      category: { type: "string", default: 'amsterdam' }
    data:
      get:
        config:
          method: 'get'
          url: '/json/books.json'
          payload:
            id: '{#/item/properties/id/value}'
        data: "{response.data[0]}"
      post:
        type: "request"
        config:
          method: "post"
          url: '/book'
          payload:
            'fullname': '{book.name}'
            'firstname': '{firstname}'
            'category': '{book.category}'
          schema: {"$ref":"#/book"}
        data: "{response}"


restgraph = {
  create: (graph) ->
    @.graph = graph
    @.get = (node) -> @.graph[node].properties
    @
}

# map functions (could be a browser webrequest or setting up an api endpoint)
for node,v of graph
  ( for method,u of v.data
      graph[node].data[method] = ( (graph,method) ->
        (cb) ->
          console.dir method.config
          req = jref.evaluate method.config, graph
          console.log "doing request:"
          console.dir req
          method.response = {data:["this","is","fake","data"]}
          cb ( jref.evaluate( {'_':method.data}, method ) )['_']
      )(graph,graph[node].data[method])
  ) if v.data?

rg = restgraph.create( jref.resolve graph )

rg.get('searchquery').query.value = "foo"
rg.get('searchquery').category.value = "scifi"

graph.items.data.get (data) ->
  console.log "\n->receive: "+data
