mongoose = require 'mongoose'
mdb = require 'mongodb'
Schema = mongoose.Schema

qschema = new Schema ({
    id: Number,
    text: Array,
    mins: Array,
    answers: Array,
    prompts: Array,
    rejects: Array,
    tournament: String,
    powerloc: Number # 0 if no power, otherwise corresponds to before nth word
})

class Question
    constructor: (id) ->
        question = Question.getQuestion (id)
        @id = question.id
        @text = question.text.split ' '
        @mins = question.mins
        @answers = question.answers
        @prompts = question.prompts
        @rejects = question.rejects
        @tournament = question.tournament
        @category = question.category
        @powerloc = question.powerloc
		
    @getQuestion: (id) ->
        return {
            id: id, 
            text: 'the answer to this question is entropy. also accept gibbs free energy, with only gibbs free required. prompt on gibbs. enthalpy is to be rejected. this question was at the 2020 entropy invitational. power stops before entropy is said.', 
            mins: ['entropy', 'gibbs free'],
            answers: ['entropy', 'gibbs free energy'],
            prompts: ['gibbs'],
            rejects: ['enthalpy'],
            tournament: ['2020 Entropy Invitational'],
            category: 'Starter Question'
            powerloc: 6
        }
    
    @getNextQuestionId: (distribution) ->
        return 0x000000000
    
    match: (buzz, word) ->
        return "cp" if @mins.includes buzz and word < @powerloc 
        return "cp" if @answers.includes buzz and word < @powerloc
        return "ci" if @mins.includes buzz and word < @text.length and word >= @powerloc
        return "ci" if @answers.includes buzz and word < @text.length and word >= @powerloc
        return "cn" if @mins.includes buzz
        return "cn" if @answers.includes buzz
        return "p" if @prompts.includes buzz
        return "ii" if @rejects.includes buzz and word < @text.length 
        return "in" if @rejects.includes buzz
        return "ii" if !res? && word < @text.length
        return "in" if !res? && word == @text.length

exports.Question = Question if exports?
		