# frozen_string_literal: true

require_relative "helpers"

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
        variants.transform_values do |variant_options|
          variant_options.transform_values do |option|
            parse_slots(option)
          end
        end
      end

      def parse_compounds(compounds)
        raise ArgumentError, "Invalid compounds structure: Expected an Array" unless compounds.is_a?(Array)
        return [] if compounds.empty?

        compounds.map do |compound|
          # Ensure each compound is a Hash and contains :variant and :attributes keys
          unless compound.is_a?(Hash) && compound.key?(:variants) && compound.key?(:attributes)
            raise ArgumentError, "Invalid compound structure: Each compound must have :variants and :attributes keys"
          end

          # Parse the attributes section using parse_slots
          {
            variants: compound[:variants], # Keep the variants as they are
            attributes: parse_slots(compound[:attributes]) # Parse the attributes section using parse_slots
          }
        end
      end

      def parse_defaults(defaults)
        # Ensure the defaults is a hash
        unless defaults.is_a?(Hash)
          raise ArgumentError, "Defaults must be a hash, got #{defaults.class}"
        end

        defaults.each_with_object({}) do |(key, value), hash|
          # Ensure keys are symbols.
          unless key.is_a?(Symbol)
            raise ArgumentError, "All keys must be symbols. Got key #{key.inspect} (#{key.class})"
          end

          hash[key] = if value.is_a?(Symbol)
            value
          elsif value.respond_to?(:to_s)
            value.to_s
          else
            raise ArgumentError, "Value #{value.inspect} cannot be used as an default value"
          end
        end

        defaults
      end

      def parse_slots(slots)
        parsed_value = parse_slot(slots)
        if parsed_value.key?(:attributes)
          parsed_value = {main: parsed_value}
        end
        parsed_value
      end

      # {
      #   class: [{set: %w[bg-blue-500 text-white]}],
      #   style:  "width:100px",
      #   data: { controller: "stimulus_controller" },
      #   # this one is a slot
      #   nested: { sub_slot: {class:"red"}, class: "10"}
      # }
      def parse_slot(slot)
        raise ArgumentError, "Invalid slot structure: Expected a Hash #{slot}" unless slot.is_a?(Hash)

        attributes = slot[:attributes] || {}

        nested_slots = nested_slots(slot)
        additional_attributes = slot.reject { |key, _| key == :attributes || nested_slots.include?(key) }

        deep_merge_hashes!(attributes, additional_attributes)

        parsed_slot = {}
        parsed_slot[:attributes] = parse_attributes(attributes) unless attributes.empty?

        # Recursively handle nested slots
        nested_slots.each do |nested_slot_name|
          parsed_slot[nested_slot_name] = parse_slot(slot[nested_slot_name])
        end
        parsed_slot
      end

      #  class: [{set: %w[bg-blue-500 text-white]}]
      #  style: "width:100px"
      #  data: { controller: "stimulus_controller" }
      #  class: "red"
      #  class: "10"
      def parse_attributes(attributes)
        unless attributes.is_a?(Hash)
          raise ArgumentError, "Invalid attributes list: Expected a Hash, got #{attributes.class}"
        end

        if is_simple_operation?(attributes)
          raise ArgumentError, "Invalid Attributes List: got an operation"
        end

        parsed_attributes = {}

        attributes.each do |key, value|
          parsed_attributes[key] = parse_attribute(key, value)
        end
        parsed_attributes
      end

      def parse_attribute(key, value)
        unless valid_attribute?(key, value)
          raise ArgumentError, "Invalid attributes list: invalid attribute #{key}"
        end
        unless key.is_a?(Symbol)
          raise ArgumentError, "Attribute: Key must be a symbol #{key}"
        end

        parse_operations(value)
      end

      def parse_operations(value)
        case value
        when Hash
          # Check if the hash is a simple operation or needs further parsing
          if is_simple_operation?(value)
            [parse_operation(value)]
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
          if value.any? { |v| is_simple_operation?(v) }
            value.map { |v| parse_operation(v) }
          else
            [parse_operation(value)]
          end
        else
          [parse_operation(value)]
        end
      end

      def parse_operation(operation)
        case operation
        when Hash
          if !is_simple_operation?(operation)
            raise ArgumentError, "Invalid operation: got #{operation}"
          end
          operation.transform_values { |v|
            if v.is_a?(Array)
              v.map { |x| x.is_a?(Proc) ? x : x.to_s }
            else
              [v.is_a?(Proc) ? v : v.to_s]
            end
          }
        when Array
          {set: operation.map { |v| v.is_a?(Proc) ? v : v.to_s }}
        when Proc
          {set: [operation]}
        else
          {set: Array(operation.to_s)}
        end
      end

      private

      def nested_slots(hash)
        hash.keys.select do |key|
          value = hash[key]
          next false unless value.is_a?(Hash)

          key != :attributes && !ALLOWED_NESTED_FIELDS.include?(key) && !is_simple_operation?(value)
        end
      end

      def valid_attribute?(key, value)
        return true unless value.is_a?(Hash)
        ALLOWED_NESTED_FIELDS.include?(key) || is_simple_operation?(value)
      end

      def is_simple_operation?(operation)
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
