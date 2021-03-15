require 'socket'

class Puppet::Util::ConnectionValidator
  attr_reader :host
  attr_reader :port

  def initialize(host, port)
    @host = host
    @port = port
  end

  def attempt_connection
    begin
      _conn = TCPSocket.new host, port
      _conn.close()
      true
    rescue StandardError => e
      Puppet.debug("Could not connect to #{host}:#{port}")
      false
    end
  end
end
