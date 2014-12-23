var mongoose = require("mongoose");
var Schema   = mongoose.Schema;
var uuid = require('node-uuid')

var UserSchema = new Schema({
  _id: String,
  name: { type: String, default: "Unknown" },
  email: { type: String, default: '' },
  profilePic:{ type: String, default: '' },
  ivle_auth: {
    token: String,
    expiry: Date
  },
  auth: {
    token: String,
    expiry: Date
  }
});

function getExpiry() {
  var d = new Date();
  d.setDate(d.getDate() + 7);
  return d;
}

UserSchema.statics.upsertUser = function(user, ivleAuth, callback) {
  this.findOneAndUpdate(
    { _id: user.UserID },
    {
      _id: user.UserID,
      name: user.Name,
      email: user.Email,
      ivle_auth: {
        token: ivleAuth.token,
        expiry: ivleAuth.expiry
      },
      auth: {
        token: uuid.v4(),
        expiry: getExpiry()
      }
    },
    { upsert: true }
  )
  .exec(callback);
}


UserSchema.statics.upsertUserBare = function(_id, callback) {
  this.findOneAndUpdate(
    { _id: _id },
    { _id: _id },
    { upsert: true }
  )
  .exec(callback);
}


mongoose.model('User', UserSchema);
