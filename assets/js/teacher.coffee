teacher = io.connect '/teacher', {'sync disconnect on unload' : true}

teacher.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()
teacher.on 'online', (data) ->
    $("#online").text "Students online: "+data.clients
teacher.on 'render', (data) ->
    console.log data
    for idx in [0...data.clients]
        id = data.idNickPairs[idx].id
        nick = data.idNickPairs[idx].nick
        $(".container").append("<div class='row'><div class='span12'>A student is connected; id=#{id},nick=#{nick}</div></div>")