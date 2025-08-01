# frozen_string_literal: true

module Obd2
  # Represents a single OBD‑II Parameter ID (PID) definition.  Each PID
  # knows how many bytes of data are expected in the response and how
  # to convert those bytes into a human readable value.  Instances of
  # this class are immutable once created.
  #
  # @example Define a custom PID for battery voltage
  #   pid = Obd2::PID.new(service: 0x01, pid: 0x42, name: "Battery Voltage",
  #                       description: "Control module voltage",
  #                       bytes: 2,
  #                       unit: "V",
  #                       formula: ->(a, b) { ((a << 8) + b) / 1000.0 })
  #   value = pid.decode([0x0F, 0xA0]) # => 4.0
  #
  class PID
    attr_reader :service, :pid, :name, :description, :bytes, :unit

    # @return [Proc] A lambda that receives one argument per response byte
    #   and returns the decoded value.
    attr_reader :formula

    # Initializes a new PID definition.
    #
    # @param service [Integer] The OBD‑II service (or mode) number, e.g. `0x01`.
    # @param pid [Integer] The PID code, e.g. `0x0C` for engine RPM.
    # @param name [String] A short name for the PID.
    # @param description [String] A longer description of the PID.
    # @param bytes [Integer] How many data bytes are expected in the response.
    # @param formula [Proc] A lambda that knows how to convert the response bytes into a value.
    # @param unit [String, nil] Optional unit of measure for the decoded value.
    # rubocop:disable Metrics/ParameterLists
    def initialize(service:, pid:, name:, description:, bytes:, formula:, unit: nil)
      @service     = Integer(service)
      @pid         = Integer(pid)
      @name        = name.to_s.freeze
      @description = description.to_s.freeze
      @bytes       = Integer(bytes)
      @formula     = formula
      @unit        = unit
    end
    # rubocop:enable Metrics/ParameterLists

    # Decode the PID value from an array of response bytes.
    #
    # The provided array must contain at least as many bytes as this
    # definition expects.  Any extra bytes are ignored.  The lambda
    # supplied at initialization time will be called with the first
    # `bytes` elements of the array.  If insufficient data is supplied
    # an ArgumentError is raised.
    #
    # @param data [Array<Integer>] The response bytes (usually extracted from a CAN frame).
    # @return [Numeric] The decoded value.
    # @raise [ArgumentError] If too few bytes are provided.
    def decode(data)
      raise ArgumentError, "Data length mismatch: expected #{@bytes} bytes, got #{data.length}" if data.length < @bytes

      # Pass only the bytes we need to the formula; extra bytes are ignored.
      @formula.call(*data.first(@bytes))
    end

    # Combine service and pid into a single integer.  This is rarely
    # needed but can be useful when storing definitions in a hash keyed
    # by their full code.
    #
    # @return [Integer] (service << 8) | pid
    def code
      (@service << 8) | @pid
    end
  end
end
