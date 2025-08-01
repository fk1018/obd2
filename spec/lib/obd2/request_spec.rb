# frozen_string_literal: true

require "test_helper"

RSpec.describe Obd2::Request do
  describe ".build" do
    it "constructs a CAN frame for a PID request" do
      frame = described_class.build(service: 0x01, pid: 0x0C, can_id: 0x7DF)
      expect(frame).to be_a(Hash)
      expect(frame[:id]).to eq(0x7DF)
      data = frame[:data]
      expect(data.length).to eq(8)
      expect(data[0]).to eq(2)        # number of additional bytes
      expect(data[1]).to eq(0x01)     # service
      expect(data[2]).to eq(0x0C)     # PID
      # remaining bytes should be zero padded
      expect(data[3..-1]).to all(eq(0))
    end
  end
end