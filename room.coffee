{Person} = require "./person"
{Question} = require "./question"

class Room

    constructor: (args) ->
        @name = args.name
        @access = args.status
        @owner = args.owner
        @wss = args.wss # this is somewhat messy
        @people = [];
        @default_distribution = {"Science": 20, "History": 20, "Literature": 15, "Art": 15, "Religion + Myth": 10, "Geography": 5, "Philosophy + Social Sci": 10, "Trash": 5 }
        @point_system = {"Power": 15, "Normal": 10, "Neg": -5}
        @distribution = @default_distribution
        @qid = 0x000000000 # first tossup ever, not actually science tho
        @q = new Question (@qid)
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
        res = ''
        for k, v of msg
            v = Room.htmlEncode v
        if msg.category == 'greeting'
            @addPerson(msg.person)
            res = {room:@name, msgContent:{category:"entry", person:msg.person, users:@people}} 
        else if msg.category == 'farewell'
            @removePerson(msg.person)
            console.log 'removing ' + msg.person
            console.log @people
            res = {room:@name, msgContent:{category:"exit", person:msg.person, users:@people}}
        else if msg.category == 'name change'
            @removePerson(msg.old)
            @addPerson(msg.value)
            res = {room:@name, msgContent:{category:"name change", old: msg.old, value: msg.value, users:@people}} 
        else if msg.category == 'buzz'
            res = {room:@name, msgContent:{category:"buzz", value:msg.value, ver:@q.match(msg.value, @word), person:msg.person}} 
        else if msg.category == 'chat'
            res = {room:@name, msgContent:{category:"chat", value:msg.value, person:msg.person}}
        else if msg.category == "next"
            @word = 0
            @qid = Question.getNextQuestionId()
            @q = new Question (@qid)
            console.log 'q is ' + @q
            self = this
            clearInterval
            setInterval () ->
                return '#eof#' if self.word > self.q.text.length 
                res = if self.word < self.q.text.length then self.q.text[self.word] else '#eof#' 
                self.wss.broadcast JSON.stringify {room:self.name, msgContent:{category:'word', value:res+' '}}
                self.word++
                self.clearInterval if res == '#eof#'
            , @speed
            res = {room:@name, next:'question', msgContent:{category:"next", speed:@speed}}
        @wss.broadcast JSON.stringify res 
        return res

    addPerson: (person) ->
        @people.push person
  	
    removePerson: (person) ->
        @people.splice @people.indexOf(person), 1 if (@people.indexOf(person) != -1)
        
exports.Room = Room if exports?