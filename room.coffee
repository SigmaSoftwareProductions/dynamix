# I am become God, creator of worlds...?

class Room

  constructor: (args) ->
    @name = args.name
    @access = args.status
    @owner = args.owner
    @state = 'end'
    @default_distribution = { "History": 20, "Science": 20, "Literature": 15, "Art": 15, "Religion + Myth": 10, "Geography": 5, "Philosophy": 5, "Social Sci": 5, "Trash": 5 }
    @distribution = @default_distribution
    @q = 'The von Neumann form of this concept is given in terms of the trace of a density matrix times its log. The Sackur-Tetrode equation gives this quantity extensively, avoiding the Gibbs paradox. Defined as the Boltzmann constant times natural log of the number of microstates, it is multiplied by temperature in the expression for Gibbs free energy. Maxwell\'s hypothetical demon purports to lowers this quantity. Symbolized by the letter S, its tendency to increase is dictated by the second law of thermodynamics. For 10 points, name this quantity, a measure of a system\'s disorder.'

  handle: (msg) ->
    return "correct" if msg.category == 'buzz' && msg.msx == 'entropy'
    return "wrong" if msg.category == 'buzz' && msg.msx != 'entropy'
    return ("chat " + msg.msx) if msg.category == 'chat'
    return "next" if msg.category == "next"

exports.Room = Room if exports?