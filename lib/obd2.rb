# frozen_string_literal: true

require_relative "obd2/version"
require_relative "obd2/pid"
require_relative "obd2/pids"
require_relative "obd2/request"
require_relative "obd2/decoder"
require_relative "obd2/client"

# Top‑level namespace for the OBD2 gem.  This module exposes the
# version constant and custom error classes while requiring all
# internal components.  Users typically only need to interact with
# {Obd2::Client} to perform requests and decode responses.
module Obd2
  # Base error class for all OBD2 specific errors.  Currently unused
  # but reserved for future use when more detailed error reporting is
  # implemented.
  class Error < StandardError; end
end
