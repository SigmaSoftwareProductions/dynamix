$(document).ready ->

    room = window.location.pathname.substring(1)
    try
        name = JSON.parse(document.cookie).username
    catch error
        name = 'comrade popov'
    finally
        #
    
    ws = new WebSocket('wss://dynamix-coordinator.herokuapp.com')
    $('#right').prepend '<input type="text" placeholder="name" id="namebox" class="form-control">'

    $(document).keypress ->

        name = document.getElementById('namebox').value
        document.cookie = JSON.stringify({username:name})

        if event.which == 13
            if document.getElementById('chatbox') != null
                ws.send JSON.stringify({
                    room: room,
                    person: name,
                    msgContent: {
                        category: 'chat',
                        value: document.getElementById('chatbox').value
                    }
                })
                $('#chatbox').remove()
      
            else if document.getElementById('buzzbox') != null
                ws.send JSON.stringify({
                    room: room
                    msgContent: {
                        person: name
                        category: 'buzz'
                        value: document.getElementById('buzzbox').value
                    }
                })
                $('#buzzbox').remove()
      
            else
                name = document.getElementById('namebox').value
            
            $('body').focus()
    
        else if document.activeElement.tagName != 'BODY'
            # do nothing! yay
    
        else if event.which == 32
            $('#main').prepend '<input type="text" placeholder="buzz" id="buzzbox" class="form-control">'
            setTimeout (->
                $('#buzzbox').focus()
            ), 120
    
        else if event.which == 110
            ws.send JSON.stringify({
                room: room
                msgContent: {
                    person: name
                    category: 'next'
                    value: 'this is for sure not the correct answer'
                }
            })
            
        else if event.which == 47
            $('#main').prepend '<input type="text" placeholder="chat" id="chatbox" class="form-control">'
            setTimeout (->
                $('#chatbox').focus()
            ), 120

    ws.onmessage = (event) ->
        if !JSON.parse(event.data).room = room
            return
        x = JSON.parse(event.data).msgContent
        alert (x)
        if x.category == 'chat'
            x = x.person + ' ' + x.value
        else if x.category == 'buzz'
            x = x.person + ' ' + x.value + ' ' + x.ver
        else if x.category == 'entry'
            x = x.person + ' joined the room'
        $('#main').prepend '<div class="container-fluid">' + x + '</div>'

    ws.onopen = (event) ->
        ws.send(JSON.stringify({greeting:'hello world!', room:room, msgContent:{person:name, category:"greeting"}}))
