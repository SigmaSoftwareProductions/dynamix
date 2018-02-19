crypto = require 'crypto'
mongoose = require 'mongoose'
mongoose.connect('mongodb://dynamix:dynamix@ds153577.mlab.com:53577/dynamix')
personSchema = new mongoose.Schema {
    name: String,
    password: String, # this is hashed, don't worry xD
    team: String
}, {collection:'users'}
person = mongoose.model('person', personSchema)

class Person
    constructor: (args) ->
        @username = args.username
        @password = args.password # again, hashed
        @team = args.team # this might be irrelevant, but good to leave it in
        @session = args.session
        
    # @addNewPerson: (username, password, team) ->
    
    @auth: (username, password) ->
        hashedpassword = crypto.createHash('sha512').update(password).digest('hex')
        user = Person.getPerson username
        console.log hashedpassword
        console.log user.password
        if (user.password == hashedpassword)
            return true
        else
            return false
        return false
        
    @getPerson: (username) ->
        res = ''
        person.findOne { 'username': username }, 'username password team', (err, person) ->
            res = {username:username, password:'no, sorry, this person doesnt exist', team:username} if err?
            res = {username:person.username, password:person.password, team:person.team}
        return res
        
exports.Person = Person if exports?