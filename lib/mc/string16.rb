module MC
  class String16
    ENCODING = 'UCS-2BE'

    def self.serialize(str)
      [ str.length ].pack('n') + str.encode(ENCODING).codepoints.to_a.pack("n#{str.length}")
    end

    def self.deserialize(io)
      data = io.read(2)
      len = data.unpack('n')[0]

      data = io.read(len * 2)
      data.force_encoding("BINARY").unpack("n#{len}").inject("".force_encoding(ENCODING)) { |a, c| a << c }.encode(Encoding.default_internal || Encoding.default_external)
    end
  end
end
