require 'socket'

module MC
  autoload :Request, 'mc/request'
  autoload :HandshakeRequest, 'mc/request'
  autoload :Parser, 'mc/parser'

  class Connection
    attr_reader :socket

    def initialize(io)
      self.socket = io
    end

    def close!
      @socket.close if @socket
    end

    def socket=(io)
      @socket = io
      @parser = Parser.new(@socket)
    end

    def process_packets(&block)
      @parser.process(&block)
    end

    def send_packet(packet)
      payload = packet.serialize
      MC.logger.debug("Sent #{payload.inspect}")
      @socket.write(payload)
      @socket.flush
    end
  end
end
