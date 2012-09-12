socket = io.connect 'http://desolate-scrubland-9651.herokuapp.com/'

socket.on 'edit', (data) ->
    $("#scratch").val data['text']

socket.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 2500


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
$("#nerd").click (event) ->
    $("#scratch").css({"color":"#0F0", "background-color":"#000", "font":"console"})
    $("#console").css({"color":"#0F0", "background-color":"#000", "font":"console"})
