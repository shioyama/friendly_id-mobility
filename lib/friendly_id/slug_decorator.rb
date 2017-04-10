require "friendly_id"

FriendlyId::Slug.class_eval do
  before_save do
    self.locale ||= ::Mobility.locale if respond_to?(:locale=)
  end
end
