require 'socket'
require 'json'
require 'uri'

class Puppet::Util::ResponseValidator
  attr_reader :uri
  attr_reader :expected_status_codes
  attr_reader :expected_json
  attr_reader :expected_keywords
  attr_reader :headers

  def initialize(uri, expected_status_codes, expected_json, expected_keywords)
    @uri = uri
    @expected_status_codes = expected_status_codes
    @expected_json = expected_json
    @expected_keywords = expected_keywords
    @headers    = { 'Accept' => 'application/json' }
  end

  def log_error(cause, code = nil)
    if code.nil?
      Puppet.notice "Unable to connect to #{uri} (#{cause})"
    else
      Puppet.notice "Unable to connect to #{uri} ([#{code}]: #{cause})"
    end
  end

  def check_response(data)
    unless expected_status_codes.nil? || expected_status_codes.empty?
      return false unless expected_status_codes.include?(data.code.to_i)
    end
    unless expected_json.nil? || expected_json.empty?
      parsed_json = JSON.parse(data.body)
      return false unless expected_json <= parsed_json
    end
    unless expected_keywords.nil? || expected_keywords.empty?
      return false unless expected_keywords.map { |keyword| data.body.include?(keyword)}.all?
    end
    true
  end

  def valid_connection_new_client?
    test_uri = URI(uri)
    begin
      conn = Puppet.runtime[:http]
      _response = conn.get(test_uri, headers: headers)
      check_response(_response)
    rescue Puppet::HTTP::ResponseError => e
      log_error e.message, e.response.code
      false
    end
  end

  def valid_connection_old_client?
    test_uri = URI(uri)
    conn = Puppet::Network::HttpPool.http_instance(test_uri.host, test_uri.port, test_uri.scheme == "http" ? false : true, false)
    response = conn.get(test_uri.path, headers)
    unless response.is_a?(Net::HTTPSuccess)
      log_error(response.msg, response.code)
      return false
    end
    check_response(response)
  end

  def attempt_connection
    if Gem::Version.new(Puppet.version) >= Gem::Version.new('7.0.0')
      valid_connection_new_client?
    else
      valid_connection_old_client?
    end
  end

end
