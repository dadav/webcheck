$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/connection_validator'

Puppet::Type.type(:wait_for_connection).provide(:ruby) do
  desc 'A provider for the resource type "wait_for_connection" which attemps to create the connection via. the socket package.'

  def exists?
    if resource[:refreshonly]
      return true
    end
    trigger
  end

  def trigger
    start_time = Time.now
    timeout = resource[:timeout]

    connected = validator.attempt_connection

    while connected == false && ((Time.now - start_time) < timeout)
      Puppet.notice('Failed to connect to %{host}:%{port}. Retry in %{sleep} seconds.' % {
        host: resource[:host],
        port: resource[:port],
        sleep: resource[:retry_sleep]
      })
      sleep resource[:retry_sleep]

      connected = validator.attempt_connection
    end

    unless connected
      Puppet.notice('Failed to connect to %{host}:%{port} in %{timeout} seconds, giving up' % {
        host: resource[:host],
        port: resource[:port],
        timeout: resource[:timeout]
      })
    end

    connected
  end

  def create
    raise Puppet::Error, "Unable to connect to the host! (#{@validator.host}:#{@validator.port})"
  end

  def validator
    @validator ||= Puppet::Util::ConnectionValidator.new(resource[:host], resource[:port])
  end

end
