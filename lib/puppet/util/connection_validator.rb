require 'socket'

class Puppet::Util::ConnectionValidator
  attr_reader :host
  attr_reader :port

  def initialize(host, port)
    @host = host
    @port = port
  end

  def failed_message
    "Unable to connect to the host! (#{host}:#{port})"
  end

  def attempt_connection
    begin
      _conn = TCPSocket.new host, port
      _conn.close()
      true
    rescue StandardError => e
      false
    end
  end
end
