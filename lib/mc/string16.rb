module MC
  class String16
    def self.serialize(str)
      [ str.length ].pack('n') + str.chars.collect { |c| c[0] }.pack("n#{str.length}")
    end

    def self.deserialize(io)
      data = io.read(2)
      len = data.unpack('n')[0]

      data = io.read(len * 2)
      data.unpack("n#{len}").inject("") { |a, c| a << c }
    end
  end
end
