require 'mc/client'
require 'mc/spec/helpers'

describe MC::Client do
  include MC::Spec::Helpers

  describe '#determine_dig_face' do
    let(:connection) { mock('Connection') }
    let(:client) { described_class.new('Tester', connection) }
    let(:position) { v(0, 0, 0) }
    before { client.position = position }
    subject { client.determine_dig_face(target) }

    North = v(-2, 0, 0)
    East = v(0, 0, 2)
    NorthEast = North + East
    South = v(2, 0, 0)
    SouthEast = South + East
    West = v(0, 0, -2)
    NorthWest = North + West
    SouthWest = South + West
    Center = v(0, 0, 0)

    Directions = [ North, NorthEast, East, SouthEast, South, SouthWest, West, NorthWest, Center ]
    { "blocks below the client" => [ -1, MC::Face_Top ],
      "blocks above the client" => [ 2, MC::Face_Bottom ]
    }.each do |desc, (y_offset, face)|
      context desc do
        context 'blocks below the client' do
          Directions.each do |dir|
            dir = dir + v(0, y_offset, 0)
            context "at #{dir}" do
              let(:target) { dir }
              let(:face) { face }
              it { should == face }
            end
          end
        end
      end
    end

    { 'foot level' => v(0, 0, 0),
      'head level' => v(0, 1, 0),
      'high head level' => v(0, 1.9, 0)
    }.each do |desc, offset|
      context "blocks at #{desc}" do
        { South     => MC::Face_North,
          SouthWest => MC::Face_North,
          West      => MC::Face_East,
          NorthWest => MC::Face_East,
          North     => MC::Face_South,
          NorthEast => MC::Face_South,
          East      => MC::Face_West,
          SouthEast => MC::Face_West,
          Center    => MC::Face_North
        }.each do |target, face|
          context "at #{target}" do
            let(:target) { target + offset }
            let(:face) { face }
            it { should == face }
          end
        end
      end
    end
  end
end
