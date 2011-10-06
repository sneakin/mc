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

    def to_s
      "<#{data.join(", ")}>"
    end

    def +(other)
      self.class.new(x + other.x, y + other.y, z + other.z)
    end
  end
end
