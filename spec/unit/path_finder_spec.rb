require 'mc'
require 'mc/path_finder'
require 'mc/spec/path_finder'
require 'mc/spec/helpers'

describe MC::PathFinder do
  include MC::Spec::Helpers

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
        let(:starting) { v(1, 0, 1) }
        let(:ending) { v(1, 0, 1) }

        it "raises an InvalidTargetError" do
          lambda { plot }.should raise_error(MC::PathFinder::InvalidTargetError)
        end
      end

      context 'straight line' do
        let(:starting) { v(1, 0, 1) }
        let(:ending) { v(4, 0, 4) }

        it "returns a list of points from the starting to destination" do
          plot.should == [ v(1, 0, 1),
                           v(2, 0, 2),
                           v(3, 0, 3),
                           v(4, 0, 4)
                         ]
        end
      end

      context 'starting and destination flipped' do
        let(:starting) { v(4, 0, 4) }
        let(:ending) { v(1, 0, 1) }

        it "returns a list of points from the starting to destination" do
          plot.should == [ v(4, 0, 4),
                           v(3, 0, 3),
                           v(2, 0, 2),
                           v(1, 0, 1)
                         ]
        end
      end

      context 'negative map offset' do
        let(:starting) { v(-1, 0, -1) }
        let(:ending) { v(-4, 0, -4) }

        let(:world) { MC::Spec::TestWorld.new(map_data, -5, -5) }
        subject { described_class.new(world, starting, ending) }

        it "returns a list of points from the starting to destination" do
          plot.should == [ v(-1, 0, -1),
                           v(-2, 0, -2),
                           v(-3, 0, -3),
                           v(-4, 0, -4)
                         ]
        end
      end

      context 'above the target' do
        let(:starting) { v(1, 1, 1) }
        let(:ending) { v(1, 0, 1) }

        it "returns a path that goes down to the target" do
          plot.should == [ v(1, 1, 1),
                           v(1, 0, 1) ]
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

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(4, 0, 4) }

      it "returns a list of points from the starting to destination" do
        plot.should == [ v(1, 0, 1),
                         v(1, 0, 2),
                         v(1, 0, 3),
                         v(1, 0, 4),
                         v(2, 0, 4),
                         v(3, 0, 4),
                         v(4, 0, 4)
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

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(5, 0, 4) }

      it "returns a list of points from the starting to destination" do
        plot.should == [ v(1, 0, 1),
                         v(1, 0, 2),
                         v(1, 0, 3),
                         v(1, 0, 4),
                         v(2, 0, 4),
                         v(3, 0, 4),
                         v(3, 0, 3),
                         v(3, 0, 2),
                         v(3, 0, 1),
                         v(4, 0, 1),
                         v(5, 0, 1),
                         v(5, 0, 2),
                         v(5, 0, 3),
                         v(5, 0, 4),
                       ]
      end
    end

    context 'solid wall' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 0, 7, 0, 0, 0, 7],
          [7, 7, 7, 7, 7, 7, 7],
        ]
      end

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(5, 0, 4) }

      it "returns a path that gets closer to the taregt" do
        plot.should == [ v(1, 0, 1),
                         v(1, 0, 2),
                         v(1, 0, 3),
                         v(1, 0, 4)
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
        let(:starting) { v(1, 0, 1) }
        let(:ending) { v(5, 0, 4) }

        it "raises an InvalidPathError" do
          lambda { plot }.should raise_error(MC::PathFinder::InvalidPathError)
        end
      end

      context 'ending point' do
        let(:starting) { v(5, 0, 4) }
        let(:ending) { v(1, 0, 1) }

        it "returns a path that moves closer to the target" do
          plot.should == [ v(5, 0, 4),
                           v(4, 0, 3),
                           v(3, 0, 2),
                           v(3, 0, 1)
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
        let(:starting) { v(2, 0, 1) }

        context 'going west' do
          let(:ending) { v(1, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ v(2, 0, 1),
                             v(1, 0, 1),
                             v(1, 0, 2) ]
          end
        end

        context 'going east' do
          let(:ending) { v(3, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ v(2, 0, 1),
                             v(3, 0, 1),
                             v(3, 0, 2) ]
          end
        end
      end

      context 'east' do
        let(:starting) { v(3, 0, 2) }

        context 'going north' do
          let(:ending) { v(2, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ v(3, 0, 2),
                             v(3, 0, 1),
                             v(2, 0, 1) ]
          end
        end

        context 'going south' do
          let(:ending) { v(2, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ v(3, 0, 2),
                             v(3, 0, 3),
                             v(2, 0, 3) ]
          end
        end
      end

      context 'west' do
        let(:starting) { v(1, 0, 2) }

        context 'going north' do
          let(:ending) { v(2, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ v(1, 0, 2),
                             v(1, 0, 1),
                             v(2, 0, 1) ]
          end
        end

        context 'going south' do
          let(:ending) { v(2, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ v(1, 0, 2),
                             v(1, 0, 3),
                             v(2, 0, 3) ]
          end
        end
      end

      context 'south' do
        let(:starting) { v(2, 0, 3) }

        context 'going west' do
          let(:ending) { v(1, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ v(2, 0, 3),
                             v(1, 0, 3),
                             v(1, 0, 2) ]
          end
        end

        context 'going east' do
          let(:ending) { v(3, 0, 2) }

          it "does not cut the corner" do
            plot.should == [ v(2, 0, 3),
                             v(3, 0, 3),
                             v(3, 0, 2) ]
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

        let(:starting) { v(2, 1, 2) }

        context 'going north west' do
          let(:ending) { v(1, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(2, 0, 1),
                             v(1, 0, 1) ]
          end
        end

        context 'going north east' do
          let(:ending) { v(3, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(2, 0, 1),
                             v(3, 0, 1) ]
          end
        end

        context 'going south west' do
          let(:ending) { v(1, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(2, 0, 3),
                             v(1, 0, 3) ]
          end
        end

        context 'going south east' do
          let(:ending) { v(3, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(2, 0, 3),
                             v(3, 0, 3) ]
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

        let(:starting) { v(2, 1, 2) }

        context 'going north west' do
          let(:ending) { v(1, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(1, 0, 2),
                             v(1, 0, 1) ]
          end
        end

        context 'going north east' do
          let(:ending) { v(3, 0, 1) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(3, 0, 2),
                             v(3, 0, 1) ]
          end
        end

        context 'going south west' do
          let(:ending) { v(1, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(1, 0, 2),
                             v(1, 0, 3) ]
          end
        end

        context 'going south east' do
          let(:ending) { v(3, 0, 3) }

          it "does not cut the corner" do
            plot.should == [ v(2, 1, 2),
                             v(3, 0, 2),
                             v(3, 0, 3) ]
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

      let(:starting) { v(2, 1, 2) }

      context 'going north' do
        let(:ending) { v(2, 0, 0) }

        it "straight lines to the target" do
          plot.should == [ v(2, 1, 2),
                           v(2, 1, 1),
                           v(2, 0, 0) ]
        end
      end

      context 'going south' do
        let(:ending) { v(2, 0, 4) }

        it "straight lines to the target" do
          plot.should == [ v(2, 1, 2),
                           v(2, 1, 3),
                           v(2, 0, 4) ]
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

      let(:starting) { v(2, 1, 2) }

      context 'under the obstacle' do
        let(:ending) { v(3, 0, 3) }

        it "goes down and around" do
          plot.should == [ v(2, 1, 2),
                           v(2, 1, 3),
                           v(2, 0, 4),
                           v(3, 0, 4),
                           v(3, 0, 3)
                         ]
        end
      end
    end

    context 'step up but with an overhead obstacle' do
      let(:map_data) do
        [ [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [7, 7, 7, 7, 7],
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
            [7, 7, 7, 7, 0],
            [0, 0, 0, 0, 0],
          ]
        ]
      end

      let(:starting) { v(2, 0, 4) }

      context 'under the obstacle' do
        let(:ending) { v(2, 0, 1) }

        it "goes down and around" do
          plot.should == [ v(2, 0, 4),
                           v(3, 0, 3),
                           v(4, 0, 3),
                           v(4, 1, 2),
                           v(3, 1, 2),
                           v(3, 0, 1),
                           v(2, 0, 1)
                         ]
        end
      end
    end

    context 'into blocked cell of bedrock' do
      let(:map_data) do
        [ [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 7, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ]
      end

      let(:starting) { v(0, 0, 0) }
      let(:ending) { v(2, 0, 2)}

      it "raises an error" do
        lambda { subject.plot }.should raise_error(MC::PathFinder::InvalidTargetError)
      end
    end

    context 'into a blocked cell of stone' do
      let(:map_data) do
        [ [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ]
      end

      let(:starting) { v(0, 0, 0) }
      let(:ending) { v(2, 0, 2)}

      it "plots a path into the stone" do
        plot.should == [ v(0, 0, 0),
                         v(1, 0, 1),
                         v(2, 0, 2)
                       ]
      end
    end

    context 'from a column of stone' do
      let(:map_data) do
        [ [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
        ]
      end

      let(:starting) { v(2, 8, 2) }

      context 'target below' do
        let(:ending) { v(1, 0, 1)}

        it "plots a path to dig out the column" do
          plot.should == [ v(2, 8, 2),
                           v(2, 7, 2),
                           v(2, 6, 2),
                           v(2, 5, 2),
                           v(2, 4, 2),
                           v(2, 3, 2),
                           v(2, 2, 2),
                           v(2, 1, 2),
                           v(1, 0, 1)
                         ]
        end
      end

      context 'target above' do
        let(:ending) { v(1, 9, 1)}

        it "raises an InvalidPathError" do
          lambda { plot }.should raise_error(MC::PathFinder::InvalidPathError)
        end
      end
    end

    context 'from a column of bedrock' do
      let(:map_data) do
        [ [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 7, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 7, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 7, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 7, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
          [ [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0]
          ],
        ]
      end

      let(:starting) { v(2, 4, 2) }
      let(:ending) { v(1, 0, 1)}

      it "plots a path that jumps off" do
        plot.should == [ v(2, 4, 2),
                         v(1, 3, 1),
                         v(1, 2, 1),
                         v(1, 1, 1),
                         v(1, 0, 1)
                       ]
      end
    end

    context 'into a solid wall of stone' do
      let(:map_data) do
        [ [0, 0, 1, 1, 1, 1, 1, 1],
          [0, 0, 1, 1, 1, 1, 1, 1],
          [0, 0, 1, 1, 1, 1, 1, 1],
          [0, 0, 1, 1, 1, 1, 1, 1],
          [0, 0, 1, 1, 1, 1, 1, 1],
        ]
      end

      context 'straight line path' do
        let(:starting) { v(0, 0, 2) }
        let(:ending) { v(7, 0, 2)}

        it "plots a path to the target through the stone" do
          plot.should == [ v(0, 0, 2),
                           v(1, 0, 2),
                           v(2, 0, 2),
                           v(3, 0, 2),
                           v(4, 0, 2),
                           v(5, 0, 2),
                           v(6, 0, 2),
                           v(7, 0, 2)
                         ]
        end
      end

      context 'next square' do
        let(:starting) { v(1, 0, 2) }
        let(:ending) { v(3, 0, 2)}

        it "plots a path to the target through the stone" do
          plot.should == [ v(1, 0, 2),
                           v(2, 0, 2),
                           v(3, 0, 2)
                         ]
        end
      end

      context 'diagonal path' do
        let(:starting) { v(0, 0, 0) }
        let(:ending) { v(4, 0, 4)}

        it "plots a path to the target through the stone, without cutting corners, with a preference to not dig" do
          plot.should == [ v(0, 0, 0),
                           v(1, 0, 1),
                           v(1, 0, 2),
                           v(1, 0, 3),
                           v(1, 0, 4),
                           v(2, 0, 4),
                           v(3, 0, 4),
                           v(4, 0, 4)
                         ]
        end
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
        let(:starting) { v(3, 0, 1) }
        let(:ending) { v(3, 0, 6) }

        it "does goes around the corner" do
          plot.should == [ v(3, 0, 1),
                           v(3, 0, 2),
                           v(3, 0, 3),
                           v(4, 0, 3),
                           v(4, 0, 4),
                           v(4, 0, 5),
                           v(3, 0, 5),
                           v(3, 0, 6)
                         ]
        end
      end

      context 'south to north' do
        let(:starting) { v(3, 0, 6) }
        let(:ending) { v(3, 0, 1) }

        it "does goes around the corner" do
          plot.should == [ v(3, 0, 6),
                           v(3, 0, 5),
                           v(4, 0, 5),
                           v(4, 0, 4),
                           v(4, 0, 3),
                           v(3, 0, 3),
                           v(3, 0, 2),
                           v(3, 0, 1)
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

      let(:starting) { v(0, 0, 1) }
      let(:ending) { v(10, 0, 1) }

      it "stops at the chunk" do
        plot.should == [ v(0, 0, 1),
                         v(1, 0, 1),
                         v(2, 0, 1)
                       ]
      end
    end

    context 'from position that is not centered on a block' do
      let(:map_data) do
        [ [ 0, 0, 0 ],
          [ 0, 0, 0 ],
          [ 0, 0, 0 ]
        ]
      end

      let(:ending) { v(2, 0, 2) }

      context 'positive starting' do
        let(:starting) { v(0.25, 0, 0.75) }

        it "makes the first move to the center of the block" do
          plot.first.should == v(0, 0, 0)
        end
      end

      context 'negative starting' do
        let(:starting) { v(-0.25, 0, -0.75) }
        it "makes the first move to the center of the block" do
          plot.first.should == v(-1, 0, -1)
        end
      end
    end

    context 'path that takes more than the allowed steps' do
      let(:map_data) do
        [ [ 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7],
          [ 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],
          [ 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],
          [ 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],
          [ 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7],
        ]
      end

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(10, 0, 3) }

      it "returns a path that gets closer to the target" do
        plot(5).should == [ v(1, 0, 1),
                            v(2, 0, 2),
                            v(3, 0, 3),
                            v(4, 0, 3)
                          ]
      end

      context 'subsequent plot' do
        before do
          plot(5).should_not be_empty
        end

        it "continues where it left off, refining the path" do
          plot(5).should == [ v(1, 0, 1),
                              v(2, 0, 2),
                              v(3, 0, 3),
                              v(4, 0, 3),
                              v(5, 0, 2),
                              v(6, 0, 3)
                            ]
        end
      end
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

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(4, 0, 4) }

      before do
        # initial path
        path = plot
        path.should_not == []

        # take a a step on the path
        subject.position = path[1]
      end

      context 'that has a passage' do
        before do
          # add a wall with a door
          1.upto(3) do |z|
            world[3, 0, z].type = 7
            subject.map_updated_at(v(3, 0, z))
          end
        end

        it "routes through the passage from the new position" do
          subject.plot.should == [ v(2, 0, 2),
                                   v(2, 0, 3),
                                   v(2, 0, 4),
                                   v(3, 0, 4),
                                   v(4, 0, 4)
                                 ]
        end
      end

      context 'that has NO passable door' do
        before do
          # add a wall
          1.upto(4) do |z|
            world[3, 0, z].type = 7
            subject.map_updated_at(v(3, 0, z))
          end
        end

        it "moves closer to the target" do
          subject.plot.should == [ v(2, 0, 2),
                                   v(2, 0, 3),
                                   v(2, 0, 4)
                                 ]
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

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(4, 0, 4) }

      it "zigs and zags around the partial wall" do
        plot.should == [ v(1, 0, 1),
                         v(2, 0, 1),
                         v(2, 0, 2),
                         v(2, 0, 3),
                         v(2, 0, 4),
                         v(3, 0, 4),
                         v(4, 0, 4)
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

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(4, 0, 4) }

      it "zigs and zags around the partial wall" do
        path = plot
        path.should == [ v(1, 0, 1),
                         v(2, 0, 1),
                         v(2, 1, 2),
                         v(3, 1, 3),
                         v(4, 0, 3),
                         v(4, 0, 4)
                       ]
      end
    end

    context 'doors' do
      let(:map_data) do
        [ [ 7, 7, 7,  7, 7 ],
          [ 7, 0, 7,  0, 7 ],
          [ 7, 0, 7,  0, 7 ],
          [ 7, 0, 64, 0, 7 ],
          [ 7, 7, 7,  7, 7 ]
        ]
      end

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(3, 0, 3) }

     context 'solid wall' do
        it "goes through the door" do
          plot.should == [ v(1, 0, 1),
                           v(1, 0, 2),
                           v(1, 0, 3),
                           v(2, 0, 3),
                           v(3, 0, 3)
                         ]
        end
      end

      context 'wall with dirt passage' do
        before do
          world[2, 0, 1].type = 3
          world[2, 1, 1].type = 3
        end

        it "goes through the door" do
          plot.should == [ v(1, 0, 1),
                           v(1, 0, 2),
                           v(1, 0, 3),
                           v(2, 0, 3),
                           v(3, 0, 3)
                         ]
        end
      end
    end

    context 'through stone' do
      let(:map_data) do
        [ [ 7, 7, 7, 7, 7 ],
          [ 7, 0, 7, 0, 7 ],
          [ 7, 0, 7, 0, 7 ],
          [ 7, 0, 1, 0, 7 ],
          [ 7, 7, 7, 7, 7 ]
        ]
      end

      let(:starting) { v(1, 0, 1) }
      let(:ending) { v(3, 0, 3) }

      it "goes through the door by digging it once" do
        plot.should == [ v(1, 0, 1),
                         v(1, 0, 2),
                         v(1, 0, 3),
                         v(2, 0, 3),
                         v(3, 0, 3)
                       ]
      end
    end

    context 'digging in the Y' do
      let(:map_data) do
        [ [ [ 1, 1, 1, 1, 1 ],
            [ 1, 0, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
          ],
          [ [ 1, 1, 1, 1, 1 ],
            [ 1, 0, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
          ],
          [ [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 0 ],
          ],
          [ [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 1 ],
            [ 1, 1, 1, 1, 0 ],
          ]
        ]
      end

      context 'up to the target' do
        let(:starting) { v(1, 0, 1) }
        let(:ending) { v(4, 2, 4)}

        it "returns a path to the target without cutting corners" do
          plot.should == [ v(1, 0, 1),
                           v(1, 0, 2),
                           v(2, 0, 2),
                           v(2, 0, 3),
                           v(3, 0, 3),
                           v(4, 1, 3),
                           v(4, 2, 4)
                         ]
        end
      end

      context 'down to the target' do
        let(:starting) { v(4, 2, 4)}
        let(:ending) { v(1, 0, 1) }

        it "does not dig straight down" do
          path = plot
          path.should_not include(v(4, 1, 4))
          path.should_not include(v(4, 0, 4))
        end

        it "returns a path to the target without cutting corners" do
          plot.should == [ v(4, 2, 4),
                           v(4, 2, 3),
                           v(3, 2, 3),
                           v(3, 2, 2),
                           v(2, 2, 2),
                           v(1, 1, 2),
                           v(1, 0, 1)
                         ]
        end
      end
    end

    context 'solid wall with water on the other side' do
      let(:map_data) do
        [ [7, 7, 7, 7, 7, 7, 7],
          [7, 8, 3, 0, 0, 0, 7],
          [7, 8, 3, 0, 0, 0, 7],
          [7, 8, 3, 0, 0, 0, 7],
          [7, 8, 3, 0, 0, 0, 7],
          [7, 7, 7, 7, 7, 7, 7],
        ]
      end

      let(:starting) { v(4, 0, 2) }
      let(:ending) { v(1, 0, 2) }

      it "returns a path that does not dig" do
        plot.should == [ v(4, 0, 2),
                         v(3, 0, 2)
                       ]
      end
    end

    context 'dropping from a cliff'
    context 'with water'
    context 'with lava'

    context 'in the protected spawn area' do
      # area seems to be a 36x36 area centered on the spawn point
      it "never returns a path that requires digging"
    end

  end
end
