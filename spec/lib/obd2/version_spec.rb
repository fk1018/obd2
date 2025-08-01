# frozen_string_literal: true

require "test_helper"

RSpec.describe Obd2 do
  it "has a version number" do
    expect(Obd2::VERSION).not_to be_nil
  end

  it "matches the expected semantic version format" do
    expect(Obd2::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end
end