$(document).ready(function () {
    room = window.location.pathname.substring(1);
    var ws = new WebSocket("wss://frozen-plains-52974.herokuapp.com", [room]);
    $("#left").prepend('<input type="text" placeholder="name" id="namebox" class="form-control">');
    var name = document.getElementById("namebox").value;
    $(document).keypress(function () {
        if (event.which == 13) {
            if (document.getElementById("chatbox") != null) {
                ws.send(JSON.stringify({
                    room: room,
                    person: name,
                    msgContent: {
                        category: "chat",
                        msx: document.getElementById("chatbox").value
                    }
                }));
                $("#chatbox").remove();
            } else if (document.getElementById("buzzbox") != null) {
                ws.send(JSON.stringify({
                    room: room,
                    person: name,
                    msgContent: {
                        category: "buzz",
                        msx: document.getElementById("buzzbox").value
                    }
                }));
                $("#buzzbox").remove();
            } else {
                name = document.getElementById("namebox").value;
            }
        } else if (document.activeElement.tagName != "BODY") {
        } else if (event.which == 32) {
            $("#main").prepend('<input type="text" placeholder="buzz" id="buzzbox" class="form-control">');
            setTimeout(function() {$("#buzzbox").focus();}, 120);
        } else if (event.which == 110) {
            ws.send (JSON.stringify ({
                room: room,
                person: "donald trump",
                msgContent: {
                    category: "next",
                    msx: "..."
                }
            }));
        } else if (event.which == 47) {
            $("#main").prepend('<input type="text" placeholder="chat" id="chatbox" class="form-control">');
            setTimeout(function () {
                $("#chatbox").focus();
            }, 120);
        }
    });
    ws.onmessage = function (event) {
        $("#main").prepend('<div class="container-fluid">'+event.data+'</div>');
    };
});
