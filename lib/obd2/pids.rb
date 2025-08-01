# frozen_string_literal: true

require_relative "pid"

module Obd2
  # A registry of common OBD‑II Parameter IDs.  The constants defined here
  # follow the SAE J1979 standard.  Each entry associates a `(service, pid)`
  # tuple with a {PID} instance that knows how to decode its response.
  #
  # While only a handful of PIDs are included by default, users may
  # augment the registry at runtime by assigning additional entries to
  # {REGISTRY}.  For example:
  #   Obd2::PIDS::REGISTRY[[0x01, 0x42]] = Obd2::PID.new(...)
  #
  module PIDS
    extend self

    # A frozen hash mapping `(service, pid)` tuples to {PID} objects.
    REGISTRY = {
      # Service 0x01 (Show current data)
      [0x01, 0x0C] => PID.new(
        service: 0x01,
        pid: 0x0C,
        name: "Engine RPM",
        description: "Engine revolutions per minute",
        bytes: 2,
        unit: "rpm",
        formula: ->(a, b) { ((a << 8) | b) / 4.0 }
      ),
      [0x01, 0x0D] => PID.new(
        service: 0x01,
        pid: 0x0D,
        name: "Vehicle Speed",
        description: "Vehicle speed",
        bytes: 1,
        unit: "km/h",
        formula: ->(a) { a }
      ),
      [0x01, 0x05] => PID.new(
        service: 0x01,
        pid: 0x05,
        name: "Coolant Temperature",
        description: "Engine coolant temperature",
        bytes: 1,
        unit: "°C",
        formula: ->(a) { a - 40 }
      ),
      [0x01, 0x0F] => PID.new(
        service: 0x01,
        pid: 0x0F,
        name: "Intake Air Temperature",
        description: "Intake air temperature",
        bytes: 1,
        unit: "°C",
        formula: ->(a) { a - 40 }
      ),
      [0x01, 0x11] => PID.new(
        service: 0x01,
        pid: 0x11,
        name: "Throttle Position",
        description: "Throttle position",
        bytes: 1,
        unit: "%",
        formula: ->(a) { (a * 100.0) / 255.0 }
      )
    }.freeze

    # Lookup a PID definition by its service and pid.  Returns nil if
    # no matching entry exists.
    #
    # @param service [Integer] The OBD‑II service number.
    # @param pid [Integer] The PID code.
    # @return [PID, nil]
    def find(service, pid)
      REGISTRY[[service, pid]]
    end
  end
end