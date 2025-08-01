# frozen_string_literal: true

require "test_helper"

RSpec.describe Obd2::Client do
  describe "#request_pid" do
    let(:mock_messenger) { instance_double(CanMessenger::Messenger) }
    let(:mock_decoder)   { instance_double(Obd2::Decoder) }
    subject(:client) do
      # Use allocate to bypass normal initialization; we'll inject dependencies manually
      described_class.allocate.tap do |obj|
        obj.instance_variable_set(:@messenger, mock_messenger)
        obj.instance_variable_set(:@decoder, mock_decoder)
      end
    end

    it "sends a request and decodes the first valid response" do
      # Expected frame from Request.build
      request_frame = { id: 0x7DF, data: Array.new(8, 0) }
      expect(Obd2::Request).to receive(:build).with(service: 0x01, pid: 0x0C, can_id: 0x7DF).and_return(request_frame)
      expect(mock_messenger).to receive(:send_can_message).with(id: request_frame[:id], data: request_frame[:data])

      # Simulate start_listening yielding a single message
      message = { id: 0x7E8, data: [4, 0x41, 0x0C, 0x0B, 0xB8, 0, 0, 0] } # corresponds to 3000 rpm
      allow(mock_messenger).to receive(:start_listening).and_yield(message)
      allow(mock_messenger).to receive(:stop_listening)

      decoded = { service: 0x01, pid: 0x0C, value: 3000, unit: "rpm", pid_def: nil }
      expect(mock_decoder).to receive(:decode).with(message[:id], message[:data]).and_return(decoded)

      result = client.request_pid(service: 0x01, pid: 0x0C)
      expect(result).to eq(decoded)
    end

    it "returns nil when no response is decoded" do
      # Build frame
      allow(Obd2::Request).to receive(:build).and_return({ id: 0x7DF, data: Array.new(8, 0) })
      allow(mock_messenger).to receive(:send_can_message)

      # start_listening yields a message for which decoder returns nil
      allow(mock_messenger).to receive(:start_listening).and_yield({ id: 0x7E8, data: [3, 0x41, 0xFF, 0x00, 0, 0, 0, 0] })
      allow(mock_messenger).to receive(:stop_listening)
      allow(mock_decoder).to receive(:decode).and_return(nil)

      expect(client.request_pid(service: 0x01, pid: 0xFF)).to be_nil
    end
  end
end