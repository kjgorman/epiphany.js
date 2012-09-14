teacher = io.connect '/teacher', {'sync disconnect on unload' : true}

teacher.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()
           
teacher.on 'render', (data) ->
    console.log data
    $("#online").text "Students online: "+data.clients
    for idx in [0...data.clients]
        id = data.idNickPairs[idx].id
        nick = data.idNickPairs[idx].nick
        id_rgx = new RegExp(id, 'g') #make sure we don't add the same id twice
        nm_rgx = new RegExp(nick, 'g')
        if !_.any( _.map( $('.container').find('.student'), (el) -> (id_rgx.test $(el).text()) and (nm_rgx.test $(el).text()) ) )
            $(".container").append("<div class='row'><div class='span12 student'>A student is connected; id=#{id},nick=#{nick}</div></div>")
    #also, delete any ids that are still client side but have disconnected from the server
     _.map $('.container').find('.student'),
          (el) ->
            pair_present = _.map data.idNickPairs, (p) ->
                             id_rgx = new RegExp p.id, 'g'
                             nm_rgx = new RegExp p.nick, 'g'
                             (id_rgx.test $(el).text()) and (nm_rgx.test $(el).text())
            if !_.any pair_present
                $(el).parent().remove()
