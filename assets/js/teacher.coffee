teacher = io.connect '/teacher', {'sync disconnect on unload' : true}

alerts = {}

completeClass = (sid, cmpl) ->
    $(($("#"+sid).find(".lesson")).slice(0, cmpl)).removeClass("incomplete").addClass("complete")

toggleAlert = (sid) ->
    $stdnt = $("#"+sid)
    $stdnt.toggleClass "alert-on"
    $stdnt.toggleClass "alert-off"
    console.log "hmmm"
        
teacher.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()

teacher.on 'update', (data) ->
    console.log data
    completeClass data.sid, data.completion
    $("#text-"+data.sid).val(data.text)

teacher.on 'help', (data) ->
    $("#"+data.sid).addClass "alert-on"
    alerts.sid = setInterval (() -> toggleAlert(data.sid)), 1000

teacher.on 'level up', (data) ->
    console.log "level up received for #{data.sid}"
    completeClass data.sid, data.cmpl

createProgress = () ->
    "<div class='prog'>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
    </div>"

teacher.on 'render', (data) ->
    console.log 'rendering'
    console.log data
    $("#online").text "Students online: "+data.clients
    for idx in [0...data.clients]
        id = data.idNickPairs[idx].id
        nick = data.idNickPairs[idx].nick
        id_rgx = new RegExp(id, 'g') #make sure we don't add the same id twice
        nm_rgx = new RegExp(nick, 'g')
        if !_.any( _.map( $('.container').find('.student-box'), (el) -> (id_rgx.test $(el).text()) and (nm_rgx.test $(el).text()) ) )
            if idx % 1 == 0
                current_row = $("<div class='row-fluid #{idx}'></div>")
                $("#student-container").append current_row
            if !current_row
                current_row = $(_.last $("#student-container").children())
            prog = createProgress()
            $("<div class='student-box span12' id='#{id}'>
                <h3 class='student-nick' id='nick-#{id}'>#{nick}</h3>
                 <div class='hide' id='text-container-#{id}'>
                  <textarea rows=10 class='span10' id='text-#{id}'></textarea>
                 </div>
                <h3 class='student-id' style='display:none'>#{id}</h3>
                #{prog}
               </div>")
            .appendTo(current_row)
            .each () ->
                    nick = $(this).find "#nick-#{id}"
                    textbox = $(this).find 'textarea'
                    ((closed_id, closed_nick) ->
                      $(nick).toggle () ->
                        if $("#"+closed_id).hasClass "alert-on"
                            $("#"+closed_id).removeClass "alert-on"
                        if $("#"+closed_id).hasClass "alert-off"
                            $("#"+closed_id).removeClass "alert-on"
                        $("#text-container-#{closed_id}").show("explode", 1000);
                      , () ->
                        $("#text-container-#{closed_id}").hide("explode", 1000);)(id, nick);
                    ((closed_box) ->
                      closed_box.keyup () ->
                        console.log "edit sending"
                        teacher.emit 'edit', {sid:$(this).parent().parent().attr('id'), text:$(this).val()}
                    )(textbox)
    #also, delete any ids that are still client side but have disconnected from the server
    _.map $('.container').find('.student-box'),
          (el) ->
            pair_present = _.map data.idNickPairs, (p) ->
                             id_rgx = new RegExp p.id, 'g'
                             nm_rgx = new RegExp p.nick, 'g'
                             (id_rgx.test $(el).find('.student-id').text()) and (nm_rgx.test $(el).find('.student-nick').text())
            if !_.any pair_present
                $(el).remove()
