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

  def newest_tweet_id(tweets)
    tweets.map(&:id).sort.last
  end

  def save_newest_tweet_to_session(tweets)
    tweet_id = newest_tweet_id(tweets)
    session[:last_tweet_id] = tweet_id if tweet_id
  end

  def tweets
    tweets = Gobbler::Daemon.tweets_since(session[:last_tweet_id], session[:current_section])
    save_newest_tweet_to_session tweets
    tweets.map { |t| { :from_user => t.from_user, :text => t.text } }
  end

  def show_sections
    Settings['sections'].size != 1
  end
  
  def sections
    Settings['sections'].map do |s|
      class_name = s == session[:current_section] ? 'selected' : ''
      '<li class="%s"><a href="/section/%s">%s</li>' % [class_name, s, s]
    end.join("\n")
  end
end

get '/' do
  session[:last_tweet_id] = nil
  session[:current_section] = Settings['sections'].first
  mustache :index, :locals => { :sections => sections, :show_sections => show_sections }
end

get '/section/:section' do
  session[:last_tweet_id] = nil
  session[:current_section] = params[:section]
  mustache :index, :locals => { :sections => sections, :show_sections => show_sections }
end

get '/updates.json' do
  start_server_if_required
  tweets.to_json
end

get '/stylesheets/screen.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
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
    {{{ yield }}}
  </body>
</html>

@@index
<ul id="updates"><li></li></ul>
{{#show_sections}}
  <ul id="sections">{{{ sections }}}</ul>
{{/show_sections}}

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

#sections
  :position absolute
  :top 0
  :background-color #ffc
  :color #333
  :margin 10px
  :padding 10px
  :list-style-type none
  :opacity 0.8

#sections a
  :color #333
  :width 100%
  :display block
  :font-size 22px
  :text-decoration none

#sections a:hover
  :background #fff
  :color #111

#sections li.selected a
  :color #990000
