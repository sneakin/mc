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
          subject.plot(starting, ending)
        end
      end
    end
  end
end
