// Generated by CoffeeScript 1.3.3
(function() {
  var dollarCharacterConsideredHarmful, output, student;

  student = io.connect('/student', {
    'sync disconnect on unload': true
  });

  student.on('edit', function(data) {
    console.log(data);
    return $("#scratch").val(data['text']);
  });

  student.on('online', function(data) {
    return $("#online").text("Users connected: " + data.clients);
  });

  student.on('class', function(data) {
    $("#class-num").text(data.clsnum);
    return $("#class-text").text(data.clstext);
  });

  student.on('connect', function(data) {
    $("#connecting").animate({
      color: '#FFFFFF'
    }, 1000, function() {
      return $(this).remove();
    });
    $("#scratch").attr('readonly', false);
    return student.emit('set name', 'test user');
  });

  $("#scratch").keydown(function(e) {
    var $this, end, start, value;
    if (e.keyCode === 9) {
      start = this.selectionStart;
      end = this.selectionEnd;
      $this = $(this);
      value = $this.val();
      $this.val((value.substring(0, start)) + "\t" + (value.substring(end)));
      this.selectionStart = this.selectionEnd = start + 1;
      e.preventDefault();
      return false;
    }
  });

  dollarCharacterConsideredHarmful = function() {
    $("#scratch").parent().append($("<div id='jqprotect' class='alert alert-error'>" + "Sorry, but for security reasons the dollar character is not allowed" + "</div>"));
  };

  $('#scratch').keyup(function() {
    var disallowDollar, hasDollar;
    disallowDollar = /\$/;
    hasDollar = disallowDollar.test($(this).val());
    if ($("#jqprotect").length === 0) {
      if (hasDollar) {
        dollarCharacterConsideredHarmful();
        return;
      }
      console.log("emitting an edit");
      return student.emit('edit', {
        text: $(this).val()
      });
    } else {
      if (!hasDollar) {
        return $(".alert-error").hide('explode', 1000, function() {
          return $(this).remove();
        });
      }
    }
  });

  output = function(txt) {
    var cnsl;
    $("#console").val($("#console").val() + txt + "\n>> ");
    cnsl = $("#console");
    return cnsl.scrollTop(cnsl[0].scrollHeight);
  };

  $("#submit").click(function(event) {
    var data;
    data = $("#scratch").val();
    return eval(data);
  });

  $("#nerd").toggle(function(event) {
    $('body').css({
      "color": "#0F0",
      "background-color": "#000",
      "font": "console"
    });
    $('#scratch').css({
      "color": "#0F0",
      "background-color": "#000",
      "font": "console"
    });
    $('#console').css({
      "color": "#0F0",
      "background-color": "#000",
      "font": "console"
    });
    $("#submit").addClass("btn-nerd-mode");
    return $(this).text("normal mode");
  }, function(event) {
    $('body').css({
      "color": "#000",
      "background-color": "#fff",
      "font": "helvetica"
    });
    $('#scratch').css({
      "color": "#000",
      "background-color": "#fff",
      "font": "helvetica"
    });
    $('#console').css({
      "color": "#000",
      "background-color": "#fff",
      "font": "helvetica"
    });
    $("#submit").removeClass("btn-nerd-mode");
    return $(this).text("nerd mode");
  });

}).call(this);
