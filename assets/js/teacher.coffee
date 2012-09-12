teacher = io.connect '/teacher', {'sync disconnect on unload' : true}

teacher.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()
teacher.on 'online', (data) ->
    $("#online").text "Students online: "+data.clients
teacher.on 'render', (data) ->
    for idx in [0...data.clients]
        $(".container").append("<div>A student is connected</div>")
