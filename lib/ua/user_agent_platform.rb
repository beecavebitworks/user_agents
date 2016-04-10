class UserAgentPlatform
  attr_accessor :sym                      # :linux, :win, :osx, :ios

  attr_accessor :os_release               # :win_8_1  or :android
  attr_accessor :os_version               # '10.11.3'     NOT set for windows
  attr_accessor :device_type              # :iphone, :ipad

#  attr_accessor :os_build

  def initialize(sym)
    @sym = sym
  end
end