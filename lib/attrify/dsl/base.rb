# frozen_string_literal: true

module Attrify
  module DSL
    class Base
      def initialize
        @base = {}
      end

      def build(&)
        instance_eval(&)
        @base
      end

      def slot(name, attributes = nil, &block)
        if block
          # If a block is provided, we need to create a nested structure
          @base[name] = self.class.new.build(&block) # Recursively build nested slots
        elsif attributes.is_a?(Hash)
          # If no block, but attributes are provided, add them directly
          @base[name] = attributes
        else
          raise ArgumentError, "Either attributes hash or a block is required"
        end
      end
    end
  end
end
