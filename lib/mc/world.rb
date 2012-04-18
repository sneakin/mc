require 'pry'

module MC
  class World
    class Block
      attr_accessor :type, :metadata, :lights, :sky_light

      def initialize(type = 0, metadata = 0, loaded = false)
        self.type = type
        self.metadata = metadata
        @loaded = loaded
      end

      def update(update_block)
        self.type = update_block.type
        self.metadata = update_block.metadata
        self.lights = update_block.lights if update_block.lights
        self.sky_light = update_block.sky_light if update_block.sky_light
        @loaded = true
      end

      def loaded?
        @loaded
      end

      def bed_rock?
        type == 7
      end

      def door?
        type == 64 || type == 71
      end

      def solid?
        type != 0 && type != 72 && type != 70 && type != 50 && type != 75 && type != 76
      end

      def liquid?
        [ 8, 9, 10, 11 ].include?(type)
      end

      def passable_from?(face)
        return !solid? unless door?
        return false if face == Face_Top || face == Face_Bottom

        hinge = metadata & 0x3
        if (metadata & 0x4) != 0
          case hinge
          when 0 then face != Face_East && face != Face_West # NE
          when 1 then face != Face_South && face != Face_North # SE hinge
          when 2 then face != Face_West && face != Face_East # SW
          when 3 then face != Face_North && face != Face_South # NW
          end
        else
          case hinge
          when 0 then face != Face_North && face != Face_South # NE
          when 1 then face != Face_East && face != Face_West # SE hinge
          when 2 then face != Face_South && face != Face_North # SW
          when 3 then face != Face_West && face != Face_East # NW
          end
        end
      end

      def strength
        if type == 7 || type == 8 || type == 9 || type == 10 || type == 11
          (1.0 / 0)
        elsif type == 0 || type == 50 || type == 75 || type == 76
          0
        elsif type == 64
          1.0
        elsif type == 18
          40.0
        elsif type == 3 || type == 2
          80.0
        else
          100.0
        end
      end
    end

    class ChunkUpdate
      attr_reader :size

      def initialize(size = nil)
        @size = size || Vector.new(16, 256, 16)
        @blocks = Array.new
        @size.z.times do |z|
          @blocks[z] = Array.new
          @size.y.times do |y|
            @blocks[z][y] = Array.new
            @size.x.times do |x|
              @blocks[z][y][x] = Block.new
            end
          end
        end
      end

      def [](x, y, z)
        @blocks[z][y][x]
      end
    end

    class Chunk
      Width = 16
      Height = 256
      Length = 16

      def initialize(x, z, height = Height)
        @x = x
        @z = z
        @height = height
        @blocks = Array.new(height) do
          Array.new(Length) do
            Array.new(Width) do
              Block.new
            end
          end
        end
      end

      def [](x, y, z)
        @blocks[y][z][x]
      end

      def absolute_block(x, y, z)
        self[x.to_i & 15, y.to_i, z.to_i & 15]
      end
    end

    attr_accessor :time, :spawn_position, :height, :dimension, :seed, :difficulty, :creative, :type
    attr_reader :chunks

    def initialize
      @height = 256
      @chunks = Hash.new { |h, x| h[x] = Hash.new { |hh, z| hh[z] = Chunk.new(x, z, height) } }
    end

    def allocate_chunk(x, z)
      #self.chunks[x][z] = Chunk.new(x, z, height)
    end

    def free_chunk(x, z)
      self.chunks[x].delete(z)
    end

    def update_chunk(position, chunk_update)
      chunk = chunks[position.x >> 4][position.z >> 4]
      c_p = Vector.new(position.x & 15, position.y, position.z & 15)

      chunk_update.size.z.times do |z|
        chunk_update.size.y.times do |y|
          chunk_update.size.x.times do |x|
            begin
              chunk[x, position.y + y, z].update(chunk_update[x, y, z])
#MC.logger.debug("Update chunk #{position} + #{x}, #{y}, #{z}\t#{chunk_update[x, y, z].inspect}")
            rescue
              raise "#{$!} raised at #{x}, #{y}, #{z}"
            end
          end
        end
      end
    end

    def multi_block_change(chunk_x, chunk_z, updates)
      chunk = chunks[chunk_x][chunk_z]
      updates.each do |(position, block)|
        chunk[position.x, position.y, position.z].update(block)
      end
    end

    def chunk_at(x, y, z)
      chunks[x.to_i >> 4][z.to_i >> 4]
    end

    def [](x, y, z)
      chunk_at(x, y, z).absolute_block(x, y, z)
    end

    def each_chunk
      chunks.each do |x, row_chunks|
        row_chunks.each do |z, chunk|
          yield(x, z, chunk)
        end
      end
    end

    def number_of_chunks
      chunks.size + chunks.inject(0) { |acc, (k, v)| acc += v.size }
    end
  end
end
