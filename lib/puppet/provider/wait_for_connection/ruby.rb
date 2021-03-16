$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/connection_validator'
require 'puppet/provider/waitfor'

Puppet::Type.type(:wait_for_connection).provide(:ruby, :parent => Puppet::Provider::WaitFor) do
  desc 'A provider for the resource type "wait_for_connection" which attemps to create the connection via. the socket package.'

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

    @result = connected
    false
  end

  def validator
    @validator ||= Puppet::Util::ConnectionValidator.new(resource[:host], resource[:port])
  end
end
