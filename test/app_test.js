// Generated by CoffeeScript 1.3.3
(function() {
  var request;

  request = require('request');

  describe('Sample test', function() {
    return it('should be true', function() {
      return true.should.equal(true);
    });
  });

  describe('GET /', function() {
    var response;
    response = null;
    before(function(done) {
      return request('http://localhost:3000', function(e, r, b) {
        response = r;
        return done();
      });
    });
    return it('should return 200', function(done) {
      response.statusCode.should.equal(200);
      return done();
    });
  });

}).call(this);
