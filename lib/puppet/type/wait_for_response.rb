Puppet::Type.newtype(:wait_for_response) do
  @doc = "Waits until a certain response is received."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:refreshonly) do
    desc 'Only run on refreshs'
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:uri, namevar: true) do
    desc 'The uri to perform a http-get request on.'
  end

  newparam(:expected_status_codes) do
    desc 'A list of status codes which a valid response should have.'
    defaultto [200]
  end

  newparam(:expected_json) do
    desc 'A hash of key/values the reponse should be checked for.'
    defaultto {}
  end

  newparam(:expected_keywords) do
    desc 'A list of keywords the response should be checked for.'
    defaultto []
  end

  newparam(:timeout) do
    desc 'The max. number of seconds to wait for a valid connection.'

    defaultto 10

    validate do |value|
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  newparam(:retry_sleep) do
    desc 'The number of seconds to wait betweet each connection attempt.'

    defaultto 2

    validate do |value|
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  def refresh
    provider.trigger
  end
end
