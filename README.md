Extremely light weight way to resolve jsonschema '$ref' references or create circular/graph structures (browser/coffeescript/javascript).

<img alt="" src="https://raw.githubusercontent.com/coderofsalvation/jsongraph/master/logo.png"/>

Dont think trees, think jsongraph, think graphmorphic applications.

# Usage

nodejs:

    reflite = require('json-ref-lite')

or in the browser:

    <script type="text/javascript" src="json-ref-lite.min.js"></script>
    reflite = require('json-ref-lite');

code:

    json = {
      foo: {
        id: 'foobar',
        value: 'bar'
      },
      example: {
        '$ref': 'foobar'
      }
    };

    console.dir(reflite.resolve(json));

Outputs:

    { 
      foo: { id: 'foobar', value: 'bar' },
      example: { value: 'bar' } 
    }

# Why?

Because dont-repeat-yourself (DRY)! 
It is extremely useful to use '$ref' keys in jsonschema graphs.
For example here's how to do a multidirected graph:

      {
        "a": { "$ref": [{"$ref":"#/b"}]           },
        "b": { "$ref": [{"$ref": [{"$ref":"#/a"}] }
      }

> NOTE: for more functionality checkout [jsongraph](https://npmjs.org/packages/jsongraph)

# Features 

| Feature                                             | Notation                                                               |
|-----------------------------------------------------|------------------------------------------------------------------------|
|resolving (old) jsonschema references to 'id'-fields | `"$ref": "foobar"`                                                     |
|resolving (new) jsonschema internal jsonpointers     | `"$ref": "#/foo/value"`                                                |
|resolving positional jsonpointers                    | `"$ref": "#/foo/bar[2]"`                                               |
|resolving grouped jsonpointers                       | `"$ref": [{"$ref": "#/foo"},{"$ref": "#/bar}]` for building jsongraphs |
|evaluating positional jsonpointer function           | `"$ref": "#/foo/bar()"`                                                |
|resolving local files                                | `"$ref": "/some/path/test.json"`                                       |
|resolving remote json(schema) files                  | `"$ref": "http://foo.com/person.json"`                                 |
|resolving remote jsonpointers                        | `"$ref": "http://foo.com/person.json#/address/street"`                 |
|evaluating jsonpointer notation in string            | `foo_{#/a/graph/value}`                                                |
|evaluating dot-notation in string                    | `foo_{a.graph.value}`                                                  |


> NOTE: for more functionality checkout [jsongraph](https://npmjs.org/packages/jsongraph)

## Example: id fields

    json = {
      foo: {
        id: 'foobar',
        value: 'bar'
      },
      example: {
        '$ref': 'foobar'
      }
    };

outputs:

    { 
      foo: { id: 'foobar', value: 'bar' },
      example: { value: 'bar' } 
    }

## Example: jsonpointers

    {
      foo: {
        value: 'bar',
        foo: 'flop'
      },
      example: {
        ids: {
          '$ref': '#/foo/foo'
        }
      }
    }

outputs:

    {
      foo: {
        value: 'bar',
        foo: 'flop'
      },
      example: {
        ids: 'flop' 
      }
    }

> NOTE: escaping slashes in keys is supported. `"#/model/foo['\\/bar']/flop"` will try to reference `model.foo['/bar'].flop` from itself 

## Example: remote schemas

    {
      foo: {
        "$ref": "http://json-schema.org/address"
      }
      bar: {
        "$ref": "http://json-schema.org/address#/street/number"
      }
    }

outputs: replaces value of foo with jsonresult from given url, also supports jsonpointers to remote source

> NOTE: please install like so for remote support: 'npm install json-ref-lite sync-request'

## Example: local files    

    {
      foo: {
        "$ref": "./test.json"
      }
    }

outputs: replaces value of foo with contents of file test.json (use './' for current directory).

## Example: array references

    {
      "bar": ["one","two"],
      "foo": { "$ref": "#/bar[1]" }
    }

outputs:

    {
      "bar": ["one","two"],
      "foo": "two"
    }

## Example: evaluating functions 

Ofcoarse functions fall outside the json scope, but they can be executed after
binding them to the json.

    json = {
      "bar": { "$ref": "#/foo()" }
    }

    json.foo = function(){ return "Hello World"; }

outputs:

    {
      "bar": "Hello World"
    }


## Example: Graphs / Circular structures

Json-ref allows you to build circular/flow structures.

    {
      "a": { edges: [{"$ref":"#/b"}] },
      "b": { edges: [{"$ref":"#/a"}] },
      "c": { edges: [{"$ref":"#/a"}] }
    }

This resembles the following graph: b<->a<-c

> HINT: Superminimalistic dataflow programming example here [JS](/test/flowprogramming.js) / [CS](/test/flowprogramming.coffee)

There you go.

## Example: evaluating data into graph

Process graph-values into strings:

    data = 
      boss: {name:"John"}
      employee: {name:"Matt"}

    template = jref.resolve 
      boss:
        name: "{boss.name}"
      employee:
        name: "{#/employee/name}"
      names: [{"$ref":"#/boss/name"},{"$ref":"#/employee/name"}]

    graph = jref.evaluate template, data # !!! (k,v) -> return v

    console.log JSON.stringify graph, null, 2

> Note #1: you can override the evaluator with your own by adding a function as third argument. See the '!!' comment 
> Note #2: both jsonpointer notation `foo_{#/a/graph/value}` as well as dot-notation is allowed `foo_{a.graph.value}`

## Example: restgraph client or server using jsonschema

CRUD operations in javascript without dealing with the underlying rest interface:

    graph = jref.resolve
      searchquery:
        type: "object"
        properties:
          category: { type: "string", default:'' }
          query:    { type: "string", default:'' }
      books:
        type: "array"
        books: [{"$ref":"#/book"}]
        data:
          get:
            config:
              method: 'get'
              url: '/books'
              payload:
                category: '{#/searchquery/properties/category/value}'
                query: '{#/searchquery/properties/query/value}'
            data: "{response.data}"
      book:
        type: "object"
        properties:
          id: { type:"number", default: 12 }
          name: { type: "string", default: 'John Doe' }
          category: { type: "string", default: 'amsterdam' }

    ....(see full source for uncut jsonschema)....

    rg = restgraph.create(graph)

    # set user input
    rg.get('searchquery').query.value = "foo"
    rg.get('searchquery').category.value = "scifi"

    # get items
    graph.items.data.get (data) ->
      # do something with data 

This could be used to allow server and/or clients to share the same rest-specs.

> NOTE: see full source here: [coffeescript](/test/restgraph.coffee) / [javascript](/test/restgraph.js)      

# Philosophy

* This is a zero-dependency module.
* should be isomorphic 

I found similar modules but for many were lacking browsercompatibility and/or had 10++ dependencies.


