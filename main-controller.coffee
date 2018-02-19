console.log 'online'

{Room} = require './room'
{Person} = require './person'
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
sessions = {}

wss.broadcast = (data) ->
    console.log 'broadcasting ' + data
    wss.clients.forEach (ws) ->
        if (ws.readyState == wsx.OPEN)
            ws.send(data)

wss.on 'connection', (ws) ->
    name = "what is a string that will never be a name?"
    room = "what is a string that will never be a room?"
    ws.on 'message', (msg) ->
        console.log msg if not msg.auth? # sneaky sneaky
        if msg == 'ping'
            ws.send('pong')
            return   
        msg = JSON.parse msg
        if (msg.greeting? && names.indexOf(msg.room) == -1)
            rooms.push(new Room ({name:msg.room, status:"standard", owner:"communist party", wss:wss})) # maybe the first person there should own it? idk
            names.push(msg.room)
        if (msg.greeting?)
            name = msg.msgContent.person
            room = msg.room
            if (!sessions[name]?)
                sessions[name] = []
            sessions[name].push msg.session
        if (msg.auth?)
            res = Person.auth msg.username, msg.password, (res) ->
                ws.send JSON.stringify {username:msg.username, auth:res} # this is awesome! works seamlessly! async programming still sucks tho
            return
        res = rooms[names.indexOf(msg.room)].handle(msg.msgContent)
        
    ws.on 'close', () ->
        res = rooms[names.indexOf(room)].handle({category:"farewell", person:name}) if name != "what is a string that will never be a name?"
