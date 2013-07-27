express = require 'express'

# Setup the server
server = express.createServer()
server.use express.bodyParser()
server.use express.errorHandler { showStack: true, dumpExceptions: true }
server.set 'view engine', 'jade'
server.set 'view options', { layout: false }
server.set 'views', __dirname + '/jade'
server.use "/js", express.static "./js"
server.use "/style", express.static "./style"

# Define Routes
server.get '/', (req, res, next) ->
  res.render('index')

# Listen for requests
server.listen 3000
