socket = io.connect 'http://localhost'

socket.on 'edit', (data) ->
    console.log(data)
    $("#scratch").val data['text']


$('#scratch').keyup ->
    socket.emit 'edit', {text:$(this).val()}

