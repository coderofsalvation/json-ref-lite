fs    = require 'fs'
request = false
request = require 'sync-request' if fs.existsSync __dirname+'/node_modules/sync-request'

module.exports = () ->
  
  @.findIds = (json, ids) ->
    id = false; obj = {}
    for k,v of json 
      id = json.id if json.id?
      obj[k] = v if id and k != "id"  
      @.findIds v, ids if typeof v is 'object' 
    ids[id] = obj if id

  @.replace = (json, ids, root) ->
    for k,v of json 
      if v['$ref']? 
        ref = v['$ref']
        if ids[ ref ]?
          json[k] = ids[ ref ] 
        else if request and String(ref).match /^http/
          json[k] = JSON.parse request("GET",ref).getBody().toString()
        else if fs.existsSync ref 
          str = fs.readFileSync(ref).toString()
          if str.match /module\.exports/
            json[k] = require ref
          else 
            json[k] = JSON.parse str
        else if String(ref).match /^#\//
          evalstr = ref.replace( /\\\//,'#SLASH#').replace( /\//g, '.' ).replace( /#/,'root').replace( /#SLASH#/,'/')
          console.log evalstr if process.env.DEBUG?
          json[k] = eval( 'try{'+evalstr+'}catch(e){}')
      else
        @.replace v, ids, root if typeof v is 'object' 

  @.resolve = (json) ->
    ids = {}; @.findIds json, ids
    @.replace json, ids, json
    return json

  return @
