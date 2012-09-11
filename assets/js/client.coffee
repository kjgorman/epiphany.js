socket = io.connect 'http://desolate-scrubland-9651.herokuapp.com/'

socket.on 'edit', (data) ->
    $("#scratch").val data['text']


$('#scratch').keyup ->
    socket.emit 'edit', {text:$(this).val()}

output = (txt) ->
    $("#console").val txt

$("#submit").click (event) ->
    data = $("#scratch").val()
    eval data
