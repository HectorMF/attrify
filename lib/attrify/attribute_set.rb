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

      tag.attributes(@attributes[:adjust]) if @attributes.key?(:adjust)
    end

    def evaluate_procs(instance)
      if @has_procs
        AttributeSet.new(run_procs_on(@attributes, instance), false)
      else
        self
      end
    end

    def to_hash
      @attributes
    end

    # Retrieve value by key
    def [](key)
      @attributes[key]
    end

    # Set value by key
    def []=(key, value)
      @attributes[key] = value
    end

    # Iterate like a hash
    def each(&block)
      @attributes.each(&block)
    end

    # Return all keys
    def keys
      @attributes.keys
    end

    # Return all values
    def values
      @attributes
    end

    def to_s
      to_html
    end

    private

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
