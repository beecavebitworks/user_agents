class UserAgentClient
  attr_accessor :sym                      # :safari, :firefox, :chrome, :silk, etc.

  attr_accessor :version                  # e.g. '10.11.3'

  def initialize(sym, ver)
    @sym = sym
    @version = ver
  end
end