# slightly odd requires because of browserify compatibility
fs      = ( if not window? then require 'fs' else false )
request = ( if fs and fs.existsSync __dirname+'/../sync-request' then require 'sync-request' else false )

expr    = require 'property-expr'

module.exports = ( () ->

  @.cache = {}
  
  @.findIds = (json, ids) ->
    id = false; obj = {}
    for k,v of json 
      id = json.id if json.id?
      obj[k] = v if id and k != "id"  
      @.findIds v, ids if typeof v is 'object' 
    ids[id] = obj if id

  @.get_json_pointer = (ref,root) ->
    evalstr = ref.replace( /\\\//,'#SLASH#').replace( /\//g, '.' ).replace( /#SLASH#/,'/')
    evalstr = evalstr.replace /#\./,''
    try
      console.log evalstr if process.env.DEBUG?
      result = expr.getter( evalstr )(root)
    catch err 
      result = ""
    return result
    #return eval( 'try{'+evalstr+'}catch(e){}')

  @.replace = (json, ids, root) ->
    for k,v of json 
      if v['$ref']? 
        ref = v['$ref']
        if ids[ ref ]?
          json[k] = ids[ ref ] 
        else if request and String(ref).match /^http/
          @.cache[ref] = JSON.parse request("GET",ref).getBody().toString() if not @.cache[ref]
          json[k] = @.cache[ref] 
          if ref.match("#")
            jsonpointer = ref.replace /.*#/,'#'
            json[k] = @.get_json_pointer jsonpointer, json[k] if jsonpointer.length 
        else if fs and fs.existsSync ref 
          str = fs.readFileSync(ref).toString()
          if str.match /module\.exports/
            json[k] = require ref
          else 
            json[k] = JSON.parse str
        else if String(ref).match /^#\//
          json[k] = @.get_json_pointer ref, root
      else
        @.replace v, ids, root if typeof v is 'object' 

  @.resolve = (json) ->
    ids = {}; @.findIds json, ids
    @.replace json, ids, json
    return json

  return @

)()
