module.exports.internal = function(res, err) {
  res.status(500);
  res.json({
    error: 'Internal server error: ' + err
  });
}

module.exports.notFound = function(res, err) {
  res.status(404);
  res.json({
    error: 'Requested resource not found: ' + err
  });
}

module.exports.notAuthorized = function(res, err) {
  res.status(401);
  res.json({
    error: 'AuthError',
    message: err
  });
}
