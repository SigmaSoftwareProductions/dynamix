express = require 'express'
app = express();
port = process.env.PORT || 2000

app.get '/', (request, response) ->
  response.send 'hi'

app.get '/teapot', (request, response) ->
  response.sendStatus 418

app.get '/dynamix-client.js', (request, response) ->
  response.sendFile __dirname+"/dynamix-client.js"

app.get '/jquery-3.2.1.js', (request, response) ->
  response.sendFile __dirname+"/jquery-3.2.1.js"

app.get '/favicon.ico', (request, response) ->
  response.sendFile __dirname+"/favicon.ico"

app.get '/\*', (request, response) ->
  response.sendFile __dirname+"/neilufi.html"

app.listen port, ->
  console.log "ayy, static server running on port " + port 
