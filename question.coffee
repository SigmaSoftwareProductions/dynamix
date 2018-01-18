mongoose = require 'mongoose'
mdb = require 'mongodb'
Schema = mongoose.Schema

qschema = new Schema ({
	id: Number,
	text: String,
	answers: Array,
	prompts: Array,
	tournament: String,
	powerloc: Number # 0 if no power, otherwise corresponds to before nth word
})

class Question
	constructor: (question) ->
		@text = question.text
		@answers = question.answers
		@prompts = question.prompts
		@tournament = question.tournament
		@powerloc = question.powerloc
		
get_question: (id) ->
	url = 'mongodb://dynamix:dynamix@ds153577.mlab.com:53577/dynamix'
	mdb.MongoClient.connect url, (err, db) -> 
		throw err if err?
		db.createCollection 'bonuses', (err, res) ->
			throw err if err?
			console.log 'created!'
			db.close
	

exports.Question = Question if exports?
exports.get_question = get_question if exports?
		