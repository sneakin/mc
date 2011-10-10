# -*- coding: utf-8 -*-
require 'mc/string16'
require 'stringio'

describe MC::String16 do
  it "can encode and decode unicode strings" do
    s = described_class.serialize("hello ☃")
    io = StringIO.new(s)
    described_class.deserialize(io).should == "hello ☃"
  end

  describe 'serialize' do
    it "returns an array whose elements are the bytes of the length and characters of the UCS-16 encoding of the argument" do
      described_class.serialize("hello ☃").should == "\x00\a\x00h\x00e\x00l\x00l\x00o\x00 &\x03".force_encoding("BINARY")
    end

    it "works with other inputs" do
      described_class.serialize("SneakyDean").should == "\000\n\000S\000n\000e\000a\000k\000y\000D\000e\000a\000n".force_encoding("BINARY")
    end
  end

  describe '.deserialize' do
    it "returns a String of the decoded bytes read from the passed io" do
      io = StringIO.new("\x00\a\x00h\x00e\x00l\x00l\x00o\x00 &\x03".force_encoding("BINARY"))
      described_class.deserialize(io).should == "hello ☃"
    end

    it "works with other data" do
      io = StringIO.new("\000\n\000S\000n\000e\000a\000k\000y\000D\000e\000a\000n".force_encoding("BINARY"))
      r = described_class.deserialize(io)
      r.should be_eql("SneakyDean")
    end
  end
end
