student = io.connect '/student', {'sync disconnect on unload' : true}

current_answer = -1

worlds = ['world', 'monde', 'mundo', 'mondo', 'welt', 'wereld', 'verden', 'bote', 'mon', 'swiat', 'svet', 'byd']
worldCounter = 0;
welcomeRotation = 0
incrProgress = {}

$("#show-nick").fadeIn(750, () ->
                                setInterval (() ->
                                  $("#welcome-text").fadeOut(1000, () ->
                                    $("#welcome-text").text(worlds[worldCounter%worlds.length])
                                    $("#welcome-text").fadeIn(1000))
                                  worldCounter++), 2000)                               
$("#set-nick-input").keypress (e) ->
        if e.keyCode == 13
                getNickInput()

setupProgressBar = () ->
        classText =  $("#class-text")
        progressCanvas = Raphael(classText.offset().left, classText.offset().top, classText.parent().width(), 20)
        progressBar = progressCanvas.rect(0,0, classText.parent().width(), 20, 5)
        progressBar.attr('fill', '#D33')
        progressBar.attr('stroke', '#FFF')
        progressProgress = 0
        progressProgressIncrement = classText.parent().width()/10
        progressProgressBar = progressCanvas.rect(0,0,progressProgress,20,5);
        progressProgressBar.attr('fill', '#3G3')
        progressProgressBar.attr('stroke', '#D33')
        
        return () -> progressProgressBar.animate(Raphael.animation({width:progressProgressBar.attr('width')+progressProgressIncrement}, 2000, "backOut"))

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

student.on 'viewing', (data) ->
    if data.sid == student.sid
        if data.opened
                viewBtn = $("<div class='viewing btn btn-info span3'>A Teacher is viewing your work</div>")
                viewBtn.appendTo $("#btn-container")
                viewBtn.show "explode", 500
        if !data.opened
                $(".viewing").hide 'explode', 500, () -> $(this).remove()

$("#show-nick").click () ->
    $("#set-nick").show('blind');

getNickInput = () ->
            potenNick = $("#set-nick-input").val()
            if potenNick != ""
                
                $("#set-nick").hide('blind', () ->                
                  $("#set-nick").animate({top:"4%", left:"10%"}, 2000)
                  $("#show-nick").animate({top:"2%", left:"10%"}, 2000, () ->        
                    $(".container").fadeIn(1500, () ->
                      incrProgress = setupProgressBar()
                    )
                  )
                )
                
                student.emit 'set name', potenNick
                $("#show-nick").text("Hi, #{potenNick}!")
                clearInterval welcomeRotation

$("#set-nick-btn").click () ->
    getNickInput()    

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
          $(".alert-error").hide 'puff', 1000, () -> $(this).remove()
      

output = (txt) ->
    if txt == current_answer
        levelUpModal = $("<div class='modal hide fade'>
                           <div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button></div>
                           <div class='modal-body'><h1>Well done, that's correct!</h1></div>
                           <div class='modal-footer centered'><a href='#' class='btn btn-large btn-success' data-dismiss='modal'>Next Lesson</a></div>
                          </div>").modal().on('hidden', () -> incrProgress())
        student.emit 'level up'
    $cnsl = $("#console")        
    $cnsl.val $cnsl.val()+txt+"\n>> " 
    $cnsl.scrollTop($cnsl[0].scrollHeight) #weird that jquery doesn't have scrollheight()

$("#submit").click (event) ->
    data = $("#scratch").val()
    try
        eval data
    catch err
        output err.message

$("#help").click (event) ->
    student.emit 'help', student.sid

applyCSS = (elems, clr, bgclr, fnt) ->
        _.each elems, (elem) -> $(elem).css({"color":clr, "background-color":bgclr, "font":fnt});

elmts = [$('body'), $("input"), $(".well"), $("textarea")]

$("#nerd").toggle (event) ->
    applyCSS elmts, "#0f0", "#000", "console"
    $(".btn").addClass("btn-nerd-mode")
    $(this).text("normal mode")
, (event) ->
    applyCSS elmts, "#000", "#fff", "helvetica"        
    $(".btn").removeClass("btn-nerd-mode")
    $(this).text("nerd mode")

    
