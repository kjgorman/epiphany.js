student = io.connect '/student', {'sync disconnect on unload' : true}

student.on 'edit', (data) ->
    console.log "edit received"
    console.log data
    $("#scratch").val data['text']
student.on 'online', (data) ->
    console.log data
    $("#online").text "Users connected: "+data.clients

student.on 'class', (data) ->
    console.log data
    $("#class-num").text(data.class_num)
    $("#class-text").text(data.class_text)

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
        $("#scratch").parent().append $("<div id='jqprotect' class='alert alert-error'>"+
                                "Sorry, but for security reasons the dollar character is not allowed"+
                                "</div>")
        return

$('#scratch').keyup ->
    disallowDollar = /\$/       
    hasDollar = disallowDollar.test $(this).val()
    if $("#jqprotect").length == 0
      if hasDollar
          dollarCharacterConsideredHarmful()
          return
      console.log "emitting an edit"
      student.emit 'edit', {text:$(this).val()}
    else
      if !hasDollar
          $(".alert-error").hide 'explode', 1000, () -> $(this).remove()
      

output = (txt) ->
    $("#console").val $("#console").val()+txt+"\n>> " 
    cnsl = $("#console")
    cnsl.scrollTop(cnsl[0].scrollHeight) #weird that jquery doesn't have scrollheight()

$("#submit").click (event) ->
    data = $("#scratch").val()
    eval data
$("#nerd").toggle (event) ->
    $('body').css({"color":"#0F0", "background-color":"#000", "font":"console"})
    $('#scratch').css({"color":"#0F0", "background-color":"#000", "font":"console"})
    $('#console').css({"color":"#0F0", "background-color":"#000", "font":"console"})
    $("#submit").addClass("btn-nerd-mode")
    $(this).text("normal mode")
, (event) ->
    $('body').css({"color":"#000", "background-color":"#fff", "font":"helvetica"})
    $('#scratch').css({"color":"#000", "background-color":"#fff", "font":"helvetica"})
    $('#console').css({"color":"#000", "background-color":"#fff", "font":"helvetica"})
    $("#submit").removeClass("btn-nerd-mode")
    $(this).text("nerd mode")

    
