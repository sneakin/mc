module MC
  module Spec
    class TestWorld
      def initialize(data, origin_x = 0, origin_z = 0)
        @data = data.collect { |row|
          row.collect { |block_id| MC::World::Block.new(block_id) }
        }
        @origin_x = origin_x
        @origin_z = origin_z
      end

      def [](x, y, z)
        @data[z - @origin_z][x - @origin_x]
      end
    end
  end
end
