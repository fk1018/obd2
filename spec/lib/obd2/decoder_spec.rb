# frozen_string_literal: true

require "test_helper"

RSpec.describe Obd2::Decoder do
  subject(:decoder) { described_class.new }

  context "when decoding known PIDs" do
    it "decodes engine RPM correctly" do
      # Engine RPM = 3000 RPM -> raw value = 3000 * 4 = 12000
      rpm   = 3000
      raw   = rpm * 4
      a     = (raw >> 8) & 0xFF
      b     = raw & 0xFF
      data  = [4, 0x41, 0x0C, a, b, 0, 0, 0]
      result = decoder.decode(0x7E8, data)
      expect(result).not_to be_nil
      expect(result[:service]).to eq(0x01)
      expect(result[:pid]).to eq(0x0C)
      expect(result[:value]).to eq(rpm)
      expect(result[:unit]).to eq("rpm")
    end

    it "returns nil for unknown PIDs" do
      data = [3, 0x41, 0xFF, 0x00, 0, 0, 0, 0]
      expect(decoder.decode(0x7E8, data)).to be_nil
    end
  end

  context "with malformed frames" do
    it "raises an error when data length is insufficient" do
      expect { decoder.decode(0x7E8, [1, 2]) }.to raise_error(ArgumentError)
    end
  end
end
