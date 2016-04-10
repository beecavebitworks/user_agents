require 'minitest/autorun'
require 'user_agents'
require 'user_agent_samples.rb'

class UserAgentPlatformsTest < Minitest::Test


  def test_os
    details = UserAgentDetails.new(SAMPLE_WIN1)
    UserAgentPlatforms.extract details
    assert_equal :win, details.platform.sym
    assert_equal :win_8_1, details.platform.os_release

    details = UserAgentDetails.new(SAMPLE_OSX1)
    UserAgentPlatforms.extract details
    assert_equal :osx, details.platform.sym
    assert_equal '10.11.4', details.platform.os_version
  end

  def test_no_win_release
    details = UserAgentDetails.new(SAMPLE_WIN2)
    UserAgentPlatforms.extract details
    assert_equal :win, details.platform.sym
    assert_equal nil, details.platform.os_release
  end

  def test_android
    details = UserAgentDetails.new(SAMPLE_ANDROID_1)
    UserAgentPlatforms.extract details
    assert_equal :linux, details.platform.sym
    assert_equal :android, details.platform.os_release
    assert_equal '2.3.3', details.platform.os_version
  end

  def test_ubuntu
    details = UserAgentDetails.new(SAMPLE_UBUNTU)
    UserAgentPlatforms.extract details
    assert_equal :linux, details.platform.sym
    assert_equal :ubuntu, details.platform.os_release
    assert_equal '10.10', details.platform.os_version
  end

  def test_iphone
    details = UserAgentDetails.new(SAMPLE_IPHONE1)
    UserAgentPlatforms.extract details
    assert_equal :ios, details.platform.sym
    assert_equal :iphone, details.platform.device_type
    assert_equal '7.1.2', details.platform.os_version
  end

  def test_facebook_app
    details = UserAgentDetails.new(SAMPLE_IPAD_FACEBOOK2)
    UserAgentPlatforms.extract details
    assert_equal :ios, details.platform.sym
    assert_equal '8.4.1', details.platform.os_version
    assert details.parts.last.value.start_with? '[FBAN/FBIOS;FBAV/38.0.0.6.79'
    assert details.has?'FBAN'
  end

  def test_no_part_version
    details = UserAgentDetails.new(SAMPLE_AMAZON_SILK)
    UserAgentPlatforms.extract details
    assert_equal :osx, details.platform.sym
    assert_equal '10.6.3', details.platform.os_version

    assert_equal 'Silk-Accelerated=true',details.parts.last.name
    assert_equal nil,details.parts.last.version
  end

end