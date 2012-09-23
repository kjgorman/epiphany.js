student = io.connect '/student', {'sync disconnect on unload' : true}

current_answer = -1

student.on 'edit', (data) ->
    if data.sid == student.sid
            $("#scratch").val data['text']
student.on 'online', (data) ->
    $("#online").text "Users connected: "+data.clients

student.on 'sid', (sid) ->
    student.sid = sid
    console.log student.sid

student.on 'class', (data) ->
    console.log data
    $("#class-num").text(data.clsnum)
    $("#class-text").text(data.clstext)
    $("#scratch").val(data.base)
    current_answer = data.clsans

student.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()
    $("#scratch").attr('readonly', false)
    student.emit 'set name', 'user'

$("#set-nick-btn").click () ->
    potenNick = $("#set-nick-input").val()
    if potenNick != ""
        student.emit 'set name', potenNick
        $("#show-nick").text("Hi, #{potenNick}!") 

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
    if txt == current_answer
        levelUpModal = $("<div class='modal hide fade'>
                           <div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button></div>
                           <div class='modal-body'><h1>Well done, that's correct!</h1></div>
                           <div class='modal-footer centered'><a href='#' class='btn btn-large btn-success' data-dismiss='modal'>Next Lesson</a></div>
                          </div>").modal()
        student.emit 'level up'
    $cnsl = $("#console")        
    $cnsl.val $cnsl.val()+txt+"\n>> " 
    $cnsl.scrollTop($cnsl[0].scrollHeight) #weird that jquery doesn't have scrollheight()

$("#submit").click (event) ->
    data = $("#scratch").val()
    eval data

applyCSS = (elems, clr, bgclr, fnt) ->
        _.each elems, (elem) -> $(elem).css({"color":clr, "background-color":bgclr, "font":fnt});

$("#nerd").toggle (event) ->
    applyCSS [$('body'), $("#scratch"), $("#console"), $(".well")], "#0f0", "#000", "console"
    $("#submit").addClass("btn-nerd-mode")
    $(this).text("normal mode")
, (event) ->
    applyCSS [$('body'), $("#scratch"), $("#console"), $(".well")], "#fff", "#fff", "helvetica"        
    $("#submit").removeClass("btn-nerd-mode")
    $(this).text("nerd mode")

    
