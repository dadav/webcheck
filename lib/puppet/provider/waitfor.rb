require 'puppet/provider'

class Puppet::Provider::WaitFor < Puppet::Provider
  def exists?
    if resource[:refreshonly] == true
      return true
    end
    trigger
  end

  def create
    if @result == false
      raise Puppet::Error, @validator.failed_message
    end
    true
  end
end
