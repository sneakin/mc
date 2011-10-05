require 'active_support/core_ext'
require 'logger'

module MC
  Version = 17

  def self.logger
    @logger ||= Logger.new($stderr, Logger::DEBUG)
  end
end

require 'mc/session'
require 'mc/packet'
require 'mc/request'
require 'mc/client'

