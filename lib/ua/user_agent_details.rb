# A class that provides parsed access to User-Agent strings
#
#

class UserAgentDetails

  attr_accessor :parts, :map, :platform, :client

  #---------------------------------------------------------------
  # Parses and initializes parts, map.  platform and client will be nil
  #---------------------------------------------------------------
  def initialize(str)

    @raw_string = str
    @lower_string = str.downcase

    _parse_and_map

  end

  def raw
    @raw_string
  end

  def lowercase
    @lower_string
  end

  #---------------------------------------------------------------
  # get a part by name
  #---------------------------------------------------------------
  def get name
    @map[name]
  end

  #---------------------------------------------------------------
  # get a part or attribute by name
  #---------------------------------------------------------------
  def get_paren_containing name
    @parts.each {|part|
      next if part.paren.nil?

      part.paren.parts.each {|p|
        return p if p.include? name
      }
    }
    nil
  end

  #---------------------------------------------------------------
  # return true if a part.name == name
  #---------------------------------------------------------------
  def has? name
    @map.has_key?(name)
  end

  #---------------------------------------------------------------
  # return true if a part.name.downcase = raw_name.downcase
  #---------------------------------------------------------------
  def ihas? raw_name
    name = raw_name.downcase
    @map.each_key {|key|
      return true if key.downcase == name
    }
    false
  end

  #---------------------------------------------------------------
  # Format: "User-Agent:<raw string from initialize>"
  #---------------------------------------------------------------
  def to_s
    "User-Agent:#{@raw_string}"
  end

  #---------------------------------------------------------------
  # static parse_simple(str)
  #
  # returns array of segments
  # [
  #   { value: 'Mozilla/5.0', name: 'Mozilla', version: '5.0', paren: '(Macintosh; Intel Mac OS X 10_11_4)' },
  #   { value: 'AppleWebKit/537.36', name: 'AppleWebKit', version: '537.36', paren: '(Windows NT 6.3; rv:39.0)' },
  #   { value: 'Chrome/49.0.2623.110', name: 'Chrome', version:'49.0.2623.110', paren:nil},
  #   { value: 'Safari/537.36', name: 'Safari', version: '537.36', paren:nil}
  # ]
  #---------------------------------------------------------------
  def self.parse_simple(str)
    parts=[]
    start=0
    while true
      if parts.length > 2 && str[start] == '['
        # handle strange facebook ending
        # 'Mozilla/5.0 (iPhone; CPU iPhone OS 8_4_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12H321 [FBAN/FBIOS;FBAV/38.0.0.6.79;FBBV/14316658;FBDV/iPhone7,1;FBMD/iPhone;FBSN/iPhone OS;FBSV/8.4.1;FBSS/3; FBCR/AT&T;FBID/phone;FBLC/en_US;FBOP/5]'

        pos = str.index(']', start)
        val = str[start..pos]
        parts.push(self._new_ua_part(val, nil)) unless val.nil? || val.length == 0
        break
      end
      pos = str.index('/', start)                   # sometimes have part names including space.  look for slash
      pos = str.index(' ', pos) unless pos.nil?
      if pos.nil?
        val = str[start..-1]
        parts.push(self._new_ua_part(val, nil)) unless val.nil? || val.length == 0
        break
      end

      val = str[start..pos]

      # now check for parenthesis (..stuff..)

      paren_val = nil
      start = pos + 1
      if str.length > start && str[start] == '('
        pos = str.index(')', start)
        paren_val = str[start+1..pos-1]
        start = pos + 2
      end

      # add to list
      parts.push(self._new_ua_part(val, paren_val))
    end
    parts
  end

  private

  #---------------------------------------------------------------
  # populates @parts and @map from @raw_string
  # Calls parse_simple()
  # returns none
  #---------------------------------------------------------------
  def _parse_and_map
    @parts = UserAgentDetails.parse_simple(@raw_string)
    @map = {}

    @parts.each {|item|

      @map[item.name] = item
    }
  end

  #---------------------------------------------------------------
  # initializes and returns a new UserAgentPart instance
  #---------------------------------------------------------------
  def self._new_ua_part(val, paren_val)

    val.strip!

    if val[0] == '['          # special case courtesy of facebook
      pos = val.index('/')
      name = val[1..pos-1]
      return UserAgentPart.new(val, nil, name, nil )
    end

    tmp = val.split('/',2)

    paren = nil
    unless paren_val.nil?
      paren = UserAgentParen.new paren_val
    end

    UserAgentPart.new(val, paren, tmp[0], tmp[1] )
  end

end

