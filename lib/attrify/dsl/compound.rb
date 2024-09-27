require "attrify/dsl/nested_variant"
module Attrify
  module DSL
    class Compound
      def initialize
        @compounds = {}
      end

      def build(&)
        # Capture the result of the block execution
        result = instance_eval(&)

        # If the result is a hash and no slots were explicitly set, treat it as compound attributes
        if result.is_a?(Hash) && @compounds.empty?
          @compounds.merge!(result)
        end

        @compounds
      end

      # Explicit slot handling
      def slot(name, attributes)
        @compounds[name] = attributes
      end
    end
  end
end
