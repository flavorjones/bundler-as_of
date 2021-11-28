# frozen_string_literal: true

require "date"
require "open-uri"
require "json"

module Bundler
  module AsOf
    BUNDLE_AS_OF = "BUNDLE_AS_OF"
    LEAVE_ALONE = ["bundler"]

    class InstallModifier
      def modify_dependencies(dependencies)
        if as_of_date.nil?
          warn("NOTE: bundler-as_of is installed but #{BUNDLE_AS_OF} is not set")
          return
        end

        warn("NOTE: bundler-as_of: bundling dependencies as of #{as_of_date} ...")
        dependencies.each do |dependency|
          next if LEAVE_ALONE.include?(dependency.name)
          orig_req = dependency.requirements_list
          release = VersionFinder.new(dependency, as_of_date).resolve
          if release
            warn("NOTE: bundler-as_of: resolving #{dependency.name} #{orig_req} to #{release.version} released on #{release.date}")
            set_dependency_requirement(dependency, release.version)
          else
            warn("NOTE: bundler-as_of: WARNING: could not resolve #{dependency.name} to a version matching #{dependency.requirements_list} from #{as_of_date}")
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

      def set_dependency_requirement(dependency, *requirements)
        dependency.instance_variable_set(:@requirement, Gem::Requirement.create(requirements))
      end
    end

    class VersionFinder
      def initialize(dependency, as_of_date)
        @dependency = dependency
        @as_of_date = as_of_date
      end

      def resolve
        releases.each do |release|
          return release if @dependency.requirement.satisfied_by?(release.version)
        end
        nil
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
      attr_reader :name, :version, :date
      def initialize(name, release_json)
        @name = name
        @version = Gem::Version.new(release_json["number"])
        @date = Date.parse(release_json["created_at"])
      end

      def to_s
        [name, version.to_s, date.to_s].to_s
      end
    end
  end
end

Bundler::Plugin.add_hook("before-install-all") do |dependencies|
  Bundler::AsOf::InstallModifier.new.modify_dependencies(dependencies)
end

require_relative "as_of/version"
