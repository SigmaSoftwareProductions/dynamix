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
        category = 'tossups'
        themodel = mongoose.model(category, qschema, category)
        cursor = themodel.findOne({id:id}).cursor()
        q = null
        cursor.on 'data', (question) ->
            q = question
            
        cursor.on 'close', () ->
            cb(q)
    
    @getNextQuestionId: (d) -> # d for distribution
        x = Math.floor(Math.random()*100)
        console.log x
        console.log "######"+typeof d.hist"######"
        console.log 
        if (x > 100-d.sci) 
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
        console.log 'generated id of ' + res
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
		