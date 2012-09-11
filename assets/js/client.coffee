socket = io.connect 'http://localhost'

socket.on 'edit', (data) ->
    $("#scratch").val data['text']


$('#scratch').keyup ->
    socket.emit 'edit', {text:$(this).val()}

output = (txt) ->
    $("#console").val $("#console").val()+txt+"\n>>"

$("#submit").click (event) ->
    data = $("#scratch").val()
    eval data
$("#nerd").click (event) ->
    $("#scratch").css({"color":"#0F0", "background-color":"#000", "font":"console"})
    $("#console").css({"color":"#0F0", "background-color":"#000", "font":"console"})
