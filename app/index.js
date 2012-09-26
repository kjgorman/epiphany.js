// Generated by CoffeeScript 1.3.3
var app, assets, classData, cls, express, fs, http, idNickPairForClient, io, onlineData, port, readClass, srvr, studentsOnline, stylus, _;

express = require('express');

stylus = require('stylus');

assets = require('connect-assets');

http = require('http');

_ = require('underscore');

fs = require('fs');

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

app.get('/contribute', function(req, resp) {
  return resp.render('contribute');
});

port = process.env.PORT || process.env.VMC_APP_PORT || 3000;

srvr = http.createServer(app);

io = (require('socket.io')).listen(srvr);

srvr.listen(port);

console.log("Listening on " + port + "\nPress CTRL-C to stop server.");

cls = "";

readClass = function() {
  return fs.readFile("class.json", "utf8", function(err, data) {
    var k;
    if (err) {
      console.log("COULD NOT LOAD CLASS");
    }
    console.log("data: " + data);
    try {
      return cls = eval(data);
    } catch (err) {
      for (k in data) {
        console.log(k);
        console.log(data[k]);
      }
      console.log(err.message);
      return cls = data;
    }
  });
};

readClass();

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

classData = function(clsnum) {
  var cls_data;
  if (!cls[clsnum]) {
    ({});
  }
  cls_data = {};
  cls_data.clsnum = clsnum;
  cls_data.clstext = cls[clsnum].clstext;
  cls_data.clsans = cls[clsnum].clsans;
  cls_data.base = cls[clsnum].base;
  return cls_data;
};

io.sockets.manager.settings.blacklist = [];

io.of('/contribute').on('connection', function(socket) {
  socket.emit('class-down', cls);
  return socket.on('class-up', function(cls) {
    return fs.writeFile('class.json', "(" + cls + ")", function(err) {
      var data;
      if (err) {
        console.log(err);
      }
      data = readClass();
      console(log(data));
      return socket.emit('class-down', data);
    });
  });
});

io.of('/teacher').on('connection', function(socket) {
  socket.emit('render', onlineData());
  socket.on('edit', function(data) {
    return io.of('/student').emit('edit', data);
  });
  return socket.on('viewing', function(data) {
    return io.of('/student').emit('viewing', data);
  });
});

io.of('/student').on('connection', function(socket) {
  var completion, current_cls, online_data;
  online_data = onlineData();
  current_cls = 1;
  completion = 0;
  socket.emit('online', online_data);
  socket.emit('class', classData(current_cls));
  socket.broadcast.emit('online', online_data);
  io.of('/teacher').emit('render', online_data);
  socket.set('id', studentsOnline().length + 1);
  socket.on('set name', function(name) {
    socket.set('nick', name);
    socket.emit('sid', socket.id);
    io.of('/teacher').emit('render', onlineData());
    return io.of('/teacher').emit('update', onlineData());
  });
  socket.on('edit', function(data) {
    return io.of('/teacher').emit('update', {
      sid: socket.id,
      text: data.text,
      completion: completion
    });
  });
  socket.on('help', function(sid) {
    return io.of('/teacher').emit('help', {
      sid: sid
    });
  });
  socket.on('disconnect', function(data) {
    var nickPairsLessThis, online, onlineLessThis;
    online = onlineData();
    nickPairsLessThis = _.filter(online.idNickPairs, function(o) {
      return o.id !== socket.id;
    });
    onlineLessThis = {
      clients: online.clients - 1,
      idNickPairs: nickPairsLessThis
    };
    io.of('/student').emit('online', onlineLessThis);
    return io.of('/teacher').emit('render', onlineLessThis);
  });
  return socket.on('level up', function(data) {
    completion = completion + 1;
    current_cls = current_cls + 1;
    socket.emit('class', classData(current_cls));
    return io.of('/teacher').emit('level up', {
      sid: socket.id,
      cmpl: completion
    });
  });
});

io.configure(function() {
  io.set("transports", ["xhr-polling"]);
  io.set("polling duration", 10);
  return io.set("sync disconnect on unload", true);
});
