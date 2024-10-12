# frozen_string_literal: true

require_relative "nested_variant"

module Attrify
  module DSL
    class Variant
      def initialize
        @variants = {}
      end

      def build(&)
        instance_eval(&)
        @variants
      end

      def respond_to_missing?(name, include_private = false)
        true
      end

      def method_missing(name, *args, &block)
        # Handle the case where the variant is provided as a block
        if block
          @variants[name] = NestedVariant.new.build(&block)
        # Handle the case where the variant is provided directly as a hash
        elsif args.length == 1 && args[0].is_a?(Hash)
          @variants[name] = args[0]
        else
          super
        end
      end
    end
  end
end
