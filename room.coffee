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
        @point_system = {"cp": 15, "ci": 10, "cn": 10, "ii": -5, "in": 0}
        @distribution = @default_distribution
        @qid = 0x000000000 # first tossup ever, not actually science tho
        @q = 'not yet!'
        @pauseRead = false
        @speed = 600 # time between words - please set default to 160 or so, as this is for power testing
        
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
        else if msg.category == 'name change'
            @removePerson(msg.old)
            @addPerson(msg.value)
            res = {room:@name, msgContent:{category:"name change", old: msg.old, value: msg.value, users:@people}} 
        else if msg.category == 'buzz'
            ver = @q.match(msg.value, @word)
            @people[msg.person] += @point_system[ver] 
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
            interval = null
            Question.getQuestion self.qid, (question) ->
                console.log self.qid
                console.log question
                self.q = new Question(question)
                clearInterval(interval)
                console.log JSON.stringify interval
                console.log('@speed: ' + self.speed)
                interval = setInterval () ->
                    return 'pause' if self.pauseRead 
                    return '#eof#' if self.word > self.q.text.length 
                    res = if self.word < self.q.text.length then self.q.text[self.word] else '#eof#' 
                    self.wss.broadcast JSON.stringify {room:self.name, msgContent:{category:'word', value:res+' '}}
                    self.word++
                    clearInterval(interval) if res == '#eof#'
                    return
                , self.speed
            res = {room:@name, next:'question', msgContent:{category:"next", speed:@speed}}
        @wss.broadcast JSON.stringify res 
        return res

    addPerson: (person) ->
        @people[person] = 0
        return
  	
    removePerson: (person) ->
        delete @people[person]
        return
        
exports.Room = Room if exports?