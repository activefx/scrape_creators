# frozen_string_literal: true

require_relative "lib/scrape_creators/version"

Gem::Specification.new do |spec|
  spec.name = "scrape_creators"
  spec.version = ScrapeCreators::VERSION
  spec.authors = ["Matt Solt"]
  spec.email = ["mattsolt@gmail.com"]

  spec.summary = "Ruby client library for the Scrape Creators API"
  spec.description = "Ruby client library for the Scrape Creators API"
  spec.homepage = "https://github.com/activefx/scrape_creators"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "faraday", ">= 2.12"
  spec.add_dependency "faraday-cookie_jar"
  spec.add_dependency "faraday-encoding"
  spec.add_dependency "faraday-follow_redirects"
  spec.add_dependency "faraday-gzip"
  spec.add_dependency "faraday-http-cache"
  spec.add_dependency "faraday-retry"
  spec.add_dependency "zeitwerk"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
