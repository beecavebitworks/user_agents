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

  def test_safari_version
    details = UserAgentDetails.new(SAMPLE_IOS_931_SAFARI)
    UserAgentPlatforms.extract details
    UserAgentClients.extract details
    assert_equal :ios, details.platform.sym
    assert_equal '9.3.1', details.platform.os_version
    assert_equal :safari, details.client.sym
    assert_equal '9.0', details.client.version

    details = UserAgentDetails.new(SAMPLE_OSX_SAFARI_91)
    UserAgentClients.extract details
    assert_equal :safari, details.client.sym
    assert_equal '9.1', details.client.version
  end

  def test_edge
    details = UserAgentDetails.new(SAMPLE_WIN10_EDGE)
    UserAgentPlatforms.extract details
    UserAgentClients.extract details

    assert_equal :win_10, details.platform.os_release
    assert_equal :edge, details.client.sym
    assert_equal '13.10586', details.client.version
    
  end

end
