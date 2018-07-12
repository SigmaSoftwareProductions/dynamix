{Room} = require './room'

class TeamRoom extends Room
    constructor = (args) ->
        console.log args
        console.log args.teama
        console.log args.teamb
        @team1 = args.teama
        @team2 = args.teamb
        @expire = 7
        @name = args.name
        @access = args.access
        @owner = args.owner
        @wss = args.wss # this is somewhat messy
        @people = {}
        @default_distributions = { 
            dynamix:{sci: 20, history: 20, lit: 20, art: 20, philsoc: 10, relmyth: 5, geogen: 5, trash: 0},
            acf:{sci: 21, history: 21, lit: 20, art: 13, philsoc: 8, relmyth: 9, geogen: 4, trash: 4},
            pace:{sci: 20, history: 20, lit: 20, art: 15, philsoc: 8, relmyth: 10, geogen: 7, trash: 0}
        }
        @ruleset = {"power": 15, "int": 10, "correct": 10, "neg": -5, "wrong": 0, "num_tu":20, "bonus":false, "bounceback":false}  
        @distribution = @default_distributions.dynamix
        @q = 'not yet!'
        @pauseRead = false
        @speed = 120 # time between words - please set default to 160 or so, as this is for power testing
        @interval = null # will be set when setInterval is first called
        @current_buzzer = null
        @ongoing_buzz = false
        @multiple_buzzes = false
        @already_buzzed = []
        
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