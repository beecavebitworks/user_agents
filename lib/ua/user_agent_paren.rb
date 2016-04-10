
class UserAgentParen
  attr_reader :value

  def initialize value
    @value = value
    @parts = nil
  end

  def parts
    return nil if @value.nil?
    return @parts unless @parts.nil?

    # first request, let's build parts now

    @parts=[]
    @value.split(';').each {|str| @parts.push str.strip }
    @parts
  end

end