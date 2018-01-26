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

rooms = []
names = []

wss.broadcast = (data) ->
    wss.clients.forEach (ws) ->
        if (ws.readyState == wsx.OPEN)
            ws.send(data)

wss.on 'connection', (ws) ->
    name = "what is a string that will never be a name?"
    ws.on 'message', (msg) ->
        if msg == 'ping'
            ws.send('pong')
            return   
        msg = JSON.parse msg
        if (msg.greeting? && names.indexOf(msg.room) == -1)
            rooms.push(new Room ({name:msg.room, status:"standard", owner:"communist party"})) # maybe the first person there should own it? idk
            names.push(msg.room)
        name = msg.msgContent.person if (msg.greeting?)    
        res = rooms[names.indexOf(msg.room)].handle(msg.msgContent)
        wss.broadcast(JSON.stringify(res))
    ws.on 'close', () ->
        res = res = rooms[names.indexOf(msg.room)].handle({farewell:"farewell!", person:name})
        wss.broadcast(JSON.stringigy(res)) 
