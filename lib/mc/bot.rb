require 'mc'

module MC
  class Bot < Client
    autoload :Message, 'mc/bot/message'

    attr_accessor :admins

    def initialize(name, connection, admins = Array.new)
      super(name, connection)
      self.admins = admins
      @last_time = Time.now
    end

    def is_admin?(nick)
      admins.include?(nick)
    end

    Float = /-?\d+(\.\d+)?/

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
      when /save chunks (.*)/ then save_chunks($1); say("Saved to #{$1}")
      when /move to (#{Float}) (#{Float})/ then move_to($1.to_f, y, $3.to_f); say("Moving to #{$1} #{$3}")
      when /move to (#{Float}) (#{Float}) (#{Float})/ then move_to($1.to_f, $3.to_f, $5.to_f); say("Moving to #{$1} #{3} #{$5}")
      when /move to (\w+)/ then say("Moving to #{move_to_entity($1)}")
      when /stop/ then stop_moving
      end
    end

    def tick
      now = Time.now
      if (now - @last_time) > 0.1
        tick_motion 
        @last_time =  now
      end
    end

    def stop_moving
      @destination = nil
    end

    def move_to(x, y, z)
      @destination = Vector.new(x, y, z)
      tick_motion
    end

    def tick_motion
      return if @destination.nil? || position.nil?

      if position.distance_to(@destination) <= 1.0
        @destination = nil
      else
        dv = (@destination - position).normalize * 2
        move_by(dv.x, dv.y, dv.z)
        say("Moving by #{dv}")
      end
    end

    def move_to_entity(name)
      ent = named_entities.find { |e| e.name =~ /#{name}/i }
      return nil if ent.nil?

      move_to(ent.position.x, ent.position.y, ent.position.z)
      ent.position
    end

    def say_server_info
      [ "Server info:",
        "Max players: #{server_info.max_players}",
        "Mode: #{server_info.mode}",
        "Difficulty: #{server_info.difficulty}",
        "Players: #{server_info.players.keys.join(', ')}"
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

    def save_chunks(directory)
      Dir.mkdir(directory) unless File.exists?(directory)
      padding = 2 + world.number_of_chunks.to_s.length

      world.each_chunk do |x, z, chunk|
        File.open("%s/%.#{padding}i_%.#{padding}i.yml" % [ directory, x, z ], "w") do |file|
          World::Chunk::Height.times do |y|
            World::Chunk::Width.times do |x|
              World::Chunk::Length.times do |z|
                file.write("%.3i %.3i" % [ chunk[x, y, z].type, chunk[x, y, z].metadata ])
                file.write("  ") unless (World::Chunk::Length - z) <= 1
              end

              file.write("\n")
            end
            file.write("\n")
          end
        end
      end
    end
  end
end
