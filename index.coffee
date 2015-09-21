module.exports = () ->
  
  @.findIds = (json, ids) ->
    id = false; obj = {}
    for k,v of json 
      id = json.id if json.id?
      obj[k] = v if id and k != "id"  
      @.findIds v, ids if typeof v is 'object' 
    ids[id] = obj if id

  @.replace = (json, ids) ->
    for k,v of json 
      if v['$ref']? and ids[ v['$ref'] ]?
        json[k] = ids[ v['$ref'] ] 
      else
        @.replace v, ids if typeof v is 'object' 

  @.resolve = (json) ->
    ids = {}; @.findIds json, ids
    @.replace json, ids
    return json

  return @
