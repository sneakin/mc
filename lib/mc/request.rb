module MC
  autoload :TypeIdFactory, 'mc/type_id_factory'

  class Request
    include TypeIdFactory

    class << self
      def packet_id(id)
        register(id)

        define_method(:packet_id) do
          id
        end
      end

      def deserialize(parser)
        i = self.new
        i.deserialize(parser)
        i
      end
    end

    def serialize
      [ packet_id ].pack('C')
    end
  end

  class LoginRequest < Request
    packet_id 0x01

    attr_accessor :protocol_version, :user_name, :unused

    def initialize(name = 'MC Bot')
      self.protocol_version = 17
      self.user_name = name
    end

    def serialize
      super + [ protocol_version ].pack('N') + String16.serialize(user_name) + Array.new(16, 0).pack('C16')
    end

    def deserialize(parser)
      self.protocol_version = parser.read_ulong
      self.user_name = parser.read_string
      self.unused = parser.read_bytes(16)
    end
  end

  class HandshakeRequest < Request
    packet_id 0x02
    attr_accessor :user_name

    def initialize(user_name = 'MC Bot')
      self.user_name = user_name
    end

    def serialize
      super + String16.serialize(user_name)
    end
  end

  class RespawnRequest < Request
    packet_id 0x09
  end

  class PlayerOnGround < Request
    packet_id 0x0A
    attr_accessor :on_ground

    def initialize(on_ground = true)
      self.on_ground = on_ground
    end

    def serialize
      super + [ on_ground ? 1 : 0 ].pack('c')
    end
  end

  class PlayerPosition < Request
    packet_id 0x0B
    attr_accessor :x, :y, :z, :stance, :on_ground

    def initialize(x, y, z, stance, on_ground)
      self.x = x
      self.y = y
      self.z = z
      self.stance = stance
      self.on_ground = on_ground
    end

    def serialize
      super + [ x.to_f, y.to_f, stance.to_f, z.to_f, on_ground ? 1 : 0 ].pack('GGGGc')
    end
  end

  class PlayerLook < Request
    packet_id 0x0C
    attr_accessor :yaw, :pitch, :on_ground

    def initialize(yaw = 0.0, pitch = 0.0, on_ground = true)
      self.yaw = yaw
      self.pitch = pitch
      self.on_ground = on_ground
    end

    def serialize
      super + [ self.yaw.to_f, self.pitch.to_f, self.on_ground ? 1 : 0 ].pack('ggc')
    end
  end

  class PlayerPositionAndLook < Request
    packet_id 0x0D
    attr_accessor :x, :y, :z, :stance, :yaw, :pitch, :on_ground

    def initialize(x, y, z, stance, yaw, pitch, on_ground)
      self.x = x
      self.y = y
      self.z = z
      self.stance = stance
      self.yaw = yaw
      self.pitch = pitch
      self.on_ground = on_ground
    end

    def serialize
      super + [ self.x.to_f, self.y.to_f, self.stance.to_f, self.z.to_f, self.yaw.to_f, self.pitch.to_f, self.on_ground ? 1 : 0].pack('GGGGggc')
    end
  end

  class PlayerDigging < Request
    packet_id 0x0E
    attr_accessor :status, :x, :y, :z, :face

    Started = 0
    Finished = 2
    Dropped = 4
    ShootArrow = 5

    Face_Bottom = 0
    Face_Top = 1
    Face_North = 3
    Face_South = 2
    Face_East = 5
    Face_West = 4

    def initialize(status, x, y, z, face)
      self.status = status
      self.x = x
      self.y = y
      self.z = z
      self.face = face
    end

    def serialize
      super + [ status.to_i, x.to_i, y.to_i, z.to_i, face.to_i ].pack("cNcNc")
    end
  end

  class PlayerBlockPlacement < Request
    packet_id 0x0F
    attr_accessor :x, :y, :z, :direction, :block_id, :amount, :damage

    def initialize(x, y, z, direction, block_id, amount = 0, damage = 0)
      self.x = x
      self.y = y
      self.z = z
      self.direction = direction
      self.block_id = block_id
      self.amount = amount
      self.damage = damage
    end

    def serialize
      if block_id >= 0
        super + [ x, y, z, direction, block_id, amount, damage ].pack('NcNcncn')
      else
        super + [ x, y, z, direction, block_id ].pack('NcNcn')
      end
    end
  end

  class HoldingChange < Request
    packet_id 0x10
    attr_accessor :slot

    def initialize(slot)
      self.slot = slot
    end

    def serialize
      super + [ slot ].pack('n')
    end
  end

  class AnimationRequest < Request
    packet_id 0x12
    attr_accessor :entity_id, :animation

    NoAnimation = 0
    SwingArm = 1
    Damage = 2
    LeaveBed = 3
    EatFood = 5
    Crouch = 104
    Uncrouch = 105

    def initialize(entity_id, animation)
      self.entity_id = entity_id
      self.animation = animation
    end

    def serialize
      super + [ entity_id, animation ].pack('Nc')
    end
  end
end
