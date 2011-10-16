require 'mc/core_ext/fixnum'

module MC
  class Vector
    X = 0
    Y = 1
    Z = 2

    def initialize(x, y, z)
      @x = x
      @y = y
      @z = z
    end

    attr_accessor :x, :y, :z

    def nan?
      x.nan? || y.nan? || z.nan?
    end

    def to_s
      "<#{x}, #{y}, #{z}>"
    end

    def +(other)
      self.class.new(x + other.x, y + other.y, z + other.z)
    end

    def -(other)
      self.class.new(x - other.x, y - other.y, z - other.z)
    end

    def *(other)
      case other
      when Numeric then self.class.new(x * other, y * other, z * other)
      else self.class.new(x * other.x, y * other.y, z * other.z)
      end
    end

    def /(other)
      case other
      when Numeric then self.class.new(x / other, y / other, z / other)
      else self.class.new(x / other.x, y / other.y, z / other.z)
      end
    end

    def length_square
      x ** 2 + y ** 2 + z ** 2
    end

    def length
      Math.sqrt(length_square)
    end

    def distance_to(other)
      (self - other).length
    end

    def normalize
      l = length
      if l > 0
        self / l
      else
        self.class.new(0.0, 0.0, 0.0)
      end
    end

    def clamp
      self.class.new(x.to_i, y.to_i, z.to_i)
    end

    def round
      self.class.new(x.round, y.round, z.round)
    end

    def to_block_position
      self.class.new(x < 0 ? x.floor : x.to_i,
                     y < 0 ? y.floor : y.to_i,
                     z < 0 ? z.floor : z.to_i)
    end

    def ==(other)
      other != nil && x == other.x && y == other.y && z == other.z
    end

    def >=(other)
      x >= other.x && y >= other.y && z >= other.z
    end

    def <(other)
      x < other.x && y < other.y && z < other.z
    end

    def dot(other)
      x * other.x + y * other.y + z * other.z
    end
  end
end
