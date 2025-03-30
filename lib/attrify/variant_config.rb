module Attrify
  class VariantConfig < Hash
    module MergeableAttributes
      def <<(other)
        merge!(other) do |key, old_val, new_val|
          if old_val.is_a?(Hash) && new_val.is_a?(Hash)
            old_val.merge(new_val)
          else
            new_val
          end
        end
      end
    end

    include MergeableAttributes

    def initialize(*args)
      super
      # missing keys auto-initialize as new AttributeSet instances.
      self.default_proc = proc { |hash, key| hash[key] = self.class.new }
    end

    def []=(key, value)
      # Convert plain hashes to AttributeSet instances.
      if value.is_a?(Hash) && !value.is_a?(self.class)
        value = self.class.new.merge(value)
      end
      super
    end

    def set(**args)
      clear
      merge!(args)
      self
    end
  end
end
