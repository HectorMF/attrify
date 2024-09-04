# frozen_string_literal: true

module Attrify
  class Parser
    OPERATIONS = [:append, :prepend, :remove, :set].freeze
    ALLOWED_NESTED_FIELDS = [:data].freeze

    class << self
      def parse_base(base)
        parse_slots(base)
      end

      def parse_variants(variants)
        variants.transform_values do |variant_group|
          variant_group.transform_values do |slots|
            if is_single_slot?(slots)
              {main: parse_slot(slots)}
            else
              slots.transform_values do |slot|
                parse_slot(slot)
              end
            end
          end
        end
      end

      def parse_compounds(compounds)
        raise ArgumentError, "Invalid compounds structure: Expected an Array" unless compounds.is_a?(Array)
        return [] if compounds.empty?
        puts "PARSING COMPOUNDS: #{compounds}"
        compounds.map do |compound|
          raise ArgumentError, "Invalid compound structure: Expected a Hash" unless compound.is_a?(Hash)
      
          # Check required and optional keys
          required_keys = [:variants]
          optional_keys = [:adjust]
          all_allowed_keys = required_keys + optional_keys
      
          missing_keys = required_keys - compound.keys
          unexpected_keys = compound.keys - all_allowed_keys
      
          raise ArgumentError, "Invalid compound structure: Missing required key(s) #{missing_keys.join(', ')}" unless missing_keys.empty?
          raise ArgumentError, "Invalid compound structure: Unexpected key(s) #{unexpected_keys.join(', ')}" unless unexpected_keys.empty?

          adjustment = {}
          if compound.key?(:adjust)
            adjustment = parse_slots(compound[:adjust])
            puts "Adjustment: #{compound[:adjust]}"
          end
        
          {
            variants: compound[:variants],
            adjust: adjustment
          }
        end
      end

      def parse_slot(slot)
        return "ERROR: Invalid slot structure" if !slot.is_a?(Hash)

        if slot.key?(:variant)
          # Validate the variant structure to ensure all values are simple key-value pairs
          unless valid_variant_structure?(slot[:variant])
            return "ERROR: Invalid variant structure"
          end

          # Process the optional 'adjust' field if present
          adjustments = parse_operations(slot[:adjust] || {})

          # Return the slot with processed adjustments if any
          {variant: slot[:variant], adjust: adjustments}
        else
          # Wrap the processed attributes in an 'adjust' field
          {adjust: parse_operations(slot)}
        end
      end

      def parse_slots(slots)
        sslots = is_single_slot?(slots) ? {main: slots} : slots
        puts "Slots: #{slots}\n"
        puts "Single Slot: #{is_single_slot?(slots)}\n"
        puts "Parsed Slots: #{sslots}\n"
        sslots.each do |name, slot|
          sslots[name] = parse_slot(slot)
        end

        sslots
      end

      def parse_operations(value)
        case value
        when Hash
          # Check if the hash is a simple operation or needs further parsing
          if is_simple_operation?(value)
            value.transform_values { |v| v.is_a?(Array) ? v.map(&:to_s) : [v.to_s] }
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
            {set: value.map(&:to_s)}
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

      # Does a hash represents a single slot
      def is_single_slot?(hash)
        hash.keys.any? && hash.keys.all? { |key| !hash[key].is_a?(Hash) || ALLOWED_NESTED_FIELDS.include?(key) || is_simple_operation?(hash[key]) }
      end

      def valid_variant_structure?(variant)
        variant.is_a?(Hash) && variant.all? do |key, value|
          # Here we check if each pair is a simple key-value where value is not a hash or array
          !value.is_a?(Hash) && !value.is_a?(Array)
        end
      end

      def is_simple_operation?(operation)
        # Checks if the hash is a simple operation
        operation.is_a?(Hash) && (operation.keys.size == 1) && OPERATIONS.include?(operation.keys.first)
      end

      def array_of_operations?(array)
        array.all? do |item|
          item.is_a?(Hash) && is_simple_operation?(item)
        end
      end
    end
  end
end
