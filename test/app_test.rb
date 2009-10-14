require 'test_helper'
require 'rack/test'
require 'app'

# TODO: these lines should be in Riot::Context, but this isn't working
def app; @app; end
def session ; last_request.env['rack.session'] ; end
include Rack::Test::Methods

context 'Web App' do
  setup { @app = Sinatra::Application }

  context '/' do
    setup { get '/' }
    asserts_response_status 200
    asserts('last_tweet_id is nil') { session[:last_tweet_id] }.nil
  end

  context '/updates.json' do
    setup do
      tweets = [{ 'from_user' => '@alex_young',
                  'text'      => 'This is a message' }]
      Sinatra::Application.any_instance.expects(:start_server_if_required).returns true
      Sinatra::Application.any_instance.expects(:tweets).returns(tweets)
      get '/updates.json'
    end
    asserts_response_status 200
  end
end
