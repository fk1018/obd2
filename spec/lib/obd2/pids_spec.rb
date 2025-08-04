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

    it "allows registering additional PID definitions" do
      custom_pid = Obd2::PID.new(
        service: 0x01,
        pid: 0x42,
        name: "Control Module Voltage",
        description: "Control module voltage",
        bytes: 2,
        unit: "V",
        formula: ->(a, b) { ((a << 8) | b) / 1000.0 }
      )

      begin
        described_class::REGISTRY[[0x01, 0x42]] = custom_pid
        expect(described_class.find(0x01, 0x42)).to be(custom_pid)
      ensure
        described_class::REGISTRY.delete([0x01, 0x42])
      end
    end
  end
end
