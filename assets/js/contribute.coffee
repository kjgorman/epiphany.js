contrib = io.connect '/contribute', {'sync disconnect on unload' : true}

appendClass = (idx, cls) ->
        console.log cls
        row = $("<div id='#{idx}' class='row'></div>")
        base = $("<div class='span4 base'><textarea class='span4'>"+cls.base+"</textarea></div>")
        ans = $("<div class='span4 ans'><textarea class='span4'>"+cls.clsans+"</textarea></div>")
        text = $("<div class='span4 text'><textarea class='span4'>"+cls.clstext+"</textarea></div>")
        row.append(base).append(ans).append(text)
        $(".container").append(row)

$(".save").click () ->
        cls = {}
        $('.row').each () ->
          idx = $(this).attr('id')
          cls[idx] = {}        
          cls[idx].clsans = $(this).find(".ans")
          cls[idx].clstext = $(this).find(".text")
          cls[idx].base = $(this).find(".base")
        console.log cls
        
contrib.on 'class-down', (data) ->
         console.log data
         for idx of data
             console.log data[idx]
             appendClass idx, data[idx]