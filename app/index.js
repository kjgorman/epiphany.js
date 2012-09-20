// Generated by CoffeeScript 1.3.3
var app, assets, express, http, idNickPairForClient, io, onlineData, port, srvr, studentsOnline, stylus, _;

express = require('express');

stylus = require('stylus');

assets = require('connect-assets');

http = require('http');

_ = require('underscore');

app = express();

app.use(assets());

app.use(express["static"](process.cwd() + '/public'));

app.set('view engine', 'jade');

app.get('/', function(req, resp) {
  return resp.render('index');
});

app.get('/student', function(req, resp) {
  return resp.render('student');
});

app.get('/teacher', function(req, resp) {
  return resp.render('teacher');
});

port = process.env.PORT || process.env.VMC_APP_PORT || 3000;

srvr = http.createServer(app);

io = (require('socket.io')).listen(srvr);

srvr.listen(port);

console.log("Listening on " + port + "\nPress CTRL-C to stop server.");

studentsOnline = function() {
  return io.of('/student').clients();
};

idNickPairForClient = function(client) {
  var pair;
  pair = {};
  pair.id = client.id;
  pair.nick = client.store.data.nick;
  return pair;
};

onlineData = function() {
  var client, nickPairs, sClients, _i, _len;
  sClients = studentsOnline();
  nickPairs = [];
  for (_i = 0, _len = sClients.length; _i < _len; _i++) {
    client = sClients[_i];
    nickPairs.push(idNickPairForClient(client));
  }
  return {
    clients: sClients.length,
    idNickPairs: nickPairs
  };
};

io.sockets.manager.settings.blacklist = [];

io.of('/teacher').on('connection', function(socket) {
  return socket.emit('render', onlineData());
});

io.of('/student').on('connection', function(socket) {
  var cls_data, num, online_data, text;
  online_data = onlineData();
  gdata.clients = online_data.clients;
  cls_data = onlineData();
  cls_data.cls - (num = 1);
  cls_data.cls - (text = 'The Fibonacci sequence is formed by adding the preceding two terms to find the next,\
                         beginning with 0 and 1, e.g. 0,1,1,2,3,5,8... Find the 200th term of the sequence');
  socket.emit('online', cls_data);
  socket.broadcast.emit('online', online_data);
  io.of('/teacher').emit('render', online_data);
  socket.set('id', studentsOnline().length + 1);
  socket.on('set name', function(name) {
    socket.set('nick', name);
    return io.of('/teacher').emit('render', onlineData());
  });
  socket.on('edit', function(data) {
    io.of('/student').emit('edit', data);
    return io.of('/teacher').emit('render', onlineData());
  });
  return socket.on('disconnect', function(data) {
    var nickPairsLessThis, online, onlineLessThis;
    online = onlineData();
    nickPairsLessThis = _.filter(online.idNickPairs, function(o) {
      return o.id !== socket.id;
    });
    onlineLessThis = {
      clients: online.clients - 1,
      idNickPairs: nickPairsLessThis
    };
    gdata.clients = online.clients;
    io.of('/student').emit('online', onlineLessThis);
    return io.of('/teacher').emit('render', onlineLessThis);
  });
});

io.configure(function() {
  io.set("transports", ["xhr-polling"]);
  io.set("polling duration", 10);
  return io.set("sync disconnect on unload", true);
});
