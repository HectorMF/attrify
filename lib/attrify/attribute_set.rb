# frozen_string_literal: true

require "action_view"

module Attrify
  class AttributeSet
    include ActionView::Helpers::TagHelper

    attr_reader :operations
    attr_reader :has_procs
    attr_reader :attributes

    def initialize(attributes, has_procs = false)
      @has_procs = has_procs
      @attributes = attributes
    end
    
    def to_html
      if @attributes.keys.count > 1 && @attributes.key?(:main)
        return "ERROR: can't convert multiple components to HTML"
      end

      # The main component
      if @attributes.key?(:main)
        @attributes = @attributes[:main]
      end

      if @attributes.key?(:variant)
        return "ERROR: can't convert a variant to HTML"
      end

      if @attributes.key?(:adjust)
        attribs = merge_arrays(@attributes[:adjust])
        puts "MERGED ATTRIBUTES: #{attribs}"
        tag.attributes(attribs) 
      end
    end

    def evaluate_procs(instance)
      if @has_procs
        AttributeSet.new(merge_arrays(run_procs_on(@attributes, instance)), false)
      else
        @attributes = merge_arrays(@attributes)
        self
      end
    end

    def to_hash
      @attributes[:adjust] || {}
    end

    # Retrieve value by key
    def [](key)
      @attributes[:adjust][key]
    end

    # Set value by key
    def []=(key, value)
      @attributes[:adjust][key] = value
    end

    # Iterate like a hash
    def each(&block)
      @attributes[:adjust].each(&block)
    end

    # Return all keys
    def keys
      @attributes[:adjust].keys
    end

    # Return all values
    def values
      @attributes[:adjust]
    end

    def to_s
      to_html
    end

    private

    def merge_arrays(hash)
      hash.transform_values do |value|
        case value
        when Hash
          merge_arrays(value)  # Recursively process nested hashes
        when Array
          if value.all? { |v| v.is_a?(String) }
            value.join(' ')    # Join array of strings into a single string
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
        if value.is_a?(Hash)
          # Recursively handle nested hashes
          processed_hash[key] = run_procs_on(value, instance)
        elsif value.is_a?(Array)
          # Process arrays, replacing any procs
          processed_hash[key] = value.map do |element|
            element.is_a?(Proc) ? instance.instance_exec(&element) : element
          end
        elsif value.is_a?(Proc)
          # If it's a proc, execute it with the instance
          processed_hash[key] = instance.instance_exec(&value)
        else
          # If it's not a proc or a hash, keep it as is
          processed_hash[key] = value
        end
      end
    end
  end
end
