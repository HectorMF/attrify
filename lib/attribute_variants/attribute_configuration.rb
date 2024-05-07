# frozen_string_literal: true

require "action_view/helpers/tag_helper"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

require "attribute_variants/parser"
require "attribute_variants/attribute_set"

require "benchmark"

module AttributeVariants
  class AttributeConfiguration
    attr_writer :base, :variants, :defaults, :compounds

    def initialize()
      @base = {}
      @variants = {}
      @defaults = {}
      @compounds = []
    end

    # General method to update base attributes

    def parse
      @base = Parser.parse_base(@base)
      @variants = Parser.parse_variants(@variants)
      @defaults = @defaults
      @compounds = @compounds
    end

    #  If we recieve a string or Array of strings, we just return { set: [value] }
    #  If it is a hash, such as the data attribute, we continue parsing deeper
    #
    # def parse_operation(operation)
    #   return { set: Array(operation) } if operation.is_a?(String)

    #   if operation.is_a?(Array)
    #     return { set: operation } if operation.all? { |value| value.is_a?(String) }

    #     operation.map! { |value| parse_operation(value) }

    #     return operation
    #   end

    #   if operation.is_a?(Hash)
    #     new_value = {}

    #     operation.each do |key, value|
    #       new_value[key] = parse_operation(value)
    #     end

    #     return new_value

    #     #how to set the value and continue nesting???
    #   data: {
    #     controller: ["asdfsa", "asdfsaf"]
    #     puts:
    #   }
    #   return operation if operatio
    #   new_value = {}
    #   if operation.is_a?(Hash)
    #     operation.each do |key, value|
    #       new_value[key] = parse_operation(value)
    #     end
    #   end

    #   return new_value
    #

    def deep_merge_hashes!(hash1, hash2)
      hash1.merge!(hash2) do |key, oldval, newval|
        if oldval.is_a?(Hash)
          deep_merge_hashes(oldval, newval)
        elsif oldval.is_a?(Array)
          oldval + newval  # Concatenate arrays
        else
          newval  # In case of conflicting types or non-container types, prefer newval
        end
      end
    end

    def deep_merge_hashes(hash1, hash2)
      hash1.merge(hash2) do |key, oldval, newval|
        if oldval.is_a?(Hash)
          deep_merge_hashes(oldval, newval)
        elsif oldval.is_a?(Array)
          oldval + newval  # Concatenate arrays
        else
          newval
        end
      end
    end

    def compile(variant: {}, adjust: {})
      input_variants = variant
      input_adjustments = adjust

      # Start with our default classes
      result = @base.dup

      # Merge defaults with user-specified variants
      selected_variants = @defaults.merge(input_variants)

      # Apply variants from the configuration
      selected_variants.each do |variant_type, variant_key|
        next unless (variant_defs = @variants.dig(variant_type, variant_key))
        deep_merge_hashes!(result, variant_defs)
      end

      # @compounds.each do |compound_variant|
      #   if compound_variant[:variants].all? { |key, value| selected_variants[key] == value }
      #     compound_variant[:attributes].each do |component, attrs|
      #       result[component] = (result[component] ? merge_attributes(result[component], attrs) : attrs.dup)
      #     end
      #   end
      # end

      # if @is_single_component

      #   @compounds.each do |compound_variant|
      #     if (compound_variant[:variants]).all? { |key, value| selected_variants[key] == value }
      #       compound_variant[:attributes].each do |attr, operations_or_values|
      #         result[attr] = merge_attribute(result[attr], operations_or_values)
      #       end
      #     end
      #   end

      #   # Compact out any nil values we may have dug up
      #   result.compact!

      #   # Apply any additional attributes directly specified
      #   input_adjustments.each do |attr, value|
      #     result[attr] = merge_attribute(result[attr], value)
      #   end

      #   #result = result.merge(attributes) { |key, a, b| (key == :a) ? a : [a, b].join(" ") }
      # else
      #         # Apply variants from the configuration
      #   selected_variants.each do |variant_type, variant_key|
      #     puts variant_type.inspect + " : " + variant_key.inspect
      #     puts "working"

      #     next unless (variant_defs = @variants.dig(variant_type, variant_key))

      #     puts variant_key.inspect + " : " + variant_defs.inspect
      #     variant_defs.each do |component, attrs|
      #       result[component] ||= {} # Ensure component exists
      #       puts result[component]
      #       puts "Attrs:" + attrs.inspect
      #       attrs.each do |attr, operations|

      #         result[component][attr] = merge_attribute(result[component][attr], operations)
      #       end
      #     end
      # end

      # Apply any additional attributes directly specified
      # attributes.each do |component, attrs|
      #   result[component] ||= {}
      #   attrs.each do |attr, value|
      #     result[component][attr] = value.is_a?(Hash) ? merge_attribute(result[component][attr], value) : value
      #   end
      # end

      # end
      AttributeSet.new(value: result)
    end

    def compile_and_run(options = {})
      run(compile(options))
    end

    def run(operations_hash)
      results = {}

      operations_hash.each do |key, operations|
        puts "executing" + key.to_s + " : " + operations.inspect
        # Check if the current key is a nested hash and call recursively
        if operations.is_a?(Hash)
          results[key] = run(operations)
        elsif operations.is_a?(Array)
          current_value = []

          # Process each operation in order
          operations.each do |operation_hash|
            operation_hash.each do |operation, value|
              current_value = execute_operation(operation.to_sym, current_value, value)
            end
          end

          # Flatten array and convert to string if not a hash
          results[key] = current_value.join(" ")
        end
      end

      results
    end

    def dup
      copy = super
      copy.instance_variable_set(:@base, @base.dup)
      copy.instance_variable_set(:@variants, @variants.dup)
      copy.instance_variable_set(:@defaults, @defaults.dup)
      copy.instance_variable_set(:@compounds, @compounds.dup)
      copy
    end

    private

    # Helper method to deeply duplicate objects to avoid mutation
    def deep_dup(object)
      case object
      when Hash
        object.transform_values { |value| deep_dup(value) }
      when Array
        object.map { |value| deep_dup(value) }
      else
        object
      end
    end

    # Handle attribute value merging based on operations or direct values
    def merge_attribute(current_value, operations_or_values)
      current_value = Array(current_value)

      if operations_or_values.is_a?(Hash)
        operations_or_values.each do |operation, value|
          puts "Operation: " + operation.inspect
          case operation.to_sym
          when :append
            current_value += Array(value)
          when :prepend
            current_value = Array(value) + current_value
          when :remove
            current_value -= Array(value)
          when :set
            current_value = Array(value)
          end
        end
      elsif operations_or_values.is_a?(Array)
        # Default operation is append if no specific operation is mentioned
        current_value += operations_or_values
      else
        # Handle string values as a direct append for simplicity
        current_value += [operations_or_values]
      end

      current_value.uniq
    end

    def execute_operation(operation, current_value, value)
      case operation
      when :append
        current_value + value
      when :prepend
        value + current_value
      when :remove
        current_value - value
      when :set
        value
      else
        current_value
      end
    end

    def finalize_attribute_value(value)
      if value.is_a?(Hash)
        value.transform_values { |v| v.is_a?(Array) ? v.join(" ") : finalize_attribute_value(v) }
      elsif value.is_a?(Array)
        value.join(" ")
      else
        value
      end
    end
  end
end
