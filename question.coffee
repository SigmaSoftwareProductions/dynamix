mongoose = require 'mongoose'
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
		
    @getQuestion: (id, cb) ->
        category = 'idk'
        if (id < 0x010000000)
            category = 'tossups.sci'
        else if (id < 0x020000000)
            category = 'tossups.history'
        else if (id < 0x030000000)
            category = 'tossups.lit'
        else if (id < 0x040000000)
            category = 'tossups.art'
        else if (id < 0x050000000)
            category = 'tossups.philsoc'
        else if (id < 0x060000000)
            category = 'tossups.relmyth'
        else if (id < 0x070000000)
            category = 'tossups.geo'
        else if (id < 0x080000000)
            category = 'tossups.trash'
        else if (id < 0x110000000)
            category = 'bonus.sci'
        else if (id < 0x120000000)
            category = 'bonus.history'
        else if (id < 0x130000000)
            category = 'bonus.lit'
        else if (id < 0x140000000)
            category = 'bonus.art'
        else if (id < 0x150000000)
            category = 'bonus.philsoc'
        else if (id < 0x160000000)
            category = 'bonus.relmyth'
        else if (id < 0x170000000)
            category = 'bonus.geo'
        else if (id < 0x180000000)
            category = 'bonus.trash'
            
        themodel = mongoose.model(category, qschema, category)
        cursor = themodel.findOne({id:id}).cursor()
        q = null
        cursor.on 'data', (question) ->
            q = question
            
        cursor.on 'close', () ->
            cb(q)
    
    @getNextQuestionId: (d) -> # d for distribution
        res = 0
        x = Math.floor(Math.random()*100)
        if (x >= 100-d.sci) 
            res = 0x000000000
        else if (x > 100-d.sci-d.hist)
            res = 0x010000000
        else if (x > 100-d.sci-d.hist-d.lit)
            res = 0x020000000
        else if (x > 100-d.sci-d.hist-d.lit-d.art)
            res = 0x030000000
        else if (x > 100-d.sci-d.hist-d.lit-d.art-d.philsoc)
            res = 0x040000000
        else if (x > 100-d.sci-d.hist-d.lit-d.art-d.philsoc-d.relmyth)
            res = 0x050000000
        else if (x > 100-d.sci-d.hist-d.lit-d.art-d.philsoc-d.relmyth-d.geo)
            res = 0x060000000
        else if (x > 100-d.sci-d.hist-d.lit-d.art-d.philsoc-d.relmyth-d.geo-d.trash)
            res = 0x070000000
        return res
            
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
		