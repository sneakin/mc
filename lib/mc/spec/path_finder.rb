module MC
  module Spec
    autoload :TestWorld, 'mc/spec/test_world'

    module PathFinder
      module Plot
        def self.included(base)
          base.let(:world) { TestWorld.new(map_data) }
          base.subject { described_class.new(world) }
        end

        def plot
          subject.target = ending
          subject.position = starting
          subject.plot
        end

        def dump_map(world)
          world.origin_z.upto(world.origin_z + world.height - 1) do |z|
            world.origin_x.upto(world.origin_x + world.width - 1) do |x|
              $stderr.write("#{world[x, 0, z].try(:type)}")
            end
            $stderr.write("\n")
          end
        end
      end
    end
  end
end
