require "spec_helper"
require "generators/friendly_id_mobility_generator"

describe FriendlyIdMobilityGenerator, type: :generator do
  require "generator_spec/test_case"
  include GeneratorSpec::TestCase

  destination File.expand_path("../tmp", __FILE__)

  before(:all) do
    prepare_destination
    run_generator
  end
  after(:all) { prepare_destination }

  it "generates migration to add locale to friendly_id_slugs table" do
    expect(destination_root).to have_structure {
      directory "db" do
        directory "migrate" do
          migration "add_locale_to_friendly_id_slugs" do
            contains "class AddLocaleToFriendlyIdSlugs < ActiveRecord::Migration[#{ENV['RAILS_VERSION']}]"
            contains "def change"
            contains "add_column :friendly_id_slugs, :locale, :string, null: :false"
            contains "remove_index :friendly_id_slugs, [:slug, :sluggable_type]"
            contains "add_index :friendly_id_slugs, [:slug, :sluggable_type, :locale], length: { slug: 140, sluggable_type: 50, locale: 2 }"
            contains "remove_index :friendly_id_slugs, [:slug, :sluggable_type, :scope]"
            contains "add_index :friendly_id_slugs, [:slug, :sluggable_type, :scope, :locale], length: { slug: 70, sluggable_type: 50, scope: 70, locale: 2 }, unique: true, name: :index_friendly_id_slugs_unique"
            contains "add_index :friendly_id_slugs, :locale"
          end
        end
      end
    }
  end
end
