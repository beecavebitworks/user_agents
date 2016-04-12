#-----------------------------------------------------------------------------
# Given the platform string, return hash containing extracted
#   { :plaform, :os_release, :os_version }
#
# Caller should use UserAgentDetails.parse_simple to isolate platform_string
#
# Examples:
#  "Windows NT 6.3; rv:39.0"
#
#     {platform: :win, release: :win_8_1, version: '8.1'  }
#
#  "Macintosh; Intel Mac OS X 10_11_4"
#
#     {platform: :osx, release: :el_capitan, version: '10.11.4'  }
#
#  "Linux; U; Android 2.2; en-sa; HTC_DesireHD_A9191 Build/FRF91"
#
#     {platform: :linux, release: :android, version: '2.2', lang: 'en-sa', sec:'U'}
#
#-----------------------------------------------------------------------------
class UserAgentPlatforms


  def self.extract(details)

    platform_sym = _platform_type(details)
    return false if platform_sym.nil?

    platform = UserAgentPlatform.new (platform_sym)

    details.platform = platform

    _get_platform_details platform, details
  end

  #---------------------------------------------------------------
  # returns nil or symbol for platform
  # :win, :linux, :ios, :osx
  #---------------------------------------------------------------
  def self._platform_type(details)

    str = details.lowercase
    if str.include?('windows') || str.include?('win32')
      return :win

    elsif str.include? 'linux'
      return :linux

    elsif str.include?('iphone') || str.include?('ipad')
      return :ios

    elsif str.include? 'mac os x'
      return :osx
    end

    return nil
  end

  def self._get_platform_details(platform, details)
    case platform.sym
      when :win
        _get_windows_attrs(platform, details)
      when :osx
        _get_osx_attrs(platform, details)
      when :linux
        _get_linux_attrs(platform, details)
      when :ios
        _get_ios_attrs(platform, details)
      else
    end
  end

  #-----------------------------------------------------------------
  # sets platform.os_release to appropriate symbol (e.g.  :win_95, :win_8_1, :win_10, :win_2000 )
  #-----------------------------------------------------------------
  def self._get_windows_attrs(platform, details)
    paren = details.parts[0].paren
    unless paren.nil?

      paren.parts.each {|str|
        next if str.length <= 5

        sym = _extract_windows_version(str)
        next if sym.nil?

        platform.os_release = sym
        break
      }
    end
  end

  #-----------------------------------------------------------------
  # sets platform.os_release = :osx
  # sets platform.os_version = (format like '10.11.4')
  #-----------------------------------------------------------------
  def self._get_osx_attrs(platform, details)
    platform.os_release = :osx
    paren = details.parts[0].paren
    unless paren.nil?

      # expect first paren to be like 'Macintosh;U;Intel Mac OS X 10_11_4;en-us'

      paren.parts.each {|str|
        next if str.length <= 5

        if str.include? 'Mac OS X'

          tmp = str.split(' ')

          osx_version = tmp.last.gsub('_','.')   # 10_11_4 -> 10.11.4

          platform.os_version = osx_version

          break
        end
      }
    end
  end

  #-----------------------------------------------------------------
  # sets platform.os_version   (format like '8.3')
  # platform.device_type :ipod, :ipad, :iphone
  #-----------------------------------------------------------------
  def self._get_ios_attrs(platform, details)
    paren = details.parts[0].paren
    unless paren.nil?

      # expect first paren to be like 'iPad; CPU iPhone OS 8_3 like Mac OS X'

      i=-1
      paren.parts.each {|str|
        i += 1

        if i == 0
          platform.device_type = str.downcase.to_sym if str.start_with?('iP')
          next
        end

        next if str.length <= 5

        pos = str.index ' like Mac'
        next if pos.nil?

        tmp = str[4..pos-1]
        next if tmp.nil?

        ver = tmp.strip.split(' ').last
        ver = ver.gsub('_','.')   # 10_11_4 -> 10.11.4

        platform.os_version = ver
        break
      }
    end
  end

  LINUX_FLAVOR_NAMES = ['Android','Ubuntu','Debian','CentOS','Suse']

  #-----------------------------------------------------------------
  # sets platform.os_release (e.g. :ubuntu) and platform.os_version   (format like '10.11.4')
  #-----------------------------------------------------------------
  def self._get_linux_attrs(platform, details)

    LINUX_FLAVOR_NAMES.each {|flavor|
      part = details.get(flavor)
      unless part.nil?
        platform.os_release = flavor.downcase.to_sym
        platform.os_version = part.version
        return
      end
    }

    # check start paren

    paren = details.parts[0].paren
    unless paren.nil?

      # expect first paren to be like 'Macintosh;U;Intel Mac OS X 10_11_4;en-us'

      paren.parts.each {|str|
        next if str.length <= 5

        LINUX_FLAVOR_NAMES.each {|flavor|

          if str.include? flavor
            platform.os_release = flavor.downcase.to_sym
            tmp = str.split(' ')
            platform.os_version = tmp.last
            break
          end
        }

        break unless platform.os_release.nil?
      }
    end
  end

  def self.extract_str(platform_str)

    str = platform_str.downcase

    platform=nil

    if str.include?('windows') || str.include?('win32')
      platform = :win

    elsif str.include? 'linux'
      platform = :linux

    elsif str.include?('iphone') || str.include?('ipad')
      platform = :ios

    elsif str.include? 'mac os x'
      platform = :osx
    end

    parts = platform_str.split(';')

    obj = {platform: platform}

    parts.each {|raw_part|
      part = raw_part.trim
      if part.length == 1
        obj[:sec] = part
      elsif part.length <= 5 && part.include?('-')
        obj[:lang] = part
      else
        vals = nil

        if platform == :win
          vals=self.extract_windows_version(part)
        elsif platform == :osx
          vals=self.extract_osx_version(part)
        elsif platform == :linux
          vals=self.extract_linux_version(part)
        end

        unless vals.nil?
          obj[:release] = vals[0]
          obj[:version] = vals[1]
        end
      end
    }

    obj
  end

  #-------------------------------------------------------------------
  # Caller needs to provide lowercase name
  # Examples:
  #   'windows nt 6.3'  -->  :win_8_1
  #-------------------------------------------------------------------
  def self._extract_windows_version(name)

    return :win_95 if name.include? 'windows 95'

    return :win_98 if name.include? 'windows 98'

    sym = nil

    if name.downcase.include? 'windows nt '
      tmp = name.split(' ')
      verstr = tmp.last

      return :win_nt if verstr.start_with? '4'

      sym = case verstr
        when '5.0'
          :win_2000
        when '5.1'
          :win_xp
        when '5.2'
          :win_2003
        when '6.0'
          :win_vista   # or Server 2008
        when '6.1'
          :win_7       # Server 2008 R2
        when '6.2'
          :win_8       # Server 2012
        when '6.3'
          :win_8_1     # Server 2012 R2
        when '10.0'
          :win_10
        else
          nil
      end
    end

    sym
  end

  def self.extract_windows_version_regex(name)
    case (name.downcase)
      when /windows 95/
        fp[:os_name] = 'Windows 95'
        fp[:os_release] = :os_win_95
      when /windows 98/
        fp[:os_name] = 'Windows 98'
        fp[:os_release] = :os_win_98
      when /windows nt 4/
        fp[:os_name] = 'Windows NT'
        fp[:os_release] = :os_win_nt
      when /windows nt 5.0/
        fp[:os_name] = 'Windows 2000'
        fp[:os_release] = :os_win_2000
      when /windows nt 5.1/
        fp[:os_name] = 'Windows XP'
        fp[:os_release] = :os_win_xp
      when /windows nt 5.2/
        fp[:os_name] = 'Windows 2003'
        fp[:os_release] = :os_win_2003
      when /windows nt 6.0/
        fp[:os_name] = 'Windows Vista'
        fp[:os_release] = :os_win_vista
      when /windows nt 6.1/
        fp[:os_name] = 'Windows 7'
        fp[:os_release] = :os_win_7
      when /windows nt 6.2/
        fp[:os_name] = 'Windows 8'
        fp[:os_release] = :os_win_8
      when /windows nt 6.3/
        fp[:os_name] = 'Windows 8.1'
        fp[:os_release] = :os_win_8_1
    end

  end

  def self.extract_linux_version(raw_name)
    name = raw_name.downcase

    if name.include? 'gentoo'
      return ['Gentoo']
    end
    case name
      when /gentoo/
        return ['Gentoo', nil]
      when /debian/
        fp[:os_vendor] = 'Debian'
      when /ubuntu/
        fp[:os_vendor] = 'Ubuntu'
      when /fedora/
        fp[:os_vendor] = 'Fedora'
      when /red hat|rhel/
        fp[:os_vendor] = 'RHEL'
      when /android/
        fp[:os_name] = OperatingSystems::ANDROID
    end

  end

  def self.extract_linux_version_regex(name)

    case name.downcase
      when /gentoo/
        return ['Gentoo', nil]
      when /debian/
        fp[:os_vendor] = 'Debian'
      when /ubuntu/
        fp[:os_vendor] = 'Ubuntu'
      when /fedora/
        fp[:os_vendor] = 'Fedora'
      when /red hat|rhel/
        fp[:os_vendor] = 'RHEL'
      when /android/
        fp[:os_name] = OperatingSystems::ANDROID
    end
  end
end

if $0 == __FILE__
  require './ua/user_agent_paren.rb'
  require './ua/user_agent_details.rb'
  require './ua/user_agent_platform.rb'
  require './ua/user_agent_part.rb'

  SAMPLE_WIN1='Mozilla/5.0 (Windows NT 6.3; rv:39.0) Gecko/20100101 Firefox/35.0'
  details = UserAgentDetails.new(SAMPLE_WIN1)
  UserAgentPlatforms.extract details

end
