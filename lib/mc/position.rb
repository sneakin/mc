module MC
  autoload :Vector, 'mc/vector'

  class Position < Vector
    def self.absolute(x, y, z)
      new(x / 32.0, y / 32.0, z / 32.0)
    end

    def self.block(x, y, z)
      new(x, y, z)
    end

    def to_absolute
      self.class.new(x * 32.0, y * 32.0, z * 32.0)
    end
  end
end
