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
# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
srvr = http.createServer app
io = (require 'socket.io').listen srvr
srvr.listen port
console.log "Listening on #{port}\nPress CTRL-C to stop server."

gdata = ''

io.sockets.on 'connection', (socket) ->
    socket.emit 'edit', gdata
    socket.on 'edit', (data) ->
        socket.broadcast.emit 'edit', (gdata: data, users:io.sockets.clients().length)
        return
    return 
io.configure() ->
    io.set "transports", ["xhr-polling"] 
    io.set "polling duration", 10
