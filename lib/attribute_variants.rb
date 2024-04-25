# frozen_string_literal: true

require_relative "attribute_variants/version"
require_relative "attribute_variants/engine"

module AttributeVariants
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attributes(base: {}, variants: {}, defaults: {}, compounds: {})
      @attribute_engine = AttributeVariants::Engine.new(base: base, variants: variants, defaults: defaults, compounds: compounds)
    end

    def attribute_engine
      @attribute_engine ||=
        if superclass.respond_to?(:attribute_engine)
          superclass.attribute_engine.dup
        else
          AttributeVariants::Engine.new
        end
    end
  end

  def tags(variants: {}, attributes: {})
    self.class.attribute_engine.render(variants: variants, attributes: attributes)
  end
end
