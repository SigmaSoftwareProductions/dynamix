express = require 'express'
app = express()
port = process.env.PORT || 2000

app.get '/', (request, response) ->
  response.sendFile __dirname+"/homepage.html"

app.get '/teapot', (request, response) ->
  response.sendStatus 418

app.get '/dynamix-client.js', (request, response) ->
  response.sendFile __dirname+"/dynamix-client.js"

app.get '/jquery-3.2.1.js', (request, response) ->
  response.sendFile __dirname+"/jquery-3.2.1.js"

app.get '/dynamix.css', (request, response) ->
  response.sendFile __dirname+"/dynamix.css"
  
app.get '/signin', (request, response) ->
  response.sendFile __dirname+"/signin.html"
  
app.get '/signin.js', (request, response) ->
  response.sendFile __dirname+"/signin.js"

app.get '/:room', (request, response) ->
  response.sendFile __dirname+"/neilufi.html"

app.listen port, ->
  console.log "ayy, static server running on port " + port