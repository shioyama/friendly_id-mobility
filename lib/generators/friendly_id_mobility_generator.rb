require 'rails/generators'
require "rails/generators/active_record"

class FriendlyIdMobilityGenerator < ::Rails::Generators::Base
  include ::Rails::Generators::Migration

  desc "Generates migration to add locale column to friendly_id_slugs table."

  source_root File.expand_path('../templates', __FILE__)

  def self.next_migration_number(dirname)
    ::ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  def create_migration_file
    template = "add_locale_to_friendly_id_slugs"
    migration_dir = File.expand_path("db/migrate")
    if self.class.migration_exists?(migration_dir, template)
      ::Kernel.warn "Migration already exists."
    else
      migration_template "migration.rb", "db/migrate/#{template}.rb"
    end
  end
end
