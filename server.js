var config = require('./config.js');

var restify = require('restify')
  , fs = require('fs')
  , mongoose = require('mongoose');


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
server.get('/timetables', controllers.timetable.index);
server.post('/timetables', controllers.timetable.create);
server.get('/timetables/:id', controllers.timetable.getById);
server.put('/timetables/:id', controllers.timetable.update);


server.get('/timetables/:id/share', controllers.timetable.getShared);
server.put('/timetables/:id/share', controllers.timetable.updateShared);

server.get('/incoming-timetables', controllers.timetable.incoming);


// party time
server.listen(3000, function () {
  console.log('%s listening at %s', server.name, server.url)
})
