mongoose = require 'mongoose'
Schema = mongoose.Schema

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
        console.log x
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
        model = mongoose.model(type, schema, type) # the first is the name , the last is the collection. :|
        cursor = model.aggregate().match({category:type}).sample(1).cursor({batchSize:50})
        cursor.each(cb)
        return
            
    match: (buzz, word) ->
        return @answer

exports.Question = Question if exports?
		