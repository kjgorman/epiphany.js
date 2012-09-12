teacher = io.connect '/teacher', {'sync disconnect on unload' : true}

teacher.on 'connect', (data) ->
    $("#connecting").animate {color:'#FFFFFF'}, 1000, () ->
        $(this).remove()
