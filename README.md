# OBD2

A simple Ruby wrapper for reading and decoding OBD-II messages over the CAN bus.

## Installation

Clone the repository and install dependencies with:

```bash
bundle install
```

To build the gem locally and push it to RubyGems:

```bash
gem build obd2.gemspec
gem push obd2-*.gem
```

## Usage

```ruby
require "obd2"

client = Obd2::Client.new(interface_name: "can0")
result = client.request_pid(service: 0x01, pid: 0x0C)
puts result.inspect
```

## Running Tests

Execute the test suite with:

```bash
bundle exec rspec
```

## License

The gem is released under the MIT License. See `LICENSE.txt` for details. Changes are documented in the [CHANGELOG](CHANGELOG.md).
