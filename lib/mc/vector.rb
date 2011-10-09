require 'mc/core_ext/fixnum'

module MC
  class Vector
    X = 0
    Y = 1
    Z = 2

    attr_reader :data

    def initialize(x, y, z)
      @data = [ x, y, z ]
    end

    def x
      @data[X]
    end

    def x=(v)
      @data[X] = v
    end

    def y
      @data[Y]
    end

    def y=(v)
      @data[Y] = v
    end

    def z
      @data[Z]
    end

    def z=(v)
      @data[Z] = v
    end

    def nan?
      x.nan? || y.nan? || z.nan?
    end

    def to_s
      "<#{data.join(", ")}>"
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

    def length
      Math.sqrt(x ** 2 + y ** 2 + z ** 2)
    end

    def distance_to(other)
      (self - other).length
    end

    def normalize
      self / length
    end

    def ==(other)
      x == other.x && y == other.y && z == other.z
    end
  end
end
