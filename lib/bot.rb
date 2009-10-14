class Gobbler::Bot
  STORAGE_LIMIT = 25

  def initialize(watch, &block)
    @watch = watch
    @tweets = []
    main_loop(block) if block
  end

  def search
    client = TwitterSearch::Client.new 'gobbler'
    client.query :q => @watch, :rpp => '20'
  rescue => exception
    Gobbler.logger.error "Exception in Bot#search for #{@watch}: #{exception}"
    []
  end

  def update
    Gobbler.logger.info "Checking twitter for updates"
    tweets = search.reverse
    tweets.delete_if { |t| t.id < @last_tweet.id or t.id == @last_tweet.id } if @last_tweet
    @last_tweet = tweets.last if tweets.length > 0

    @tweets += tweets.clone
    @tweets.slice!(0, @tweets.size - STORAGE_LIMIT) if @tweets.size > STORAGE_LIMIT

    Gobbler.logger.info "Update found #{tweets.length} tweets.  @tweets now has #{@tweets.length} items"

    tweets
  rescue => exception
    Gobbler.logger.error "Exception in Bot#update for #{@watch}: #{exception}"
    []
  rescue Exception => exception
    Gobbler.logger.error "Fatal exception in Bot#update for #{@watch}: #{exception}"
    exit 99
  end

  def new_tweets
    update
  end

  def tweets_since(tweet_id)
    if tweet_id
      @tweets.reject { |t| t.id <= tweet_id }
    else
      @tweets
    end
  end

  def main_loop(block)
    while true
      tweets = new_tweets
      block.call(tweets) if tweets.length > 0
      sleep 5
    end
  end
end
