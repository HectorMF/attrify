# frozen_string_literal: true

require "action_view/helpers/tag_helper"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

require "attrify/parser"
require "attrify/variant"
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
      @defaults = Parser.parse_defaults(value)
    end

    # Fetch the correct variant, with caching
    def fetch(**args)
      # Split args into variant and operations
      variant_keys = variants.keys
      variant_args = {}
      operation_args = {}

      args.each do |key, value|
        if variant_keys.include?(key)
          variant_args[key] = Array(value).join("_").to_sym
        else
          operation_args[key] = value
        end
      end

      operations = Parser.parse_slots(operation_args)

      cache_key = generate_cache_key(variant_args)

      # Return the cached result if it exists
      unless @cache.key?(cache_key)
        @cache[cache_key] = compute_variant(variant: variant_args)
      end

      @cache[cache_key].adjust(operations)
    end

    def initialize_copy(orig)
      super
      @base = @base.dup
      @variants = @variants.dup
      @defaults = @defaults.dup
      @compounds = @compounds.dup
      @cache = {}
    end

    private

    # Generate a unique key based on the variants
    def generate_cache_key(variant)
      variant.sort.to_h.to_s
    end

    def compute_variant(variant: {})
      # Start with our base attributes
      result = @base.dup

      # Merge default variants with user-specified variants
      selected_variants = @defaults.merge(variant)

      # Apply selected variants to the base attributes
      selected_variants.each do |variant_type, variant_key|
        variant_defs = @variants.dig(variant_type, variant_key)
        next unless variant_defs
        deep_merge_hashes!(result, variant_defs)
      end

      # Apply compounds variants
      @compounds.each do |compound_variant|
        if compound_variant[:variants].all? { |key, value| selected_variants[key] == value }
          deep_merge_hashes!(result, compound_variant[:attributes])
        end
      end

      Variant.new(result)
    end
  end
end
