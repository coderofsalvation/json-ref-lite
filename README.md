Extremely light weight way to resolve jsonschema '$ref' references or create circular/graph structures (browser/coffeescript/javascript).

<img alt="" src="https://raw.githubusercontent.com/coderofsalvation/jsongraph/master/logo.png"/>

Dont think trees, think jsongraph, think graphmorphic applications.

# Usage

nodejs:

    jref = require('json-ref-lite')

or in the browser:

    <script type="text/javascript" src="json-ref-lite.min.js"></script>
    jref = require('json-ref-lite');

For example here's how to do a multidirected graph:

      json = {
        "a": { "$ref": [{"$ref":"#/b"}]           },
        "b": { "$ref": [{"$ref": [{"$ref":"#/a"}] }
      }
      console.dir(jref.resolve(json));

outputs:

      { a: { '$ref': [ { '$ref': [ [Circular] ] } ] },
        b: { '$ref': [ { '$ref': [ [Circular] ] } ] } }

> NOTE #1: for flowprogramming with json-ref-lite see [jsongraph](https://npmjs.org/packages/jsongraph)
> NOTE #2: for converting a restful service to server/client graph see [ohmygraph](https://npmjs.org/packages/ohmygraph)

# Resolve Jsonschema v1/2/3 references

json-ref-lite resolves newer, older jsonschema reference notations, as well as simple dotstyle:

    json = {
      foo: {
        id: 'foobar',
        value: 'bar'
      },
      old: { '$ref': 'foobar'      }
      new: { '$ref': '#/foo/id'    }
      dotstyle: { '$ref': '#foo.id' } 
    };

    console.dir(jref.resolve(json));

Outputs:

    { 
      foo: { id: 'foobar', value: 'bar' },
      old: { value: 'bar' },
      new: 'foobar',
      dotstyle: 'foobar',
    }

# Why?

Because dont-repeat-yourself (DRY)! 
It is extremely useful to use '$ref' keys in jsonschema graphs.
Instead of writing manual REST-api gluecode, you can build a restgraph client & server.

# Rule of thumb

When referencing to keys, always use underscores. Not doing this will not resolve references correctly.

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

Developer tools:

| Feature                                             | Howto                                                                  |
|-----------------------------------------------------|------------------------------------------------------------------------|
|console.log debug output                             | `jref.debug = true`                                                    |
|define ref token                                     | `jref.reftoken = '@ref'`                                               |
|define jsonpointer starttoken                        | `jref.pathtoken = '#'`                                                 |

> NOTE: re-defining tokens is useful to prevent resolving only certain references. A possible rule of thumb could be to have '$ref' references for serverside, and '@ref' references for clientside when resolving the same jsondata.

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
      "a": { "$ref": [{"$ref":"#/b"}] },
      "b": { "$ref": [{"$ref":"#/a"}] },
      "c": { "$ref": [{"$ref":"#/a"}] }
    }

This resembles the following graph: b<->a<-c

See superminimalistic dataflow programming example here [JS](/test/flowprogramming.js) / [CS](/test/flowprogramming.coffee)

> HINT: But hey, since you're reading this, why not use [jsongraph](https://npmjs.org/packages/jsongraph) instead?

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

## Example: restgraph using jsonschema

CRUD operations in server/client without dealing with the underlying rest interface?
See the [ohmygraph](https://npmjs.org/packages/ohmygraph) module.

# Philosophy

* This is a zero-dependency module.
* isomorphic is cool
* pistachio icecream is nice
