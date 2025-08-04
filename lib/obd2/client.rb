# frozen_string_literal: true

require "can_messenger"
require "timeout"
require_relative "request"
require_relative "decoder"

module Obd2
  # Provides a synchronous interface for requesting and decoding OBD‑II
  # PIDs over a CAN bus.  It leverages {CanMessenger::Messenger} to
  # handle low‑level socket communication and {Decoder} to parse
  # responses.  Consumers can override the messenger or decoder for
  # testing.
  class Client
    attr_reader :messenger, :decoder

    # Create a new OBD‑II client bound to a given CAN interface.
    #
    # @param interface_name [String] The SocketCAN interface to use (e.g. 'can0').
    # @param logger [Logger, nil] Optional logger passed to {CanMessenger::Messenger}.
    # @param endianness [Symbol] Endianness for CAN IDs (:big or :little).  See {CanMessenger::Messenger}.
    # @param can_fd [Boolean] Whether to enable CAN FD frames.
    # @param messenger [CanMessenger::Messenger, nil] Inject a pre‑constructed messenger (useful for tests).
    # @param decoder [Decoder, nil] Inject a custom decoder (useful for tests).
    # rubocop:disable Metrics/ParameterLists
    def initialize(interface_name:, logger: nil, endianness: :big, can_fd: false, messenger: nil, decoder: nil)
      @messenger = messenger || CanMessenger::Messenger.new(interface_name: interface_name, logger: logger,
                                                            endianness: endianness, can_fd: can_fd)
      @decoder   = decoder   || Decoder.new
    end
    # rubocop:enable Metrics/ParameterLists

    # Request a single PID and wait for the first matching response.  A
    # request frame is sent using {Request.build}.  Responses are
    # filtered by CAN ID to only process messages from ECUs
    # (0x7E8..0x7EF by default).  Listening stops when a result is
    # decoded or when the timeout expires.  If no response is
    # received within the timeout or the PID is unknown, `nil` is
    # returned.
    #
    # @param service [Integer] The service number (mode) to request.
    # @param pid [Integer] The PID code to request.
    # @param request_id [Integer] The CAN identifier used for the request (defaults to 0x7DF).
    # @param response_filter [Integer, Range, Array<Integer>] Which CAN IDs to listen for (defaults to 0x7E8..0x7EF).
    # @param timeout [Numeric] Maximum number of seconds to wait for a response.
    # @return [Hash, nil] Decoded response or nil if timed out or unknown PID.
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def request_pid(service:, pid:, request_id: 0x7DF, response_filter: (0x7E8..0x7EF), timeout: 1.0)
      frame = Obd2::Request.build(service: service, pid: pid, can_id: request_id)
      result = nil
      listener = nil

      begin
        Timeout.timeout(timeout) do
          listener = Thread.new do
            @messenger.start_listening(filter: response_filter) do |message|
              # Each message is a hash with :id and :data; decode it
              begin
                decoded = @decoder.decode(message[:id], message[:data])
              rescue ArgumentError
                next
              end
              next unless decoded

              result = decoded
              @messenger.stop_listening
            end
          end

          sleep 0.01
          @messenger.send_can_message(id: frame[:id], data: frame[:data])
          listener.join
        end
      rescue Timeout::Error
        result = nil
      ensure
        # Ensure we stop listening even if an exception occurs
        begin
          @messenger.stop_listening
        rescue StandardError
          nil
        end
        listener&.kill
      end
      result
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
