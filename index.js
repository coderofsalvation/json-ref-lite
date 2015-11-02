// Generated by CoffeeScript 1.9.3
(function() {
  var expr, fs, request;

  fs = (typeof window === "undefined" || window === null ? require('fs') : false);

  request = (fs && fs.existsSync(__dirname + '/../sync-request') ? require('sync-request') : false);

  expr = require('property-expr');

  module.exports = (function() {
    this.cache = {};
    this.findIds = function(json, ids) {
      var id, k, obj, v;
      id = false;
      obj = {};
      for (k in json) {
        v = json[k];
        if (json.id != null) {
          id = json.id;
        }
        if (id && k !== "id") {
          obj[k] = v;
        }
        if (typeof v === 'object') {
          this.findIds(v, ids);
        }
      }
      if (id) {
        return ids[id] = obj;
      }
    };
    this.get_json_pointer = function(ref, root) {
      var err, evalstr, result;
      evalstr = ref.replace(/\\\//, '#SLASH#').replace(/\//g, '.').replace(/#SLASH#/, '/');
      evalstr = evalstr.replace(/#\./, '');
      try {
        if (process.env.DEBUG != null) {
          console.log(evalstr);
        }
        result = expr.getter(evalstr)(root);
      } catch (_error) {
        err = _error;
        result = "";
      }
      return result;
    };
    this.replace = function(json, ids, root) {
      var jsonpointer, k, ref, results, str, v;
      results = [];
      for (k in json) {
        v = json[k];
        if ((v != null) && (v['$ref'] != null)) {
          ref = v['$ref'];
          if (ids[ref] != null) {
            results.push(json[k] = ids[ref]);
          } else if (request && String(ref).match(/^http/)) {
            if (!this.cache[ref]) {
              this.cache[ref] = JSON.parse(request("GET", ref).getBody().toString());
            }
            json[k] = this.cache[ref];
            if (ref.match("#")) {
              jsonpointer = ref.replace(/.*#/, '#');
              if (jsonpointer.length) {
                results.push(json[k] = this.get_json_pointer(jsonpointer, json[k]));
              } else {
                results.push(void 0);
              }
            } else {
              results.push(void 0);
            }
          } else if (fs && fs.existsSync(ref)) {
            str = fs.readFileSync(ref).toString();
            if (str.match(/module\.exports/)) {
              results.push(json[k] = require(ref));
            } else {
              results.push(json[k] = JSON.parse(str));
            }
          } else if (String(ref).match(/^#\//)) {
            results.push(json[k] = this.get_json_pointer(ref, root));
          } else {
            results.push(void 0);
          }
        } else {
          if (typeof v === 'object') {
            results.push(this.replace(v, ids, root));
          } else {
            results.push(void 0);
          }
        }
      }
      return results;
    };
    this.resolve = function(json) {
      var ids;
      ids = {};
      this.findIds(json, ids);
      this.replace(json, ids, json);
      return json;
    };
    return this;
  })();

}).call(this);
