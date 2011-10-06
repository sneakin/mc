module MC
  autoload :TypeIdFactory, 'mc/type_id_factory'
  autoload :Vector, 'mc/vector'

  class Packet
    include TypeIdFactory

    class << self
      def packet_id(id)
        register(id)

        define_method(:packet_id) do
          id
        end
      end

      def create(packet_id, parser)
        p = Factory.create(packet_id)
        p.deserialize(parser)
        p
      end

      def deserialize(parser)
        p = self.new
        p.deserialize(parser)
        p
      end
    end

    def serialize
      [ packet_id ].pack('C')
    end

    def deserialize(parser)
    end
  end

  class KickPacket < Packet
    attr_accessor :reason

    packet_id 0xFF

    def deserialize(parser)
      self.reason = parser.read_string
    end
  end

  class KeepAlive < Packet
    packet_id 0x00

    attr_accessor :keep_alive_id

    def initialize
      self.keep_alive_id = rand(0xFFFFFFFF)
    end

    def serialize
      super + [ keep_alive_id ].pack('N')
    end

    def deserialize(parser)
      self.keep_alive_id = parser.read_ulong
    end
  end

  class LoginReply < Packet
    packet_id 0x01
    attr_accessor :entity_id, :map_seed, :server_mode, :dimension, :difficulty, :world_height, :max_players

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      parser.read_bytes(2)
      self.map_seed = parser.read_ulonglong
      self.server_mode = parser.read_ulong
      self.dimension = parser.read_char
      self.difficulty = parser.read_char
      self.world_height = parser.read_byte
      self.max_players = parser.read_byte

      # data = io.read(24)
      # puts data.inspect
      # self.entity_id, self.map_seed, self.server_mode, self.dimension, self.difficulty, self.world_height, self.max_players = data.unpack('NxxQNccCC')
    end
  end

  class ChatMessage < Packet
    packet_id 0x03
    attr_accessor :message

    def initialize(message = nil)
      self.message = message
    end

    def serialize
      super + String16.serialize(message)
    end

    def deserialize(parser)
      self.message = parser.read_string
    end
  end

  class NamedEntitySpawn < Packet
    packet_id 0x14
    attr_accessor :entity_id, :name, :position, :yaw, :pitch, :current_item

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.name = parser.read_string
      self.position = Vector.new(parser.read_long, parser.read_long, parser.read_long)
      self.yaw = parser.read_char
      self.pitch = parser.read_char
      self.current_item = parser.read_short
    end
  end

  class HandshakeReply < Packet
    packet_id 0x02
    attr_accessor :connection_hash

    def deserialize(parser)
      self.connection_hash = parser.read_string
    end

    def serialize
      super + String16.serialize(connection_hash)
    end
  end

  class Metadata
    def self.deserialize(parser)
      data = Hash.new

      while (x = parser.read_byte) && x != 127
        #puts x.inspect
        data[x & 0x1F] = case (x >> 5)
                         when 0 then parser.read_byte
                         when 1 then parser.read_short
                         when 2 then parser.read_long
                         when 3 then parser.read_float
                         when 4 then parser.read_string
                         when 5 then ItemStack.deserialize(parser)
                         when 6 then EntityInfo.deserialize(parser)
                         end
      end

      data
    end
  end

  class MobSpawn < Packet
    packet_id 0x18
    attr_accessor :entity_id, :mob_type, :position, :yaw, :pitch, :meta_data

    delegate :x, :y, :z, :to => :position
    delegate :x=, :y=, :z=, :to => :position

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.mob_type = parser.read_byte
      self.position = Vector.new(parser.read_long, parser.read_long, parser.read_long)
      self.yaw = parser.read_char
      self.pitch = parser.read_char

      # data = io.read(19)
      # self.entity_id, self.mob_type, self.x, self.y, self.z, self.yaw, self.pitch = data.unpack('NcNNNcc')
      # self.x = self.x - MAX_INT if self.x > MAX_SIGNED_INT
      # self.y = self.y - MAX_INT if self.y > MAX_SIGNED_INT
      # self.z = self.z - MAX_INT if self.z > MAX_SIGNED_INT
      self.meta_data = parser.read_metadata
    end

    def block_position
      [ x / 32.0, y / 32.0, z / 32.0 ]
    end
  end

  class AddObject < Packet
    packet_id 0x17
    attr_accessor :entity_id, :entity_type, :x, :y, :z, :thrower_id, :a, :b, :c

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.entity_type = parser.read_byte
      self.x = parser.read_long
      self.y = parser.read_long
      self.z = parser.read_long
      self.thrower_id = parser.read_long
      if thrower_id > 0
        self.a = parser.read_short
        self.b = parser.read_short
        self.c = parser.read_short
      end

      # self.entity_id, self.entity_type, self.x, self.y, self.z, self.thrower_id = io.read(21).unpack('NcNNNN')
      # self.a, self.b, self.c = io.read(6).unpack('nnn') if self.thrower_id > 0
    end
  end

  class ItemStack
    attr_accessor :id, :count, :damage

    def self.deserialize(parser)
      r = self.new
      r.deserialize(parser)
      r
    end

    def deserialize(parser)
      self.id = parser.read_short
      self.count = parser.read_byte
      self.damage = parser.read_short
      #self.id, self.count, self.damage = io.read(5).unpack('ncn')
    end
  end

  class EntityInfo
    attr_accessor :a, :b, :c

    def self.deserialize(parser)
      r = self.new
      r.deserialize(parser)
      r
    end

    def deserialize(parser)
      self.a = parser.read_long
      self.b = parser.read_long
      self.c = parser.read_long
      #self.a, self.b, self.c = io.read(4 * 3).unpack('NNN')
    end
  end

  class EntityMetadata < Packet
    packet_id 0x28
    attr_accessor :entity_id, :meta_data

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.meta_data = parser.read_metadata
    end
  end

  class DestroyEntity < Packet
    packet_id 0x1D
    attr_accessor :entity_id

    def deserialize(parser)
      self.entity_id = parser.read_ulong
    end
  end

  class EntityVelocity < Packet
    packet_id 0x1C
    attr_accessor :entity_id, :velocity

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.velocity = Vector.new(parser.read_short, parser.read_short, parser.read_short)
      #self.entity_id, self.x, self.y, self.z = io.read(10).unpack('Nnnn')
    end

    delegate :x, :y, :z, :to => :velocity
    delegate :x=, :y=, :z=, :to => :velocity
  end

  class EntityRelativeMove < Packet
    packet_id 0x1F
    attr_accessor :entity_id, :delta

    def dx; delta.x; end
    def dy; delta.y; end
    def dz; delta.z; end

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.delta = Vector.new(parser.read_char, parser.read_char, parser.read_char)
      #self.entity_id, self.dx, self.dy, self.dz = io.read(7).unpack('Nccc')
    end
  end

  class EntityLookRelativeMove < Packet
    packet_id 0x21
    attr_accessor :entity_id, :dx, :dy, :dz, :yaw, :pitch

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.dx = parser.read_char
      self.dy = parser.read_char
      self.dz = parser.read_char
      self.yaw = parser.read_char
      self.pitch = parser.read_char
      #self.entity_id, self.dx, self.dy, self.dz, self.yaw, self.pitch = io.read(9).unpack('Nccccc')
    end
  end

  class EntityStatus < Packet
    packet_id 0x26
    attr_accessor :entity_id, :status

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.status = parser.read_char
      #self.entity_id, self.status = io.read(5).unpack('Nc')
    end
  end

  class EntityTeleport < Packet
    packet_id 0x22
    attr_accessor :entity_id, :x, :y, :z, :yaw, :pitch

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.x = parser.read_long
      self.y = parser.read_long
      self.z = parser.read_long
      self.yaw = parser.read_char
      self.pitch = parser.read_char
      #self.entity_id, self.x, self.y, self.z, self.yaw, self.pitch = io.read(18).unpack('NNNNcc')
    end
  end

  class Experience < Packet
    packet_id 0x2B
    attr_accessor :current, :level, :total

    def deserialize(parser)
      self.current = parser.read_byte
      self.level = parser.read_byte
      self.total = parser.read_short
    end
  end

  class PreChunk < Packet
    packet_id 0x32
    attr_accessor :x, :z, :mode

    def deserialize(parser)
      self.x = parser.read_long
      self.z = parser.read_long
      self.mode = parser.read_char
      #self.x, self.z, self.mode = io.read(9).unpack('NNc')
    end
  end

  class MapChunk < Packet
    packet_id 0x33
    attr_accessor :x, :y, :z, :size_x, :size_y, :size_z, :data_size, :data

    def deserialize(parser)
      self.x = parser.read_long
      self.y = parser.read_short
      self.z = parser.read_long
      self.size_x = parser.read_byte
      self.size_y = parser.read_byte
      self.size_z = parser.read_byte
      self.data_size = parser.read_ulong
      #self.x, self.y, self.z, self.size_x, self.size_y, self.size_z, self.data_size = io.read(17).unpack('NnNcccN')
      self.data = parser.read_bytes(self.data_size)
    end
  end

  class BlockAction < Packet
    packet_id 0x36
    attr_accessor :x, :y, :z, :byte1, :byte2

    def deserialize(parser)
      self.x = parser.read_long
      self.y = parser.read_short
      self.z = parser.read_long
      self.byte1 = parser.read_byte
      self.byte2 = parser.read_byte
      #self.x, self.y, self.z, self.byte1, self.byte2 = io.read(12).unpack('NnNcc')
    end
  end

  class BlockChange < Packet
    packet_id 0x35
    attr_accessor :x, :y, :z, :block_type, :meta_data

    def deserialize(parser)
      self.x = parser.read_long
      self.y = parser.read_char
      self.z = parser.read_long
      self.block_type = parser.read_byte
      self.meta_data = parser.read_byte
      #self.x, self.y, self.z, self.block_type, self.meta_data = io.read(11).unpack('NcNcc')
    end
  end

  class MultiBlockChange < Packet
    packet_id 0x34
    attr_accessor :x, :y, :size, :coordinates, :type, :meta_data

    def deserialize(parser)
      self.x = parser.read_long
      self.y = parser.read_long
      self.size = parser.read_short
      self.coordinates = parser.read_shorts(self.size)
      self.type = parser.read_bytes(self.size)
      self.meta_data = parser.read_bytes(self.size)
      #self.x, self.y, self.size = io.read(10).unpack('NNn')
      #self.coordinates = io.read(self.size * 2).unpack("n#{self.size}")
      #self.type = io.read(self.size).unpack("C#{self.size}")
      #self.meta_data = io.read(self.size).unpack("C#{self.size}")
    end
  end

  class PickupSpawn < Packet
    packet_id 0x15
    attr_accessor :entity_id, :item_id, :count_id, :damage, :x, :y, :z, :rotation, :pitch, :roll

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.item_id = parser.read_ushort
      self.count_id = parser.read_char
      self.damage = parser.read_short
      self.x = parser.read_long
      self.y = parser.read_long
      self.z = parser.read_long
      self.rotation = parser.read_char
      self.pitch = parser.read_char
      self.roll = parser.read_char

      #self.entity_id, self.item_id, self.count_id, self.damage, self.x, self.y, self.z, self.rotation, self.pitch, self.roll = io.read(24).unpack('NncnNNNccc')
    end
  end

  class UseBed < Packet
    packet_id 0x11
    attr_accessor :entity_id, :in_bed, :x, :y, :z

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.in_bed = parser.read_char
      self.x = parser.read_long
      self.y = parser.read_byte
      self.z = parser.read_long
    end
  end

  class Animation < Packet
    packet_id 0x12
    attr_accessor :entity_id, :animation

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.animation = parser.read_byte
      #self.entity_id, self.animation = io.read(5).unpack('Nc')
    end
  end

  class EntityAction < Packet
    packet_id 0x13
    attr_accessor :entity_id, :action_id

    Crouch = 1
    Stand = 2
    LeaveBed = 3
    Start_Sprinting = 4
    Stop_Sprinting = 5

    def initialize(entity_id = nil, action_id = Stand)
      self.entity_id = entity_id
      self.action_id = action_id
    end

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.action_id = parser.read_byte
      #self.entity_id, self.action_id = io.read(5).unpack('Nc')
    end

    def serialize
      super + [ entity_id, action_id ].pack('Nc')
    end
  end

  class CollectItem < Packet
    packet_id 0x16
    attr_accessor :collected, :collector

    def deserialize(parser)
      self.collected = parser.read_ulong
      self.collector = parser.read_ulong
    end
  end

  class SoundEffect < Packet
    packet_id 0x3D
    attr_accessor :effect_id, :x, :y, :z, :data

    def deserialize(parser)
      self.effect_id = parser.read_ulong
      self.x = parser.read_long
      self.y = parser.read_char
      self.z = parser.read_long
      self.data = parser.read_long
      #self.effect_id, self.x, self.y, self.z, self.data = io.read(17).unpack('NNcNN')
    end
  end

  class NewState < Packet
    packet_id 0x46
    attr_accessor :reason, :game_mode

    def deserialize(parser)
      self.reason = parser.read_byte
      self.game_mode = parser.read_byte
    end

    def reason_string
      [ "Invalid bed", "Begin raining", "End raining", "Change game mode" ][reason]
    end
  end

  class ThunderBolt < Packet
    packet_id 0x47
    attr_accessor :entity_id, :unknown, :x, :y, :z

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.unknown = parser.read_byte
      self.x = parser.read_long
      self.y = parser.read_long
      self.z = parser.read_long
    end
  end

  class IncrementStatistic < Packet
    packet_id 0xC8
    attr_accessor :statistic_id, :amount

    def deserialize(parser)
      self.statistic_id = parser.read_ulong
      self.amount = parser.read_char
      #self.statistic_id, self.amount = io.read(5).unpack('Nc')
    end
  end

  class PlayerListItem < Packet
    packet_id 0xC9
    attr_accessor :player_name, :online, :ping

    def packet_id
      0xC9
    end

    def deserialize(parser)
      self.player_name = parser.read_string
      self.online = parser.read_byte
      self.ping = parser.read_ushort
      #self.player_name = String16.deserialize(io)
      #self.online, self.ping = io.read(3).unpack('cn')
    end
  end

  class UpdateHealth < Packet
    packet_id 0x08
    attr_accessor :health, :food, :food_saturation

    def deserialize(parser)
      self.health = parser.read_short
      self.food = parser.read_short
      self.food_saturation = parser.read_float
    end
  end

  class PlayerPositionLookResponse < Packet
    packet_id 0x0D
    attr_accessor :x, :stance, :y, :z, :yaw, :pitch, :on_ground

    def deserialize(parser)
      self.x = parser.read_double_float_big
      self.stance = parser.read_double_float_big
      self.y = parser.read_double_float_big
      self.z = parser.read_double_float_big
      self.yaw = parser.read_float_big
      self.pitch = parser.read_float_big
      self.on_ground = parser.read_char
      #self.x, self.stance, self.y, self.z, self.yaw, self.pitch, self.on_ground = io.read(41).unpack('GGGGggc')
    end
  end

  class TimeUpdate < Packet
    packet_id 0x04
    attr_accessor :time

    def deserialize(parser)
      self.time = parser.read_double_float_big
      #self.time = io.read(8).unpack('Q')
    end
  end

  class SpawnPosition < Packet
    packet_id 0x06
    attr_accessor :position

    def deserialize(parser)
      self.position = Vector.new(parser.read_long, parser.read_long, parser.read_long)
      #self.x, self.y, self.z = io.read(12).unpack('NNN')
    end

    delegate :x, :y, :z, :to => :position
    delegate :x=, :y=, :z=, :to => :position
  end

  class EntityEquipment < Packet
    packet_id 0x05
    attr_accessor :entity_id, :slot, :item_id, :damage

    def deserialize(parser)
      self.entity_id = parser.read_ulong
      self.slot = parser.read_short
      self.item_id = parser.read_short
      self.damage = parser.read_short
      #self.entity_id, self.slot, self.item_id, self.damage = io.read(10).unpack('Nnnn')
    end
  end

  class SetSlot < Packet
    packet_id 0x67
    attr_accessor :window_id, :slot, :item_id, :item_count, :item_uses

    def deserialize(parser)
      self.window_id = parser.read_char
      self.slot = parser.read_short
      self.item_id = parser.read_short

      if item_id > -1
        self.item_count = parser.read_char
        self.item_uses = parser.read_short
      end
      #self.window_id, self.slot, self.item_id = io.read(5).unpack('css')
      #self.item_count, self.item_uses = io.read(3).unpack('cs') if self.item_id > -1
    end
  end

  class WindowItems < Packet
    packet_id 0x68
    attr_accessor :window_id, :count, :slots

    Slot = Struct.new(:item_id, :count, :uses)

    def deserialize(parser)
      self.window_id = parser.read_byte
      self.count = parser.read_short
      #self.window_id, self.count = io.read(3).unpack('cn')
      MC.logger.debug("Reading #{count} slots")

      self.slots = Hash.new
      self.count.times do |i|
        item_id = parser.read_short

        if item_id != -1
          slot_count = parser.read_byte
          slot_uses = parser.read_ushort
          self.slots[i] = Slot.new(item_id, slot_count, slot_uses)
          MC.logger.debug("Added slot #{i}\t#{slots[i].inspect}")
        end

        #item_id = io.read(2).unpack('s')[0]
        #count, uses = io.read(3).unpack('cs') if item_id != -1
      end
    end
  end

end
