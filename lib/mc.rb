require 'active_support/core_ext'
require 'logger'

module MC
  Version = 17

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stderr, Logger::DEBUG)
    end
  end
end

require 'mc/session'
require 'mc/faces'
require 'mc/packet'
require 'mc/request'
require 'mc/client'
