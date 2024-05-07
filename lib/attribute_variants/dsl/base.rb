module AttributeVariants
  module DSL
    class Base
      def initialize
        @base = {}
      end

      def build(&block)
        result = instance_eval(&block)
        @base.merge!(result) if result.is_a?(Hash)
        @base
      end

      def slot(name, attributes)
        @base[name] = attributes
      end
    end
  end
end
