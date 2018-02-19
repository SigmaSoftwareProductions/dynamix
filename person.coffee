crypto = require 'crypto'
mongoose = require 'mongoose'
mongoose.connect('mongodb://dynamix:dynamix@ds153577.mlab.com:53577/dynamix')
personSchema = new mongoose.Schema {
    name: String,
    password: String, # this is hashed, don't worry xD
    team: String
}, {collection:'users'}
person = mongoose.model('person', personSchema)

do_nothing = () ->
    return

class Person
    constructor: (args) ->
        @username = args.username
        @password = args.password # again, hashed
        @team = args.team # this might be irrelevant, but good to leave it in
        @session = args.session
        
    # @addNewPerson: (username, password, team) ->
    
    @auth: (username, password, cb) ->
        hashedpassword = crypto.createHash('sha512').update(password).digest('hex')
        res = false
        cursor = person.findOne({ 'username': username }).cursor()
        cursor.on 'data', (user) ->
            if user.password == hashedpassword
                res = true
        cursor.on 'close', () ->
            cb (res)
        
exports.Person = Person if exports?