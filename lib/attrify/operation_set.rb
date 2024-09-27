# frozen_string_literal: true

require "action_view"
require "attrify/parser"

module Attrify
  class OperationSet
    include ActionView::Helpers::TagHelper
    include Helpers

    attr_reader :operations
    attr_reader :has_procs

    def initialize(operations, has_procs = false)
      @has_procs = has_procs
      @operations = operations
    end

    def to_html
      tag.attributes(@result)
    end

    def to_tags
      to_hash
    end

    def dig(*keys)
      result = @result.dig(*keys)

      if result.present?
        if result.has_key?(:attributes)
          result[:attributes]
        end
      end
    end

    def values_for(instance:, keys:)
      # if @has_procs

      @operations = run_procs_on(@operations, instance)
      @result = cache_result(@operations)[:value]
      @result = @result.dig(*keys)
      if @result.present?
        if @result.has_key?(:attributes)
          @result = @result[:attributes]
        end
      end
      self
      # else
      #  self
      # end
    end

    def to_hash
      @result
    end

    # Retrieve value by key
    def [](key)
      @result[key]
    end

    # Set value by key
    def []=(key, value)
      @result[key] = value
    end

    # Iterate like a hash
    def each(&)
      @result.each(&)
    end

    # Return all keys
    def keys
      @result.keys
    end

    # Return all values
    def values
      @result
    end

    def to_s
      to_html
    end

    private

    def cache_result(hash, current_root = nil)
      results = {}
      has_procs = false

      hash.each do |key, operations|
        # Set current_root if it's not already set (top-level keys)
        current_root = key if current_root.nil?

        if operations.is_a?(Hash)
          # Recursively process the nested hash
          result = cache_result(operations, current_root)
          results[key] = result[:value]
          has_procs ||= result[:has_procs]
        elsif operations.is_a?(Array)
          current_value = []
          # Determine if we can cache the value
          can_cache_value = operations.any? { |operation| operation.key?(:set) } ||
            current_root == :main

          # Process each operation in order
          operations.each do |operation_hash|
            operation_hash.each do |operation, value|
              # Ensure value is an array
              value_array = Array(value)
              has_procs ||= value_array.any? { |c| c.is_a?(Proc) }
              if can_cache_value
                current_value = execute_operation(operation.to_sym, current_value, value_array)
              end
            end
          end

          # Set the result based on whether we can cache the value
          results[key] = if can_cache_value
            current_value.join(" ")
          else
            operations
          end
        else
          has_procs ||= operations.is_a?(Proc)
          results[key] = operations
        end
      end

      {value: results, has_procs: has_procs}
    end

    def cache_resultss(hash)
      results = {}
      has_procs = false

      hash.each do |key, operations|
        if operations.is_a?(Hash)
          result = cache_result(operations)
          results[key] = result[:value]
          has_procs = true if result[:has_procs]
        elsif operations.is_a?(Array)
          current_value = []
          # If any operation is a SET operation, then we can simply perform all operations now
          can_cache_value = operations.any? { |operation| operation.key?(:set) } || key == :main

          # Process each operation in order
          operations.each do |operation_hash|
            operation_hash.each do |operation, value|
              has_procs = true if value.any? { |c| c.is_a?(Proc) }
              if can_cache_value
                current_value = execute_operation(operation.to_sym, current_value, value)
              end
            end
          end

          # Flatten array and convert to string if not a hash
          results[key] = if can_cache_value
            current_value.join(" ")
          else
            operations
          end
        else
          has_procs = true if operations.is_a?(Proc)
          results[key] = operations
        end
      end

      {value: results, has_procs: has_procs}
    end

    def merge_arrays(hash)
      hash.transform_values do |value|
        case value
        when Hash
          merge_arrays(value)  # Recursively process nested hashes
        when Array
          if value.all? { |v| v.is_a?(String) }
            value.join(" ")    # Join array of strings into a single string
          else
            value.map { |v| v.is_a?(Hash) ? merge_arrays(v) : v }
          end
        else
          value  # Return the value as is if it's neither a Hash nor an Array
        end
      end
    end

    # Recursively traverse a hash and run any procs
    def run_procs_on(hash, instance)
      hash.each_with_object({}) do |(key, value), processed_hash|
        processed_hash[key] = if value.is_a?(Hash)
          # Recursively handle nested hashes
          run_procs_on(value, instance)
        elsif value.is_a?(Array)
          # Process arrays, replacing any procs
          value.map do |element|
            if element.is_a?(Proc)
              # If it's a proc, execute it with the instance
              instance.instance_exec(&element)
            elsif element.is_a?(Hash)
              # Recursively handle nested hashes
              run_procs_on(element, instance)
            else
              element
            end
          end
        elsif value.is_a?(Proc)
          # If it's a proc, execute it with the instance
          instance.instance_exec(&value)
        else
          # If it's not a proc or a hash, keep it as is
          value
        end
      end
    end
  end
end
