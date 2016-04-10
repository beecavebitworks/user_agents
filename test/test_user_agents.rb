require 'minitest/autorun'
require 'user_agents'

class UserAgentsTest < Minitest::Test

  SAMPLE_WIN1='Mozilla/5.0 (Windows NT 6.3; rv:39.0) Gecko/20100101 Firefox/35.0'
  SAMPLE_OSX1='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36'
  SAMPLE_ANDROID_1='Mozilla/5.0 (Linux; U; Android 2.3.3; en-fr; HTC/WildfireS/1.33.163.2 Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
  SAMPLE_MULTI_FIRST='iBrowser/3.0/Mozilla/5.0 (Linux; U; Android 2.3.6; yy-yy; Karbonn A2 Build/GRK39F) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'

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
  def test_spaced_part
    details = UserAgentDetails.new(SAMPLE_MULTI_FIRST)

    part = details.get('iBrowser')
    assert part.version == '3.0/Mozilla/5.0'
  end

end