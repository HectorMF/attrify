# frozen_string_literal: true

require "action_view/helpers/tag_helper"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

require "attrify/parser"
require "attrify/attribute_set"
require "attrify/helpers"

module Attrify
  class VariantRegistry
    include Helpers

    attr_reader :base, :variants, :defaults, :compounds

    def initialize(base: {}, variants: {}, defaults: {}, compounds: [])
      self.base = base
      self.variants = variants
      self.defaults = defaults
      self.compounds = compounds
      @cache = {}
    end

    def base=(value)
      @base = Parser.parse_base(value)
    end
  
    def variants=(value)
      @variants = Parser.parse_variants(value)
    end

    def compounds=(value)
      @compounds = Parser.parse_compounds(value)
    end

    def defaults=(value)
      @defaults = value
    end

    # Fetch the correct attribute set, with caching
    def fetch(variant: {}, adjust: {})
      # Generate a cache key based on the variant and adjustment inputs
      cache_key = generate_cache_key(variant, adjust)

      # Return the cached result if it exists
      if @cache.key?(cache_key)
        return @cache[cache_key] 
      end

      # Otherwise, compute the attribute set
      attribute_set = compute_attribute_set(variant: variant, adjust: adjust)
      
      # Store the result in the cache and return it
      @cache[cache_key] = attribute_set
    end

    def dup
      copy = super
      copy.instance_variable_set(:@base, @base.dup)
      copy.instance_variable_set(:@variants, @variants.dup)
      copy.instance_variable_set(:@defaults, @defaults.dup)
      copy.instance_variable_set(:@compounds, @compounds.dup)
      copy.instance_variable_set(:@cache, {})
      copy
    end

    private

    # Generate a unique key based on the variants and adjustments
    def generate_cache_key(variant, adjust)
      # Create a simple string-based key from the variant and adjustment inputs
      "#{variant.sort.to_h}_#{adjust.sort.to_h}"
    end

    def compute_attribute_set(variant: {}, adjust: {})
      input_variants = variant
      input_adjustments = Parser.parse_slots(adjust)

      # Start with our default classes
      result = @base.dup

      # Merge defaults with user-specified variants
      selected_variants = @defaults.merge(input_variants)

      # Apply variants from the configuration
      selected_variants.each do |variant_type, variant_key|
        next unless (variant_defs = @variants.dig(variant_type, variant_key))
        deep_merge_hashes!(result, variant_defs)
      end

      @compounds.each do |compound_variant|
        if compound_variant[:variants].all? { |key, value| selected_variants[key] == value }
          deep_merge_hashes!(result, compound_variant[:adjust])
        end
      end

      # Apply user-specified adjustments
      deep_merge_hashes!(result, input_adjustments)

      AttributeSet.new(result)
    end
  end
end
