# frozen_string_literal: true

module Obd2
  # Builds CAN frames for requesting OBD‑II PIDs.  The ISO 15765‑2
  # specification (ISO‑TP) requires that single‑frame requests specify
  # the payload length in the first byte followed by the service and
  # PID bytes.  The remaining bytes are padded to a total length of
  # eight.  Multi‑frame requests are not supported at this time.
  module Request
    # Default broadcast CAN identifier for OBD‑II requests.  All
    # electronic control units (ECUs) respond to requests sent on
    # this ID.
    DEFAULT_ID = 0x7DF

    module_function

    # Build a request frame for a given service and PID.
    #
    # @param service [Integer] The service number (also called mode) to request.
    # @param pid [Integer] The PID code to request.
    # @param can_id [Integer] The CAN identifier to use.  Defaults to {DEFAULT_ID}.
    # @return [Hash] A hash with keys `:id` and `:data` suitable for passing to {CanMessenger::Messenger#send_can_message}.
    def build(service:, pid:, can_id: DEFAULT_ID)
      # In a single frame request the first byte is the number of subsequent
      # bytes.  A request contains exactly two bytes: the service and the PID.
      length  = 2
      payload = [length, service, pid]
      # Pad the payload to eight bytes using zeros.  Some implementations
      # pad with 0x55 but zero padding is permitted and unambiguous.
      padded  = payload + Array.new(8 - payload.length, 0)
      { id: can_id, data: padded }
    end
  end
end
