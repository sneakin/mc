require 'mc/path_finder'
require 'mc/spec/path_finder'

describe MC::PathFinder do
  describe '#plot' do
    include MC::Spec::PathFinder::Plot

    context 'memory use' do
      let(:map_data) do
        [ [ 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7],
          [ 7, 0, 7, 0, 0, 0, 7, 7, 0, 0, 0, 0, 0, 0, 7],
          [ 7, 0, 7, 0, 7, 0, 0, 7, 0, 7, 7, 7, 7, 0, 7],
          [ 7, 0, 7, 0, 0, 7, 0, 7, 0, 7, 0, 0, 0, 0, 7],
          [ 7, 0, 7, 7, 0, 7, 0, 7, 0, 7, 0, 7, 7, 7, 7],
          [ 7, 0, 7, 0, 0, 7, 0, 7, 0, 7, 0, 0, 0, 0, 7],
          [ 7, 0, 7, 0, 7, 0, 0, 7, 0, 7, 7, 7, 7, 0, 7],
          [ 7, 0, 7, 0, 7, 0, 7, 7, 0, 0, 0, 0, 7, 0, 7],
          [ 7, 0, 7, 0, 7, 0, 7, 7, 7, 7, 7, 0, 7, 0, 7],
          [ 7, 0, 7, 0, 7, 0, 0, 0, 0, 0, 7, 0, 7, 0, 7],
          [ 7, 0, 7, 0, 7, 7, 7, 7, 7, 0, 7, 0, 7, 0, 7],
          [ 7, 0, 7, 0, 0, 0, 0, 0, 7, 0, 7, 0, 7, 0, 7],
          [ 7, 0, 7, 7, 7, 7, 7, 0, 7, 0, 7, 7, 7, 0, 7],
          [ 7, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 7],
          [ 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7]
        ]
      end

      let(:starting) { MC::Vector.new(1, 0, 1) }
      let(:ending) { MC::Vector.new(13, 0, 13) }
      let(:runs) { 1000 }

      let(:expected_total_time) do
        if RUBY_VERSION =~ /^1\.8/
          21.0
        else
          7.0
        end
      end

      it "is still faster than 0.03 of a second after being called multiple times" do
        times = Benchmark.measure do
          runs.times { plot.should_not be_empty }
        end

        times.real.should_not >= expected_total_time
      end
    end
  end
end