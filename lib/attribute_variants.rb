# frozen_string_literal: true

require_relative "attribute_variants/version"
require_relative "attribute_variants/attribute_configuration"

require_relative "attribute_variants/dsl/engine"

module AttributeVariants
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attributes(&block)
      result = DSL::Engine.new.build(&block)
      config = attribute_configuration
      config.base = result.base_attr
      config.variants = result.variants
      config.defaults = result.defaults
      config.compounds = result.compounds
      config.parse
    end

    def attribute_configuration
      @attribute_configuration ||=
        if superclass.respond_to?(:attribute_configuration)
          superclass.attribute_configuration.dup
        else
          AttributeConfiguration.new
        end
    end
  end

  def attributes(slot: :default, variant: {}, adjust: {})
    self.class.attribute_configuration&.compile(variant: variant, adjust: adjust)&.dig(slot)
  end
end
