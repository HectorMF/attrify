# frozen_string_literal: true

require "attrify/attribute_set"

module Attrify
  class Variant

    attr_reader :operations
    attr_reader :has_procs
    attr_reader :attributes

    def initialize(operations)
      @operations = operations
      
      result = cache_result(operations)

      @has_procs = result[:has_procs]
      @attributes = result[:value]
      puts "OPERATIONS: #{@operations}"
      puts "ATTRIBUTES: #{@attributes}"
    end

    def dig(*keys)
      result = @attributes.dig(*keys)
      puts "ATTRIBUTESSSSS:" + @attributes.to_s
      puts "Keys: #{keys}"
      puts "RESULT: #{result}"
      puts "HAS_PROCS: #{@has_procs}"
      if !result.nil?
        return AttributeSet.new(result, @has_procs)
      end
      AttributeSet.new({}, false)
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
          puts "OPERATIONS: #{operations}"
          # Process each operation in order
          operations.each do |operation_hash|
            operation_hash.each do |operation, value|
              puts "OPERATION: #{operation}"
              puts "VALUE: #{value}"
  
              has_procs = true if value.any? { |c| c.is_a?(Proc) }
                          puts "proc #{has_procs}"
              current_value = execute_operation(operation.to_sym, current_value, value)
            end
          end

          # Flatten array and convert to string if not a hash
          results[key] = current_value#.join(" ")
        else
          has_procs = true if operations.is_a?(Proc)
          results[key] = operations
        end
      end

      { value: results, has_procs: has_procs }
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
