student = io.connect '/student', {'sync disconnect on unload' : true}

student.on 'edit', (data) ->
    $("#scratch").val data['text']
student.on 'online', (data) ->
    $("#online").text "Users connected: "+data.clients

student.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()
    $("#scratch").attr('readonly', false)
    student.emit 'set name', 'test user'

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

dollarCharacterConsideredHarmful = () ->
        $("#scratch").parent().append $("<div class='alert alert-error'>"+
                                "Sorry, but for security reasons the dollar character is not allowed"+
                                "</div>")
        return

$('#scratch').keyup ->
    disallowDollar = /\$/
    if disallowDollar.test $(this).val()
        dollarCharacterConsideredHarmful()
        return
    if !~($(".alert-error").length-1)
        $(".alert-error").hide 'explode', 1000
    student.emit 'edit', {text:$(this).val()}

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
    
