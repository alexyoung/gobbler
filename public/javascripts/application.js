$ = glow.dom.get;
observe = glow.events.addListener;

glow.ready(function() {
  var updating = false;

  observe(window, 'resize', function() {
    window.scrollTo(0, 1);
  });

  function render_tweet(tweet) {
    return '<li><a href="">' + tweet['from_user'] + '</a> ' + tweet['text'] + '</li>';
  }

  function limit_list() {
    var items = $('#updates li');
    if (items.length > 25) {
      items.slice(0, items.length - 25).destroy();
    }
  }

  function run_update() {
    if (updating) return;
    updating = true;

    glow.net.get('/updates.json', { onLoad: function(response) {
      var tweets = response.json(),
          element = $('#updates');

      for (var key in tweets) {
        try {
          var tweet = glow.dom.create(render_tweet(tweets[key])),
              last_height = element[0].scrollHeight;
          element.append(tweet);
          element[0].style.bottom = '-' + (element[0].scrollHeight - last_height) + 'px';
          tweet[0].style.opacity = 0.0;
          glow.anim.fadeIn(tweet, 1);
          glow.anim.css(element, 0.5, { 'bottom': { to: 0 } }).start();
        } catch (exception) {
          console.log(exception);
        }
        
        limit_list();
      }
      updating = false;
    }});
  }

  run_update();
  setInterval(run_update, 3000);
});
