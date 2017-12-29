console.log 'online'

{Room} = require './room'
wsx = require 'ws'
mongodb = require 'mongodb'
mongoose = require 'mongoose'
crypto = require 'crypto'
util = require 'util'
http = require 'http'
express = require 'express'
http = require 'http'

app = express()
port = process.env.PORT || 2020
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

wss = new wsx.Server(server: http.createServer(app))
console.log "wss online"

q = 'The von Neumann form of this concept is given in terms of the trace of a density matrix times its log. The Sackur-Tetrode equation gives this quantity extensively, avoiding the Gibbs paradox. Defined as the Boltzmann constant times natural log of the number of microstates, it is multiplied by temperature in the expression for Gibbs free energy. Maxwell\'s hypothetical demon purports to lowers this quantity. Symbolized by the letter S, its tendency to increase is dictated by the second law of thermodynamics. For 10 points, name this quantity, a measure of a system\'s disorder.'

rooms = []
names = []

{Room} = require './room'

process.on 'message', (msg) ->
  rooms.push(new Room ({name: msg.toString(), status: "public", owner: "entropy"}))
  names.push(msg)

wss.broadcast = (data, room) ->
  wss.clients.forEach (ws) ->
    if (ws.readyState == wsx.OPEN && ws.protocols = [room])
      ws.send(data)


wss.on 'connection', (ws) ->
  console.log 'connection established'
  ws.send 'hello there folks!'
  ws.on 'message', (msg) ->
    msg = JSON.parse msg
    res = rooms[names.indexOf(msg.room)].handle(msg.msgContent)
    if (res == "correct")
      wss.broadcast "correct by " + msg.person
    else if (res == "wrong")
      wss.broadcast "neg by " + msg.person
    else if (res.substring(0, 4) == "chat")
      wss.broadcast "chat by " + msg.person + " saying " + res.substring(5)
