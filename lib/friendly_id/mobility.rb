require "friendly_id"
require "friendly_id/mobility/version"

module FriendlyId
  module Mobility
    class << self
      def setup(model_class)
        model_class.friendly_id_config.use :slugged
      end

      def included(model_class)
        advise_against_untranslated_model(model_class)

        mod = Module.new do
          def friendly
            super.i18n
          end
        end
        model_class.send :extend, mod
      end

      def advise_against_untranslated_model(model)
        field = model.friendly_id_config.query_field
        if !model.respond_to?(:translated_attribute_names) || model.translated_attribute_names.exclude?(field)
          raise "[FriendlyId] You need to translate the '#{field}' field with " \
            "Mobility (add 'translates :#{field}' in your model '#{model.name}')"
        end
      end
    end
  end
end
