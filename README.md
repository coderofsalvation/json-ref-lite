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
