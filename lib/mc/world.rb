module MC
  class World
    class Block
      attr_accessor :type, :metadata, :lights, :sky_light

      def initialize(type = 1, metadata = 0)
        self.type = type
        self.metadata = metadata
      end

      def update(update_block)
        self.type = update_block.type
        self.metadata = update_block.metadata
        self.lights = update_block.lights if update_block.lights
        self.sky_light = update_block.sky_light if update_block.sky_light
      end
    end

    class ChunkUpdate
      attr_reader :size

      def initialize(size)
        @size = size
        @blocks = Array.new
        size.z.times do |z|
          @blocks[z] = Array.new
          size.y.times do |y|
            @blocks[z][y] = Array.new
            size.x.times do |x|
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
      Height = 128
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
    end

    attr_accessor :time, :spawn_position, :height, :dimension, :seed
    attr_reader :chunks

    def initialize
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
      c_p = Vector.new(position.x & 15, position.y & 127, position.z & 15)

      chunk_update.size.z.times do |z|
        chunk_update.size.y.times do |y|
          chunk_update.size.x.times do |x|
            chunk[c_p.x + x, c_p.y + y, c_p.z + z].update(chunk_update[x, y, z])
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

    def [](x, y, z)
      chunk = chunks[x >> 4][z >> 4]
      c_p = Vector.new(x & 15, y & 127, z & 15)

      chunk[c_p.x, c_p.y, c_p.z]
    end
  end
end
