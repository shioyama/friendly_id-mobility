$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'mobility'
require 'friendly_id'
require 'friendly_id/mobility'
require 'pry'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

I18n.enforce_available_locales = false

ENV['RAILS_VERSION'] ||= "7.0"

class FriendlyIdMobilityTest < ActiveRecord::Migration[ENV['RAILS_VERSION'].to_f]
  def self.up
    create_table :journalists do |t|
      t.string  :name
      t.boolean :active
    end

    create_table :articles do |t|
      t.string :title_translations
    end

    create_table :posts do |t|
      t.boolean :published
    end

    create_table :novels do |t|
      t.integer :novelist_id
      t.integer :publisher_id
    end

    create_table :novelists do |t|
    end

    create_table :publishers do |t|
    end

    create_table :products do |t|
      t.string :name
      t.string :slug
      t.string :description
    end

    create_table :mobility_string_translations do |t|
      t.string  :locale
      t.string  :key
      t.string  :value
      t.integer :translatable_id
      t.string  :translatable_type
      t.timestamps
    end

    create_table :mobility_text_translations do |t|
      t.string  :locale
      t.string  :key
      t.text    :value
      t.integer :translatable_id
      t.string  :translatable_type
      t.timestamps
    end

    create_table :friendly_id_slugs do |t|
      t.string   :slug,                      null: false
      t.integer  :sluggable_id,              null: false
      t.string   :sluggable_type, limit: 50
      t.string   :locale                                if ENV['SLUG_LOCALE_COLUMN'] == 'true'
      t.string   :scope
      t.datetime :created_at
    end
  end
end

# Base plugins
Mobility.configure do
  plugins do
    backend :key_value
    active_record
    reader
    writer
    query
    fallbacks
    fallthrough_accessors
  end
end

class Journalist < ActiveRecord::Base
  extend Mobility
  translates :slug, type: :string

  extend FriendlyId
  friendly_id :name, use: :mobility
end

class Post < ActiveRecord::Base
  extend Mobility
  translates :slug, :title, type: :string
  translates :content, type: :text

  extend FriendlyId
  friendly_id :title, use: [:history, :mobility]
end

class Novelist < ActiveRecord::Base
  extend Mobility
  translates :slug, :name, type: :string

  extend FriendlyId
  friendly_id :name, use: [:mobility, :slugged]
end

class Novel < ActiveRecord::Base
  extend Mobility
  translates :slug, :name, type: :string

  extend FriendlyId
  belongs_to :novelist
  belongs_to :publisher
  friendly_id :name, use: [:mobility, :scoped], scope: [:publisher, :novelist]

  def should_generate_new_friendly_id?
    new_record? || super
  end
end

class Publisher < ActiveRecord::Base
  extend Mobility
  translates :name, type: :string

  has_many :novels
end

class Product < ActiveRecord::Base
  extend Mobility
  translates :description, type: :string

  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]
end

ActiveRecord::Migration.verbose = false
FriendlyIdMobilityTest.up

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before :each do
    DatabaseCleaner.start
    I18n.locale = :en
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.filter_run_excluding :locale_slugs unless ENV['SLUG_LOCALE_COLUMN'] == 'true'
end
