contrib = io.connect '/contribute', {'sync disconnect on unload' : true}

appendClass = (idx, cls) ->
        row = $("<div id='#{idx}' class='row'></div>")
        base = $("<div class='span4'></div>")
        ans = $("<div class='span4'></div>")
        text = $("<div class='span4'></div>")
        row.append(base).append(ans).append(text)
        

contrib.on 'class-down', (data) ->
         for idx, cls in data
                appendClass idx, cls