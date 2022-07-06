# frozen_string_literal: true

require "date"
require "open-uri"
require "json"
require "set"

module Bundler
  module AsOf
    BUNDLE_AS_OF = "BUNDLE_AS_OF"

    class InstallModifier
      def initialize
        @modified_dependencies = {} # name => modified Bundler::Dependency
      end

      def modify_dependencies(dependencies)
        if as_of_date.nil?
          warn("NOTE: bundler-as_of is installed but #{BUNDLE_AS_OF} is not set")
          return
        end
        warn("NOTE: bundler-as_of: bundling dependencies as of #{as_of_date} ...")

        resolve_transitive_dependencies(dependencies)

        dependencies.clear
        @modified_dependencies.each do |name, dep|
          dependencies << dep
        end
      end

      def resolve_transitive_dependencies(dependencies)
        queued = dependencies.dup

        while !queued.empty?
          resolving = queued
          queued = []

          resolving.each do |dependency|
            if dependency.name == "bundler"
              raise(BundlerError, "ERROR: please remove bundler from the Gemfile or gemspec")
            end

            next if @modified_dependencies.key?(dependency.name)

            orig_req = dependency.requirements_list
            release, exact_match = VersionFinder.new(dependency, as_of_date).resolve
            if exact_match
              warn("NOTE: bundler-as_of: resolving #{dependency.name} #{orig_req} to #{release.version} released on #{release.date}")
              @modified_dependencies[release.name] = Bundler::Dependency.new(release.name, release.version)

              release.dependencies.each do |transitive_name, transitive_req|
                transitive_dep = Gem::Dependency.new(transitive_name, transitive_req.split(","))
                queued << transitive_dep
              end
            else
              warn(
                "NOTE: bundler-as_of: WARNING: could not resolve #{dependency.name} to a version " \
                  "matching #{dependency.requirements_list} from #{as_of_date}\n\n" \
                  "Deferring to #{dependency.name} #{release.version} from #{release.date}"
              )
              @modified_dependencies[dependency.name] = dependency
            end
          end
        end
      end

      def as_of_date
        return nil if as_of_env.nil?

        @as_of_date ||= begin
          Date.parse(as_of_env)
        rescue Date::Error
          raise(BundlerError, "ERROR: bundler-as_of could not parse #{BUNDLE_AS_OF}=#{as_of_env.inspect}")
        end
      end

      def as_of_env
        ENV[BUNDLE_AS_OF]
      end
    end

    class VersionFinder
      def initialize(dependency, as_of_date)
        @dependency = dependency
        @as_of_date = as_of_date
      end

      def resolve
        releases.each do |release|
          next if release.prerelease
          return [release, true] if @dependency.requirement.satisfied_by?(release.version)
        end

        # We did not find an exact match, and are reverting to the oldest possible match
        [releases.first, false]
      end

      def releases
        gem_releases
          .select { |r| r.date <= @as_of_date }
          .sort_by { |r| [r.date, r.version] }
          .reverse
      end

      def gem_releases
        @gem_releases ||=
          JSON.parse(::URI.parse(gem_url).open.read)
            .map { |r| ReleaseWrapper.new(@dependency.name, r) }
      end

      def gem_url
        @gem_url ||= "https://rubygems.org/api/v1/versions/#{@dependency.name}.json"
      end
    end

    class ReleaseWrapper
      attr_reader :name, :version, :date, :prerelease
      def initialize(name, release_json)
        @name = name
        @version = Gem::Version.new(release_json["number"])
        @date = Date.parse(release_json["created_at"])
        @prerelease = release_json["prerelease"]
      end

      def to_s
        [name, version.to_s, date.to_s, prerelease, dependencies.to_s].to_s
      end

      def dependencies
        gem_info.find { |info| info[:number] == version.to_s }[:dependencies] || []
      end

      def gem_info
        @gem_info ||= Marshal.load(::URI.parse(gem_url).open.read)
      end

      def gem_url
        @gem_url ||= "https://rubygems.org/api/v1/dependencies?gems=#{name}"
      end
    end
  end
end

Bundler::Plugin.add_hook("before-install-all") do |dependencies|
  Bundler::AsOf::InstallModifier.new.modify_dependencies(dependencies)
end

require_relative "as_of/version"
