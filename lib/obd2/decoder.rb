# frozen_string_literal: true

require_relative "pids"

module Obd2
  # Decodes OBD‑II response frames.  A response frame encodes the
  # response service (original service + 0x40), the PID, and zero or
  # more data bytes.  This class validates the frame structure and
  # uses the {PIDS} registry to decode known PIDs.
  class Decoder
    # Parse a raw response frame into a structured hash.  If the PID
    # is not recognised, `nil` is returned.  Errors are raised for
    # malformed frames.  The CAN ID itself is not used for decoding
    # but is included in the result for completeness.
    #
    # @param can_id [Integer] The CAN identifier from the received frame.
    # @param data [Array<Integer>] Eight data bytes from the CAN frame.
    # @return [Hash, nil] Parsed response or nil if PID not found.
    # @raise [ArgumentError] If fewer than three bytes of data are supplied.
    def decode(can_id, data)
      raise ArgumentError, "Data must contain at least 3 bytes" if data.length < 3

      _length    = data[0]
      resp_svc   = data[1]
      resp_pid   = data[2]
      # According to the OBD‑II spec, response service = request service + 0x40.
      service    = resp_svc - 0x40
      pid_def    = Obd2::PIDS.find(service, resp_pid)
      return nil unless pid_def
      # Extract the number of bytes the PID expects starting at byte 3.
      bytes      = data[3, pid_def.bytes]
      value      = pid_def.decode(bytes)
      {
        can_id:   can_id,
        service:  service,
        pid:      resp_pid,
        value:    value,
        unit:     pid_def.unit,
        pid_def:  pid_def
      }
    end
  end
end