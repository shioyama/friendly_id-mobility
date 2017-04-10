require "friendly_id"

# This override must handle both the situation where locale column has been
# added to the slugs table, and also the situation where it has not.
#
FriendlyId::Slug.class_eval do
  default_scope { column_names.include?("locale") ? where(locale: ::Mobility.locale) : all }

  before_save do
    self.locale ||= ::Mobility.locale if respond_to?(:locale=)
  end
end
