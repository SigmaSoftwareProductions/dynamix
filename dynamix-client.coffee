$(document).ready ->
    room = window.location.pathname.substring(1)
    messages = []
    $('#buzzbox').hide()
    $('#chatbox').hide()
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
            
    speed = 120
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
            window.scrollTo 0, 0
        ), 30
        return
            
    openbuzz = () ->
        $('#buzzbox').show()
        setTimeout (->
            $('#buzzbox').focus()
            window.scrollTo 0, 0
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
        
    renderUsers = (users) ->
        $('#users').empty()
        rank = 1
        for max of users
            for user of users
                if users.user > users.max
                    max = user
            $('#users').append('<tr><td>'+rank+'</td><td>'+max+'</td><td>'+users[max]+'</td></tr>')
            delete users[max]
            users[rank+10000000]=-999999999-rank # guaranteed to be a low score
        
    render = (msg, pos) ->
        console.log pos
        if msg.users?
            renderUsers msg.users
        if ['next', 'word'].indexOf(msg.category) != -1
            messages.splice pos, 1 # we don't want individual words taking up space
            if msg.category == 'word'
                $('#question').append msg.value
                return
            else if msg.category == 'next'
                $('#question').text ''
                return
            # stuff!
            return
        else
            message_value = '' # the final rendered form
            if msg.category == 'chat'
                message_value = '<b>' + msg.person + '</b> ' + msg.value
            else if msg.category == 'buzzinit-approved'
                message_value = '<em>' + msg.person + " buzzed</em>"
            else if msg.category == 'buzz'
                if msg.ver == "wrong"
                    message_value = '<b><font color="#ff9900">' + msg.person + '</font></b> ' + msg.value
                else if msg.ver == "neg"
                    message_value = '<b><font color="#dc143c">' + msg.person + '</font></b> ' + msg.value
                else if msg.ver == "correct"
                    message_value = '<b><font color="#3e89b4">' + msg.person + '</font></b> ' + msg.value
                else if msg.ver == "int"
                    message_value = '<b><font color="#3eb489">' + msg.person + '</font></b> ' + msg.value
            else if msg.category == 'entry'
                message_value = '--- <b>' + msg.person + '</b> entered the room</div>'
            else
                message_value = JSON.stringify msg
            if messages.length == 0
                $("#message-container").prepend "<div id=\"msg-0\" class=\"container-fluid\">" + message_value + "</div>"
                return
            else if pos == messages.length - 1
                $('#message-container').prepend "<div id=\"msg-#{ pos }\" class=\"container-fluid\">" + message_value + "</div>"
                return
            else
                for id in [pos...messages.length-1]
                    $("#msg-#{ id }").prop 'id', "msg-#{ id + 1 }"
                $("#msg-#{ pos + 1 }").before "<div id=\"msg-#{ pos }\" class=\"container-fluid\">" + message_value + "</div>"
                return
            return
        return
    
    ws.onmessage = (event) ->
        console.log JSON.stringify event.data
        return if event.data == 'pong'
        z = JSON.parse(event.data)
        return if z.room != room
        pos = 0 # the position to add the msg at
        if messages.length == 0
            messages.push z
            pos = 0
        else if z.timestamp <= messages[0].timestamp
            messages.unshift z
            pos = 0
        else if z.timestamp >= messages[messages.length-1].timestamp
            pos = (messages.push z) - 1
        else
            for msgid in [1...messages.length-2]
                if (messages[msgid].timestamp <= z.timestamp and messages[msgid+1].timestamp >= z.timestamp)
                    messages.splice msgid, 0, z # goddamn js arrays are stupid
                    pos = msgid
        render z.msgContent, pos
        return

    ws.onopen = (event) ->
        ws.send(JSON.stringify({timestamp: new Date(), greeting:'hello world!', session: session, room:room, msgContent:{person:name, category:'greeting'}}))
        pinger = setInterval ping, 30000
        return
        
    ws.onclose = (event) ->
        $('#question').after '<div class="container-fluid"><em>you have been disconnected from the server</em></div>'
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