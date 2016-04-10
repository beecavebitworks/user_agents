# user_agents
A lightweight ruby gem to parse and search browser User-Agent strings.
There are three top-level classes:

#### UserAgentDetails
  Parses the string and provides access to parts (UserAgentPart array)

#### UserAgentPlatforms
  (Optional) Extract platform and operating system information from the UserAgentDetails object

#### UserAgentClients
  (Optional) Extracts client (e.g. browser) details from the UserAgentDetails object

#### Basic Usage:
<pre><code>

details = UserAgentDetails.new('Mozilla/5.0 (X11; U; Linux i686; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Ubuntu/10.10 Chromium/10.0.648.133 Chrome/10.0.648.133 Safari/534.16')

 # parts is an array of UserAgentPart type

    safari = details.parts.last
    safari.name == 'Safari'
    safari.version == '534.16'
    
    details.parts[0].paren.parts[0] == 'X11'

 # get and has? access a map of parts
 
    details.has?('Chromium')  == true
    chromium = details.get 'Chromium'
    chromium.version == '10.0.648.133'

 # extract platform details

    UserAgentPlatforms.extract details
    
    details.platform.sym == :linux
    details.platform.os_release == :ubuntu
    details.platform.os_version == '10.10'

 # extract client details
 
    UserAgentClients.extract details

    details.client.sym     == :chrome                 # will be nil if unknown
    details.client.version == '10.0.648.133'
    
</code></pre>

#### Dealing with versions

I suggest using 'version_compare' gem (https://github.com/pdobb/version_compare).

Example:
  If I have a part with version '600.1.4', I could compare like so:

<pre><code>
Version.new(part.version) <= Version.new('600.1.3') # false
Version.new(part.version) <= Version.new('600.1.5') # true
Version.new(part.version) > Version.new('600.2')    # false
Version.new(part.version) == Version.new('600.1.4') # true
</code></pre>
