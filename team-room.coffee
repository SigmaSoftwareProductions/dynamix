{Room} = require './room'

class TeamRoom extends Room
    constructor: (args) ->
        super args
        @team1 = args.teama
        @team2 = args.teamb
        
    setTeams = (team1, team2) ->
        @team1 = team1
        @team2 = team2
        
    handle: (msg, timestamp) ->
        console.log 'my team 1 is ' + JSON.stringify(@team1)
        console.log 'my team 2 is ' + JSON.stringify(@team2)
        res = ''
        for k, v of msg
            msg[k] = Room.htmlEncode v
        if (!timestamp?)
            timestamp = new Date()
        if msg.category == 'greeting'
            @addPerson(msg.person)
            teams = {}
            teams[team1.name]=team1.points
            teams[team2.name]=team2.points
            res = {timestamp:timestamp, room:@name, msgContent:{category:"entry", person:msg.person, users:teams}} 
        else if msg.category == 'farewell'
            @removePerson(msg.person)
            teams = {}
            teams[team1.name]=team1.points
            teams[team2.name]=team2.points
            res = {timestamp:timestamp, room:@name, msgContent:{category:"exit", person:msg.person, users:teams}}
        else if msg.category == 'config'
            # please implement permission controls!
            @setConfig msg.config
            res = {timestamp:timestamp, room:@name, msgContent:msg}
        else if msg.category == 'buzzinit'
            player_team = null
            if @team1.players.indexOf(msg.person) == -1
                player_team = @team2
            else
                player_team = @team1
            if not @ongoing_buzz or @buzz_time > timestamp or @already_buzzed.indexOf(msg.person) == -1
                for player in player_team.players
                    @already_buzzed.push player
                @buzz_time = timestamp
                teams = {}
                teams[@team1.name]=@team1.points
                teams[@team2.name]=@team2.points
                console.log teams
                res = {timestamp:timestamp, room:@name, msgContent:{category:"buzzinit-approved", person:msg.person, users:teams}}
                @current_buzzer = msg.person
            else 
                teams = {}
                teams[team1.name]=team1.points
                teams[team2.name]=team2.points
                console.log teams
                res = {timestamp:timestamp, room:@name, msgContent:{category:"buzzinit-denied", person:msg.person, users:teams}}
            @pauseRead= true
            @ongoing_buzz = true
        else if msg.category == 'buzz'
            if @current_buzzer != msg.person or @ongoing_read == false
                return
            player_team = null
            if @team1.players.indexOf(msg.person) == -1
                player_team = @team2
            else
                player_team = @team1
            ver = @q.match(msg.value, @word)
            player_team.points += @ruleset[ver] 
            teams = {}
            teams[team1.name]=team1.points
            teams[team2.name]=team2.points
            console.log teams
            res = {timestamp:timestamp, room:@name, msgContent:{category:"buzz", value:msg.value, ver:ver, person:msg.person, users:teams}}
            @pauseRead = false
            @ongoing_buzz = false
        else if msg.category == 'chat'
            res = {timestamp:timestamp, room:@name, msgContent:{category:"chat", value:msg.value, person:msg.person}}
        else if msg.category == 'toggle'
            @pauseRead = not @pauseRead
        else if msg.category == "next"
            res = @next()
            res.timestamp = timestamp
        @wss.broadcast JSON.stringify res 
        return res
        
exports.TeamRoom = TeamRoom if exports?        