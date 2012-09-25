contrib = io.connect '/contribute', {'sync disconnect on unload' : true}

contrib.on 'class-down', (data) ->
          console.log data