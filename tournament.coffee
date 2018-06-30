mongoose = require 'mongoose'
{Room} = require './room'
mongoose.connect(process.env.DB)

tournamentSchema = new mongoose.Schema {
    name: String,
    date: Date,
    difficulty: Number,
    set: String, # either "dynamix chooses" or the mint archive
    fieldcap: Number,
    field: Array,
    full: Boolean,
    # the following are null until the tournament is full
    stageformat: Array, # [{"swiss":numrounds},{"rr":numrounds},{"elim":[degree,numrounds]} put stages in order
    rooms: Array, # ideally [room] for when we make roomSchema
    completed: Boolean
}

class Tournament
    constructor: (tournament) ->
        @name = tournament.name
        @date = tournament.date
        @difficulty = tournament.number
        @set = tournament.set
        @fieldcap = tournament.fieldcap
        @field = tournament.field
        @full = tournament.full
        @stageformat = tournament.stageformat
        @rooms = tournament.rooms
        @completed = tournament.completed
    
    @createTournament: (args) ->
        # args contains name, date, difficulty, set (either mint archive name or just dynamix), fieldcap
        # validate all these before creating tourney
        @name = args.name
        @date = args.date
        @difficulty = args.difficulty
        @set = args.set
        @fieldcap = args.fieldcap
        @field = []
        @full = false
        @stageformat = null
        @rooms = null
        @completed = false
        
    @getTournament: (name, cb) -> # cb takes err, tournament
        tournamentModel = mongoose.model('tournament', tournamentSchema, 'tournaments') # collection = tournaments
        tournamentModel.findOne({name:name}, cb) # hopefully if tournament doesn't exist returns null
        
    