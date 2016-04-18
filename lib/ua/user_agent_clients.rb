class UserAgentClients

  # Chrome tries to look like Safari, so check it first

  COMMON_BROWSERS=['Edge','Chrome','Safari','Firefox','Opera','MSIE','AdobeAIR'].freeze

  # Try to determine client (e.g. browser) making request
  # @param details [UserAgentDetails]
  # @return true on success, false otherwise
  def self.extract(details)


    COMMON_BROWSERS.each {|name|

      part = details.get(name)
      unless part.nil?
        details.client = UserAgentClient.new(name.downcase.to_sym, part.version)

        if (name == 'Safari')
          v = details.get('Version')
          details.client.version = v.version unless v.nil?
        end

        return true
      end
    }


    part = details.get('AppleWebKit')
    unless part.nil?
      details.client = UserAgentClient.new(:webkit, part.version)
      return true
    end

    part = details.get('Trident')
    unless part.nil?
      paren = details.parts[0].paren
      v=nil
      paren.parts.each {|part|
        if part.start_with?('rv:')
          tmp,v=part.split(':',2)
        end
      }

      details.client = UserAgentClient.new(:msie, v)
      return true
    end

    return false
  end

end
