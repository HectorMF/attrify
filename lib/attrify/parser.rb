# frozen_string_literal: true
require_relative 'helpers' 

module Attrify
  class Parser

    OPERATIONS = [:append, :prepend, :remove, :set].freeze
    ALLOWED_NESTED_FIELDS = [:data, :aria].freeze

    class << self
      include Helpers

      def parse_base(base)
        parse_slots(base)
      end

      def parse_variants(variants)
        # Iterate over each variant (e.g., color, size)
        variants.transform_values do |variant_options|
          # For each variant, iterate over its options (e.g., primary, secondary, sm, md)
          variant_options.transform_values do |option|
            # Call parse_slots on the contents of each option and replace its value
            parse_slots(option)
          end
        end
      end

      def parse_compounds(compounds)
        # Ensure the compounds structure is an array
        raise ArgumentError, "Invalid compounds structure: Expected an Array" unless compounds.is_a?(Array)
        return [] if compounds.empty?
      
        compounds.map do |compound|
          # Ensure each compound is a Hash and contains :variant and :adjust keys
          unless compound.is_a?(Hash) && compound.key?(:variants) && compound.key?(:adjust)
            raise ArgumentError, "Invalid compound structure: Each compound must have :variants and :adjust keys"
          end
      
          # Parse the adjust section using parse_slots
          {
            variants: compound[:variants],         # Keep the variant as it is
            adjust: parse_slots(compound[:adjust]) # Parse the adjust section using parse_slots
          }
        end
      end
      
      def parse_defaults(defaults)
        # Ensure the defaults is a hash
        unless defaults.is_a?(Hash)
          raise ArgumentError, "Defaults must be a hash, got #{defaults.class}"
        end
      
        # Ensure that all keys and values are symbols
        unless defaults.all? { |key, value| key.is_a?(Symbol) && value.is_a?(Symbol) }
          raise ArgumentError, "Defaults must be a flat hash of symbols. Got: #{defaults.inspect}"
        end

        defaults
      end


      
      def parse_slot(slot)
        raise ArgumentError, "Invalid slot structure: Expected a Hash #{slot}" unless slot.is_a?(Hash)

        variants = slot[:variant] || {}
        adjustments = slot[:adjust] || {}

        nested_slots = nested_slots(slot)
        additional_adjustments = slot.reject { |key, _| [:variant, :adjust].include?(key) || nested_slots.include?(key) }
        adjustments = deep_merge_hashes!(adjustments, additional_adjustments)

        unless valid_variant_structure?(variants)
          raise ArgumentError, "Invalid slot structure: Variant structure is invalid #{slot}"   
        end 

        unless valid_adjustment_structure?(adjustments)
          raise ArgumentError, "Invalid slot structure: Adjustment structure is invalid #{slot}"   
        end

        parsed_slot = {}
        parsed_slot[:variant] = variants unless variants.empty?
        parsed_slot[:adjust] = parse_operations(adjustments) unless adjustments.empty?
        # Recursively handle nested slots
        nested_slots.each do |nested_slot_name|
          parsed_slot[nested_slot_name] = parse_slot(slot[nested_slot_name])
        end
        parsed_slot
      end
      
      def parse_slots(slots)
        parsed_value = parse_slot(slots)
        if parsed_value.key?(:variant) || parsed_value.key?(:adjust)
          parsed_value = { main: parsed_value }
        end
        parsed_value
      end

      def parse_operations(value)
        case value
        when Hash
          # Check if the hash is a simple operation or needs further parsing
          if is_simple_operation?(value)
            value.transform_values { |v| v.is_a?(Array) ? v.map { |x| x.is_a?(Proc) ? x : x.to_s } : [v.is_a?(Proc) ? v : v.to_s] }
          else
            value.transform_values { |v|
              parsed_operation = parse_operations(v)
              if is_simple_operation?(parsed_operation)
                [parsed_operation]
              else
                parsed_operation
              end
            }
          end
        when Array
          # Determine if the array is of single operations or plain values
          if array_of_operations?(value)
            value.map { |v| parse_operations(v) }
          else
            {set: value.map { |v| v.is_a?(Proc) ? v : v.to_s }}
          end
        when Proc
          # For procs, wrap them in a `set` operation
          {set: [value]}
        else
          # For other types (e.g., strings, numbers), wrap them in a `set` operation
          {set: Array(value.to_s)}
        end
      end

      private

      def nested_slots(hash)
        # Filter out the keys that are not variant, adjust, or in ALLOWED_NESTED_FIELDS and have hash values
        hash.keys.select do |key|
          value = hash[key]
          value.is_a?(Hash) && ![:variant, :adjust].include?(key) && 
          !ALLOWED_NESTED_FIELDS.include?(key) && !is_simple_operation?(value)
        end
      end

      def valid_variant_structure?(variant)
        variant.is_a?(Hash) && variant.all? do |key, value|
          # Here we check if each pair is a simple key-value where value is not a hash or array
          !value.is_a?(Hash) && !value.is_a?(Array)
        end
      end

      def valid_adjustment_structure?(adjustments)
        adjustments.all? do |key, value|
          # Check if the value is a Hash and whether the key is allowed to have nested values
          !value.is_a?(Hash) || ALLOWED_NESTED_FIELDS.include?(key) || is_simple_operation?(value)
        end
      end

      def is_simple_operation?(operation)
        # Checks if the hash is a simple operation
        operation.is_a?(Hash) && (operation.keys.size == 1) && OPERATIONS.include?(operation.keys.first)
      end

      def array_of_operations?(array)
        return false if array.empty?
        array.all? do |item|
          item.is_a?(Hash) && is_simple_operation?(item)
        end
      end
    end
  end
end
