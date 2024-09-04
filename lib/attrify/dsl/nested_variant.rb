module Attrify
  module DSL
    class NestedVariant
      def initialize
        @variants = {}
      end

      def build(&block)
        instance_eval(&block)
        @variants
      end

      def slot(name, attributes)
        @variants[name] = attributes
      end

      def respond_to_missing?(name, include_private = false)
        true
      end

      def method_missing(name, *args, &block)
        # Handle the case where the slot is provided as a block
        if block
          @variants[name] = instance_eval(&block)
        # Handle the case where the slot is provided directly as a hash
        elsif args.length == 1 && args[0].is_a?(Hash)
          @variants[name] = args[0]
        else
          super
        end
      end
    end
  end
end
