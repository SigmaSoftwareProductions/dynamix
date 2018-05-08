{Person} = require "./person"
{Question} = require "./question"

class Room

    constructor: (args) ->
        @name = args.name
        @access = args.status
        @owner = args.owner
        @wss = args.wss # this is somewhat messy
        @people = {}
        @default_distribution = {sci: 22, history: 19, lit: 17, art: 17, philsoc: 10, relmyth: 8, geo: 4, trash: 3}
        @ruleset = {"cp": 15, "ci": 10, "cn": 10, "ii": -5, "in": 0}
        @distribution = @default_distribution
        @qid = 0x000000000 # first tossup ever, not actually science tho
        @q = 'not yet!'
        @pauseRead = false
        @speed = 600 # time between words - please set default to 160 or so, as this is for power testing
        @interval = null # will be set when setInterval is first called
        
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

    handle: (msg) ->
        console.log 'msg found as ' + msg
        if (@access == "szpecial")
            return
        res = ''
        for k, v of msg
            msg[k] = Room.htmlEncode v
        if msg.category == 'greeting'
            @addPerson(msg.person)
            res = {room:@name, msgContent:{category:"entry", person:msg.person, users:JSON.stringify(@people)}} 
        else if msg.category == 'farewell'
            @removePerson(msg.person)
            console.log 'removing ' + msg.person
            console.log @people
            res = {room:@name, msgContent:{category:"exit", person:msg.person, users:JSON.stringify(@people)}}
        else if msg.category == 'config'
            # please implement permission controls!
            @setConfig msg.config
            res = {room:@name, msgContent:msg}
        else if msg.category == 'name change'
            @removePerson(msg.old)
            @addPerson(msg.value)
            res = {room:@name, msgContent:{category:"name change", old: msg.old, value: msg.value, users:@people}} 
        else if msg.category == 'buzz'
            ver = @q.match(msg.value, @word)
            @people[msg.person] += @ruleset[ver] 
            res = {room:@name, msgContent:{category:"buzz", value:msg.value, ver:ver, person:msg.person, users:@people}}
            @pauseRead = false
        else if msg.category == 'chat'
            res = {room:@name, msgContent:{category:"chat", value:msg.value, person:msg.person}}
        else if msg.category == 'toggle'
            @pauseRead = not @pauseRead
        else if msg.category == "next"
            @word = 0
            @qid = Question.getNextQuestionId(@distribution)
            self = this
            Question.getQuestion self.qid, (question) ->
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
            res = {room:@name, next:'question', msgContent:{category:"next", speed:@speed}}
        @wss.broadcast JSON.stringify res 
        return res

    setConfig: (config) ->
        # this one is a big concern, might crash the server if something goes null
        isProperFormat = @checkConfig (config)
        if (not isProperFormat)
            @wss.broadcast JSON.stringify {room:@name,msgContent:{category:'info-error',value:'improper config format'}}
            return
        @distribution = config.distribution
        @speed = config.speed
        @ruleset = config.ruleset
        console.log JSON.stringify 
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