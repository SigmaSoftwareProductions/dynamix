console.log 'online'

{Room} = require './room'
wsx = require 'ws'
mongodb = require 'mongodb'

console.log JSON.stringify(process.argv[2])

wss = new wsx.SocketServer(process.argv[2])
console.log "server: " + wss

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
  ws.on 'message', (msg) ->
    msg = JSON.parse msg
    res = rooms[names.indexOf(msg.room)].handle(msg.msgContent)
    if (res == "correct")
      wss.broadcast "correct by " + msg.person
    else if (res == "wrong")
      wss.broadcast "neg by " + msg.person
    else if (res.substring(0, 4) == "chat")
      wss.broadcast "chat by " + msg.person + " saying " + res.substring(5)
