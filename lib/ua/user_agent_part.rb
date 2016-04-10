# Represents a part or segment of a User-Agent string.
#
#   Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36
#
# The first UserAgentPart would have the following attribute values:
#
#   value: 'Mozilla/5.0', name: 'Mozilla', version: '5.0', paren: 'Macintosh; Intel Mac OS X 10_11_4'
#
# While the last part would have the following attribute values:
#
#   value: 'Safari/537.36', name: 'Safari', version: '537.36', paren: nil

class UserAgentPart
  attr_accessor :value, :version, :name, :paren

  def initialize(val, paren, name, version)
    @value = val
    @paren = paren
    @name = name
    @version = version
  end

  def to_s
    s =  "#{@value}"
    s += " (#{@paren})" unless @parent.nil?
    s
  end

end
