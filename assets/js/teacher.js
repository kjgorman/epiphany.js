// Generated by CoffeeScript 1.3.3
(function() {
  var alerts, completeClass, createProgress, teacher, toggleAlert;

  teacher = io.connect('/teacher', {
    'sync disconnect on unload': true
  });

  alerts = {};

  completeClass = function(sid, cmpl) {
    return $(($("#" + sid).find(".lesson")).slice(0, cmpl)).removeClass("incomplete").addClass("complete");
  };

  toggleAlert = function(sid) {
    var $stdnt;
    $stdnt = $("#" + sid);
    console.log("hm");
    $stdnt.toggleClass("alert-on");
    console.log("hmm");
    $stdnt.toggleClass("alert-off");
    return console.log("hmmm");
  };

  teacher.on('connect', function(data) {
    return $("#connecting").animate({
      color: '#FFFFFF'
    }, 1000, function() {
      return $(this).remove();
    });
  });

  teacher.on('update', function(data) {
    console.log(data);
    completeClass(data.sid, data.completion);
    return $("#text-" + data.sid).val(data.text);
  });

  teacher.on('help', function(data) {
    $("#" + data.sid).addClass("alert-on");
    return alerts.sid = setInterval((function() {
      return toggleAlert(data.sid);
    }), 1000);
  });

  teacher.on('level up', function(data) {
    console.log("level up received for " + data.sid);
    return completeClass(data.sid, data.cmpl);
  });

  createProgress = function() {
    return "<div class='prog'>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>       <div class='lesson incomplete'></div>    </div>";
  };

  teacher.on('render', function(data) {
    var current_row, id, id_rgx, idx, nick, nm_rgx, prog, _i, _ref;
    console.log('rendering');
    console.log(data);
    $("#online").text("Students online: " + data.clients);
    for (idx = _i = 0, _ref = data.clients; 0 <= _ref ? _i < _ref : _i > _ref; idx = 0 <= _ref ? ++_i : --_i) {
      id = data.idNickPairs[idx].id;
      nick = data.idNickPairs[idx].nick;
      id_rgx = new RegExp(id, 'g');
      nm_rgx = new RegExp(nick, 'g');
      if (!_.any(_.map($('.container').find('.student-box'), function(el) {
        return (id_rgx.test($(el).text())) && (nm_rgx.test($(el).text()));
      }))) {
        if (idx % 1 === 0) {
          current_row = $("<div class='row-fluid " + idx + "'></div>");
          $("#student-container").append(current_row);
        }
        if (!current_row) {
          current_row = $(_.last($("#student-container").children()));
        }
        prog = createProgress();
        $("<div class='student-box span12' id='" + id + "'>                <h3 class='student-nick' id='nick-" + id + "'>" + nick + "</h3>                 <div class='hide' id='text-container-" + id + "'>                  <textarea rows=10 class='span10' id='text-" + id + "'></textarea>                 </div>                <h3 class='student-id' style='display:none'>" + id + "</h3>                " + prog + "               </div>").appendTo(current_row).each(function() {
          var textbox;
          nick = $(this).find("#nick-" + id);
          textbox = $(this).find('textarea');
          (function(closed_id, closed_nick) {
            return $(nick).toggle(function() {
              if ($("#" + closed_id).hasClass("alert-on")) {
                $("#" + closed_id).removeClass("alert-on");
              }
              if ($("#" + closed_id).hasClass("alert-off")) {
                $("#" + closed_id).removeClass("alert-on");
              }
              return $("#text-container-" + closed_id).show("explode", 1000);
            }, function() {
              return $("#text-container-" + closed_id).hide("explode", 1000);
            });
          })(id, nick);
          return (function(closed_box) {
            return closed_box.keyup(function() {
              console.log("edit sending");
              return teacher.emit('edit', {
                sid: $(this).parent().parent().attr('id'),
                text: $(this).val()
              });
            });
          })(textbox);
        });
      }
    }
    return _.map($('.container').find('.student-box'), function(el) {
      var pair_present;
      pair_present = _.map(data.idNickPairs, function(p) {
        id_rgx = new RegExp(p.id, 'g');
        nm_rgx = new RegExp(p.nick, 'g');
        return (id_rgx.test($(el).find('.student-id').text())) && (nm_rgx.test($(el).find('.student-nick').text()));
      });
      if (!_.any(pair_present)) {
        return $(el).remove();
      }
    });
  });

}).call(this);
