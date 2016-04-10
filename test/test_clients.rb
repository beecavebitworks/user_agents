require 'minitest/autorun'
require 'user_agents'
require 'user_agent_samples.rb'

class UserAgentClientsTest < Minitest::Test


  def test_clients
    details = UserAgentDetails.new(SAMPLE_WIN1)
    UserAgentClients.extract details
    assert_equal :firefox, details.client.sym
    assert_equal '35.0', details.client.version

    details = UserAgentDetails.new(SAMPLE_OSX1)
    assert UserAgentClients.extract(details), "Should return true on success"

    assert_equal :chrome, details.client.sym

    details = UserAgentDetails.new(SAMPLE_IPAD_FACEBOOK)
    UserAgentClients.extract details
    assert_equal :webkit, details.client.sym

  end

  def test_unknowns
    details = UserAgentDetails.new(SAMPLE_GOOGLE_BOT5)
    assert_equal false, UserAgentClients.extract(details), "should return false when unknown"
    assert details.client.nil?

    details = UserAgentDetails.new(SAMPLE_CUSTOM1)
    UserAgentClients.extract(details)
    assert details.client.nil?
  end
end
