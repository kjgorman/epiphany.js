// Generated by CoffeeScript 1.3.3
(function() {
  var appendClass, contrib;

  contrib = io.connect('/contribute', {
    'sync disconnect on unload': true
  });

  $(".sortable").sortable();

  appendClass = function(idx, cls) {
    var ans, base, row, text;
    row = $("<div id='" + idx + "' class='row' style='background-color:#fafafa'><i class='icon-move'></i></div>");
    base = $("<div class='span4 odd'><textarea class='span4 base'>" + cls.base + "</textarea></div>");
    ans = $("<div class='span4 even'><textarea class='span4 ans'>" + cls.clsans + "</textarea></div>");
    text = $("<div class='span4 odd'><textarea class='span4 text'>" + cls.clstext + "</textarea></div>");
    row.append(base).append(ans).append(text);
    return $(".class-container").append(row);
  };

  $(".save").click(function() {
    var cls;
    cls = {};
    $('.row').each(function(index, value) {
      var idx;
      idx = index;
      cls[idx] = {};
      cls[idx].clsans = $(this).find(".ans").val();
      cls[idx].clstext = $(this).find(".text").val();
      return cls[idx].base = $(this).find(".base").val();
    });
    console.log(cls);
    return contrib.emit('class-up', cls);
  });

  $(".add").click(function() {
    return appendClass($(".row").length + 1, {
      base: "your base code here",
      clsans: "the answer here",
      clstext: "your description text here"
    });
  });

  contrib.on('class-down', function(data) {
    var idx, _results;
    console.log(data);
    $(".row").remove();
    _results = [];
    for (idx in data) {
      _results.push(appendClass(idx, data[idx]));
    }
    return _results;
  });

}).call(this);
