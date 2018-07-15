Match = require('./tournament').Match

round_robin = (teams) ->
    top = []
    bottom = []
    rounds = []
    i = 0
    while i < teams.length / 2
        top.push teams[i]
        i++
    i = teams.length - 1
    while i > teams.length/2 - 1
        bottom.push teams[i]
        i--
    i = 0
    while i < teams.length - 1
        rounds.push []
        j = 0
        while j < teams.length/2
            match = new Match(top[j], bottom[j])
            rounds[i].push match
            j++
        bottom.push top[top.length - 1]
        top.splice 1, 0, bottom[0]
        top.splice top.length - 1, 1
        bottom.splice 0, 1
        i++
    return rounds
    
elimination = (teams) ->
    rounds = []
    hadBye = {}
    hadBye[team] = false for team in teams
    winners = []
    losers = []
    if teams.length % 4 == 1
        for team in teams
            if team != teams[teams.length - 1] 
                winners.push team 
        losers.push teams[teams.length - 1]
        init = new Match(teams[teams.length - 2], teams[teams.length - 1])
        init.useLaterRound = true
        rounds.push [init]
        round = 1
    else
        winners.push team for team in teams
        round = 0
    while winners.length > 1 || losers.length > 1
        rounds[round] = []
        losers = losers.sort()
        winners = winners.sort()
        # losers
        tiny = losers.length <= 1
        if losers.length % 2 == 1
            bye = losers[0]
            while hadBye[bye]
                bye = losers[losers.indexOf(bye)+1]
            hadBye[bye] = true
            losers.splice losers.indexOf(bye), 1
        if not tiny
            i = 0
            while i < losers.length/2
                rounds[round].push new Match(losers[i], losers[losers.length-i-1])
                i++
            while i < losers.length
                losers.splice i, 1
        losers.push bye if bye?
        bye = null
        # ez
        # winners
        tiny = winners.length <= 1
        if winners.length % 2 == 1
            bye = winners[0]
            while hadBye[bye]
                bye = winners[winners.indexOf(bye) + 1]
            winners.splice winners.indexOf(bye), 1 
        if not tiny
            i = 0
            while i < winners.length/2
                rounds[round].push new Match(winners[i], winners[winners.length-i-1])
                i++
            while i < winners.length
                hadBye[winners[i]] = false
                losers.unshift winners[i]
                winners.splice i, 1
        winners.push bye if bye?
        bye = null
        # ez
        round++
    final = new Match(winners[0], losers[0])
    final.disadvantaged = true
    rounds.push [final]
    return rounds

factor = (a) ->
    factors = []
    i = 1
    while i <= Math.sqrt a
        if a % i == 0
            factors.push i
        i++
    return factors

bracket = (teams) -> # teams should be the seeds
    field_size = teams.length
    if field_size <= 2
        return round_robin teams 
    matches = []
    factors = factor field_size
    c = factors[0]
    for num in factors
        if field_size/num - num < field_size/c - c
            c = num
    if (field_size/c - c) > 4
        teams.push 65535 # 65535 = bye
        return bracket (teams)
    numBrackets = Math.min c, field_size/c
    bracketSize = Math.max c, field_size/c
    brackets = []
    i = 0
    while i < numBrackets
        brackets.push []
        i++
    i = 0
    while i < bracketSize
        if i % 2 == 0
            j = 0
            while j < numBrackets
                brackets[j].push teams[i*numBrackets + j]
                j++
        else
            j = 0
            while j < numBrackets
                brackets[j].push teams[(i+1)*numBrackets - j - 1]
                j++
        i++
    # for when mario is done
    bracketMatches = []
    for group in brackets
        bracketMatches.push round_robin group 
    i = 0
    while i < bracketMatches[0].length
        matches.push []
        j = 0
        while j < numBrackets
            matches[i] = matches[i].concat bracketMatches[j][i] if bracketMatches[j]?
            j++
        i++
    # continue to playoffs
    amtInPlayoffs = numBrackets*Math.floor(bracketSize/3)
    teamsInElim = []
    i = 0
    while i < amtInPlayoffs
        teamsInElim.push teams[i]
        i++
    bracketMatches = []
    bracketMatches.push elimination teamsInElim
    brackets = []
    j = 0
    i = amtInPlayoffs
    while j < (teams.length - amtInPlayoffs)/numBrackets
        brackets[j] = []
        k = 0
        while k < numBrackets
            brackets[j].push teams[i]
            i++
            k++
        j++ 
    for group in brackets
        bracketMatches.push round_robin(group)
    i = matches.length
    initRounds = i
    while i < bracketMatches[0].length + initRounds
        matches.push []
        j = 0
        while j < bracketMatches.length
            matches[i] = matches[i].concat bracketMatches[j][i - initRounds] if bracketMatches[j][i - initRounds]?
            j++
        i++
    # rr brackets, select top and elim
    # rr the rest according to record - single grab (all 4-3, 3-4, 2-5, 1-6, 0-7 in one each)
    return matches

exports.bracket = bracket if exports?
