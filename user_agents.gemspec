Gem::Specification.new do |s|
  s.name        = 'user_agents'
  s.version     = '0.5.2'
  s.date        = '2016-04-09'
  s.summary     = "A lightweight gem for parsing and searching browser User-Agent strings"
  s.description = "The goal is to provide a utility to quickly parse User-Agent strings and determine browser, platform, and operating system versions for the most popular http clients with a miminum of regex."
  s.authors     = ["Alex Malone"]
  s.email       = 'originalsix@bluesand.org'
  s.files       = ["lib/user_agents.rb", "lib/ua/user_agent_details.rb", "lib/ua/user_agent_platforms.rb", "lib/ua/user_agent_part.rb", "lib/ua/user_agent_platform.rb", "lib/ua/user_agent_paren.rb", "lib/ua/user_agent_client.rb", "lib/ua/user_agent_clients.rb" ]
  s.homepage    =
    'https://github.com/beecavebitworks/user_agents'
  s.license       = 'Apache 2.0'
end
