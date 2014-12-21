var exports = module.exports

var mongoose = require('mongoose')
  , Timetable = mongoose.model("Timetable")
  //, Sharing = mongoose.model("Sharing")
  , errorResponse = require('../helpers/error_response.js');

exports.incoming = {}
exports.outgoing = {}

// TODO
function currentUser() {
  return 1;
}

exports.incoming.index = function(req, res, next) {
  Sharing.findIncoming(currentUser(), function(err, sharings) {
    if (err) {
      errorResponse.internal(res, err);
    } else {
      res.json(sharing);
    }
  })
}

exports.incoming.create = function(req, res, next) {

}

exports.outgoing.index = function(req, res, next) {
  Sharing.findOutgoing(currentUser(), function(err, sharings) {
    if (err) {
      errorResponse.internal(res, err);
    } else {
      res.json(sharing);
    }
  })
}

exports.outgoing.create = function(req, res, next) {

}

exports.outgoing.delete = function(req, res, next) {

}

