{Person} = require "./person"
{Question} = require "./question"

class Room

    constructor: (args) ->
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
        @ruleset = {"power": 15, "int": 10, "correct": 10, "neg": -5, "wrong": 0, "num_tu":0, "bonus":false, "bounceback":false}  
        @distribution = @default_distributions.dynamix
        @q = 'not yet!'
        @pauseRead = false
        @speed = 140 # time between words - please set default to 160 or so, as this is for power testing
        @interval = null # will be set when setInterval is first called
        @current_buzzer = null
        @ongoing_buzz = false
        ###
            about access permissions:
            kinda like a chmod code, but in hexadec
            first digit - owner (default the first dude there)
            second digit - invites (people specifically invited to the room)
            third digit - everyone
            digits:
                1 for being able to view the room
                2 for being able to play
                4 for regulating invited users
                8 for changing room settings (distribution, ruleset, etc) 
            only owner can change room permissions.
        ###
        
    @htmlEncode = (text) -> # beware, messy regexes ahead
        rx = [
            [/&/g, '&amp;']
            [/</g, '&lt;']
            [new RegExp("'", 'g'), '"']
            [new RegExp('"', 'g'), '&quot;']
        ]
        for r in rx
            text=text.replace r[0], r[1]
        return text

    handle: (msg, timestamp) ->
        res = ''
        for k, v of msg
            msg[k] = Room.htmlEncode v
        if (!timestamp?)
            timestamp = new Date()
        if msg.category == 'greeting'
            @addPerson(msg.person)
            res = {timestamp:timestamp, room:@name, msgContent:{category:"entry", person:msg.person, users:JSON.stringify(@people)}} 
        else if msg.category == 'farewell'
            @removePerson(msg.person)
            res = {timestamp:timestamp, room:@name, msgContent:{category:"exit", person:msg.person, users:JSON.stringify(@people)}}
        else if msg.category == 'config'
            # please implement permission controls!
            @setConfig msg.config
            res = {timestamp:timestamp, room:@name, msgContent:msg}
        else if msg.category == 'buzzinit'
            res = {timestamp:timestamp, room:@name, msgContent:{category:"buzzinit", ver:ver, person:msg.person, users:@people}}
            @current_buzzer = msg.person
            @pauseRead= true
            @ongoing_buzz = true
        else if msg.category == 'buzz'
            if @current_buzzer != msg.person or @ongoing_read == false
                return
            ver = @q.match(msg.value, @word)
            # @people[msg.person] += @ruleset[ver] 
            res = {timestamp:timestamp, room:@name, msgContent:{category:"buzz", value:msg.value, ver:ver, person:msg.person, users:@people}}
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
        
    next: () ->
        @word = 0
        self = this
        Question.getQuestion @distribution, (err, questions) ->
            question = questions[0]
            console.log 'err ' + err
            console.log 'q ' + JSON.stringify question
            self.q = new Question(question)
            clearInterval(self.interval)
            self.interval = setInterval () ->
                return 'pause' if self.pauseRead 
                return '#eof#' if self.word > self.q.text.length 
                res = if self.word < self.q.text.length then self.q.text[self.word] else '#eof#' 
                self.wss.broadcast JSON.stringify {room:self.name, msgContent:{category:'word', value:res+' '}}
                self.word++
                clearInterval(self.interval) if res == '#eof#'
                return
            , self.speed
        return {room:@name, next:'question', msgContent:{category:"next", speed:@speed}}
        
    setConfig: (config) ->
        # this one is a big concern, might crash the server if something goes null
        isProperFormat = @checkConfig (config)
        if (not isProperFormat)
            @wss.broadcast JSON.stringify {room:@name,msgContent:{category:'info-error',value:'improper config format'}}
            return
        @distribution = config.distribution
        @speed = config.speed
        @ruleset = config.ruleset
        @wss.broadcast JSON.stringify {room:@name,msgContent:{category:'config',config:config}}
        return
        
    checkConfig: (config) ->
        # this isnt the method you want to read
        if (not (config.speed? and config.speed >= 0))
            return false
        if (not config.ruleset?)
            return false
        if (not (config.ruleset.cp? and config.ruleset.cp >= 0))
            return false
        if (not (config.ruleset.ci? and config.ruleset.ci >= 0))
            return false
        if (not (config.ruleset.cn? and config.ruleset.cn >= 0))
            return false
        if (not (config.ruleset.ii?))
            return false
        if (not (config.ruleset.in?))
            return false
        if (not (config.distrubution.sci? and config.distribution.sci >= 0))
            return false
        if (not (config.distrubution.hist? and config.distribution.hist >= 0))
            return false
        if (not (config.distrubution.lit? and config.distribution.lit >= 0))
            return false
        if (not (config.distrubution.art? and config.distribution.art >= 0))
            return false
        if (not (config.distrubution.relmyth? and config.distribution.relmyth >= 0))
            return false
        if (not (config.distrubution.philsoc? and config.distribution.philsoc >= 0))
            return false
        if (not (config.distrubution.geo? and config.distribution.geo >= 0))
            return false
        if (not (config.distrubution.trash? and config.distribution.trash >= 0))
            return false
        # u made it pal
        return true

    addPerson: (person) ->
        @people[person] = 0
        return
  	
    removePerson: (person) ->
        delete @people[person]
        return
        
exports.Room = Room if exports?