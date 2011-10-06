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

    def y
      @data[Y]
    end

    def z
      @data[Z]
    end

    def to_s
      "<#{data.join(", ")}>"
    end
  end
end
