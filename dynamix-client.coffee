$(document).ready ->
  room = window.location.pathname.substring(1)
  ws = new WebSocket('wss://dynamix-coordinator.herokuapp.com')
  $('#right').prepend '<input type="text" placeholder="name" id="namebox" class="form-control">'
  $(document).keypress ->
    name = document.getElementById('namebox').value
    if event.which == 13
      if document.getElementById('chatbox') != null
        ws.send JSON.stringify(
          room: room
          person: name
          msgContent:
            category: 'chat'
            msx: document.getElementById('chatbox').value)
        $('#chatbox').remove()
      else if document.getElementById('buzzbox') != null
        ws.send JSON.stringify(
          room: room
          person: name
          msgContent:
            category: 'buzz'
            msx: document.getElementById('buzzbox').value)
        $('#buzzbox').remove()
      else
        name = document.getElementById('namebox').value
    else if document.activeElement.tagName != 'BODY'
    else if event.which == 32
      $('#main').prepend '<input type="text" placeholder="buzz" id="buzzbox" class="form-control">'
      setTimeout (->
        $('#buzzbox').focus()
        return
      ), 120
    else if event.which == 110
      ws.send JSON.stringify(
        room: room
        person: 'donald trump'
        msgContent:
          category: 'next'
          msx: '...')
    else if event.which == 47
      $('#main').prepend '<input type="text" placeholder="chat" id="chatbox" class="form-control">'
      setTimeout (->
        $('#chatbox').focus()
        return
      ), 120
    return

  ws.onmessage = (event) ->
    console.log event.data
    $('#main').prepend '<div class="container-fluid">' + event.data + '</div>'

  ws.onopen = (event) ->
    ws.send(JSON.stringify({greeting: 'hello', room: room}))
