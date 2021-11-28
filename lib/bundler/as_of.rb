# frozen_string_literal: true

puts "MIKE: #{__FILE__}:#{__LINE__}:#{__method__}"
require_relative "as_of/version"

module Bundler
  module AsOf
    class InstallModifier
      def modify_dependencies(dependencies)
        puts "MIKE: #{__FILE__}:#{__LINE__}:#{__method__}"
        pp dependencies
      end
    end
  end
end

Bundler::Plugin.add_hook("before-install-all") do |dependencies|
  Bundler::AsOf::InstallModifier.new.modify_dependencies(dependencies)
end
