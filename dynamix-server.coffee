express = require 'express'
cp = require 'child_process'
app = express();
main = cp.fork './main-controller'
rooms = []

app.get '/', (request, response) ->
  response.send 'hi'

app.get '/teapot', (request, response) ->
  response.sendStatus 418

app.get '/dynamix-client.js', (request, response) ->
  response.sendFile "/Users/karangurazada/Documents/Node/dynamix-client.js"

app.get '/jquery-3.2.1.js', (request, response) ->
  response.sendFile "/Users/karangurazada/Documents/Node/jquery-3.2.1.js"

app.get '/favicon.ico', (request, response) ->
  response.sendFile "/Users/karangurazada/Downloads/kubuntu.png"

app.get '/\*', (request, response) ->
  response.sendFile "/Users/karangurazada/Documents/Node/neilufi.html"
  room = request.originalUrl.substring(1)
  if (rooms.indexOf(room) == -1)
    rooms.push room
    main.send room

port = process.env.PORT || 80
app.listen port, ->
  console.log "ayy, process running on port " + port 
