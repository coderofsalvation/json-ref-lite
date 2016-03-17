# slightly odd requires because of browserify compatibility
fs      = ( if not window? then require 'fs' else false )
request = ( if fs and fs.existsSync __dirname+'/../sync-request' then require 'sync-request' else false )
expr    = require 'property-expr'

module.exports = ( () ->

  @.cache = {}
  @.extendtoken = '$extend'
  @.reftoken = '$ref'
  @.pathtoken = "#"
  @.debug = false

  @.clone = (obj) ->
    return obj if obj == null or typeof obj != 'object' or typeof obj == 'function'
    temp = obj.constructor()
    temp[key] = @.clone(obj[key]) for key of obj
    temp
  
  @.findIds = (json, ids) ->
    id = false; obj = {}
    for k,v of json 
      id = json.id if json.id?
      obj[k] = v if id and k != "id"  
      @.findIds v, ids if typeof v is 'object' 
    ids[id] = obj if id

  @.get_json_pointer = (ref,root) ->
    evalstr = ref.replace( /\\\//,'#SLASH#').replace( /\//g, '.' ).replace( /#SLASH#/,'/')
    evalstr = evalstr.replace new RegExp('^'+@.pathtoken),''
    evalstr = evalstr.substr(1, evalstr.length-1) if evalstr[0] is '.'
    try
      console.log "evaluating '"+evalstr+"'" if @.debug
      result = expr.getter( evalstr )(root)
    catch err 
      result = ""
    return result
    #return eval( 'try{'+evalstr+'}catch(e){}')

  @.replace = (json, ids, root) ->
    for k,v of json 
      console.log "checking "+k if @.debug and typeof ref is 'string'
      if v? and v[reftoken]? 
        ref = v[reftoken]
        console.log "checking "+k+" -> "+ref if @.debug and typeof ref is 'string'
        if Object.keys(v).length > 1 
          console.error "json-ref-lite error: object '#{k}' contains reference as well as other properties..ignoring properties" 
        if Array.isArray ref
          ref = @.replace ref, ids, root
        else if ids[ ref ]?
          json[k] = ids[ ref ] 
        else if request and String(ref).match /^https?:/
          url = ref.match(/^[^#]*/)
          @.cache[url] = JSON.parse request("GET",url).getBody().toString() if not @.cache[url]
          json[k] = @.cache[url]
          if ref.match( @.pathtoken )
            jsonpointer = ref.replace new RegExp(".*"+pathtoken),@.pathtoken
            json[k] = @.get_json_pointer jsonpointer, json[k] if jsonpointer.length 
        else if fs and fs.existsSync ref 
          str = fs.readFileSync(ref).toString()
          if str.match /module\.exports/
            json[k] = require ref
          else 
            json[k] = JSON.parse str
        else if String(ref).match new RegExp('^'+@.pathtoken)
          console.log "checking "+ref+" pathtoken" if @.debug
          json[k] = @.get_json_pointer ref, root
        console.log ref+" reference not found" if json[k]?.length? and json[k]?.length == 0 and @.debug
      else
        @.replace v, ids, root if typeof v is 'object'

  @.extend = (json) ->
    if typeof json is 'object'
      for k,v of json 
        if k is @.extendtoken and v[ @.reftoken ]?
          ref = @.get_json_pointer v[ @.reftoken ], json
          ( ref[rk] = rv if rk != @.reftoken ) for rk,rv of v
          delete json[k]
        v = @.extend v if typeof v is 'object'

  @.resolve = (json) ->
    ids = {}; @.findIds json, ids
    console.dir ids if @.debug and Object.keys(ids).length
    @.replace json, ids, json
    return json

  @.evaluate = (json,data,cb) ->
    cb = @.evaluateStr if not cb?
    for k,v of @.clone json 
      json[k] = cb v,data if typeof v is 'string'
      json[k] = @.evaluate v,data if typeof v is 'object'
    return json

  @.evaluateStr = (k,data) ->
    return k if typeof k != 'string'
    if k[0] is '{' and k[k.length-1] is '}'
      try return expr.getter( k.replace(/^{/,'').replace(/}$/,'') )(data)
      catch
        return null
    else
      itemstr = k.replace /(\{)(.*?)(\})/g, ($0,$1,$2) -> 
        result = '' ; 
        return result if not data? or not $2?
        if data[$2]? and typeof data[$2] == 'function'
          result = data[$2]()
        else 
          if data[$2]?
            result = data[$2] 
          else
            try
              $2 = $2.replace( new RegExp('^'+@.pathtoken+'\/'),'' ).replace(/\//g,'.') # convert jsonpath to normal path
              result = expr.getter( $2 )(data)
            catch err
              result = ''
            result = '' if not result?
        @.evaluateStr result, data
        return result
      return itemstr
  
  return @

)()
