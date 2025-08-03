# OBD2

A simple Ruby wrapper for reading and decoding OBD-II messages over the CAN bus. It relies on the
`can_messenger` gem to communicate over a working SocketCAN interface. Currently, only single-frame
PID requests are supported.

## Installation

### Using RubyGems

```bash
gem install obd2
```

### Using Bundler

Add the gem to your `Gemfile`:

```ruby
gem "obd2"
```

Then install dependencies with:

```bash
bundle install
```

## Prerequisites
- Ruby ≥ 3.0 (check with `ruby -v`)
- Bundler (`gem install bundler`)
- A working SocketCAN interface (e.g. `can0`). See the [official SocketCAN setup instructions](https://www.kernel.org/doc/html/latest/networking/can.html). To create a virtual interface for testing:

+  ```bash
+  # Load the virtual-CAN kernel module (needed once per boot)
+  sudo modprobe vcan
+
+  # Create and bring up a virtual CAN interface called vcan0
+  sudo ip link add dev vcan0 type vcan
+  sudo ip link set vcan0 up
+  ```

or

-  ```bash
-  sudo ip link add dev can0 type vcan
-  sudo ip link set can0 up
-  ```

- The `can_messenger` gem (installed automatically as a dependency)

### Building & publishing (maintainers only)

To build the gem locally and, if you are an authorised maintainer, push it to RubyGems:

```bash
gem build obd2.gemspec
gem push obd2-*.gem  # requires RubyGems credentials
```

## Usage

```ruby
require "obd2"

client = Obd2::Client.new(interface_name: "can0") # make sure `can0` exists (e.g. SocketCAN)
result = client.request_pid(service: 0x01, pid: 0x0C)
puts result.inspect
```

Only single-frame PID requests are currently supported. `request_pid` returns
`nil` if no response is received before the timeout (default 1 second) and will
block until either a response is decoded or the timeout expires.

The method also accepts optional parameters:

* `request_id` – CAN identifier used for the request (default `0x7DF`).
* `response_filter` – CAN IDs to listen for in responses (default `0x7E8..0x7EF`).
* `timeout` – Seconds to wait for a response (default `1.0`).

For example:

```ruby
result = client.request_pid(
  service: 0x01,
  pid: 0x0C,
  request_id: 0x7E0,
  response_filter: 0x7E8,
  timeout: 2.0
)
```

## Custom PIDs

Additional PIDs can be registered at runtime by adding entries to
`Obd2::PIDS::REGISTRY`:

```ruby
Obd2::PIDS::REGISTRY[[0x01, 0x42]] = Obd2::PID.new(
  service: 0x01,
  pid: 0x42,
  name: "Control Module Voltage",
  description: "Control module voltage",
  bytes: 2,
  unit: "V",
  formula: ->(a, b) { ((a << 8) | b) / 1000.0 }
)
```

## Running Tests

Execute the test suite and rubocop with:

```bash
bundle exec rspec
bundle exec rubocop -a
```

## License

The gem is released under the MIT License. See `LICENSE.txt` for details. Changes are documented in the [CHANGELOG](CHANGELOG.md).
