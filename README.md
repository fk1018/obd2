# OBD2

A simple Ruby wrapper for reading and decoding OBD-II messages over the CAN bus.

## Installation

Clone the repository and install dependencies with:

```bash
bundle install
```

Prerequisites
-------------
- Ruby ≥ 3.0 (check with `ruby -v`)
- Bundler (`gem install bundler`)

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

## Running Tests

Execute the test suite with:

```bash
bundle exec rspec
```

## License

The gem is released under the MIT License. See `LICENSE.txt` for details. Changes are documented in the [CHANGELOG](CHANGELOG.md).
