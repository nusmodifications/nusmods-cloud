var request = require('request')
  , config = require('./config.js');


var exports = module.exports;


exports.validate = function(authToken, callback) {
  request.get({
    url: config.vars.ivle_base_url + '/Validate',
    qs: {
      APIKey: config.creds.lapi_key,
      Token: authToken
    }
  }, function (err, response, body) {
    if (err || response.statusCode !== 200) {
      callback(err);
    } else {
      var content = JSON.parse(body);
      if (content.Success) {
        var token = {
          expiry: new Date(content.ValidTill_js),
          token: content.Token
        };
        return callback(null, token);
      } else {
        callback('invalid');
      }
    }
  })
}


exports.getProfile = function(authToken, callback) {
  request.get({
    url: config.vars.ivle_base_url + '/Profile_View',
    qs: {
      APIKey: config.creds.lapi_key,
      AuthToken: authToken
    }
  }, function (err, response, body) {
    if (err) {
      callback(err);
    } else if (response.statusCode !== 200) {
      callback(response);
    } else {
      var content = JSON.parse(body);
      if (content.Results.length) {
        return callback(null, content.Results[0]);
      } else {
        callback(content.Comments);
      }
    }
  })
}
