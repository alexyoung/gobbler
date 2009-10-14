%w(rubygems riot fakeweb mocha rack/test).each do |lib|
  require lib
end
require 'lib/gobbler'
require 'riot_macros'

# TODO: This should be in Riot::Context
include Mocha::API

class File
  def self.here
    dirname(__FILE__)
  end
end

def fake_query(query, file_name)
  sanitized_query = TwitterSearch::Client.new.sanitize_query query
  uri = "#{TwitterSearch::Client::TWITTER_SEARCH_API_URL}?#{sanitized_query}&rpp=20"
  FakeWeb.register_uri(:get, uri, :response => File.here / 'fixtures' / 'twitter' / file_name)
end

def mock_query(query, json_file)
  query = { :q => query }
  fake_query query, json_file
  Gobbler::Bot.new query[:q]
end

Gobbler.logger = Logger.new STDOUT
Gobbler.logger.level = Logger::WARN
FakeWeb.allow_net_connect = false
