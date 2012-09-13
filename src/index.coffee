express = require 'express'
stylus  = require 'stylus'
assets  = require 'connect-assets'
http    = require 'http'
_       = require '_'

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
    return io.of('/student').clients()
onlineData = () ->
    sClients = studentsOnline()
    nickPairs = []
    for client in sClients
        pair = {}
        pair.id = client.id
        pair.nick = client.get 'nick', (err, name) -> name || err
        nickPairs.push pair
    return {clients:sClients.length, idNickPairs:nickPairs}

gdata = {clients:0}
io.sockets.manager.settings.blacklist = []

io.of('/student')
  .on 'connection', (socket) ->

    gdata.clients = onlineData().clients
    socket.emit 'online', onlineData()
    socket.broadcast.emit 'online', onlineData()
    io.of('/teacher').emit 'online', onlineData()
    socket.set 'id', studentsOnline().length+1
    socket.on 'set name', (name) ->
        socket.set 'nick', name
    socket.on 'edit', (data) ->
        gdata.text = data.text
        socket.broadcast.emit 'edit', gdata
        socket.emit 'online', onlineData()
        return 
    socket.on 'disconnect', () ->
        gdata.clients = studentsOnline()
        socket.broadcast.emit 'online', onlineData()

io.of('/teacher')
  .on 'connection', (socket) ->
    #should probably do something sometime soon    
    socket.emit 'online', onlineData()
    socket.emit 'render', onlineData()    

#unfortunately heroku doesn't support cool websockets : (
io.configure ->
    io.set "transports", ["xhr-polling"] 
    io.set "polling duration", 10
    io.set "sync disconnect on unload", true
