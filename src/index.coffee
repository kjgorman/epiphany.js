#author: kjgorman.com
express = require 'express'
stylus  = require 'stylus'
assets  = require 'connect-assets'
http    = require 'http'
_       = require 'underscore'
fs      = require 'fs'

app = express()
# Add Connect Assets
app.use assets()
# Set the public folder as static assets
app.use express.static(process.cwd() + '/public')
# Set View Engine
app.set 'view engine', 'jade'
# Get root_path return index view
app.get '/', (req, resp) -> 
  resp.render 'index'
app.get '/student', (req,resp) ->
  resp.render 'student'
app.get '/teacher', (req, resp) ->
  resp.render 'teacher'
app.get '/contribute', (req,resp) ->
  resp.render 'contribute'
# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
srvr = http.createServer app
io = (require 'socket.io').listen srvr
srvr.listen port
console.log "Listening on #{port}\nPress CTRL-C to stop server."

cls = ""

readClass = () ->
        fs.readFile "class.json", "utf8", (err,data) ->
                if err
                        console.log "COULD NOT LOAD CLASS"
                console.log "data: "+data    
                try
                        cls = eval(data)
                catch err
                        for k of data
                                console.log k
                        console.log err.message
                        cls = data                        
readClass()

studentsOnline = () ->
    io.of('/student').clients()

idNickPairForClient = (client) ->
        pair = {}
        pair.id = client.id
        pair.nick = client.store.data.nick
        pair

onlineData = () ->
    sClients = studentsOnline()
    nickPairs = []
    nickPairs.push (idNickPairForClient client) for client in sClients 
    {clients:sClients.length, idNickPairs:nickPairs}

classData = (clsnum) ->
    if !cls[clsnum]
        {} #don't explode when there isn't a class left
    cls_data = {}
    cls_data.clsnum = clsnum
    cls_data.clstext = cls[clsnum].clstext
    cls_data.clsans = cls[clsnum].clsans
    cls_data.base = cls[clsnum].base
    cls_data

io.sockets.manager.settings.blacklist = []

io.of('/contribute')
  .on 'connection', (socket) ->
        socket.emit 'class-down', cls
        socket.on 'class-up', (cls) ->
                fs.writeFile 'class.json', "("+cls+")", (err) ->
                        console.log err if err
                        socket.emit 'class-down', readClass()
io.of('/teacher')
  .on 'connection', (socket) ->
    socket.emit 'render', onlineData()

    socket.on 'edit', (data) ->
        io.of('/student').emit 'edit', data

    socket.on 'viewing', (data) ->
        io.of('/student').emit 'viewing', data
        
io.of('/student')
  .on 'connection', (socket) ->
    online_data = onlineData() #don't need to recompute this for the next few emissions
    current_cls = 1
    completion = 0
    
    socket.emit 'online', online_data
    socket.emit 'class', classData(current_cls)

    socket.broadcast.emit 'online', online_data
    io.of('/teacher').emit 'render', online_data

    socket.set 'id', studentsOnline().length+1

    socket.on 'set name', (name) ->
        socket.set 'nick', name
        socket.emit 'sid', socket.id
        io.of('/teacher').emit 'render', onlineData()
        io.of('/teacher').emit 'update', onlineData()
        
    socket.on 'edit', (data) ->
        io.of('/teacher').emit 'update', {sid:socket.id, text:data.text, completion:completion}
        
    socket.on 'help', (sid) ->
        io.of('/teacher').emit 'help', {sid:sid}
        
    socket.on 'disconnect', (data) ->
        online = onlineData()
        nickPairsLessThis = _.filter online.idNickPairs, (o) -> o.id != socket.id
        onlineLessThis = {clients:online.clients-1, idNickPairs:nickPairsLessThis}
        io.of('/student').emit 'online',  onlineLessThis
        io.of('/teacher').emit 'render', onlineLessThis
        
    socket.on 'level up', (data) ->
        completion = completion + 1
        current_cls = current_cls + 1
        socket.emit 'class', classData(current_cls)
        io.of('/teacher').emit 'level up', {sid:socket.id, cmpl:completion}  
    

        
#unfortunately heroku doesn't support cool websockets : (
io.configure ->
    io.set "transports", ["xhr-polling"] 
    io.set "polling duration", 10
    io.set "sync disconnect on unload", true
