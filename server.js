var config = require('./config.js');

var restify = require('restify')
  , fs = require('fs')
  , mongoose = require('mongoose')
  , _ = require('lodash')
  , errorResponse = require('./helpers/error_response.js')


// init db, controllers and models
mongoose.connect(config.creds.mongoose_auth_local);

var controllers = {}
  , controllers_path = './controllers/'
  , models = {}
  , models_path = './models/';

fs.readdirSync(models_path).forEach(function (file) {
  if (file.indexOf('.js') != -1) {
    models[file.split('.')[0]] = require(models_path + file);
  }
})

fs.readdirSync(controllers_path).forEach(function (file) {
  if (file.indexOf('.js') != -1) {
    controllers[file.split('.')[0]] = require(controllers_path + file);
  }
})

// server setup
var server = restify.createServer();
server
  .use(restify.fullResponse())
  .use(restify.queryParser())
  .use(restify.bodyParser({mapParams: false}));

// routing

server.get('/auth', controllers.user.auth);

function protectedRoute(handler) {
  return function(req, res, next) {
    controllers.user.getCurrentUser(req.params.user, req.params.token, function(err, user) {
      if (err) {
        errorResponse.notAuthorized(res, err)
      } else {
        req.currentUser = user;
        handler(req, res, next);
      }
    });
  }
}

server.get('/timetables', protectedRoute(controllers.timetable.index));
server.post('/timetables', protectedRoute(controllers.timetable.create));
server.get('/timetables/:id', protectedRoute(controllers.timetable.getById));
server.put('/timetables/:id', protectedRoute(controllers.timetable.update));


server.get('/timetables/:id/share', protectedRoute(controllers.timetable.getShared));
server.put('/timetables/:id/share', protectedRoute(controllers.timetable.updateShared));

server.get('/incoming-timetables', protectedRoute(controllers.timetable.incoming));


// party time
server.listen(3000, function () {
  console.log('%s listening at %s', server.name, server.url)
})
