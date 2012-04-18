module MC
  class String16
    #ENCODING = 'UCS-2BE'
    ENCODING = 'UTF-16BE'

    def self.serialize(str)
MC.logger.info("Serializing #{str.inspect}")
      str ||= ""
      [ str.length ].pack('n') + str.encode(ENCODING).codepoints.to_a.pack("n#{str.length}")
    end

    def self.deserialize(io)
      data = io.read(2)
MC.logger.info "Data len: #{data.inspect}"
      len = data.unpack('n')[0]

      data = io.read(len * 2)
      #data.force_encoding("BINARY").unpack("n#{len}").inject("".force_encoding(ENCODING)) { |a, c| a << c }.encode("UTF-8")
MC.logger.info "Data: #{len}\n#{data.inspect}"
      data.force_encoding(ENCODING).encode('UTF-8')
    end
  end
end
