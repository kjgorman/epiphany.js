express = require 'express'
stylus  = require 'stylus'
assets  = require 'connect-assets'
http    = require 'http'

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
    return io.of('/student').clients().length
onlineData = () ->
    return {clients:studentsOnline()}

gdata = {clients:0}
io.sockets.manager.settings.blacklist = []

io.of('/student')
  .on 'connection', (socket) ->

    gdata.clients = io.sockets.clients().length
    socket.emit 'online', onlineData()
    socket.broadcast.emit 'online', onlineData()
    io.of('/teacher').emit 'online', onlineData()
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
