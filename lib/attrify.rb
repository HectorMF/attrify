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
  
  def attribs(slot: :main, **args)
    @attr_options ||= {}
    arguments = @attr_options.merge(args)
  
    variant = self.class.variant_registry&.fetch(**arguments)
    variant.dig(*Array(slot)).evaluate_procs(self)
  end

  def with_attributes(**args)
    @attr_options = args
    self
  end
end
