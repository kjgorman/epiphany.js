contrib = io.connect '/contribute', {'sync disconnect on unload' : true}

appendClass = (idx, cls) ->
        row = $("<div id='#{idx}' class='row'></div>")
        base = $("<div class='span4'><textarea class='span4'>"+cls.base+"</textarea></div>")
        ans = $("<div class='span4'><textarea class='span4'>"+cls.clsans+"</textarea></div>")
        text = $("<div class='span4'><textarea class='span4'>"+cls.clstext+"</textarea></div>")
        row.append(base).append(ans).append(text)
        $(".container").append(row)

contrib.on 'class-down', (data) ->
         for idx, cls in data
                appendClass idx, cls