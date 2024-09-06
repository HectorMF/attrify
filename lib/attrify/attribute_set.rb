# frozen_string_literal: true

require "action_view"

module Attrify
  class AttributeSet
    include ActionView::Helpers::TagHelper
    attr_reader :value
    attr_reader :has_procs

    def initialize(value)
      @value = value
      @has_procs = false
    end

    def to_html
      attributes = execute(@value)

      if attributes.keys.count > 1 && attributes.key?(:main)
        return "ERROR: can't convert multiple components to HTML"
      end

      # The main component
      if attributes.key?(:main)
        attributes = attributes[:main]
      end

      if attributes.key?(:variant)
        return "ERROR: can't convert a variant to HTML"
      end

      attributes[:adjust] if attributes.key?(:adjust)
    end

    def with_procs(instance)
      AttributeSet.new(run_procs(@value, instance))
    end

    def to_hash
      @value
    end

    # Retrieve value by key
    def [](key)
      @value[key]
    end

    # Set value by key
    def []=(key, value)
      @value[key] = value
    end

    # Iterate like a hash
    def each(&block)
      @value.each(&block)
    end

    # Return all keys
    def keys
      @value.keys
    end

    # Return all values
    def values
      @value.values
    end

    def to_s
      tag.attributes(to_html)
    end

    def dig(*keys)
      result = @value.dig(*keys)
      if !result.nil?
        return AttributeSet.new(result)
      end

      # result = data
      # keys.each do |key|
      #   return nil unless result.is_a?(Hash) && result.key?(key)
      #   result = result[key]
      # end

      # You could use variant and adjust here to modify the result if needed
      result
    end

    def run 
      return execute(@value)
    end

    private

    def run_procs(hash, instance)
      results = {}
      hash.each do |key, operations|
        if operations.is_a?(Hash)
          results[key] = run_procs(operations, instance)
        elsif operations.is_a?(Array)
          results[key] = operations.map do |operation_hash|
            operation_hash.transform_values do |values|
              values.map do |value|
                value.is_a?(Proc) ? instance.instance_exec(&value) : value
              end
            end
          end
        end
      end
      results
    end

    def execute(operations_hash)
      results = {}

      operations_hash.each do |key, operations|
        if operations.is_a?(Hash)
          results[key] = execute(operations)
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
        else
          results[key] = operations
        end
      end

      results
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
  end
end
