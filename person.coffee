crypto = require 'crypto'
mongoose = require 'mongoose'
mongoose.connect('mongodb://dynamix:dynamix@ds153577.mlab.com:53577/dynamix')
personSchema = new mongoose.Schema {
    id: Number
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
        
    @createUser: (username, password, team) ->
        person.count {}, (err, count) ->
            userInfo = {
                        id:count,
                        name:username, 
                        password:crypto.createHash('sha512').update(password).digest('hex'),
                        team:team
                       }
            userInstance = new person(userInfo)
            userInstance.save (err) ->
                throw err if err
                return
            return   
        return
    
    @auth: (username, password, cb) ->
        hashedpassword = crypto.createHash('sha512').update(password).digest('hex')
        console.log username
        console.log password
        console.log hashedpassword
        res = false
        cursor = person.findOne({ 'username': username }).cursor()
        cursor.on 'data', (user) ->
            console.log user.password
            console.log hashedpassword
            if user.password == hashedpassword
                res = true
        cursor.on 'close', () ->
            cb (res)
        
exports.Person = Person if exports?