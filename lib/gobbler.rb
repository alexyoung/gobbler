require 'rubygems'
require 'yaml'
require 'twitter_search'
require 'drb'
require 'fileutils'
require 'logger'
require 'timeout'

class String
  def /(other)
    File.join(self, other)
  end
end

module Gobbler
  LOG_DIR = File.dirname(__FILE__) / '..' / 'log'

  def self.logger
    @logger ||= enable_logging
  end

  def self.logger=(logger)
    @logger.close if @logger
    @logger = logger
  end

  def self.enable_logging
    FileUtils.mkdir_p LOG_DIR
    Logger.new(LOG_DIR / 'twitter-bot.log')
  rescue => exception
    puts "Error opening log file: #{exception}"
    Logger.new STDOUT
  end
end

require File.join(File.dirname(__FILE__), 'settings')
require File.join(File.dirname(__FILE__), 'bot')
require File.join(File.dirname(__FILE__), 'bots')
require File.join(File.dirname(__FILE__), 'daemon')
