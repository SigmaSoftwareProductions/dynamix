{Question} = require './question'

check = (q, ans, word) ->
    # 0 -> right 1-> wrong 2 -> prompt
    if Math.random >= 0.5
        return 0
    return 1
    
exports.check = check if exports?