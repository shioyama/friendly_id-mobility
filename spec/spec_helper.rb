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

ENV['RAILS_VERSION'] ||= "5.2"

class FriendlyIdMobilityTest < ActiveRecord::Migration[ENV['RAILS_VERSION'].to_f]
  def self.up
    create_table :journalists do |t|
      t.string  :name
      t.boolean :active
    end

    create_table :articles do |t|
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
      t.string   :locale,                    null: false if ENV['SLUG_LOCALE_COLUMN'] == 'true'
      t.string   :scope
      t.datetime :created_at
    end
  end
end

class Journalist < ActiveRecord::Base
  extend Mobility
  translates :slug, type: :string, fallthrough_accessors: true, backend: :key_value

  extend FriendlyId
  friendly_id :name, use: :mobility
end

class Article < ActiveRecord::Base
  extend Mobility
  translates :slug, :title, type: :string, dirty: true, backend: :key_value, fallbacks: { en: [:es] }

  extend FriendlyId
  friendly_id :title, use: :mobility
end

class Post < ActiveRecord::Base
  extend Mobility
  translates :slug, :title, type: :string, dirty: true, backend: :key_value
  translates :content, type: :text, dirty: true, backend: :key_value

  extend FriendlyId
  friendly_id :title, use: [:history, :mobility]
end

class Novelist < ActiveRecord::Base
  extend Mobility
  translates :slug, :name, type: :string, dirty: true, backend: :key_value

  extend FriendlyId
  friendly_id :name, use: [:mobility, :slugged]
end

class Novel < ActiveRecord::Base
  extend Mobility
  translates :slug, :name, type: :string, dirty: true, backend: :key_value

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
  translates :name, type: :string, dirty: true, backend: :key_value

  has_many :novels
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
