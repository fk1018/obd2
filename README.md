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
- A working SocketCAN interface (e.g. `can0`)
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

Only single-frame PID requests are currently supported.

## Running Tests

Execute the test suite with:

```bash
bundle exec rspec
```

## License

The gem is released under the MIT License. See `LICENSE.txt` for details. Changes are documented in the [CHANGELOG](CHANGELOG.md).
