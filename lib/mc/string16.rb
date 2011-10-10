module MC
  class String16
    def self.serialize(str)
      [ str.length ].pack('n') + str.encode("UCS-2BE").codepoints.to_a.pack("n#{str.length}")
    end

    def self.deserialize(io)
      data = io.read(2)
      len = data.unpack('n')[0]

      data = io.read(len * 2)
      data.force_encoding("BINARY").unpack("n#{len}").inject("".force_encoding("UCS-2BE")) { |a, c| a << c }.encode(Encoding.default_internal || Encoding.default_external)
    end
  end
end
