class File
  def self.here
    expand_path dirname(__FILE__)
  end
end

module Gobbler::Daemon
  TMP_DIR = File.here / '..' / 'tmp'
  DRB_FILE_NAME = TMP_DIR / 'drb-handle'
  SERVER_COMMAND =  "#{File.here / '..' / 'bin' / 'twitter-server'} start &"

  def self.running?
    if current_drb_handle
      connect_to_drb unless server
      server.alive
      true
    else
      false
    end
  rescue DRb::DRbConnError
    false
  end

  def self.start_drb_if_required
    DRb.start_service unless DRb.primary_server
  end

  def self.connect_to_drb
    start_drb_if_required
    @server = DRbObject.new nil, current_drb_handle
  end

  def self.server ; @server ; end

  def self.tweets_since(tweet_id, section = nil)
    server.tweets_since(tweet_id, section)
  end

  def self.write_drb_handle(drb_handle)
    FileUtils.mkdir_p TMP_DIR
    File.open(DRB_FILE_NAME, 'w') do |f|
      puts "Running: #{drb_handle}"
      f.write drb_handle
    end
  end

  def self.current_drb_handle
    if File.exists? DRB_FILE_NAME 
      File.read DRB_FILE_NAME
    end
  end

  def self.remove_drb_handle
    if File.exists? DRB_FILE_NAME 
      File.delete DRB_FILE_NAME
    end
  end

  def self.install_at_exit_handler
    at_exit { stop }
  end

  def self.launch_daemon
    server_launched = system SERVER_COMMAND
    
    sleep 3

    if server_launched
      connect_to_drb
      install_at_exit_handler
      true
    else
      Gobbler.logger.error "bin/twitter-server binary could not be launched"
    end
  end

  def self.start
    return if running?

    start_drb_if_required
    bot_service = Gobbler::Bots.new
    bot_service.start
  end

  def self.stop
    connect_to_drb
    server.stop
    remove_drb_handle
    true
  rescue DRb::DRbConnError
    puts "Server down"
  end
end
