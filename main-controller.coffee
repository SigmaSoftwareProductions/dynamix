console.log 'online'
{Team} = require './team'
{Room} = require './room'
{Person} = require './person'
{Tournament} = require './tournament'
wsx = require 'ws'
mongodb = require 'mongodb'
mongoose = require 'mongoose'
crypto = require 'crypto'
util = require 'util'
http = require 'http'

port = process.env.PORT || 2020

wss = new wsx.Server({port: port})
console.log "wss online on port " + port

rooms = [new Room ({name:'', access:0, owner:"entropy", wss:wss})]
names = [""]
sessions = {"guest": [0]}

wss.broadcast = (data) ->
    console.log 'broadcasting ' + data
    wss.clients.forEach (ws) ->
        if (ws.readyState == wsx.OPEN)
            ws.send(data)

wss.on 'connection', (ws) ->
    name = "what is a string that will never be a name?"
    room = ""
    type = 0 # 0 -> std, 1 -> team
    ws.on 'message', (msg) ->
        if msg == 'ping'
            ws.send('pong')
            return   
        msg = JSON.parse msg
        console.log 'msg received as ' + JSON.stringify msg if not msg.password? # sneaky sneaky
        if (msg.greeting? && names.indexOf(msg.room) == -1)
            rooms.push(new Room ({name:msg.room, access:0xF71, owner:msg.msgContent.person, wss:wss})) # maybe the first person there should own it? idk
            names.push(msg.room)
        if (msg.changeRoomType?)
            if type == 0
                rooms.splice names.indexOf(room), 1, new Room ({name:room, access:0xF71, owner:msg.msgContent.person, wss:wss, team1:new Team(msg.team1ppl, msg.team1), team2:new Team(msg.team2ppl, msg.team2)})
            else 
                rooms.splice names.indexOf(room), 1, new Room ({name:msg.room, access:0xF71, owner:msg.msgContent.person, wss:wss})
            return
        if (msg.greeting?)
            name = msg.msgContent.person
            room = msg.room
            if (not sessions[name]? or sessions[name].indexOf(msg.session) == -1)
                ws.send("error - invalid credentials. please sign in again") # make @info style
                ws.close()
                return
        if (msg.auth?)
            console.log 'authing!'
            res = Person.auth msg.username, msg.password, (res) ->
                ws.send JSON.stringify {username:msg.username, auth:res} # this is awesome! works seamlessly! async programming still sucks tho
            return
        if (msg.createUser?) 
            Person.createUser msg.username, msg.password, msg.team
            return
        if (msg.add_session?)
            name = msg.user
            if (!sessions[name]?)
                sessions[name] = []
            sessions[name].push msg.session if sessions[name].indexOf(name) == -1
            return           
        if (!msg.add_session?)
            res = rooms[names.indexOf(msg.room)].handle(msg.msgContent, msg.timestamp)
        return
        
    ws.on 'close', () ->
        res = rooms[names.indexOf(room)].handle({category:"farewell", person:name}) if name != "what is a string that will never be a name?"
