$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/response_validator'
require 'puppet/provider/waitfor'

Puppet::Type.type(:wait_for_response).provide(:ruby, :parent => Puppet::Provider::WaitFor) do
  desc 'A provider for the resource type "wait_for_connection" which attemps to create the connection via. the socket package.'

  def trigger
    start_time = Time.now
    timeout = resource[:timeout]

    connected = validator.attempt_connection

    while connected == false && ((Time.now - start_time) < timeout)
      Puppet.notice('Failed to validate response of %{uri}. Retry in %{sleep} seconds.' % {
        uri: resource[:uri],
        sleep: resource[:retry_sleep]
      })
      sleep resource[:retry_sleep]

      connected = validator.attempt_connection
    end

    unless connected
      Puppet.notice('Failed to validate response of %{uri} in %{timeout} seconds, giving up' % {
        uri: resource[:uri],
        timeout: resource[:timeout]
      })
    end

    @result = connected
    false
  end

  def validator
    @validator ||= Puppet::Util::ResponseValidator.new(resource[:uri], resource[:expected_status_codes], resource[:expected_json], resource[:expected_keywords])
  end

end
