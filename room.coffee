{Person} = require "./person"
{Question} = require "./question"

class Room

    constructor: (args) ->
        @name = args.name
        @access = args.status
        @owner = args.owner
        @people = [];
        @default_distribution = { "History": 20, "Science": 20, "Literature": 15, "Art": 15, "Religion + Myth": 10, "Geography": 5, "Philosophy + Social Sci": 10, "Trash": 5 }
        @distribution = @default_distribution
        @q = 0x010000000

    handle: (msg) ->   
        return {room:@name, msgContent:{category:"buzz", value:"correct", person:msg.person}} if msg.category == 'buzz' && msg.value == 'entropy'
        return {room:@name, msgContent:{category:"buzz", value:"wrong", person:msg.person}} else if msg.category == 'buzz' && msg.value != 'entropy'
        return {room:@name, msgContent:{category:"chat", value:msg.value, person:msg.person}} else if msg.category == 'chat'
        return {room:@name, msgContent:{category:"next", value:"shouldn't be read"}} else if msg.category == "next"
  	
    """
        addPlayer: (person) ->
            @people.push person
  	
        removePerson: (person) ->
            @people.splice (@people.indexOf(person), 1) if @people.indexOf(person) != -1
    """

exports.Room = Room if exports?