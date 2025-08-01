# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  # Exclude the test suite itself from coverage reports
  add_filter "/spec/"
end

# Add the lib directory to the load path so we can require the gem
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "obd2"

require "rspec"
