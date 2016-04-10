require 'minitest/autorun'
require 'user_agents'
require 'user_agent_samples'

class UserAgentsTest < Minitest::Test

  def test_basic_details
    details = UserAgentDetails.new(SAMPLE_WIN1)
    assert_equal 3, details.parts.length
    assert_equal nil, details.platform

    moz = details.parts[0]
    assert_equal 'Mozilla', moz.name
    assert_equal '5.0', moz.version
    assert_equal 'Mozilla/5.0', moz.value
    assert_equal false, moz.paren.nil?

    firefox = details.parts.last
    assert_equal 'Firefox', firefox.name
    assert_equal '35.0', firefox.version
    assert firefox.paren.nil?
  end

  def test_has
    details = UserAgentDetails.new(SAMPLE_WIN1)
    assert details.has? 'Firefox'
    assert_equal false, details.has?('firefox')
    assert details.ihas? 'firefox'

    assert_equal false, details.has?('Chrome')
    assert_equal false, details.ihas?('20100101')
  end

  def test_get
    details = UserAgentDetails.new(SAMPLE_OSX1)
    assert_equal 4, details.parts.length

    part = details.get('Chrome')
    assert part.name == 'Chrome'
    assert part.version == '49.0.2623.110'

    part = details.get('blah')
    assert part.nil?

    assert details.get(nil).nil?
  end

  def test_spaced_part
    details = UserAgentDetails.new(SAMPLE_ANDROID_1)

    part = details.get('Mobile Safari')
    assert part.version == '533.1'
  end

  #
  def test_spaced_part2
    details = UserAgentDetails.new(SAMPLE_MULTI_FIRST)

    part = details.get('iBrowser')
    assert part.version == '3.0/Mozilla/5.0'
  end

end