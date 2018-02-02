{Person} = require "./person"
{Question} = require "./question"

class Room

    constructor: (args) ->
        @name = args.name
        @access = args.status
        @owner = args.owner
        @people = [];
        @default_distribution = {"Science": 20, "History": 20, "Literature": 15, "Art": 15, "Religion + Myth": 10, "Geography": 5, "Philosophy + Social Sci": 10, "Trash": 5 }
        @point_system = {"Power": 15, "Normal": 10, "Neg": -5}
        @distribution = @default_distribution
        @qid = 0x000000000 # first tossup ever, not actually science tho
        @q = new Question (@qid)
        @word = 0
        
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
        for k, v of msg
            v = Room.htmlEncode v
        if msg.category == 'greeting'
            @addPerson(msg.person)
            return {room:@name, msgContent:{category:"entry", person:msg.person, users:@people}} 
        else if msg.category == 'word'
            @word++
            return {room:@name, msgContent:{category:'word', value:@q.text[word]}} if word != @q.text.length
            return {room:@name, msgContent:{category:'word', value:'%#eof#%'}} 
        else if msg.category == 'farewell'
            @removePerson(msg.person)
            console.log 'removing ' + msg.person
            console.log @people
            return {room:@name, msgContent:{category:"exit", person:msg.person, users:@people}}
        else if msg.category == 'name change'
            @removePerson(msg.old)
            @addPerson(msg.value)
            return {room:@name, msgContent:{category:"name change", old: msg.old, value: msg.value, users:@people}} 
        else if msg.category == 'buzz'
            return {room:@name, msgContent:{category:"buzz", value:msg.value, ver:msg.match, person:msg.person}} 
        else if msg.category == 'chat'
            return {room:@name, msgContent:{category:"chat", value:msg.value, person:msg.person}}
        else if msg.category == "next"
            @word = 0
            @qid = Question.getNextQuestionId()
            @q = new Question (@qid)
            return {room:@name, msgContent:{category:"next", value:"shouldn't be read"}} 

    addPerson: (person) ->
        @people.push person
  	
    removePerson: (person) ->
        @people.splice @people.indexOf(person), 1 if (@people.indexOf(person) != -1)

exports.Room = Room if exports?