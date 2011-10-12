module MC
  module Spec
    autoload :TestWorld, 'mc/spec/test_world'

    module PathFinder
      module Plot
        def self.included(base)
          base.let(:world) { TestWorld.new(map_data) }
          base.subject { described_class.new(world, starting, ending) }
        end

        def plot
          subject.plot
        end

        def dump_map(world)
          $stderr.puts("World:\t#{world.width}, #{world.height}, #{world.length}")
          world.origin_y.upto(world.origin_y + world.height - 1) do |y|
            world.origin_z.upto(world.origin_z + world.length - 1) do |z|
              world.origin_x.upto(world.origin_x + world.width - 1) do |x|
                $stderr.write("#{world[x, y, z].try(:type)}")
              end
              $stderr.write("\n")
            end
            $stderr.write("\n")
            $stderr.write("\n")
          end
        end
      end
    end
  end
end
