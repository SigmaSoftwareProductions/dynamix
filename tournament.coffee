mongoose = require 'mongoose'
{Room} = require './room'
mongoose.connect(process.env.DB)

tournamentSchema = new mongoose.Schema {
    name: String,
    date: Date,
    difficulty: Number,
    set: String, # either "dynamix chooses" or the mint archive
    rounds: Number, # 0 for as many as needed, otherwise the ceiling
    fieldcap: Number,
    field: Array,
    full: Boolean,
    # the following are null until the tournament is full
    matches: Array, # ["swiss",{"rr":{numpools, poolsizes},{"elim":{degree,[ppl in each bracket]}} put stages in order
    rooms: Array, # ideally [room] for when we make roomSchema
    completed: Boolean
}

class Match
    constructor: (a, b) ->
        @winner = Math.min(a,b)
        @loser = Math.max(a,b)
        @disadvantaged = false
        @useLaterRound = false
        # the beauties of card systems
    toString: () ->
        return @winner + 'v' + @loser

class Tournament
    constructor: (tournament) ->
        @name = tournament.name
        @startdate = tournament.startdate
        @enddate = tournament.enddate
        @difficulty = tournament.number
        @set = tournament.set
        @rounds = tournament.rounds
        @fieldcap = tournament.fieldcap
        @field = tournament.field
        @full = tournament.full
        @matches = tournament.matches
        @rooms = tournament.rooms
        @completed = tournament.completed
    
    @createTournament: (args) ->
        # args contains name, date, difficulty, set (either mint archive name or just dynamix), fieldcap, rounds
        # validate all these before creating tourney
        @name = args.name
        @startdate = args.startdate
        @enddate = args.enddate
        @difficulty = args.difficulty
        @set = args.set
        @rounds = tournament.rounds
        @fieldcap = args.fieldcap
        @field = []
        @full = false
        @matches = null
        @rooms = null
        @completed = false
        
    @getTournament: (name, cb) -> # cb takes err, tournament
        tournamentModel = mongoose.model('tournament', tournamentSchema, 'tournaments') # collection = tournaments
        tournamentModel.findOne({name:name}, cb) # if tournament doesn't exist returns null
        
    finalize: () -> # either when full is true or one day before start.
        rounds_left = @rounds
        @matches = []
        if field.length >= 64 # plox just for pows of 2
            # swiss, teams with w-l>1 progress, w-l=1 into loser's bracket in odd pow (ie 128)
            # double elimination + advantaged final
        else if field.length >= 16
            # rr nicely + crossover + single final
        else
            # rr
            
    rr: (teams) ->
        topGroup = []
        bottomGroup = []
        # finish shit later
        
exports.Tournament = Tournament if exports?
exports.Match = Match if exports?