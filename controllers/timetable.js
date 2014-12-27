var exports = module.exports

var mongoose = require('mongoose')
  , Timetable = mongoose.model("Timetable")
  , User = mongoose.model("User")
  , errorResponse = require('../helpers/error_response.js')
  , _ = require('lodash');


exports.create = function(req, res, next) {
  var fields = {
    academicYear: req.body.academicYear,
    semester: req.body.semester,
    modules: req.body.modules,
    _owner: req.currentUser._id,
    main: false
  }
  var duplicate = new Timetable(fields);
  duplicate.save(function(err, timetable) {
    if (err) {
      errorResponse.internal(res, err);
    } else {
      var actual = new Timetable(fields);
      actual.main = true;
      actual.copy = duplicate._id;
      actual.save(function(err, timetable) {
        if (err) {
          errorResponse.internal(res, err);
        } else {
          res.status(201);
          res.json(timetable);
        }
      })
    }
  });
}

exports.index = function(req, res, next) {
  var filter = {
    academicYear: req.params.academicYear,
    semester: req.params.semester,
  };

  Timetable.findWithOwner(req.currentUser._id, filter, function(err, timetables) {
    if (err) {
      errorResponse.internal(res, err);
    } else {
      res.json(timetables)
    }
  })
}

exports.getById = function(req, res, next) {
  Timetable.findByIdWithUser(req.params.id, req.currentUser._id, function(err, timetable) {
    if (err) {
      errorResponse.internal(res, err);
    } else if (timetable) {
      if (timetable._owner != req.currentUser._id) {
        delete timetable.copy;
      }
      res.json(timetable);
    } else {
      errorResponse.notFound(res, "Timetable " + req.params.id + " not found.");
    }
  });
};

exports.update = function(req, res, next) {
  Timetable.findByIdWithOwner(req.params.id, req.currentUser._id, function(err, timetable) {
    var duplicate = new Timetable({
      academicYear: timetable.academicYear,
      semester: timetable.semester,
      modules: req.body.modules,
      _owner: req.currentUser._id,
      main: false
    })
    duplicate.save(function(err, dupe) {
      if (err) {
        errorResponse.internal(res, err);
      } else {
        timetable.copy = dupe._id;
        timetable.modules = dupe.modules;
        timetable.save(function(err, timetable) {
          if (err) {
            errorResponse.internal(res, err);
          } else {
            res.json(timetable);
          }
        })
      }
    });
  });
}

exports.detele = function(req, res, next) {
  Timetable.findByIdAndRemoveWithUser(req.params.id, req.currentUser._id, function(err, timetable) {
    if (err) {
      errorResponse.internal(res, err);
    } else if (timetable) {
      res.status(204);
    } else {
      errorResponse.notFound(res, "Timetable " + req.params.id + " not found.");
    }
  });
};

exports.getShared = function(req, res, next) {
  Timetable.findByIdWithOwner(req.params.id, req.currentUser._id, function(err, timetable) {
    if (err) {
      errorResponse.internal(res, err);
    } else if (timetable) {
      res.json(timetable.sharedUsers);
    } else {
      errorResponse.notFound(res, "Timetable " + req.params.id + " not found.");
    }
  });
}

exports.updateShared = function(req, res, next) {
  Timetable.findByIdWithOwner(req.params.id, req.currentUser._id, function(err, timetable) {
    if (err) {
      errorResponse.internal(res, err);
    } else if (!timetable) {
      errorResponse.notFound(res, "Timetable " + req.params.id + " not found.");
    } else {
      _.forEach(req.body, function(user) {
        if (user && user[0] != '-') {
          timetable.sharedUsers.addToSet(user);
        } else {
          timetable.sharedUsers.pull(user.slice(1));
        }
      });

      var users = _.clone(req.body);
      var total = users.length;
      // save all users to db
      function upsertAll(users) {
        var user = users.pop();
        if (user && user[0] == '-') {
          user = user.slice(1);
        }

        User.upsertUserBare(user, function(err, saved){
          if (err) throw err;//handle error

          if (--total) {
            upsertAll(users);
          } else {
            timetable.save(function(err, timetable) {
            if (err) {
              errorResponse.internal(res, err);
            } else {
              res.json(timetable.sharedUsers)
            }
          });
          }
        });
      }
      upsertAll(users);
    }
  });
}

exports.incoming = function(req, res, next) {
  var filter = {
    user: req.params.user,
    academicYear: req.params.academicYear,
    semester: req.params.semester,
  };
  Timetable.findShared(req.currentUser._id, filter, function(err, timetables) {
    if (err) {
      errorResponse.internal(res, err);
    } else {
      res.json(timetables);
    }
  });
}

