# frozen_string_literal: true

module Attrify
  module Helpers
    def deep_merge_hashes!(hash1, hash2)
      hash1.merge!(hash2) do |key, oldval, newval|
        if oldval.is_a?(Hash)
          deep_merge_hashes(oldval, newval)
        elsif oldval.is_a?(Array)
          oldval + newval  # Concatenate arrays
        else
          newval  # In case of conflicting types or non-container types, prefer newval
        end
      end
    end

    def deep_merge_hashes(hash1, hash2)
      hash1.merge(hash2) do |key, oldval, newval|
        if oldval.is_a?(Hash)
          deep_merge_hashes(oldval, newval)
        elsif oldval.is_a?(Array)
          oldval + newval  # Concatenate arrays
        else
          newval
        end
      end
    end
  end
end