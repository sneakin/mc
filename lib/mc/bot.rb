require 'mc'

module MC
  class Bot < Client
    autoload :Message, 'mc/bot/message'

    attr_accessor :admins

    def initialize(name, connection)
      super
      self.admins = []
    end

    def is_admin?(nick)
      admins.include?(nick)
    end

    def on_chat_message(packet)
      super
      msg = Message.new(packet.message)
      return unless is_admin?(msg.from) && msg.for?(name)

      case msg.body
      when /hello/i then say("Hello")
      when /say (.*)/ then say($1)
        #when /look (-?\d+) (-?\d+)/ then send_packet(MC::PlayerPositionAndLook.new(x_absolute, y_absolute, z_absolute, stance, $1.to_i, $2.to_i, on_ground)) && send_packet(MC::ChatMessage.new("looking at #{$1} #{$2}"))
      when /look (-?\d+) (-?\d+)/ then send_packet(MC::PlayerLook.new($1.to_i, $2.to_i, on_ground)) && say("looking at #{$1} #{$2}")
        #when /move (-?\d+) (-?\d+)/ then send_packet(MC::PlayerPositionAndLook.new(x_absolute + $1.to_i, y_absolute, z_absolute + $2.to_i, stance, yaw, pitch, on_ground)) && send_packet(MC::ChatMessage.new("moving to #{x_absolute + $1.to_i} #{z_absolute + $2.to_i}"))
      when /move (-?\d+) (-?\d+) (-?\d+)/ then move_by($1.to_i, $2.to_i, $3.to_i) && say("moving to #{x + $1.to_i} #{y + $2.to_i} #{z + $3.to_i}")
      when /move (-?\d+) (-?\d+)/ then move_by($1.to_i, $2.to_i) && say("moving to #{x + $1.to_i / 32.0} #{z + $2.to_i / 32.0}")
      when /dig (-?\d+) (-?\d+) (-?\d+) (\d) (\d)/ then dig($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
      when /dig (-?\d+) (-?\d+) (-?\d+) (\d)/ then dig($1.to_i, $2.to_i, $3.to_i, $4.to_i)
      when /slot (\d)/ then holding_slot($1.to_i)
      when /place (-?\d+) (-?\d+) (-?\d+) (-?\d+) (\d)/ then place($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
      when /place (-?\d+) (-?\d+) (-?\d+) (\d)/ then place($1.to_i, $2.to_i, $3.to_i, -1, $4.to_i)
      when /place (-?\d+) (-?\d+) (-?\d+)/ then place($1.to_i, $2.to_i, $3.to_i, -1)
      when /crouch/ then crouch
      when /stand/ then stand
      when /eat/ then eat && say("nom nom")
      when /server info/ then say_server_info
      when /world info/ then say_world_info
      end
    end

    def say_server_info
      [ "Server info:",
        "Max players: #{server_info.max_players}",
        "Mode: #{server_info.mode}",
        "Difficulty: #{server_info.difficulty}"
      ].each do |line|
        say(line)
      end
    end

    def say_world_info
      [ "World:",
        "time: #{world.time}",
        "height: #{world.height}",
        "seed: #{world.seed}",
        "dimension: #{world.dimension}",
        "spawn: #{world.spawn_position}"
      ].each do |line|
        say(line)
      end
    end
  end
end
