module MC
  class BotGui
    Mobs = Hash.new("Unknown")
    <<-EOT.split("\n").each { |l| tid, name = l.split(/\s+/); Mobs[tid.to_i] = name }
50	 Creeper
51	 Skeleton
52	 Spider
53	 Giant Zombie
54	 Zombie
55	 Slime
56	 Ghast
57	 Zombie Pigman
58	 Enderman
59	 Cave Spider
60	 Silverfish
61	 Blaze
62	 Magma Cube
90	 Pig
91	 Sheep
92	 Cow
93	 Hen
94	 Squid
95	 Wolf
97	 Snowman
120	 Villager
-1       Player
EOT

    attr_accessor :packets, :packet_rate, :bot

    def initialize(bot)
      @bot = bot
      @packets = 0
      @packet_rate = 0
    end

    def update
      reset_screen
      puts "Packets: #{packets}\t#{packet_rate} packets per sec"
      print_status
      print_entity_count
      print_players
      print_chat_messages
    end

    private

    def print_status
      puts("Health:\t#{bot.health}\tFood:\t#{bot.food}\t#{bot.food_saturation}")
      puts("Position:\t#{bot.x}, #{bot.y}, #{bot.z}\t#{bot.stance}")
      puts("Rotation:\t#{bot.yaw} #{bot.pitch}")
      puts("On ground") if bot.on_ground
    end

    def print_entity_count
      puts(entity_count_by_type.collect { |(type, count)| "#{Mobs[type]}\t#{count}" }.join("\n"))
    end

    def entity_count_by_type
      bot.entities.
        collect { |eid, data| data }.
        group_by { |e| e.mob_type }.
        collect { |type, e| [type, e.count ] }
    end

    def print_players
      puts(named_entities.
           collect { |p| "#{p.name}\t#{p.entity_id}\t#{p.x}, #{p.y}, #{p.z}" }.
           join("\n"))
    end

    def named_entities
      bot.entities.
        inject([]) { |acc, (eid, data)| acc << data if data.kind_of?(MC::Client::NamedEntity); acc }
    end

    def print_chat_messages
      bot.chat_messages[0, 5].reverse.each do |msg|
        puts "#{msg}"
      end
    end

    def reset_screen
      print("\033[0;0f\033[2J")
    end
  end
end
