require 'rspec-prof'
require 'benchmark'
require 'mc/path_finder'
require 'mc/spec/path_finder'

describe MC::PathFinder do
  describe '#plot' do
    include MC::Spec::PathFinder::Plot

    context 'repeated runs' do
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
          93
        else
          110
        end
      end

      it "plots a valid path" do
        path = plot
        path.first.should == starting
        path.last.should == ending
      end

      context 'without resets between plots' do
        it "is faster on the second run" do
          initial_times = Benchmark.measure { plot }
          times = Benchmark.measure { plot }

          times.real.should <= initial_times.real
        end
      end

      context 'with resets after each plot' do 
        it "remains faster than the expected time" do
          times = Benchmark.measure do
            runs.times { subject.reset!; plot.should_not be_empty }
          end

          MC.logger.debug("#{described_class}\#plot benchmark: #{times}")
          times.real.should_not >= expected_total_time
        end

        profile do
          it "should be awesome" do
            100.times { subject.reset!; plot.should_not be_empty }
          end
        end
      end
    end
  end
end
