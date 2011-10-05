require 'mc_bot'
require 'stringio'

describe MC::KickPacket do
  describe '#deserialize' do
    let(:data) { "\000\016\000P\000r\000o\000t\000o\000c\000o\000l\000 \000e\000r\000r\000o\000r" }
    let(:io) { StringIO.new(data) }

    before { subject.deserialize(io) }

    it "has the reason 'Protocol error'" do
      subject.reason.should == 'Protocol error'
    end
  end
end

describe MC::LoginRequest do
  describe '#deserialize' do
    let(:data) { "\000\000\000\021\000\n\000S\000n\000e\000a\000k\000y\000D\000e\000a\000n\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000" }

    subject { described_class.deserialize(StringIO.new(data)) }

    it "has protocol version 17" do
      subject.protocol_version.should == 17
    end

    it "has SneakyDean as the user" do
      subject.user_name.should == 'SneakyDean'
    end

    it "has 16 bytes unused" do
      subject.unused.length.should == 16
    end
  end

  describe '#serialize' do
    context 'empty name' do
      let(:packet) { described_class.new("") }
      subject { packet.serialize }

      it "is 23 bytes long" do
        subject.length.should == 23
      end
    end

    context "client data" do
      let(:data) { "\001\000\000\000\021\000\n\000S\000n\000e\000a\000k\000y\000D\000e\000a\000n\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000" }

      subject { described_class.deserialize(StringIO.new(data[1..-1])) }

      it "is the same" do
        subject.serialize.should == data
      end
    end
  end
end

describe MC::LoginReply do
  describe '#deserialize' do
    let(:data) { "\000\003\266\253\000\000\352\273[7\375\271\253\266\000\000\000\000\000\001\200\024\006\000" }

    subject { described_class.deserialize(StringIO.new(data)) }

    it "is survival" do
      subject.server_mode.should == 0
    end

    it "is not in the nether" do
      subject.dimension.should == 0
    end

    it "is easy" do
      subject.difficulty.should == 1
    end

    it "has 128 world height" do
      subject.world_height.should == 128
    end

    it "has 20 players" do
      subject.max_players.should == 20
    end
  end
end

describe MC::MobSpawn do
  describe '.deserialize' do
    let(:data) { "\000\003\264\3434\377\377\361\220\000\000\005\200\000\000\v\360z\000" }

    subject { described_class.deserialize(StringIO.new(data)) }

    it "has 242915 as entity id" do
      subject.entity_id.should == 242915
    end

    it "is a spider" do
      subject.mob_type.should == 52
    end

    it "has a position" do
      subject.x.should == 4294963600
      subject.y.should == 1408
      subject.z.should == 3056
    end

    it "is yawed" do
      subject.yaw.should == 122
    end

    it "is pitched" do
      subject.pitch.should == 0
    end

    it "has metadata"
  end
end
