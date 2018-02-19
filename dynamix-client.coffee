$(document).ready ->
    room = window.location.pathname.substring(1)
    try
        session = JSON.parse(document.cookie).session
        name = JSON.parse(document.cookie).username
        $('#login').text(name)
        login = true
    catch error
        login = false
        name = 'guest'
    finally
        if name == ''
            name = 'comrade popov'
            
    speed = 120 # time distance between two words
    ws = new WebSocket('wss://dynamix-coordinator.herokuapp.com')
    
    sendbuzz = () ->
        ws.send JSON.stringify({
            room: room
            msgContent: {
                person: name
                category: 'buzz'
                value: document.getElementById('buzzbox').value
                }
            })
        $('#buzzbox').remove()
            
    sendchat = () ->
        ws.send JSON.stringify({
            room: room,
            msgContent: {
                category: 'chat',
                value: document.getElementById('chatbox').value,
                person: name
            }
        })
        $('#chatbox').remove()
            
    openchat = () ->
        $('#question').after '<div class="container-fluid input"><input type="text" placeholder="chat" id="chatbox" class="form-control"></div>'
        setTimeout (->
            $('#chatbox').focus()
        ), 120
            
    openbuzz = () ->
        $('#question').after '<div class="container-fluid input"><input type="text" placeholder="buzz" id="buzzbox" class="form-control"></div>'
        setTimeout (->
            $('#buzzbox').focus()
        ), 120
    
    next = () ->
        ws.send JSON.stringify({
            room: room
            msgContent: {
                person: name
                category: 'next'
                value: 'this is for sure not the correct answer'
            }
        })

    toggle = () ->
        ws.send JSON.stringify ({
            room:room
            msgContent:{
                category:'toggle'
            }
        })

    ws.onmessage = (event) ->
        console.log JSON.stringify event.data
        return if event.data == 'pong'
        return if JSON.parse(event.data).room != room
        x = JSON.parse(event.data).msgContent
        if x.category == 'chat'
            x = '<span style="font-weight: bold;">' + x.person + '</span> ' + x.value
        else if x.category == 'buzz'
            x = '<span style="font-weight: bold;">' + x.person + '</span> ' + x.value + ' ' + x.ver
        else if x.category == 'entry'
            y = x.users
            x = '<span style="font-style: italic;">' + x.person + ' joined the room</span>'
        else if x.category == 'exit'
            y = x.users
            x = '<span style="font-style: italic;">' + x.person + ' left the room</span>'
        else if x.category == 'word'
            $('#question').append x.value 
            x = '#eof#'
            
        else if x.category == 'next'
            $('#question').empty()
            x = '#eof#'
            
        $('#question').after '<div class="container-fluid">' + x + '</div>' if x != '#eof#'
        if y?
            $('#users').empty()
            i = 1
            for user, score in y
                $('#users').append '<tr><th scope="row">'+i'</th><td>'+user+'</td><td>'+score+'</td></tr>'
                i++

    ws.onopen = (event) ->
        ws.send(JSON.stringify({greeting:'hello world!', room:room, msgContent:{person:name, category:'greeting'}}))
        pinger = setInterval ping, 40000
        
    ws.onclose = (event) ->
        $('#question').after '<div class="container-fluid">you have been disconnected from the server</div>'
        
    ping = () ->
        ws.send('ping')    
        
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
            toggle()
            openbuzz()
    
        else if event.which == 110
            next()
            
        else if event.which == 47 || event.which == 99
            openchat()