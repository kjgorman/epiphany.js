socket = io.connect 'http://localhost'

socket.on 'edit', (data) ->
    $("#scratch").val data['text']


$('#scratch').keyup ->
    socket.emit 'edit', {text:$(this).val()}

output = (txt) ->
    $("#console").val txt

$("#submit").click (event) ->
    data = $("#scratch").val()
    eval data
