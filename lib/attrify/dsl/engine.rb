require "attrify/dsl/base"
require "attrify/dsl/variant"
require "attrify/dsl/compound"
# require "attrify/dsl/default"

module Attrify
  module DSL
    class Engine
      attr_reader :base_attr, :variants, :defaults, :compounds

      def initialize
        @base_attr = {}
        @variants = {}
        @defaults = {}
        @compounds = []
      end

      def build(&block)
        instance_eval(&block)
        self
      end

      def base(input = nil, &block)
        if block
          @base_attr = Base.new.build(&block)
        elsif input.is_a?(Hash)
          @base_attr = input
        else
          raise ArgumentError, "Expected a block or a hash"
        end
      end

      def variant(name, &block)
        @variants[name] = Variant.new.build(&block)
      end

      def compound(variants, &block)
        @compounds.concat([{variants: variants, adjust: Compound.new.build(&block)}])
      end

      def default(defaults)
        @defaults = defaults
      end
    end
  end
end
