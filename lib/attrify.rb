# frozen_string_literal: true

require_relative "attrify/version"
require_relative "attrify/variant_registry"
require_relative "attrify/variant_config"
require_relative "attrify/parser"
require_relative "attrify/dsl/engine"

module Attrify
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def variants(&)
      result = DSL::Engine.new.build(&)
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

  include Helpers

  def attributes(slot: :main, **args)
    new_arguments = (slot == :main) ? args : {slot => args}

    merged_arguments = deep_merge_hashes(variant, new_arguments)

    variant = self.class.variant_registry&.fetch(**merged_arguments)
    variant.values_for(instance: self, keys: Array(slot))
  end

  def variant
    @variant_config ||= VariantConfig.new
  end
end
