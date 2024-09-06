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
  
  def attribs(slot: :main, variant: {}, adjust: {})
    @attr_options ||= {}

    # Use defaults from @attr_options if they exist, otherwise fall back to the passed arguments
    variant = @attr_options[:variant] ? @attr_options[:variant].merge(variant) : variant
    adjust = @attr_options[:adjust] ? @attr_options[:adjust].merge(adjust) : adjust


    # Explicitly handle single or multiple slots
    slots = slot.is_a?(Array) ? slot : [slot] 

    # Fetch the attribute set and safely dig into the nested slots
    attribute_set = self.class.variant_registry&.fetch(variant: variant, adjust: adjust)
  
    # Use dig if we have a valid attribute set
    attribute_set.dig(*slots)
  end

  # Add a `with_attribs` method to handle attribute merging
  def with_attributes(attributes)
    if attributes.is_a?(Hash)
      @attr_options = attributes
    end
    self
  end

  def variant(**options)
    @attr_options ||= {}
    @attr_options[:variant] = options
    self
  end

  def adjust(**options)
    @attr_options ||= {}
    @attr_options[:adjust] = options
    self
  end
  
  def attr_options
    @attr_options ||= {}
  end
end
