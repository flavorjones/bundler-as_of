# frozen_string_literal: true

require_relative "lib/bundler/as_of/version"

Gem::Specification.new do |spec|
  spec.name = "bundler-as_of"
  spec.version = Bundler::AsOf::VERSION
  spec.authors = ["Mike Dalessio"]
  spec.email = ["mike.dalessio@gmail.com"]

  spec.summary = "Resolve gem dependencies as-of a date in the past."
  spec.description = <<~TEXT
    Resolve gem dependencies as-of a date in the past. Intended to resurrect older projects with
    out-of-date dependencies.
  TEXT
  spec.homepage = "https://github.com/flavorjones/bundler-as_of"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
