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
    end

    def update
      reset_screen
      print_status
      print_slots
      print_inventory
      print_entity_count
      print_players
      print_map
      print_chat_messages
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
      floor = Array.new(height) { Array.new(width) }

      height.times do |x|
        width.times do |z|
          floor[x][z] = bot.world[bot.position.x.to_i - height / 2 + x - 1, bot.position.y.to_i, bot.position.z.to_i - width / 2 + z]
        end
      end

      floor[height / 2][width / 2] = 'X'

      box(65, 1) do |boxer|
        floor.each do |col|
          boxer.puts(col.reverse.collect { |c| if c == 'X'; c.color(:red); else; map_char(c); end }.join)
        end
      end
    end

    def box(column, row, &block)
      boxer = GUI::Boxer.new(column, row)
      block.call(boxer)
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

    def reset_screen
      print("\033[0;0f\033[2J")
    end

    def map_char(block)
      return '?'.color(64, 64, 64) unless block.loaded?

      case block.type
      when 0 then ' '
      when 1 then '#'.color(:default)
      when 2 then '#'.color(:green)
      when 3 then '#'.color(255, 64, 0)
      when 8 then '~'.color(:blue)
      when 9 then '~'.color(:blue)
      when 10 then '^'.color(:red)
      when 11 then '^'.color(:red)
      when 12 then '.'.color(:yellow)
      when 17 then '@'.color(128, 64, 0)
      when 18 then '#'.color(0, 128, 0)
      when 50 then '`'.color(255, 255, 0)
      when 64 then '|'.color(255, 255, 128)
      when 71 then '|'.color(255, 255, 128)
      when 53 then '>'
      when 67 then '>'
      when 108 then '>'
      when 109 then '>'
      when 114 then '>'
      else '#'
      end
    end
  end
end
