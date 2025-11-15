# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "scrape_creators"

require "minitest/autorun"
require_relative "support/vcr"
