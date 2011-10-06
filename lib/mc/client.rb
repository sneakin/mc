module MC
  autoload :Connection, 'mc/connection'
  autoload :World, 'mc/world'
  autoload :SpawnPosition, 'mc/packet'
  autoload :TimeUpdate, 'mc/packet'
  autoload :ServerInfo, 'mc/server_info'

  class Client
    attr_reader :socket, :name, :entities
    attr_accessor :connection_hash
    attr_accessor :connection
    attr_accessor :entity_id
    attr_reader :handlers
    attr_reader :server_info, :world

    def initialize(name, connection)
      @name = name
      @connection = connection
      @entities = Hash.new
      @holding = 0

      @handlers = Hash.new { |h, key| h[key] = Array.new }
      register_handler(MC::LoginReply, :on_login_reply)
      register_handler(MC::HandshakeReply, :on_handshake)
      register_handler(MC::KeepAlive, :on_keep_alive)
      register_handler(MC::UpdateHealth, :on_update_health)
      register_handler(MC::MobSpawn, :on_mob_spawn)
      register_handler(MC::NamedEntitySpawn, :on_named_entity_spawn)
      register_handler(MC::EntityRelativeMove, :on_entity_relative_move)
      register_handler(MC::EntityVelocity, :on_entity_velocity)
      register_handler(MC::DestroyEntity, :on_destroy_entity)
      register_handler(MC::ChatMessage, :on_chat_message)
      register_handler(MC::PlayerPositionLookResponse, :on_player_position_look)
      register_handler(MC::SetSlot, :on_set_slot)
      register_handler(MC::WindowItems, :on_window_items)

      @server_info = ServerInfo.new
      register_handler(MC::LoginReply) do |packet|
        @server_info.update(packet)
      end

      @world = World.new
      register_handler(MC::TimeUpdate) do |packet|
        @world.time = packet.time
      end

      register_handler(MC::SpawnPosition) do |packet|
        @world.spawn_position = packet.position
      end

      register_handler(MC::LoginReply) do |packet|
        @world.height = packet.world_height
        @world.dimension = packet.dimension
        @world.seed = packet.map_seed
      end
    end

    def close!
      @connection.close!
    end

    def connect
      send_packet(MC::HandshakeRequest.new(name))
      process_packets(MC::HandshakeReply)
    end

    def on_login_reply(packet)
      self.entity_id = packet.entity_id
    end

    def on_handshake(packet)
      self.connection_hash = packet.connection_hash
    end

    def needs_session?
      connection_hash != '-'
    end

    def login
      send_packet(MC::LoginRequest.new(name))
    end

    def process_packets(stopper = nil)
      @connection.process_packets do |packet|
        process_packet(packet)
        break if stopper && packet.kind_of?(stopper)
      end
    end

    def register_handler(packet_type, handler = nil, &block)
      handlers[packet_type] << block if block
      handlers[packet_type] << handler if handler
    end

    def process_packet(packet)
      h = handlers[packet.class]
      MC.logger.warn("No packet handlers for #{packet.inspect}") if h.empty?

      h.each do |handler|
        if handler.kind_of?(Symbol)
          send(handler, packet)
        else
          handler.call(packet)
        end
      end
    end

    def send_packet(packet)
      MC.logger.debug("Sending #{packet.inspect}")
      @connection.send_packet(packet)
    end

    def socket
      @connection.socket
    end

    def say(msg)
      send_packet(MC::ChatMessage.new(msg))
    end

    attr_accessor :x, :y, :z, :stance, :yaw, :pitch, :on_ground

    def x_absolute
      x * 32
    end

    def y_absolute
      y * 32
    end

    def z_absolute
      z * 32
    end

    def stance_absolute
      stance * 32
    end

    def change_stance_to(height)
      self.stance = y + height
      move_by(0, 0)
    end

    def crouch
      change_stance_to(0.8)
      send_packet(MC::EntityAction.new(0, MC::EntityAction::Crouch))
    end

    def stand
      change_stance_to(1.5)
      send_packet(MC::EntityAction.new(0, MC::EntityAction::Stand))
    end

    def move_by(*args)
      if args.length == 2
        dx, dz = args
        send_packet(MC::PlayerPosition.new(x + dx.to_f, y, z + dz.to_f, stance, on_ground))
        self.x += dx.to_f
        self.z += dz.to_f
      elsif args.length == 3
        dx, dy, dz = args
        send_packet(MC::PlayerPosition.new(x + dx.to_f, y + dy.to_f, z + dz.to_f, stance + dy.to_f, on_ground))
        self.x += dx.to_f
        self.y += dy.to_f
        self.stance += dy.to_f
        self.z += dz.to_f
      end
    end

    attr_accessor :health, :food, :food_saturation

    def on_update_health(packet)
      self.health = packet.health
      self.food = packet.food
      self.food_saturation = packet.food_saturation
    end

    def on_keep_alive(packet)
      send_packet(packet)
    end

    Mob = Struct.new(:entity_id, :x, :y, :z, :velocity, :meta_data, :pitch, :yaw, :mob_type)

    def on_mob_spawn(packet)
      mob = Mob.new
      mob.entity_id = packet.entity_id
      mob.x = packet.x
      mob.y = packet.y
      mob.z = packet.z
      mob.meta_data = packet.meta_data
      mob.pitch = packet.pitch
      mob.yaw = packet.yaw
      mob.mob_type = packet.mob_type
      @entities[packet.entity_id] = mob
    end

    NamedEntity = Struct.new(:entity_id, :name, :x, :y, :z, :velocity, :rotation, :pitch, :current_item, :mob_type)

    def on_named_entity_spawn(packet)
      e = NamedEntity.new
      e.entity_id = packet.entity_id
      e.name = packet.name
      e.x = packet.x
      e.y = packet.y
      e.z = packet.z
      e.rotation = packet.rotation
      e.pitch = packet.pitch
      e.current_item = packet.current_item
      e.mob_type = -1
      @entities[packet.entity_id] = e
    end

    def on_entity_relative_move(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.x += packet.dx
      e.y += packet.dy
      e.z += packet.dz
    end

    def on_entity_velocity(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.velocity = packet.velocity
    end

    def on_destroy_entity(packet)
      @entities.delete(packet.entity_id)
    end

    def chat_messages
      @chat_messages ||= Array.new
    end

    def on_chat_message(packet)
      chat_messages.unshift(packet.message)
    end

    def on_player_position_look(packet)
      self.x = packet.x
      self.y = packet.y
      self.z = packet.z
      self.yaw = packet.yaw
      self.pitch = packet.pitch
      self.stance = packet.stance
      self.on_ground = packet.on_ground

      send_packet(PlayerPositionAndLook.new(self.x, self.y, self.z, self.stance, self.yaw, self.pitch, self.on_ground))
    end

    class Window
      Slot = Struct.new(:item_id, :item_count, :item_uses)

      def initialize
        @slots = Hash.new
      end

      def clear_slot(slot)
        @slots.delete(slot)
      end

      def set_slot(slot, item_id = -1, item_count = 0, item_uses = 0)
        if item_id == -1
          clear_slot(slot)
        else
          @slots[slot] = Slot.new(item_id, item_count, item_uses)
        end
      end

      def use_slot(slot)
        return unless @slots.has_key?(slot)
        @slots[slot].item_count -= 1
        clear_slot(slot) if @slots[slot].item_count == 0
      end

      def slots
        @slots
      end
    end

    def windows
      @windows ||= Hash.new { |h, key| h[key] = Window.new }
    end

    def on_set_slot(packet)
      window = windows[packet.window_id]
      window.set_slot(packet.slot, packet.item_id, packet.item_count, packet.item_uses)
    end

    def on_window_items(packet)
      window = windows[packet.window_id]
      packet.slots do |i, slot|
        window.set_slot(i, slot.item_id, slot.item_count, slot.item_uses)
      end
    end

    attr_reader :holding

    def holding_slot(slot)
      send_packet(HoldingChange.new(slot))
      @holding = slot
    end

    def eat
      send_packet(PlayerBlockPlacement.new(-1, -1, -1, -1, -1, 0, 0))
    end

    def dig(dx, dy, dz, strikes = 50, face = MC::PlayerDigging::Face_Top)
      send_packet(MC::ChatMessage.new("I am digging at #{x + dx} #{y + dy} #{z + dy}."))

      # need to send a lot depending on the material and tool
      strikes.times do
        send_packet(MC::AnimationRequest.new(0, MC::AnimationRequest::SwingArm))
        send_packet(MC::PlayerDigging.new(MC::PlayerDigging::Started, x + dx, y + dy, z + dz, face))
      end

      if strikes > 1
        send_packet(MC::PlayerDigging.new(MC::PlayerDigging::Finished, x + dx, y + dy, z + dz, face))
        send_packet(MC::AnimationRequest.new(0, MC::AnimationRequest::NoAnimation))
      end
    end

    def place(dx, dy, dz, block_id = -1, direction = 2)
      windows[0].use_slot(@holding + 36)
      send_packet(MC::PlayerBlockPlacement.new(x + dx, y + dy, z + dz, direction, block_id))
    end

    def method_missing(mid, *args, &block)
      MC.logger.debug("Method missing: #{mid}")
      return super unless mid.to_s =~ /^on/
    end
  end
end
