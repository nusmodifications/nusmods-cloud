var mongoose = require("mongoose");
var Schema   = mongoose.Schema
  , ObjectId = mongoose.Types.ObjectId;

var TimetableSchema = new Schema({
  _owner: { type: String, ref: 'User'},
  academicYear: String,
  semester: Number,
  main: { type: Boolean, default: true },
  copy: { type: Schema.Types.ObjectId, ref: 'Timetable' },
  modules: Schema.Types.Mixed,
  timestamp: { type : Date, default: Date.now },
  sharedUsers: [
    { type: String, ref: 'User', select: false }
  ]
});


TimetableSchema.statics.findWithOwner = function(owner, filter, callback) {
  var query = this.find()
    .select('_owner copy academicYear semester modules timestamp')
    .where('_owner', owner)
    .where('main', true)
    .sort('academicYear semester')

  if (filter.academicYear) {
    query.where('academicYear', filter.academicYear);
  }
  if (filter.semester) {
    query.where('semester', filter.semester);
  }
  query.exec(callback);
}

TimetableSchema.statics.findByIdWithUser = function(id, current, callback) {
  var query = this.findById(new ObjectId(id))
    .select('_owner copy academicYear semester modules timestamp')
    .or([
      { _owner: current },
      { sharedUsers: { $all: current } }
      ])
    // .populate('_owner', 'name profilePic')
    .exec(callback);
}


TimetableSchema.statics.findByIdWithOwner = function(id, current, callback) {
  var query = this.findById(new ObjectId(id))
    .select('_owner academicYear semester modules timestamp sharedUsers')
    .where('_owner', current)
    //.populate('sharedUsers', 'name profilePic')
    // .populate('_owner', 'name profilePic')
    .exec(callback);
}

TimetableSchema.statics.findShared = function(current, filter, callback) {
  var query = this.find({sharedUsers: current});
  query.select('_owner academicYear semester modules timestamp')
    // .populate('_owner', 'name profilePic').;
  if (filter.academicYear) {
    query.where('academicYear', filter.academicYear);
  }
  if (filter.semester) {
    query.where('semester', filter.semester);
  }
  if (filter.user) {
    query.where('_owner', filter.user)
  }
  query.exec(callback);
}

mongoose.model('Timetable', TimetableSchema);
