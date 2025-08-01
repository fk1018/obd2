# frozen_string_literal: true

require_relative "lib/obd2/version"

Gem::Specification.new do |spec|
  # The name and version of the gem match the top‑level module
  spec.name          = "obd2"
  spec.version       = Obd2::VERSION

  # Author information
  spec.authors       = ["fk1018"]
  spec.email         = ["fk1018@users.noreply.github.com"]

  # A short summary and a longer description appear on RubyGems
  spec.summary       = "A simple Ruby wrapper to read and decode OBD‑II messages over CAN."
  spec.description   = "OBD2 provides a convenient interface for requesting OBD‑II PIDs and decoding their responses via the CAN bus. It builds upon the CanMessenger library and includes a registry of common PIDs, a request builder, a decoder, and a high‑level client for synchronous requests." # rubocop:disable Layout/LineLength

  # Project metadata
  spec.homepage      = "https://github.com/fk1018/obd2"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # Additional metadata used by RubyGems
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["changelog_uri"]     = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Files to be packaged with the gem
  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  # Declare runtime dependencies.  The OBD2 gem depends on can_messenger
  spec.add_dependency "can_messenger", "~> 1.0"

  # Development dependencies for running the test suite
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "simplecov", "~> 0.22"

  # Enforce MFA for publishing
  spec.metadata["rubygems_mfa_required"] = "true"
end
