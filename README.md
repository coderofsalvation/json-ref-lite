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

* supports resolving json references to 'id'-fields ( `"$ref": "foobar"` )
* supports resolving internal jsonpointers ( `"$ref": "#/foo/value"` )
* supports resolving positional jsonpointers ( `"$ref": "#/foo/bar[2]"` )
* supports resolving grouped jsonpointers ( `"$ref": [{"$ref":"#/foo"},{"$ref":"#/bar}]` ) for building jsongraph
* supports evaluating positional jsonpointer function ( `"$ref": "#/foo/bar()"` )
* supports resolving local files ( `"$ref": "/some/path/test.json"` )
* supports resolving remote json(schema) files ( `"$ref": "http://foo.com/person.json"` )
* supports resolving remote jsonpointers: ( `"$ref": "http://foo.com/person.json#/address/street"` )

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

# Philosophy

* This is a zero-dependency module.
* should be isomorphic 

I found similar modules but for many were lacking browsercompatibility and/or had 10++ dependencies.


