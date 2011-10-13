module MC
  autoload :Connection, 'mc/connection'
  autoload :World, 'mc/world'
  autoload :SpawnPosition, 'mc/packet'
  autoload :TimeUpdate, 'mc/packet'
  autoload :ServerInfo, 'mc/server_info'

  autoload :Entity, 'mc/entity'
  autoload :NamedEntity, 'mc/named_entity'

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
      register_handler(MC::Experience, :on_experience)
      register_handler(MC::MobSpawn, :on_mob_spawn)
      register_handler(MC::NamedEntitySpawn, :on_named_entity_spawn)
      register_handler(MC::Animation, :on_entity_animation)
      register_handler(MC::EntityTeleport, :on_entity_teleport)
      register_handler(MC::EntityRelativeMove, :on_entity_relative_move)
      register_handler(MC::EntityLook, :on_entity_look)
      register_handler(MC::EntityLookRelativeMove, :on_entity_look_relative_move)
      register_handler(MC::EntityVelocity, :on_entity_velocity)
      register_handler(MC::EntityEquipment, :on_entity_equipment)
      register_handler(MC::EntityMetadata, :on_entity_metadata)
      register_handler(MC::EntityStatus, :on_entity_status)
      register_handler(MC::DestroyEntity, :on_destroy_entity)
      register_handler(MC::ChatMessage, :on_chat_message)
      register_handler(MC::PlayerPositionLookResponse, :on_player_position_look)
      register_handler(MC::SetSlot, :on_set_slot)
      register_handler(MC::WindowItems, :on_window_items)

      @server_info = ServerInfo.new
      register_handler(MC::LoginReply) do |packet|
        @server_info.update(packet)
      end
      register_handler(MC::PlayerListItem) do |packet|
        @server_info.update_player(packet.player_name, packet.online?, packet.ping)
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

      register_handler(MC::PreChunk) do |packet|
        if packet.mode == 1
          # @world.allocate_chunk(packet.x, packet.z)
        else
          @world.free_chunk(packet.x, packet.z)
        end
      end

      register_handler(MC::MapChunk) do |packet|
        @world.update_chunk(packet.position, packet.chunk_update)
      end

      register_handler(MC::MultiBlockChange) do |packet|
        @world.multi_block_change(packet.x, packet.z, packet.updates)
      end

      register_handler(MC::BlockChange) do |packet|
        @world[packet.x, packet.y, packet.z].update(World::Block.new(packet.block_type, packet.meta_data))
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

    attr_accessor :position, :stance, :yaw, :pitch, :on_ground
    delegate :x, :y, :z, :to => :position

    def x
      position.try(:x)
    end

    def y
      position.try(:y)
    end

    def z
      position.try(:z)
    end

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
        self.position += Vector.new(dx, 0, dz)
      elsif args.length == 3
        dx, dy, dz = args
        send_packet(MC::PlayerPosition.new(x + dx.to_f, y + dy.to_f, z + dz.to_f, stance + dy.to_f, on_ground))
        self.position += Vector.new(dx, dy, dz)
        self.stance += dy.to_f
      end
    end

    def move_to(nx, ny, nz)
      send_packet(MC::PlayerPosition.new(nx, ny, nz, ny + (self.stance - self.y), on_ground))
      self.stance = ny + (self.stance - self.y)
      self.position = Vector.new(nx, ny, nz)
    end

    attr_accessor :health, :food, :food_saturation

    def on_update_health(packet)
      self.health = packet.health
      self.food = packet.food
      self.food_saturation = packet.food_saturation

      if health < 0
        send_packet(MC::RespawnRequest.new)
      end
    end

    attr_accessor :experience_total, :experience_level, :experience_current

    def on_experience(packet)
      experience_total = packet.total
      experience_level = packet.level
      experience_current = packet.current
    end

    def on_keep_alive(packet)
      send_packet(packet)
    end

    def on_mob_spawn(packet)
      mob = Entity.new
      mob.entity_id = packet.entity_id
      mob.position = packet.position
      mob.meta_data = packet.meta_data
      mob.pitch = packet.pitch
      mob.yaw = packet.yaw
      mob.mob_type = packet.mob_type
      @entities[packet.entity_id] = mob
    end

    def named_entities
      @entities.inject(Array.new) do |acc, (eid, entity)|
        acc << entity if entity.named?
        acc
      end
    end

    def on_named_entity_spawn(packet)
      e = NamedEntity.new
      e.entity_id = packet.entity_id
      e.name = packet.name
      e.position = packet.position
      e.yaw = packet.yaw
      e.pitch = packet.pitch
      e.current_item = packet.current_item
      e.mob_type = -1
      @entities[packet.entity_id] = e
    end

    def on_entity_animation(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.animation = packet.animation
    end

    def on_entity_look(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.yaw = packet.yaw
      e.pitch = packet.pitch
    end

    def on_entity_teleport(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.position = packet.position
      e.yaw = packet.yaw
      e.pitch = packet.pitch
    end

    def on_entity_relative_move(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.position += packet.delta
    end

    def on_entity_look_relative_move(packet)
      on_entity_relative_move(packet)
      on_entity_look(packet)
    end

    def on_entity_velocity(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.velocity = packet.velocity
    end

    def on_entity_equipment(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.equip(packet.slot, packet.item_id, packet.damage)
    end

    def on_entity_metadata(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.meta_data = packet.meta_data
    end

    def on_entity_status(packet)
      e = @entities[packet.entity_id]
      return if e.nil?

      e.status = packet.status
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
      self.position = packet.position
      self.yaw = packet.yaw
      self.pitch = packet.pitch
      self.stance = packet.stance
      self.on_ground = packet.on_ground

      send_packet(PlayerPositionAndLook.new(position.x, position.y, position.z, self.stance, self.yaw, self.pitch, self.on_ground))
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
