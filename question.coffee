mongoose = require 'mongoose'
mdb = require 'mongodb'
Schema = mongoose.Schema

qschema = new Schema ({
    id: Number,
    text: String,
    mins: Array,
    answers: Array,
    prompts: Array,
    rejects: Array,
    tournament: String,
    powerloc: Number # 0 if no power, otherwise corresponds to before nth word
})

class Question
	constructor: (id) ->
        question = get_question (id)
        @id = question.id
        @text = question.text
        @mins = question.mins
        @answers = question.answers
        @prompts = question.prompts
        @rejects = question.rejects
        @tournament = question.tournament
        @powerloc = question.powerloc
		
    get_question = (id) ->
        return {
            id: id, 
            text: 'the answer to this question is entropy. also accept gibbs free energy, with only gibbs free required. prompt on gibbs. enthalpy is to be rejected. this question was at the 2020 entropy invitational. power stops before entropy is said.', 
            mins: ['entropy', 'gibbs free'],
            answers: ['entropy', 'gibbs free energy'],
            prompts: ['gibbs'],
            rejects: ['enthalpy'],
            tournament: ['2020 Entropy Invitational'],
            powerloc: 6
        }
	

exports.Question = Question if exports?
		