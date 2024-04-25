# frozen_string_literal: true

require "action_view/helpers/tag_helper"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

module AttributeVariants
  class Engine
    attr_reader :base, :variants, :defaults, :compound_variants

    def initialize(base: {}, variants: {}, defaults: {}, compounds: [])
      @base = base
      # puts @base.class
      # puts @base
      # @base = base.is_a?(Hash) ? base : base.values.reduce({}, :merge)
      # puts @base
      # puts "BASE"
      @variants = variants
      @defaults = defaults
      @compounds = compounds
    end

    def render(variants: {}, attributes: {})
      # Start with our default classes
      result = @base

      # Then merge the passed in overrides on top of the defaults
      selected = @defaults.merge(variants)

      selected.each do |variant_type, variant|
        # dig the classes out and add them to the result
        result = result.merge(@variants.dig(variant_type, variant)) { |key, a, b| (key == :a) ? a : [a, b].join(" ") }
      end

      @compounds.each do |compound_variant|
        if (compound_variant[:variants]).all? { |key, value| selected[key] == value }
          result = result.merge(compound_variant[:attributes]) { |key, a, b| (key == :a) ? a : [a, b].join(" ") }
        end
      end

      # Compact out any nil values we may have dug up
      result.compact!

      result.merge(attributes) { |key, a, b| (key == :a) ? a : [a, b].join(" ") }

      # Return the final token list
    end
  end
end
