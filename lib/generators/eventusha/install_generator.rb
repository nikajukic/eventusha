require 'rails/generators/migration'
require 'generators/eventusha/migration'
require 'eventusha'

module Eventusha
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      extend Eventusha::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      def copy_migration
        migration_template 'install.rb', 'db/migrate/create_events.rb'
      end
    end
  end
end
