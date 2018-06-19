$(document).ready ->
    room = window.location.pathname.substring(1)
    messages = []
    try
        session = JSON.parse(document.cookie).session
        name = JSON.parse(document.cookie).username
        $('#login').text(name)
        login = true
    catch error
        login = false
        name = 'guest'
        session = 0
    finally
        if name == ''
            name = 'comrade popov'
            
    speed = 120 # time distance between two words
    ws = new WebSocket('wss://dynamix-coordinator.herokuapp.com')
    
    sendbuzz = () ->
        ws.send JSON.stringify({
            timestamp: new Date(),
            room: room
            msgContent: {
                person: name
                category: 'buzz'
                value: document.getElementById('buzzbox').value
                }
            })
        $('#buzzbox').val('')
        $('#buzzbox').hide()
        return
            
    sendchat = () ->
        ws.send JSON.stringify({
            timestamp: new Date(),
            room: room,
            msgContent: {
                category: 'chat',
                value: document.getElementById('chatbox').value,
                person: name
            }
        })
        $('#chatbox').val('')
        $('#chatbox').hide()
        return
            
    openchat = () ->
        $('#chatbox').show()
        setTimeout (->
            $('#chatbox').focus()
        ), 30
        return
            
    openbuzz = () ->
        $('#buzzbox').show()
        setTimeout (->
            $('#buzzbox').focus()
        ), 30
        ws.send JSON.stringify({
            timestamp: new Date()
            room: room
            msgContent: {
                person:name
                category:'buzzinit'
            }
        })
        return
    
    next = () ->
        ws.send JSON.stringify({
            timestamp: new Date()
            room: room
            msgContent: {
                person: name
                category: 'next'
                value: 'this is for sure not the correct answer'
            }
        })
        return

    toggle = () ->
        ws.send JSON.stringify ({
            timestamp: new Date(),
            room:room
            msgContent:{
                category:'toggle'
            }
        })
        return
        
    sendconfig = () ->
        config_obj = {
            # spaghetti code lmao
            # checks for proper format are performed on server side,
            # so don't get smart.
            room:room,
            msgContent:{
                category:'config',
                config:{
                    speed:document.getElementById('speed').value,
                    ruleset:{
                        cp:document.getElementById('cp').value,
                        ci:document.getElementById('ci').value,
                        cn:document.getElementById('cn').value,
                        ii:document.getElementById('ii').value,
                        in:document.getElementById('in').value
                    },
                    distribution:{
                        sci:document.getElementById('dsci').value,
                        hist:document.getElementById('dhist').value,
                        lit:document.getElementById('dlit').value,
                        art:document.getElementById('dart').value,
                        relmyth:document.getElementById('drelmyth').value,
                        philsoc:document.getElementById('dphilsoc').value,
                        geo:document.getElementById('dgeo').value,
                        trash:document.getElementById('dtrash').value
                    }
                }
            }
        }
        console.log JSON.stringify config_obj
        ws.send (JSON.stringify (config_obj))
        return
        
    render = (msg, pos) ->
        if messages.length == 0
            $('#message-container').prepend("<div id=\"msg-0\""JSON.stringify(msg)"</div>")
            return
        else if pos == messages.length - 1
            $('#message-container').prepend("<div id=\"msg-#{ pos }\""JSON.stringify(msg)"</div>")
            return
        for id in [pos, messages.length -1]
            $("#msg-#{ id }").prop('id', "msg-#{ id + 1 }")
        $("#msg-#{ pos + 1 }").before("<div id=\"msg-#{ pos }\""JSON.stringify(msg)"</div>")
        return
    
    renderQuestionMsg = (msg) ->
        if msg.category == 'word'
            $('#question').append msg.value
        else
            $('#question').val('')
        
    ws.onmessage = (event) ->
        console.log JSON.stringify event.data
        return if event.data == 'pong'
        z = JSON.parse(event.data)
        return if z.room != room
        if z.msgContent.category == 'word' or z.msgContent.category == 'next'
            renderQuestionMsg z.msgContent
            return
        pos = 0 # the position to add the msg at
        if messages.length == 0
            messages.push z
            pos = 0
        else if z.timestamp <= messages[0].timestamp
            messages.shift z
            pos = 0
        else if z.timestamp >= messages[messages.length -1].timestamp
            pos = (messages.push z) - 1
        else
            for msgid in [1, messages.length - 2]
                if (messages[msgid].timestamp <= z.timestamp and messages[msgid+1].timestamp >= z.timestamp)
                    messages.splice msgid, 0, z # goddamn js arrays are stupid
                    pos = msgid
        render z.msgContent, pos
        return

    ws.onopen = (event) ->
        ws.send(JSON.stringify({greeting:'hello world!', session: session, room:room, msgContent:{person:name, category:'greeting'}}))
        pinger = setInterval ping, 40000
        return
        
    ws.onclose = (event) ->
        $('#question').after '<div class="container-fluid">you have been disconnected from the server</div>'
        return
        
    ping = () ->
        ws.send('ping')   
        return 
        
    $('#chat-clicky').on 'click', -> openchat()
    $('#next-clicky').on 'click', -> next()
    $('#toggle-clicky').on 'click', -> toggle()
    $('#buzz-clicky').on 'click', -> openbuzz()
    $('#signin').on 'click', -> window.location.href = 'signin'

    $(document).keypress ->
        
        if name == ''
            name = 'comrade popov'

        if event.which == 13
            if document.activeElement.id == 'chatbox'
                sendchat()
      
            else if document.activeElement.id == 'buzzbox'
                sendbuzz()
      
            else
                openchat()
                
            $('body').focus()
    
        else if document.activeElement.tagName != 'BODY'
            # do nothing! yay
    
        else if event.which == 32
            openbuzz()
    
        else if event.which == 110
            next()
            
        else if event.which == 47
            openchat()
            
        else if event.which == 99
            sendconfig()
            
        return