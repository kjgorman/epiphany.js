// Generated by CoffeeScript 1.3.3
(function() {
  var applyCSS, current_answer, dollarCharacterConsideredHarmful, elmts, output, student, welcomeRotation, worldCounter, worlds;

  student = io.connect('/student', {
    'sync disconnect on unload': true
  });

  current_answer = -1;

  worlds = ['world', 'monde', 'mundo', 'mondo', 'welt', 'wereld', 'verden', 'bote', 'mon', 'swiat', 'svet', 'byd'];

  worldCounter = 0;

  welcomeRotation = setInterval((function() {
    $("#welcome-text").fadeOut(1000, function() {
      $("#welcome-text").text(worlds[worldCounter % worlds.length]);
      return $("#welcome-text").fadeIn(1000);
    });
    return worldCounter++;
  }), 2000);

  student.on('edit', function(data) {
    if (data.sid === student.sid) {
      return $("#scratch").val(data['text']);
    }
  });

  student.on('online', function(data) {
    return $("#online").text("Users connected: " + data.clients);
  });

  student.on('sid', function(sid) {
    student.sid = sid;
    return console.log(student.sid);
  });

  student.on('class', function(data) {
    console.log(data);
    $("#class-num").text(data.clsnum);
    $("#class-text").text(data.clstext);
    $("#scratch").val(data.base);
    return current_answer = data.clsans;
  });

  student.on('connect', function(data) {
    $("#connecting").animate({
      color: '#FFFFFF'
    }, 1000, function() {
      return $(this).remove();
    });
    $("#scratch").attr('readonly', false);
    return student.emit('set name', 'user');
  });

  student.on('viewing', function(data) {
    var viewBtn;
    if (data.sid === student.sid) {
      if (data.opened) {
        viewBtn = $("<div class='viewing btn btn-info span3'>A Teacher is viewing your work</div>");
        viewBtn.appendTo($("#btn-container"));
        viewBtn.show("explode", 500);
      }
      if (!data.opened) {
        return $(".viewing").hide('explode', 500, function() {
          return $(this).remove();
        });
      }
    }
  });

  $("#show-nick").click(function() {
    return $("#set-nick").show('blind');
  });

  $("#set-nick-btn").click(function() {
    var potenNick;
    potenNick = $("#set-nick-input").val();
    if (potenNick !== "") {
      $("#set-nick").hide('blind', function() {
        $("#set-nick").animate({
          top: "35px",
          left: "100px"
        });
        return $("#show-nick").animate({
          top: "15px",
          left: "100px"
        }, function() {
          return $(".container").fadeIn(1500);
        });
      });
      student.emit('set name', potenNick);
      $("#show-nick").text("Hi, " + potenNick + "!");
      return clearInterval(welcomeRotation);
    }
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
        return $(".alert-error").hide('puff', 1000, function() {
          return $(this).remove();
        });
      }
    }
  });

  output = function(txt) {
    var $cnsl, levelUpModal;
    if (txt === current_answer) {
      levelUpModal = $("<div class='modal hide fade'>                           <div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button></div>                           <div class='modal-body'><h1>Well done, that's correct!</h1></div>                           <div class='modal-footer centered'><a href='#' class='btn btn-large btn-success' data-dismiss='modal'>Next Lesson</a></div>                          </div>").modal();
      student.emit('level up');
    }
    $cnsl = $("#console");
    $cnsl.val($cnsl.val() + txt + "\n>> ");
    return $cnsl.scrollTop($cnsl[0].scrollHeight);
  };

  $("#submit").click(function(event) {
    var data;
    data = $("#scratch").val();
    return eval(data);
  });

  $("#help").click(function(event) {
    return student.emit('help', student.sid);
  });

  applyCSS = function(elems, clr, bgclr, fnt) {
    return _.each(elems, function(elem) {
      return $(elem).css({
        "color": clr,
        "background-color": bgclr,
        "font": fnt
      });
    });
  };

  elmts = [$('body'), $("input"), $(".well"), $("textarea")];

  $("#nerd").toggle(function(event) {
    applyCSS(elmts, "#0f0", "#000", "console");
    $(".btn").addClass("btn-nerd-mode");
    return $(this).text("normal mode");
  }, function(event) {
    applyCSS(elmts, "#000", "#fff", "helvetica");
    $(".btn").removeClass("btn-nerd-mode");
    return $(this).text("nerd mode");
  });

}).call(this);
