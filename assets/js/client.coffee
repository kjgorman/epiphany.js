socket = io.connect 'http://desolate-scrubland-9651.herokuapp.com/'
#socket = io.connect 'http://localhost'

socket.on 'edit', (data) ->
    $("#scratch").val data['text']
    $("#online").text "Users connected: "+data.clients

socket.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()
    $("#scratch").attr('readonly', false)


$("#scratch").keydown (e) -> 
    if e.keyCode == 9
        start = this.selectionStart
        end = this.selectionEnd
        $this = $(this)
        value = $this.val()
        $this.val (value.substring 0, start)+"\t"+(value.substring end)
        this.selectionStart = this.selectionEnd = start + 1
        e.preventDefault()
        false

$('#scratch').keyup ->
    socket.emit 'edit', {text:$(this).val()}

output = (txt) ->
    $("#console").val $("#console").val()+txt+"\n>> " 

$("#submit").click (event) ->
    data = $("#scratch").val()
    eval data
$("#nerd").toggle (event) ->
    $("#scratch").css({"color":"#0F0", "background-color":"#000", "font":"console"})
    $("#console").css({"color":"#0F0", "background-color":"#000", "font":"console"})
    $(this).text("normal mode")
, (event) ->
    $("#scratch").css({"color":"#000", "background-color":"#fff", "font":"helvetica"})
    $("#console").css({"color":"#000", "background-color":"#fff", "font":"helvetica"})
    $(this).text("nerd mode")
    
