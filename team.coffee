{Person} = require './person'

class Team
    constructor: (people, name) ->
        @name = name
        @players = people
        @points = 0
        
exports.Team = Team if exports? 