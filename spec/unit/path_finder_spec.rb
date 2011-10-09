require 'mc'
require 'mc/path_finder'
require 'mc/spec/path_finder'

describe MC::PathFinder do
  describe '#plot' do
    include MC::Spec::PathFinder::Plot

    context 'open room' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 7, 7, 7, 7, 7],
        ]
      end

      context 'already at destination' do
        let(:starting) { MC::Vector.new(1, 0, 1) }
        let(:ending) { MC::Vector.new(1, 0, 1) }

        it "returns an empty list" do
          plot.should == [ ]
        end
      end

      context 'straight line' do
        let(:starting) { MC::Vector.new(1, 0, 1) }
        let(:ending) { MC::Vector.new(4, 0, 4) }

        it "returns a list of points from the starting to destination" do
          plot.should == [ MC::Vector.new(2, 0, 2),
                           MC::Vector.new(3, 0, 3),
                           MC::Vector.new(4, 0, 4)
                         ]
        end
      end

      context 'starting and destination flipped' do
        let(:starting) { MC::Vector.new(4, 0, 4) }
        let(:ending) { MC::Vector.new(1, 0, 1) }

        it "returns a list of points from the starting to destination" do
          plot.should == [ MC::Vector.new(3, 0, 3),
                           MC::Vector.new(2, 0, 2),
                           MC::Vector.new(1, 0, 1)
                         ]
        end
      end

      context 'negative map offset' do
        let(:starting) { MC::Vector.new(-1, 0, -1) }
        let(:ending) { MC::Vector.new(-4, 0, -4) }

        let(:world) { MC::Spec::TestWorld.new(map_data, -5, -5) }
        subject { described_class.new(world) }

        it "returns a list of points from the starting to destination" do
          plot.should == [ MC::Vector.new(-2, 0, -2),
                           MC::Vector.new(-3, 0, -3),
                           MC::Vector.new(-4, 0, -4)
                         ]
        end
      end
    end

    context 'obstructing wall with door' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 0, 7],
          [7, 7, 7, 7, 7, 7, 7],
        ]
      end

      let(:starting) { MC::Vector.new(1, 0, 1) }
      let(:ending) { MC::Vector.new(4, 0, 4) }

      it "returns a list of points from the starting to destination" do
        plot.should == [ MC::Vector.new(1, 0, 2),
                         MC::Vector.new(1, 0, 3),
                         MC::Vector.new(1, 0, 4),
                         MC::Vector.new(2, 0, 4),
                         MC::Vector.new(3, 0, 4),
                         MC::Vector.new(4, 0, 4)
                       ]
      end
    end

    context 'simple maze' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 7, 0, 7],
          [7, 0, 7, 0, 7, 0, 7],
          [7, 0, 0, 0, 7, 0, 7],
          [7, 7, 7, 7, 7, 7, 7],
        ]
      end

      let(:starting) { MC::Vector.new(1, 0, 1) }
      let(:ending) { MC::Vector.new(5, 0, 4) }

      it "returns a list of points from the starting to destination" do
        plot.should == [ MC::Vector.new(1, 0, 2),
                         MC::Vector.new(1, 0, 3),
                         MC::Vector.new(1, 0, 4),
                         MC::Vector.new(2, 0, 4),
                         MC::Vector.new(3, 0, 4),
                         MC::Vector.new(3, 0, 3),
                         MC::Vector.new(3, 0, 2),
                         MC::Vector.new(3, 0, 1),
                         MC::Vector.new(4, 0, 1),
                         MC::Vector.new(5, 0, 1),
                         MC::Vector.new(5, 0, 2),
                         MC::Vector.new(5, 0, 3),
                         MC::Vector.new(5, 0, 4),
                       ]
      end
    end

    context 'solid wall, no solution' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 7, 7, 7, 7, 7, 7],
        ]
      end

      let(:starting) { MC::Vector.new(1, 0, 1) }
      let(:ending) { MC::Vector.new(5, 0, 4) }

      it "returns a list of points that moves closer" do
        plot.should == [ MC::Vector.new(1, 0, 2),
                         MC::Vector.new(1, 0, 3),
                         MC::Vector.new(1, 0, 4)
                       ]
      end
    end

    context 'boxed' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 7, 7, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 0, 7],
          [7, 7, 7, 7, 7, 7, 7],
        ]
      end

      context 'starting point' do
        let(:starting) { MC::Vector.new(1, 0, 1) }
        let(:ending) { MC::Vector.new(5, 0, 4) }

        it "returns an empty list" do
          plot.should == []
        end
      end

      context 'ending point' do
        let(:starting) { MC::Vector.new(5, 0, 4) }
        let(:ending) { MC::Vector.new(1, 0, 1) }

        it "returns a list moving towards the ending" do
          plot.should == [ MC::Vector.new(4, 0, 4),
                           MC::Vector.new(3, 0, 4),
                           MC::Vector.new(2, 0, 4),
                           MC::Vector.new(1, 0, 4)
                         ]
        end
      end
    end

    context 'cornering' do
      let(:map_data) do
        [ [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 7, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ]
      end

      context 'north' do
        let(:starting) { MC::Vector.new(2, 0, 1) }

        context 'going west' do
          let(:ending) { MC::Vector.new(1, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(1, 0, 1), MC::Vector.new(1, 0, 2) ]
          end
        end

        context 'going east' do
          let(:ending) { MC::Vector.new(3, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(3, 0, 1), MC::Vector.new(3, 0, 2) ]
          end
        end
      end

      context 'east' do
        let(:starting) { MC::Vector.new(3, 0, 2) }

        context 'going north' do
          let(:ending) { MC::Vector.new(2, 0, 1) }

          it "does not cut the corner" do
            subject.plot(starting, ending).should == [ MC::Vector.new(3, 0, 1), MC::Vector.new(2, 0, 1) ]
          end
        end

        context 'going south' do
          let(:ending) { MC::Vector.new(2, 0, 3) }

          it "does not cut the corner" do
            subject.plot(starting, ending).should == [ MC::Vector.new(3, 0, 3), MC::Vector.new(2, 0, 3) ]
          end
        end
      end

      context 'west' do
        let(:starting) { MC::Vector.new(1, 0, 2) }

        context 'going north' do
          let(:ending) { MC::Vector.new(2, 0, 1) }

          it "does not cut the corner" do
            subject.plot(starting, ending).should == [ MC::Vector.new(1, 0, 1), MC::Vector.new(2, 0, 1) ]
          end
        end

        context 'going south' do
          let(:ending) { MC::Vector.new(2, 0, 3) }

          it "does not cut the corner" do
            subject.plot(starting, ending).should == [ MC::Vector.new(1, 0, 3), MC::Vector.new(2, 0, 3) ]
          end
        end
      end

      context 'south' do
        let(:starting) { MC::Vector.new(2, 0, 3) }

        context 'going west' do
          let(:ending) { MC::Vector.new(1, 0, 2) }

          it "does not cut the corner" do
            subject.plot(starting, ending).should == [ MC::Vector.new(1, 0, 3), MC::Vector.new(1, 0, 2) ]
          end
        end

        context 'going east' do
          let(:ending) { MC::Vector.new(3, 0, 2) }

          it "does not cut the corner" do
            subject.plot(starting, ending).should == [ MC::Vector.new(3, 0, 3), MC::Vector.new(3, 0, 2) ]
          end
        end
      end
    end

    context 'into blocked cell' do
      let(:map_data) do
        [ [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 7, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ]
      end

      let(:starting) { MC::Vector.new(0, 0, 0) }
      let(:ending) { MC::Vector.new(2, 0, 2)}

      it "does not try to cerate a path" do
        plot.should == []
      end
    end

    context 'around a wall' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7],
          [7, 0, 0, 0, 7, 7],
          [7, 0, 0, 0, 7, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 7, 7, 7, 0, 7],
          [7, 0, 0, 0, 0, 7],
          [0, 0, 0, 0, 7, 7],
          [0, 0, 0, 7, 7, 7],
        ]
      end

      context 'north to south' do
        let(:starting) { MC::Vector.new(3, 0, 1) }
        let(:ending) { MC::Vector.new(3, 0, 6) }

        it "does goes around the corner" do
          plot.should == [ MC::Vector.new(3, 0, 2),
                           MC::Vector.new(3, 0, 3),
                           MC::Vector.new(4, 0, 3),
                           MC::Vector.new(4, 0, 4),
                           MC::Vector.new(4, 0, 5),
                           MC::Vector.new(3, 0, 5),
                           MC::Vector.new(3, 0, 6)
                         ]
        end
      end

      context 'south to north' do
        let(:starting) { MC::Vector.new(3, 0, 6) }
        let(:ending) { MC::Vector.new(3, 0, 1) }

        it "does goes around the corner" do
          plot.should == [ MC::Vector.new(3, 0, 5),
                           MC::Vector.new(4, 0, 5),
                           MC::Vector.new(4, 0, 4),
                           MC::Vector.new(4, 0, 3),
                           MC::Vector.new(3, 0, 3),
                           MC::Vector.new(3, 0, 2),
                           MC::Vector.new(3, 0, 1)
                         ]
        end
      end
    end

    context 'into an unloaded chunk'
  end
end
