Extremely light weight module to resolve jsonschema '$ref' references 

This is a zero-dependency module.
I found similar modules but for some reason they had 10++ dependencies.

# Usage

    reflite = require('json-ref-lite')();

    json = {
      foo: {
        id: '#/foo/bar',
        value: 'bar'
      },
      example: {
        '$ref': '#/foo/bar'
      }
    };

    console.dir(reflite.resolve(json));

Outputs:

    { 
      foo: { id: '#/foo/bar', value: 'bar' },
      example: { value: 'bar' } 
    }

# Why?

Because dont-repeat-yourself (DRY)! 
It is extremely useful to use '$ref' keys in json.

# Features 

* supports resolving json references to 'id'-fields ( "$ref": "foobar" )
* supports resolving internal jsonpointers ( "$ref": "#/foo/value" )
* supports resolving local files ( "$ref": "/some/path/test.json" )
* supports resolving remote json(schema) files ( "$ref": "http://foo.com/person.json" )

# Example: jsonpointers

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

## Example: remote schemas

    {
      foo: {
        "$ref": "http://json-schema.org/address"
      }
    }

outputs: replaces value of foo with jsonresult from given url 

## Example: local files    

    {
      foo: {
        "$ref": "./test.json"
      }
    }

outputs: replaces value of foo with contents of file test.json (use './' for current directory).

