{Person} = require "./person"
{Question} = require "./question"

class Room

  constructor: (args) ->
    @name = args.name
    @access = args.status
    @owner = args.owner
    @state = 'end'
    @people = [];
    @default_distribution = { "History": 20, "Science": 20, "Literature": 15, "Art": 15, "Religion + Myth": 10, "Geography": 5, "Philosophy + Social Sci": 10, "Trash": 5 }
    @distribution = @default_distribution
    @q = 010000000

  handle: (msg) ->
    return "correct" if msg.category == 'buzz' && msg.msx == 'entropy'
    return "wrong" if msg.category == 'buzz' && msg.msx != 'entropy'
    return {type:'chat',content:msg.msx} if msg.category == 'chat'
    return "next" if msg.category == "next"
  """
  addPlayer: (person) ->
  	@people.push person
  	
  removePerson: (person) ->
  	@people.splice (@people.indexOf(person), 1) if @people.indexOf(person) != -1
  """

exports.Room = Room if exports?