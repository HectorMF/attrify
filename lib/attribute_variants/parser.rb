# frozen_string_literal: true

module AttributeVariants
  class Parser
    OPERATIONS = [:append, :prepend, :remove, :set].freeze
    ALLOWED_NESTED_FIELDS = [:data].freeze

    def self.parse_variants(variants)
      variants.transform_values do |variant_group|
        variant_group.transform_values do |components|
          if is_single_component?(components)
            {default: parse_component(components)}
          else
            components.transform_values do |component|
              parse_component(component)
            end
          end
        end
      end
    end

    def self.parse_base(base)
      components = is_single_component?(base) ? {default: base} : base

      components.each do |name, component|
        components[name] = parse_component(component)
      end

      components
    end

    def self.parse_component(component)
      return "ERROR: Invalid component structure" if !component.is_a?(Hash)


      if component.key?(:variant)
        # Validate the variant structure to ensure all values are simple key-value pairs
        unless valid_variant_structure?(component[:variant])
          return "ERROR: Invalid variant structure"
        end

        # Process the optional 'adjust' field if present
        adjustments = parse_operations(component[:adjust] || {})

        # Return the component with processed adjustments if any
        {variant: component[:variant], adjust: adjustments}
      else
        # Wrap the processed attributes in an 'adjust' field
        {adjust: parse_operations(component)}
      end
    end

    def self.parse_operations(value)
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

    # Does a hash represents a single component
    def self.is_single_component?(hash)
      hash.keys.any? && hash.keys.all? { |key| !hash[key].is_a?(Hash) || ALLOWED_NESTED_FIELDS.include?(key) || is_simple_operation?(hash[key]) }
    end

    def self.valid_variant_structure?(variant)
      variant.is_a?(Hash) && variant.all? do |key, value|
        # Here we check if each pair is a simple key-value where value is not a hash or array
        !value.is_a?(Hash) && !value.is_a?(Array)
      end
    end

    def self.is_simple_operation?(operation)
      # Checks if the hash is a simple operation
      operation.is_a?(Hash) && (operation.keys.size == 1) && OPERATIONS.include?(operation.keys.first)
    end

    def self.array_of_operations?(array)
      array.all? do |item|
        item.is_a?(Hash) && is_simple_operation?(item)
      end
    end
  end
end
