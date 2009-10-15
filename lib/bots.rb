class Gobbler::Bots
  attr_reader :bots

  def initialize
    @bots = {}
  end

  def start
    init_bots
    run_update_loop
  end

  def stop
    Gobbler.logger.info "Stopping bots"
    DRb.stop_service
    exit
  end

  def run_update_loop
    DRb.start_service nil, self
    Gobbler::Daemon.write_drb_handle DRb.uri
    Thread.new do
      while true do
        begin
          get_updates
        rescue => exception
          Gobbler.logger.error "Exception in main Bots loop thread: #{exception}"
        end

        sleep 5
      end
    end
    DRb.thread.join
  end

  def init_bots
    Settings['sections'].each do |section|
      @bots[section] = init_bot section
    end
  end

  def init_bot(query)
    Gobbler::Bot.new query
  end

  def alive
    "I'm alive"
  end

  def bot_names
    @bots.collect do |query, bot|
      query
    end
  end

  def get_updates
    results = {}
    @bots.each do |query, bot|
      results[query] = bot.new_tweets
    end
    results
  end

  def tweets_since(tweet_id, section = nil)
    if section
      tweets_since_for_section tweet_id, section
    else
      all_tweets_since tweet_id
    end
  end

  def all_tweets_since(tweet_id)
    @bots.collect do |query, bot|
      bot.tweets_since(tweet_id)
    end
  end

  def tweets_since_for_section(tweet_id, section = nil)
    @bots[section].tweets_since tweet_id
  end
end
