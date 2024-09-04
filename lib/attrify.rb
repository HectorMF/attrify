# frozen_string_literal: true

require_relative "attrify/version"
require_relative "attrify/variant_registry"

require_relative "attrify/dsl/engine"

module Attrify
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attributes(&block)
      result = DSL::Engine.new.build(&block)
      config = variant_registry
      config.base = result.base_attr
      config.variants = result.variants
      config.compounds = result.compounds
      config.defaults = result.defaults
    end

    def variant_registry
      @variant_registry ||=
        if superclass.respond_to?(:variant_registry)
          superclass.variant_registry.dup
        else
          VariantRegistry.new
        end
    end
  end

  def attributes(slot: :main, variant: {}, adjust: {})
    # Explicitly handle single or multiple slots
    slots = slot.is_a?(Array) ? slot : [slot] 

    # Fetch the attribute set and safely dig into the nested slots
    attribute_set = self.class.variant_registry&.fetch(variant: variant, adjust: adjust)

    # Use dig if we have a valid attribute set
    attribute_set&.dig(*slots)
  end
end
