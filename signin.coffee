$(document).ready ->
    ws = new WebSocket('wss://dynamix-coordinator.herokuapp.com')
    $('#submit').click = () ->
        ws.send ({
            auth:'auth please!', 
            username:document.getElementById('username').value, 
            password:document.getElementById('password').value
        })
    ws.onmessage = (event) ->
        alert event.data