require 'rainbow'

module MC
  autoload :Mobs, 'mc/mobs'
  autoload :Items, 'mc/items'
  autoload :GUI, 'mc/gui'

  class BotGui
    attr_accessor :packets, :packet_rate, :bot

    def initialize(bot)
      @bot = bot
      @packets = 0
      @packet_rate = 0
      @mapper = GUI::Mapper.new(bot.world)
      @console = Array.new
      @term = GUI::Terminal.new($stdout)
    end

    def quit!
      @done = true
    end

    def done?
      @done
    end

    def update
      process_input

      clear_stats
      print_status
      print_slots
      print_inventory
      print_entity_count
      print_players
      print_chat_messages
      print_console
      print_map
      print_prompt
    end

    def process_input
      i, o, e = IO.select([$stdin], nil, nil, 0)
      return unless i && i.include?($stdin)

      line = $stdin.readline
      process_command(line.strip)
    end

    def process_command(cmdline)
      MC.logger.debug("GUI command: #{cmdline}")
      if cmdline == 'quit'
        quit!
      else
        @bot.process_command(cmdline)
      end
    end

    private

    def print_status
      box(1, 1) do |boxer|
        boxer.puts "Packets: #{packets}\t#{packet_rate} packets per sec"
        boxer.puts("Health:\t#{bot.health}\tFood:\t#{bot.food}\t#{bot.food_saturation}")
        boxer.puts("Position:\t#{bot.x}, #{bot.y}, #{bot.z}\t#{bot.stance}")
        boxer.puts("Rotation:\t#{bot.yaw} #{bot.pitch}")
        boxer.puts("Time:\t#{bot.world.time}")
        boxer.puts("On ground") if bot.on_ground
      end
    end

    def print_map
      return if bot.position.nil? || bot.position.nan?

      width = 32
      height = 16

      box(65, 1) do |boxer|
        @mapper.print(boxer, bot.position, width, height)
      end
    end

    def box(column, row, &block)
      @term.box(column, row, &block)
    end

    def print_slots
      box(1, 7) do |boxer|
        boxer.puts "== Slots =="
        bot.windows[0].slots.
          select { |id, slot| (36..44).member?(id) }.
          sort { |a, b| a[0] <=> b[0] }.
          each { |(id, slot)| boxer.puts("#{'*' if (id - 36) == bot.holding}Slot #{id - 36}\t#{slot.item_count} #{Items[slot.item_id]}(#{slot.item_id}) #{slot.item_uses}") }
      end
    end

    def print_inventory
      box(40, 7) do |boxer|
        boxer.puts "== Inventory =="
        bot.windows[0].slots.
          reject { |id, slot| (36..44).member?(id) }.
          sort { |a, b| a[0] <=> b[0] }.
          each { |(id, slot)| boxer.puts("Slot #{id}\t#{slot.item_count} #{Items[slot.item_id]}(#{slot.item_id}) #{slot.item_uses}") }
      end
    end

    def print_entity_count
      box(1, 18) do |boxer|
        boxer.puts "== Entities =="
        boxer.puts(entity_count_by_type.collect { |(type, count)| "%s%s%4i" % [ Mobs[type], " " * (16 - Mobs[type].length), count ] }.join("\n"))
      end
    end

    def entity_count_by_type
      bot.entities.
        collect { |eid, data| data }.
        group_by { |e| e.mob_type }.
        collect { |type, e| [type, e.count ] }
    end

    def print_players
      box(40, 18) do |boxer|
        boxer.puts "== Players =="
        boxer.puts(named_entities.
             collect { |p| "#{p.name}\t#{p.entity_id}\t#{p.x}, #{p.y}, #{p.z}" }.
             join("\n"))
      end
    end

    def named_entities
      bot.entities.
        inject([]) { |acc, (eid, data)| acc << data if data.named?; acc }
    end

    def print_chat_messages
      box(1, 29) do |boxer|
        boxer.puts "== Chat =="
        bot.chat_messages[0, 5].reverse.each do |msg|
          boxer.puts "#{msg}"
        end
      end
    end

    def print_console
      box(1, 35) do |boxer|
        boxer.puts "== Console =="
        @console.reverse[0, 5].reverse.each do |msg|
          boxer.puts "#{msg}"
        end
      end
    end

    def print_prompt
      box(1, 41) do |boxer|
        boxer.write("> ")
      end
    end

    def clear_stats
      (1..@term.height).each do |line|
        @term.move_cursor_to(64, line)
        @term.clear_left
      end
    end
  end
end
