require 'mc'

module MC
  class Bot < Client
    def on_chat_message(packet)
      super

      m = packet.message.match(/<(\w+)> (.*)/)
      if m
        return if m[1] != 'SneakyDean'
        body = m[2]
      else
        m = packet.message.match(/[Server] (.*)/)
        return if m == nil
        body = m[1]
      end

      case body
      when /hello/i then send_packet(MC::ChatMessage.new("Hello"))
      when /say (.*)/ then send_packet(MC::ChatMessage.new($1))
        #when /look (-?\d+) (-?\d+)/ then send_packet(MC::PlayerPositionAndLook.new(x_absolute, y_absolute, z_absolute, stance, $1.to_i, $2.to_i, on_ground)) && send_packet(MC::ChatMessage.new("looking at #{$1} #{$2}"))
      when /look (-?\d+) (-?\d+)/ then send_packet(MC::PlayerLook.new($1.to_i, $2.to_i, on_ground)) && send_packet(MC::ChatMessage.new("looking at #{$1} #{$2}"))
        #when /move (-?\d+) (-?\d+)/ then send_packet(MC::PlayerPositionAndLook.new(x_absolute + $1.to_i, y_absolute, z_absolute + $2.to_i, stance, yaw, pitch, on_ground)) && send_packet(MC::ChatMessage.new("moving to #{x_absolute + $1.to_i} #{z_absolute + $2.to_i}"))
      when /move (-?\d+) (-?\d+) (-?\d+)/ then move_by($1.to_i, $2.to_i, $3.to_i) && send_packet(MC::ChatMessage.new("moving to #{x + $1.to_i} #{y + $2.to_i} #{z + $3.to_i}"))
      when /move (-?\d+) (-?\d+)/ then move_by($1.to_i, $2.to_i) && send_packet(MC::ChatMessage.new("moving to #{x + $1.to_i / 32.0} #{z + $2.to_i / 32.0}"))
      when /dig (-?\d+) (-?\d+) (-?\d+) (\d) (\d)/ then dig($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
      when /dig (-?\d+) (-?\d+) (-?\d+) (\d)/ then dig($1.to_i, $2.to_i, $3.to_i, $4.to_i)
      when /slot (\d)/ then holding_slot($1.to_i)
      when /place (-?\d+) (-?\d+) (-?\d+) (-?\d+) (\d)/ then place($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
      when /place (-?\d+) (-?\d+) (-?\d+) (\d)/ then place($1.to_i, $2.to_i, $3.to_i, -1, $4.to_i)
      when /place (-?\d+) (-?\d+) (-?\d+)/ then place($1.to_i, $2.to_i, $3.to_i, -1)
      when /crouch/ then crouch
      when /stand/ then stand
      when /eat/ then eat && chat("nom nom")
      end
    end
  end
end
