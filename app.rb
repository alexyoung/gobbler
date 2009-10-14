%w(rubygems sinatra mustache/sinatra sass htmlentities json).each do |lib|
  begin
    require lib
  rescue LoadError
    puts "Please install #{lib}"
    exit 1
  end
end
require 'lib/gobbler'

set :sessions, true

helpers do
  def start_server_if_required
    Gobbler::Daemon.launch_daemon unless Gobbler::Daemon.running?
  end

  def current_section
    Settings['sections'].first
  end

  def newest_tweet_id(tweets)
    tweets.map { |section, t| t.map(&:id) }.flatten.compact.sort.last
  end

  def save_newest_tweet_to_session(tweets)
    tweet_id = newest_tweet_id(tweets)
    session[:last_tweet_id] = tweet_id if tweet_id
  end

  def tweets
    tweets = Gobbler::Daemon.tweets_since(session[:last_tweet_id])
    save_newest_tweet_to_session tweets
    tweets[current_section].map do |tweet|
      { :from_user => tweet.from_user,
        :text => HTMLEntities.decode_entities(tweet.text)
      }
    end
  end
end

get '/' do
  session[:last_tweet_id] = nil
  @current_section = current_section
  mustache :index
end

get '/updates.json' do
  start_server_if_required
  tweets.to_json
end

get '/stylesheets/screen.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  #sass 'public/stylesheets/screen.sass'
  sass :stylesheet
end

__END__

@@layout
<!DOCTYPE html>
<html>
  <head>
    <title>Gobble</title>
    <script src="/javascripts/glow/core/core.js" type="text/javascript"></script>
    <script src="/javascripts/application.js" type="text/javascript"></script>
    <link href="/stylesheets/screen.css" media="screen" rel="Stylesheet" type="text/css" />
  </head>
  <body>
    {{{yield}}}
  </body>
</html>

@@index
<ul id="updates"><li></li></ul>

@@stylesheet
body
  :font-family helvetica, sans-serif
  :background-color #fff
  :overflow hidden

a
  :color #ffc

#updates
  :position absolute
  :bottom 0
  :left 0
  :background-color #000
  :color #ccc
  :font-size 28px
  :list-style-type none
  :margin 0
  :padding 0
  :width 100%

#updates li
  :overflow hidden
  :margin 10px
