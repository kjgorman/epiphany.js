contrib = io.connect '/contribute', {'sync disconnect on unload' : true}

appendClass = (idx, cls) ->
        row = $("<div id='#{idx}' class='row'></div>")
        base = $("<div class='span4'><textarea class='span4 base'>"+cls.base+"</textarea></div>")
        ans = $("<div class='span4'><textarea class='span4 ans'>"+cls.clsans+"</textarea></div>")
        text = $("<div class='span4'><textarea class='span4 text'>"+cls.clstext+"</textarea></div>")
        row.append(base).append(ans).append(text)
        $(".container").append(row)

$(".save").click () ->
        cls = {}
        $('.row').each () ->
          idx = $(this).attr('id')
          cls[idx] = {}        
          cls[idx].clsans = $(this).find(".ans").val()
          cls[idx].clstext = $(this).find(".text").val()
          cls[idx].base = $(this).find(".base").val()
        console.log cls
        contrib.emit 'class-up', cls

$(".add").click () ->
        appendClass $(".row").length+1, {base:"your base code here", clsans:"the answer here", clstext:"your description text here"}        
        
contrib.on 'class-down', (data) ->
         $(".row").remove()
         for idx of data
             appendClass idx, data[idx]