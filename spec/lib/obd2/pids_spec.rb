# frozen_string_literal: true

require "test_helper"

RSpec.describe Obd2::PIDS do
  describe ".find" do
    it "returns nil for unknown PID definitions" do
      expect(described_class.find(0x01, 0xFF)).to be_nil
    end

    it "returns the correct PID definition for engine RPM" do
      pid = described_class.find(0x01, 0x0C)
      expect(pid).not_to be_nil
      expect(pid.name).to eq("Engine RPM")
      expect(pid.unit).to eq("rpm")
    end
  end
end