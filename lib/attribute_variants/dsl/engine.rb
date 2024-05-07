require "attribute_variants/dsl/base"
require "attribute_variants/dsl/variant"
#require "attribute_variants/dsl/compound"
#require "attribute_variants/dsl/default"

module AttributeVariants
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
        result = instance_eval(&block)
        self
      end

      def base(input = nil, &block)
        if block_given?
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
        @compounds.concat([{variants: variants, attributes: attribs}])
      end
  
      def default(defaults)
        @defaults = defaults
      end
    end
  end
end
