require 'mc'

class Array
  def max_depth
    m = collect do |el|
      if el.respond_to?(:max_depth)
        el.max_depth
      else
        0
      end
    end.max

    1 + m
  end
end

module MC
  module Spec
    class TestWorld
      attr_accessor :origin_x, :origin_y, :origin_z

      def initialize(data, origin_x = 0, origin_z = 0, origin_y = -1)
        @data = case data.max_depth
                when 1 then raise ArgumentError.new("1d worlds not allowed")
                when 2 then init_data([data, data])
                else init_data(data)
                end
        @origin_x = origin_x
        @origin_z = origin_z
        @origin_y = origin_y
      end

      def make_solid_floor(width, length, block_type)
        Array.new(length) { Array.new(width) { MC::World::Block.new(block_type, 1, true) } }
      end

      def init_data(data)
        d = Array.new
        d << make_solid_floor(data[0][0].size, data[0].size, 7)
        data.each do |floor|
          d << blockify_floor(floor)
        end
        d << make_solid_floor(data[0][0].size, data[0].size, 7)
        d
      end

      def blockify_floor(data)
        data.collect { |row|
          row.collect { |block_id| MC::World::Block.new(block_id, 0, true) }
        }
      end

      NullBlock = MC::World::Block.new(0, 0, false)

      def [](x, y, z)
        x = x - @origin_x
        y = y - @origin_y
        z = z - @origin_z
        if x < 0 || x >= width || z < 0 || z >= length || y < 0 || y >= height
          return NullBlock
        end

        @data[y][z][x] ||
          NullBlock
      rescue
        NullBlock
      end

      def width
        @data[0][0].size
      end

      def height
        @data.size
      end

      def length
        @data[0].size
      end
    end
  end
end
