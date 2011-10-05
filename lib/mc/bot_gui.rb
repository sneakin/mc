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
      print_chat_messages
    end

    private

    def print_status
      box(1, 1) do |boxer|
        boxer.puts "Packets: #{packets}\t#{packet_rate} packets per sec"
        boxer.puts("Health:\t#{bot.health}\tFood:\t#{bot.food}\t#{bot.food_saturation}")
        boxer.puts("Position:\t#{bot.x}, #{bot.y}, #{bot.z}\t#{bot.stance}")
        boxer.puts("Rotation:\t#{bot.yaw} #{bot.pitch}")
        boxer.puts("On ground") if bot.on_ground
      end
    end

    def box(column, row, &block)
      boxer = GUI::Boxer.new(column, row)
      block.call(boxer)
    end

    def print_slots
      box(0, 6) do |boxer|
        boxer.puts "== Slots =="
        bot.windows[0].slots.
          select { |id, slot| (36..44).member?(id) }.
          sort { |a, b| a[0] <=> b[0] }.
          each { |(id, slot)| boxer.puts("#{'*' if (id - 36) == bot.holding}Slot #{id - 36}\t#{slot.item_count} #{Items[slot.item_id]}(#{slot.item_id}) #{slot.item_uses}") }
      end
    end

    def print_inventory
      box(40, 6) do |boxer|
        boxer.puts "== Inventory =="
        bot.windows[0].slots.
          reject { |id, slot| (36..44).member?(id) }.
          sort { |a, b| a[0] <=> b[0] }.
          each { |(id, slot)| boxer.puts("Slot #{id}\t#{slot.item_count} #{Items[slot.item_id]}(#{slot.item_id}) #{slot.item_uses}") }
      end
    end

    def print_entity_count
      box(0, 17) do |boxer|
        boxer.puts "== Entities =="
        boxer.puts(entity_count_by_type.collect { |(type, count)| "#{Mobs[type]}\t#{count}" }.join("\n"))
      end
    end

    def entity_count_by_type
      bot.entities.
        collect { |eid, data| data }.
        group_by { |e| e.mob_type }.
        collect { |type, e| [type, e.count ] }
    end

    def print_players
      box(40, 17) do |boxer|
        boxer.puts "== Players =="
        boxer.puts(named_entities.
             collect { |p| "#{p.name}\t#{p.entity_id}\t#{p.x}, #{p.y}, #{p.z}" }.
             join("\n"))
      end
    end

    def named_entities
      bot.entities.
        inject([]) { |acc, (eid, data)| acc << data if data.kind_of?(MC::Client::NamedEntity); acc }
    end

    def print_chat_messages
      box(0, 28) do |boxer|
        boxer.puts "== Chat =="
        bot.chat_messages[0, 5].reverse.each do |msg|
          boxer.puts "#{msg}"
        end
      end
    end

    def reset_screen
      print("\033[0;0f\033[2J")
    end
  end
end
