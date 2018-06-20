mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema ({
    text: String,
    mins: Array,
    answers: Array,
    prompts: Array,
    rejects: Array,
    tournament: String,
    powerloc: Number # 0 if no power, otherwise corresponds to before nth word
})

class Question
    constructor: (question) ->
        @id = question.id
        @text = question.text.split ' '
        @mins = question.mins
        @answers = question.answers
        @prompts = question.prompts
        @rejects = question.rejects
        @tournament = question.tournament
        @category = question.category
        @powerloc = question.powerloc
		
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
        model.aggregate.match({category:type}).sample(1).exec(cb)
    
            
    match: (buzz, word) ->
        console.log 'matching "' + buzz + '" at word number ' + word
        return "cp" if @mins.includes buzz and word < @powerloc 
        return "cp" if @answers.includes buzz and word < @powerloc
        return "ci" if @mins.includes buzz and word < @text.length and word >= @powerloc
        return "ci" if @answers.includes buzz and word < @text.length and word >= @powerloc
        return "cn" if @mins.includes buzz
        return "cn" if @answers.includes buzz
        return "p" if @prompts.includes buzz
        return "ii" if @rejects.includes buzz and word < @text.length 
        return "in" if @rejects.includes buzz
        return "ii" if word < @text.length
        return "in" if word == @text.length

exports.Question = Question if exports?
		