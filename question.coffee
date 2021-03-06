mongoose = require 'mongoose'
checker = require './checker'
Schema = mongoose.Schema
mongoose.connect(process.env.DB)

schema = new Schema({
    category: String,
    subcategory: String,
    difficulty: String,
    tournament: String,
    question: String,
    source: String,
    num: Number,
    year: Number,
    answer: String,
    seen: Number,
    type: String,
    round: String
})

class Question
    constructor: (question) ->
        console.log JSON.stringify question
        @text = question.question.split ' '
        @answer = question.answer
        @tournament = question.tournament
        @category = question.category
		
    @getQuestion: (d, cb) ->
        type = 'tossups'
        category = 'error'
        x = Math.floor(Math.random()*100)
        if (x > 100-d.sci) 
            category = 'sci'
        else if (x > 100-d.sci-d.history)
            category = 'history'
        else if (x > 100-d.sci-d.history-d.lit)
            category = 'lit'
        else if (x > 100-d.sci-d.history-d.lit-d.art)
            category = 'art'
        else if (x > 100-d.sci-d.history-d.lit-d.art-d.philsoc)
            category = 'philsoc'
        else if (x > 100-d.sci-d.history-d.lit-d.art-d.philsoc-d.relmyth)
            category = 'relmyth'
        else if (x > 100-d.sci-d.history-d.lit-d.art-d.philsoc-d.relmyth-d.geogen)
            category = 'geogen'
        else if (x >= 100-d.sci-d.history-d.lit-d.art-d.philsoc-d.relmyth-d.geogen-d.trash)
            category = 'trash'
        else
            category = 'error'
        console.log category
        model = mongoose.model(type, schema, type) # the first is the name , the last is the collection. :|
        model.aggregate().match({"category":category}).sample(1).exec(cb)
            
    match: (buzz, word) ->
        checked = checker.check this, buzz, word
        if checked == 1 and word < @text.length - 1
            return "neg"
        else if checked == 1
            return "wrong"
        else if word < @text.length - 1
            return "int"
        else
            return "correct"
            

exports.Question = Question if exports?
		