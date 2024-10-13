# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_operation" do
    context "when input is a string" do
      it "returns an empty set operation for an empty string" do
        expect(described_class.parse_operation("")).to eq({set: [""]})
      end

      it "parses a string as a set operation" do
        expect(described_class.parse_operation("border-1")).to eq({set: ["border-1"]})
      end
    end

    context "when input is an array" do
      it "returns an empty set operation for an empty array" do
        expect(described_class.parse_operation([])).to eq({set: []})
      end

      it "parses a string array as a set operation with multiple values" do
        expect(described_class.parse_operation(["border-1", "border-bottom-0"])).to eq({set: ["border-1", "border-bottom-0"]})
      end

      it "handles arrays containing mixed types" do
        parsed = described_class.parse_operation(["border-1", 42, :symbol_value])
        expect(parsed).to eq({set: ["border-1", "42", "symbol_value"]})
      end
    end

    context "when input contains a symbol" do
      it "parses a symbol as a set operation" do
        expect(described_class.parse_operation(:border)).to eq({set: ["border"]})
      end

      it "correctly parses an operation where the value is a symbol" do
        parsed = described_class.parse_operation({append: :symbol_test})
        expect(parsed).to eq({append: ["symbol_test"]})
      end
    end

    context "when input is a hash" do
      # it "fails if an empty hash" do
      #  expect(described_class.parse_operation({})).to raise_error(ArgumentError)
      # end

      it "parses an append operation" do
        expect(described_class.parse_operation({append: "10"})).to eq({append: ["10"]})
      end
    end

    context "when input contains unexpected types" do
      it "returns an empty set operation for nil input" do
        expect(described_class.parse_operation(nil)).to eq({set: [""]})
      end

      it "raises an error for types without a valid to_s" do
        no_to_s_object = Class.new do
          undef_method :to_s # Explicitly remove the to_s method
        end.new

        expect { described_class.parse_operation(no_to_s_object) }.to raise_error(NoMethodError)
      end
    end
  end
end
