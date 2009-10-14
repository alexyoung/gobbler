require 'test_helper'

def mock_drb_file_handling
  Gobbler.stubs(:current_drb_handle).returns('test_file')
  File.stubs('exists?').returns(true)
  File.stubs(:read).returns('druby://blah:9999')
  File.stubs(:delete).returns(true)
end

def mock_launch_daemon
  Gobbler::Daemon.stubs(:sleep).returns(true)
  Gobbler::Daemon.stubs(:install_at_exit_handler).returns(true)
  Gobbler::Daemon.expects(:system).with(Gobbler::Daemon::SERVER_COMMAND)
end

context 'Daemon' do

  context 'launching the daemon' do
    setup do
      mock_drb_file_handling
    end

    asserts 'launching the daemon calls system' do
      mock_launch_daemon.returns(true)
      Gobbler::Daemon.launch_daemon
    end

    asserts 'launching the daemon fails' do
      mock_launch_daemon.returns(false)
      Gobbler.expects(:logger).returns(mock :error => true)
      Gobbler::Daemon.launch_daemon
    end.nil?

    asserts('drb handle is expected value') { Gobbler::Daemon.current_drb_handle }.equals('druby://blah:9999')
  end

  context 'context stopping the daemon' do
    setup do
      mock_drb_file_handling
    end

    asserts 'stopping the daemon calls @server stop' do
      server = mock :alive => true
      server.expects :stop
      Gobbler::Daemon.expects(:connect_to_drb).returns(true)
      Gobbler::Daemon.instance_variable_set('@server', server)
      Gobbler::Daemon.stop
    end
 end

end

