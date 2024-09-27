# frozen_string_literal: true

require "attrify/operation_set"

module Attrify
  class Variant
    include Helpers

    attr_reader :operations
    attr_reader :attributes
    attr_reader :has_procs

    def initialize(operations)
      @operations = operations

      result = cache_result(operations)

      @has_procs = result[:has_procs]
      @attributes = result[:value]
    end

    def adjust(hash)
      OperationSet.new(deep_merge_hashes(@operations, hash))
    end

    private

    def cache_result(hash)
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
            current_value # .join(" ")
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
  end
end
