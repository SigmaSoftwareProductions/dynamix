$(document).ready ->
    ws = new WebSocket('wss://dynamix-coordinator.herokuapp.com')
    $('#submit').on 'click', ->
        ws.send ( JSON.stringify {
            auth:'auth please!', 
            username:document.getElementById('username').value, 
            password:document.getElementById('password').value
        })
        return
    ws.onmessage = (event) ->
        x = JSON.parse event.data
        if x.room?
            return
        if (x.auth)
            alert 'succesful!'
            session = Math.floor(Math.random()*1000000)
            ws.send JSON.stringify {add_session:true, user:document.getElementById('username').value, session:session}
            futurecookie = {username:document.getElementById('username').value, session:session}
            document.cookie = JSON.stringify futurecookie
            document.location.href = document.referrer
        return
    return