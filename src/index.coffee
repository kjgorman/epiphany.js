express = require 'express'
stylus  = require 'stylus'
assets  = require 'connect-assets'
http    = require 'http'
_       = require 'underscore'

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
# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
srvr = http.createServer app
io = (require 'socket.io').listen srvr
srvr.listen port
console.log "Listening on #{port}\nPress CTRL-C to stop server."

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

io.sockets.manager.settings.blacklist = []

io.of('/teacher')
  .on 'connection', (socket) ->
    socket.emit 'render', onlineData()

io.of('/student')
  .on 'connection', (socket) ->
    online_data = onlineData() #don't need to recompute this for the next few emissions
    gdata.clients = online_data.clients
    socket.emit 'online', online_data
    socket.emit 'class', {cls_num:1}
    # {class_num:1, class_text:"The fibonacci sequence adds the last two numbers in the sequence to find the next, e.g. 0,1,1,2,3,5. Find the 200th number"}
    socket.broadcast.emit 'online', online_data
    io.of('/teacher').emit 'render', online_data

    socket.set 'id', studentsOnline().length+1

    socket.on 'set name', (name) ->
        socket.set 'nick', name
        io.of('/teacher').emit 'render', onlineData()
    socket.on 'edit', (data) ->
        io.of('/student').emit 'edit', data
        io.of('/teacher').emit 'render', onlineData()
                
    socket.on 'disconnect', (data) ->
        online = onlineData()
        nickPairsLessThis = _.filter online.idNickPairs, (o) -> o.id != socket.id
        onlineLessThis = {clients:online.clients-1, idNickPairs:nickPairsLessThis}
        gdata.clients = online.clients
        io.of('/student').emit 'online',  onlineLessThis
        io.of('/teacher').emit 'render', onlineLessThis
  
    

        
#unfortunately heroku doesn't support cool websockets : (
io.configure ->
    io.set "transports", ["xhr-polling"] 
    io.set "polling duration", 10
    io.set "sync disconnect on unload", true
