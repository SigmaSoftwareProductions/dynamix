console.log 'online'

{Room} = require './room'
wsx = require 'ws'
mongodb = require 'mongodb'
mongoose = require 'mongoose'
crypto = require 'crypto'
util = require 'util'
http = require 'http'

port = process.env.PORT || 2020

wss = new wsx.Server({port: port})
console.log "wss online on port " + port

q = 'The von Neumann form of this concept is given in terms of the trace of a density matrix times its log. The Sackur-Tetrode equation gives this quantity extensively, avoiding the Gibbs paradox. Defined as the Boltzmann constant times natural log of the number of microstates, it is multiplied by temperature in the expression for Gibbs free energy. Maxwell\'s hypothetical demon purports to lowers this quantity. Symbolized by the letter S, its tendency to increase is dictated by the second law of thermodynamics. For 10 points, name this quantity, a measure of a system\'s disorder.'

rooms = []
names = []

wss.broadcast = (data) ->
  wss.clients.forEach (ws) ->
    if (ws.readyState == wsx.OPEN)
      ws.send(data)

wss.on 'connection', (ws) ->
  console.log 'connection established'
  ws.send 'hello there folks!'
  ws.on 'message', (msg) ->
    msg = JSON.parse msg
    res = rooms[names.indexOf(msg.room)].handle(msg.msgContent) if !msg.greeting?
    rooms.add msg.room if msg.greeting?
    if (res == "correct")
      wss.broadcast "correct by " + msg.person
    else if (res == "wrong")
      wss.broadcast "neg by " + msg.person
    else if (res.substring(0, 4) == "chat")
      wss.broadcast "chat by " + msg.person + " saying " + res.substring(5)
