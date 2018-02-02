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
        question = @getQuestion (id)
        @id = question.id
        @text = question.text.split ' '
        @mins = question.mins
        @answers = question.answers
        @prompts = question.prompts
        @rejects = question.rejects
        @tournament = question.tournament
        @category = question.category
        @powerloc = question.powerloc
		
    @getQuestion = (id) ->
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
    
    @getNextQuestionId = (distribution) ->
        return 0x000000000
    
    match = (buzz, word) ->
        res = ""
        res = "power" if @mins.includes buzz and word < @powerloc 
        res = "power" if @answers.includes buzz and word < @powerloc
        res = "correct interrupt" if @mins.includes buzz and word < @text.length and word >= @powerloc
        res = "correct interrupt" if @answers.includes buzz and word < @text.length and word >= @powerloc
        res = "correct" if @mins.includes buzz and word == @text.length
        res = "correct" if @answers.includes buzz and word == @text.length
        res = "prompt" if @prompts.includes buzz
        res = "neg" if @rejects.includes buzz 
        res = "incorrect" if @rejects.includes buzz
        res = "neg" if res == "" && word < @text.length
        res = "incorrect" if res == "" && word == @text.length
        return res
        
        
        
	

exports.Question = Question if exports?
		