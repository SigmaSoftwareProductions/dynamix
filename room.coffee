{Person} = require "./person"
{Question} = require "./question"

class Room

    constructor: (args) ->
        @name = args.name
        @access = args.status
        @owner = args.owner
        @people = [];
        @default_distribution = {"History": 20, "Science": 20, "Literature": 15, "Art": 15, "Religion + Myth": 10, "Geography": 5, "Philosophy + Social Sci": 10, "Trash": 5 }
        @point_system = {"Power": 15, "Normal": 10, "Neg": -5}
        @distribution = @default_distribution
        @q = 0x010000000
        
    static htmlEncode = (str) ->
        str.replace /[&<>"']/g, ($0) ->
        "&" + {"&":"amp", "<":"lt", ">":"gt", '"':"quot", "'":"#39"}[$0] + ";"

    handle: (msg) ->
        for k, v of msg
            v = htmlEncode v
        if msg.category == 'greeting'
            @addPerson(msg.person)
            return {room:@name, msgContent:{category:"entry", person:msg.person, users:@people}} 
        else if msg.category == 'farewell'
            @removePerson(msg.person)
            console.log 'removing ' + msg.person
            console.log @people
            return {room:@name, msgContent:{category:"exit", person:msg.person, users:@people}}
        else if msg.category == 'name change'
            @removePerson(msg.old)
            @addPerson(msg.value)
            return {room:@name, msgContent:{category:"name change", old: msg.old, value: msg.value, users:@people}} 
        else if msg.category == 'buzz' && msg.value == 'entropy'
            return {room:@name, msgContent:{category:"buzz", value:msg.value, ver:"correct", person:msg.person}} 
        else if msg.category == 'buzz' && msg.value != 'entropy'
            return {room:@name, msgContent:{category:"buzz", value:msg.value, ver:"wrong", person:msg.person}}
        else if msg.category == 'chat'
            return {room:@name, msgContent:{category:"chat", value:msg.value, person:msg.person}}
        else if msg.category == "next"
            return {room:@name, msgContent:{category:"next", value:"shouldn't be read"}} 

    addPerson: (person) ->
        @people.push person
  	
    removePerson: (person) ->
        @people.splice @people.indexOf(person), 1 if (@people.indexOf(person) != -1)

exports.Room = Room if exports?