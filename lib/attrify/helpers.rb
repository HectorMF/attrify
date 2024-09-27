# frozen_string_literal: true

module Attrify
  module Helpers
    def compute_attributes(hash)
      results = {}

      hash.each do |key, operations|
        if operations.is_a?(Hash)
          results[key] = compute_attributes(operations)
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
  end
end
