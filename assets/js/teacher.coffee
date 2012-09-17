teacher = io.connect '/teacher', {'sync disconnect on unload' : true}

teacher.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()

#At some point this will do something!           
createProgress = () ->
    "<div class='prog'>
       <div class='lesson complete'></div>
       <div class='lesson complete'></div>
       <div class='lesson complete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
       <div class='lesson incomplete'></div>
    </div>"


teacher.on 'render', (data) ->
    $("#online").text "Students online: "+data.clients
    for idx in [0...data.clients]
        id = data.idNickPairs[idx].id
        nick = data.idNickPairs[idx].nick
        id_rgx = new RegExp(id, 'g') #make sure we don't add the same id twice
        nm_rgx = new RegExp(nick, 'g')
        if !_.any( _.map( $('.container').find('.student-box'), (el) -> (id_rgx.test $(el).text()) and (nm_rgx.test $(el).text()) ) )
            if idx % 2 == 0
                current_row = $("<div class='row-fluid #{idx}'></div>")
                $("#student-container").append current_row
            if !current_row
                current_row = $(_.last $("#student-container").children())
            prog = createProgress()
            current_row.append $("<div class='student-box span6' id='#{id}'>
                                   <h3 class='student-nick' id='nick-#{id}'>#{nick}</h3>
                                   <div class='hide' id='text-container-#{id}'>
                                       <textarea rows=10 class='span10' id='text-#{id}'></textarea>
                                   </div>
                                   <h3 class='student-id' style='display:none'>#{id}</h3>
                                    #{prog}
                                  </div>")
            ((closed_id) ->
              $("#nick-#{closed_id}").toggle () ->
                $("#text-container-#{closed_id}").show("explode", 1000);
              , () ->
                $("#text-container-#{closed_id}").hide("explode", 1000);)(id);
    #also, delete any ids that are still client side but have disconnected from the server
     _.map $('.container').find('.student-box'),
          (el) ->
            pair_present = _.map data.idNickPairs, (p) ->
                             id_rgx = new RegExp p.id, 'g'
                             nm_rgx = new RegExp p.nick, 'g'
                             (id_rgx.test $(el).find('.student-id').text()) and (nm_rgx.test $(el).find('.student-nick').text())
            if !_.any pair_present
                $(el).remove()
