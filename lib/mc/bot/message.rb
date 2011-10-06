class MC::Bot::Message
  def initialize(msg)
    m = msg.match(/<(\w+)> (.*)/)
    if m
      @from = m[1]
      @body = m[2]
    else
      m = msg.match(/[Server] (.*)/)
      @from = nil
      @body = m[1]
    end
  end

  attr_reader :body, :from

  def for?(nick)
    body =~ /#{nick}/i
  end
end
