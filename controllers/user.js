var exports = module.exports

var mongoose = require('mongoose')
  , User = mongoose.model("User")
  , errorResponse = require('../helpers/error_response.js')
  , ivle = require('../ivle.js')

exports.getCurrentUser = function(_id, token, callback) {
  User.findOne({ '_id': _id, 'auth.token': token }, function(err, user) {
    if (err) {
      callback(err);
    } else if (!user) {
      callback('Invalid Token');
    } else {
      callback(null, user);
    }
  })
}


exports.auth = function(req, res, next) {
  var token = req.params.token;
  ivle.validate(token, function(err, ivleResult) {
    if (err) {
      console.log(err);
      errorResponse.notAuthorized(res, 'Invalid IVLE login');
    } else {
      ivle.getProfile(ivleResult.token, function(err, result) {
        if (err) {
          console.log(err)
          errorResponse.notAuthorized(res, 'Invalid IVLE login');
        } else {
          User.upsertUser(result, ivleResult, function(err, result) {
            if (err) {
              errorResponse.internal(res, err);
            } else {
              res.json({
                token: result.auth.token,
                expiry: result.auth.expiry
              });
            }
          });
        }
      });
    }
  })
}
