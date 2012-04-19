module MC
  autoload :String16, 'mc/string16'
  autoload :Packet, 'mc/packet'

  MAX_SIGNED_INT = (2 ** 31) - 1
  MAX_INT = (2 ** 32)

  MAX_SIGNED_SHORT = (2 ** 15) - 1
  MAX_SHORT = (2 ** 16)

  class Parser
    def initialize(io)
      @io = io
    end

    def process(limit = 50, &block)
      counter = 0

      begin
        block.call(read_packet)
        counter += 1
        i, o, e = IO.select(nil, [@io], nil, 0)
      end while counter < limit && o.include?(@io)

      counter
    end

    def read_packet
      data = read_byte
      return unless data

      packet = Packet.create(data, self)
      MC.logger.debug("Packet: #{packet.inspect}")
      packet
    end

    def read_string
      String16.deserialize(@io)
    end

    def read_short
      i = @io.read(2).unpack('n')[0]
      i = i - MAX_SHORT if i > MAX_SIGNED_SHORT
      i
    end

    def read_shorts(n)
      @io.read(n * 2).unpack("n#{n}")
    end

    def read_ushort
      s = @io.read(2).unpack('n')[0]
      s = s - (2 ** 16) if s > (2 ** 15)
      s
    end

    def read_long
      i = @io.read(4).unpack('N')[0]
      i = i - MAX_INT if i > MAX_SIGNED_INT
      i
    end

    def read_ulong
      @io.read(4).unpack('N')[0]
    end

    def read_ulongs(n)
      @io.read(4 * n).unpack("N#{n}")
    end

    def read_ulonglong
      parts = @io.read(8).unpack('NN')
      parts[0] << 32 | parts[1]
    end

    def read_char
      @io.read(1).unpack("c")[0]
    end

    def read_byte
      @io.read(1).unpack("C")[0]
    end

    def read_bytes(n)
      @io.read(n).unpack("C#{n}")
    end

    def read_raw_bytes(n)
      @io.read(n)
    end

    def read_float
      @io.read(4).unpack('e')[0]
    end

    def read_float_big
      @io.read(4).unpack('g')[0]
    end

    def read_double_float_big
      @io.read(8).unpack('G')[0]
    end

    def read_bool
      read_byte != 0
    end

    def read_metadata
      Metadata.deserialize(self)
    end
  end
end
