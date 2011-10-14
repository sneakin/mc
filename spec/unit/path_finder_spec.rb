require 'mc'
require 'mc/path_finder'
require 'mc/spec/path_finder'

describe MC::PathFinder do
  describe '#plot' do
    include MC::Spec::PathFinder::Plot

    context 'open room' do
      let(:map_data) do
        [ [ [7, 7, 7, 7, 7, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 7, 7, 7, 7, 7],
          ],
          [ [7, 7, 7, 7, 7, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 7, 7, 7, 7, 7],
          ],
          [ [7, 7, 7, 7, 7, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 7, 7, 7, 7, 7],
          ],
          [ [7, 7, 7, 7, 7, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 7, 7, 7, 7, 7],
          ]
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
        subject { described_class.new(world, starting, ending) }

        it "returns a list of points from the starting to destination" do
          plot.should == [ MC::Vector.new(-2, 0, -2),
                           MC::Vector.new(-3, 0, -3),
                           MC::Vector.new(-4, 0, -4)
                         ]
        end
      end

      context 'above the target' do
        let(:starting) { MC::Vector.new(1, 1, 1) }
        let(:ending) { MC::Vector.new(1, 0, 1) }

        it "returns a path that goes down to the target" do
          plot.should == [ MC::Vector.new(1, 0, 1) ]
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

      it "returns a path that gets closer to the taregt" do
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

        it "returns a path that gets closer to the target" do
          plot.should == []
        end
      end

      context 'ending point' do
        let(:starting) { MC::Vector.new(5, 0, 4) }
        let(:ending) { MC::Vector.new(1, 0, 1) }

        it "returns a path that moves closer to the target" do
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
        [ [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 7, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
          ]
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
            plot.should == [ MC::Vector.new(3, 0, 1), MC::Vector.new(2, 0, 1) ]
          end
        end

        context 'going south' do
          let(:ending) { MC::Vector.new(2, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(3, 0, 3), MC::Vector.new(2, 0, 3) ]
          end
        end
      end

      context 'west' do
        let(:starting) { MC::Vector.new(1, 0, 2) }

        context 'going north' do
          let(:ending) { MC::Vector.new(2, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(1, 0, 1), MC::Vector.new(2, 0, 1) ]
          end
        end

        context 'going south' do
          let(:ending) { MC::Vector.new(2, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(1, 0, 3), MC::Vector.new(2, 0, 3) ]
          end
        end
      end

      context 'south' do
        let(:starting) { MC::Vector.new(2, 0, 3) }

        context 'going west' do
          let(:ending) { MC::Vector.new(1, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(1, 0, 3), MC::Vector.new(1, 0, 2) ]
          end
        end

        context 'going east' do
          let(:ending) { MC::Vector.new(3, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(3, 0, 3), MC::Vector.new(3, 0, 2) ]
          end
        end
      end
    end

    context 'step' do
      context 'that is east-west' do
        let(:map_data) do
          [ [ [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [7, 7, 7, 7, 7],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
            ],
            [ [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 7, 0, 7, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
            ],
            [ [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
            ]
          ]
        end

        let(:starting) { MC::Vector.new(2, 1, 2) }

        context 'going north west' do
          let(:ending) { MC::Vector.new(1, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(2, 0, 1), MC::Vector.new(1, 0, 1) ]
          end
        end

        context 'going north east' do
          let(:ending) { MC::Vector.new(3, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(2, 0, 1), MC::Vector.new(3, 0, 1) ]
          end
        end

        context 'going south west' do
          let(:ending) { MC::Vector.new(1, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(2, 0, 3), MC::Vector.new(1, 0, 3) ]
          end
        end

        context 'going south east' do
          let(:ending) { MC::Vector.new(3, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(2, 0, 3), MC::Vector.new(3, 0, 3) ]
          end
        end
      end

      context 'that is north-south' do
        let(:map_data) do
          [ [ [0, 0, 7, 0, 0],
              [0, 0, 7, 0, 0],
              [0, 0, 7, 0, 0],
              [0, 0, 7, 0, 0],
              [0, 0, 7, 0, 0],
            ],
            [ [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
            ],
            [ [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0],
            ]
          ]
        end

        let(:starting) { MC::Vector.new(2, 1, 2) }

        context 'going north west' do
          let(:ending) { MC::Vector.new(1, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(1, 0, 2), MC::Vector.new(1, 0, 1) ]
          end
        end

        context 'going north east' do
          let(:ending) { MC::Vector.new(3, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(3, 0, 2), MC::Vector.new(3, 0, 1) ]
          end
        end

        context 'going south west' do
          let(:ending) { MC::Vector.new(1, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(1, 0, 2), MC::Vector.new(1, 0, 3) ]
          end
        end

        context 'going south east' do
          let(:ending) { MC::Vector.new(3, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ MC::Vector.new(3, 0, 2), MC::Vector.new(3, 0, 3) ]
          end
        end
      end
    end

    context 'strange step' do
      let(:map_data) do
        [ [ [0, 0, 0, 0, 0],
            [0, 0, 7, 7, 0],
            [7, 7, 7, 7, 7],
            [0, 0, 7, 7, 0],
            [0, 0, 0, 0, 0],
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 7, 0, 7, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
          ]
        ]
      end

      let(:starting) { MC::Vector.new(2, 1, 2) }

      context 'going north' do
        let(:ending) { MC::Vector.new(2, 0, 0) }

        it "straight lines to the target" do
          plot.should == [ MC::Vector.new(2, 1, 1), MC::Vector.new(2, 0, 0) ]
        end
      end

      context 'going south' do
        let(:ending) { MC::Vector.new(2, 0, 4) }

        it "straight lines to the target" do
          plot.should == [ MC::Vector.new(2, 1, 3), MC::Vector.new(2, 0, 4) ]
        end
      end
    end

    context 'step down but with headlevel obstacle' do
      let(:map_data) do
        [ [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [7, 7, 7, 7, 7],
            [0, 7, 7, 0, 0],
            [0, 0, 0, 0, 0],
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 7, 0, 7, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 7, 0],
            [0, 0, 0, 7, 0],
            [0, 0, 0, 0, 0],
          ]
        ]
      end

      let(:starting) { MC::Vector.new(2, 1, 2) }

      context 'under the obstacle' do
        let(:ending) { MC::Vector.new(3, 0, 3) }

        it "goes down and around" do
          plot.should == [ MC::Vector.new(2, 1, 3),
                           MC::Vector.new(2, 0, 4),
                           MC::Vector.new(3, 0, 4),
                           MC::Vector.new(3, 0, 3)
                         ]
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

      it "raises an error" do
        lambda { subject.plot }.should raise_error(ArgumentError)
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

    context 'into an unloaded chunk' do
      let(:map_data) do
        [ [ 0, 0, 0 ],
          [ 0, 0, 0 ],
          [ 0, 0, 0 ]
        ]
      end

      let(:starting) { MC::Vector.new(0, 0, 1) }
      let(:ending) { MC::Vector.new(10, 0, 1) }

      it "stops at the chunk" do
        plot.should == [ MC::Vector.new(1, 0, 1),
                         MC::Vector.new(2, 0, 1)
                       ]
      end

      context 'when the chunk is loaded after the path is calculated' do
        it "routes into the chunk"
      end
    end

    context 'from position that is not centered on a block' do
      it "makes the first move to the center of the block"
    end

    context 'position update after initial calculation' do
      context 'along the path' do
        it "does not change the rest of the path to the target"
      end

      context 'off the path' do
        it "recalculates the rest of the path to the target"
      end
    end

    context 'target update after initial calculation' do
      context 'along the path' do
        it "shortens the path"
      end

      context 'off of the path' do
        it "recalculates the path to the new target"
      end
    end

    context "map update after path calculation" do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 0, 0, 0, 0, 7],
          [7, 7, 7, 7, 7, 7],
        ]
      end

      let(:starting) { MC::Vector.new(1, 0, 1) }
      let(:ending) { MC::Vector.new(4, 0, 4) }

      before do
        # initial path
        path = plot
        path.should_not == []

        # take a a step on the path
        subject.position = path[0]
      end

      context 'that has a passable door' do
        before do
          # add a wall with a door
          1.upto(3) do |z|
            world[3, 0, z].type = 7
            subject.map_updated_at(MC::Vector.new(3, 0, z))
          end
        end

        it "routes through the door from the new position" do
          subject.plot.should == [ MC::Vector.new(2, 0, 3),
                                   MC::Vector.new(2, 0, 4),
                                   MC::Vector.new(3, 0, 4),
                                   MC::Vector.new(4, 0, 4)
                                 ]
        end
      end

      context 'that has NO passable door' do
        before do
          # add a wall
          1.upto(4) do |z|
            world[3, 0, z].type = 7
            subject.map_updated_at(MC::Vector.new(3, 0, z))
          end
        end

        it "returns no path" do
          subject.plot.should == [ MC::Vector.new(1, 0, 1) ]
        end
      end
    end

    context 'in a map with head level obstacles' do
      let(:map_data) do
        [ 
         [ [7, 7, 7, 7, 7, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 7, 7, 7, 7, 7]
          ],
          [ [7, 7, 7, 7, 7, 7],
            [7, 0, 0, 7, 0, 7],
            [7, 7, 0, 7, 0, 7],
            [7, 0, 0, 7, 0, 7],
            [7, 0, 0, 0, 0, 7],
            [7, 7, 7, 7, 7, 7]
          ]
        ]
      end

      let(:starting) { MC::Vector.new(1, 0, 1) }
      let(:ending) { MC::Vector.new(4, 0, 4) }

      it "zigs and zags around the partial wall" do
        plot.should == [ MC::Vector.new(2, 0, 1),
                         MC::Vector.new(2, 0, 2),
                         MC::Vector.new(2, 0, 3),
                         MC::Vector.new(2, 0, 4),
                         MC::Vector.new(3, 0, 4),
                         MC::Vector.new(4, 0, 4)
                       ]
      end
    end

    context 'in a map with hurdles' do
      let(:map_data) do
        [ 
         [ [7, 7, 7, 7, 7, 7],
           [7, 0, 0, 7, 0, 7],
           [7, 7, 7, 7, 0, 7],
           [7, 7, 0, 7, 0, 7],
           [7, 0, 0, 7, 0, 7],
           [7, 7, 7, 7, 7, 7]
         ],
         [ [7, 7, 7, 7, 7, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 7, 7, 7, 7, 7]
         ],
         [ [7, 7, 7, 7, 7, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 0, 0, 0, 0, 7],
           [7, 7, 7, 7, 7, 7]
         ],
        ]
      end

      let(:starting) { MC::Vector.new(1, 0, 1) }
      let(:ending) { MC::Vector.new(4, 0, 4) }

      it "zigs and zags around the partial wall" do
        path = plot
        path.should == [ MC::Vector.new(1, 1, 2),
                         MC::Vector.new(2, 0, 3),
                         MC::Vector.new(3, 1, 3),
                         MC::Vector.new(4, 0, 3),
                         MC::Vector.new(4, 0, 4)
                       ]
      end
    end

    context 'dropping from a cliff'
    context 'with minable obstacles'
    context 'with water'
    context 'with lava'
  end
end
