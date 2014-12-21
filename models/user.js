var mongoose = require("mongoose");
var Schema   = mongoose.Schema;

var UserSchema = new Schema({
  userId: Number,
  name: String,
  email: String,
  profilePic: String
});

mongoose.model('User', UserSchema);
