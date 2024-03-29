module MC
  autoload :GUI, 'mc/gui'

  module Spec
    autoload :TestWorld, 'mc/spec/test_world'

    module PathFinder
      module Plot
        def self.included(base)
          base.let(:world) { TestWorld.new(map_data) }
          base.subject { described_class.new(world, starting, ending) }
        end

        def plot(steps = described_class.const_get('MaxSteps'))
          subject.plot(steps)
        end

        def dump_map
          size = (ending - starting).abs
          m = GUI::Mapper.new(world, size.x + 4, size.z + 4)
          m.position = starting + (size / 2.0)
          $stderr.write("\n")
          m.draw_world($stderr)
          $stderr.puts("World:\t#{world.width}, #{world.height}, #{world.length}")
          world.origin_z.upto(world.origin_z + world.length - 1) do |z|
            world.origin_y.upto(world.origin_y + world.height - 1) do |y|
              world.origin_x.upto(world.origin_x + world.width - 1) do |x|
                $stderr.write("%3i " % [ world[x, y, z].try(:type) ])
              end
              $stderr.write("   ")
            end
            $stderr.write("\n")
          end
          $stderr.write("\n")
        end
      end
    end
  end
end
