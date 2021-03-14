
Puppet::Type.newtype(:wait_for_connection) do
  @doc = "Waits until a socket is available."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:host, namevar: true) do
    desc 'The DNS name or IP address of the server.'
  end

  newparam(:port, namevar: true) do
    desc 'The port that the server should be listening on.'
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
end
