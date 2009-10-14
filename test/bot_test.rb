require 'test_helper'

context 'Twitter Bot' do

  context 'Search results are available' do
    setup do
      mock_query('example', 'example.json')
    end

    asserts('returns tweets') { topic.new_tweets }.any?
  end

  context 'Search results are not available' do
    setup do
      mock_query('example', 'empty.json')
    end

    asserts('returns array') { topic.new_tweets }.empty?
  end

  context 'Fetches updates "since" ID' do
    setup do
      mock_query('example', 'example.json')
    end

    asserts('returns expected messages') { topic.update ; topic.tweets_since(4781718128) }.any?
  end

end
