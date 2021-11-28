# frozen_string_literal: true

require_relative "as_of/version"
require "date"

module Bundler
  module AsOf
    BUNDLE_AS_OF = "BUNDLE_AS_OF"

    class InstallModifier
      def modify_dependencies(dependencies)
        return unless as_of_date
        warn "NOTE: bundler-as_of: bundling dependencies as of #{as_of_date} ..."

        dependencies.each do |dep|
          pp [dep.name, dep.requirement, dep.requirements_list]
        end
      end

      def as_of_date
        if as_of_env.nil?
          warn "NOTE: bundler-as_of is installed but #{BUNDLE_AS_OF} is not set"
          return nil
        end
        @as_of_date ||= begin
          Date.parse(as_of_env)
        rescue Date::Error
          raise(BundlerError, "ERROR: bundler-as_of could not parse #{BUNDLE_AS_OF}=#{as_of_env.inspect}")
        end
      end

      private

      def as_of_env
        ENV[BUNDLE_AS_OF]
      end
    end
  end
end

Bundler::Plugin.add_hook("before-install-all") do |dependencies|
  Bundler::AsOf::InstallModifier.new.modify_dependencies(dependencies)
end
