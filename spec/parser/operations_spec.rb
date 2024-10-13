# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_operations" do
    context "when input is a string" do
      it "returns an empty set operation for an empty string" do
        expect(described_class.parse_operations("")).to eq([{set: [""]}])
      end

      it "parses a string as a set operation" do
        expect(described_class.parse_operations("border-1")).to eq([{set: ["border-1"]}])
      end
    end

    context "when input is an array" do
      it "returns an empty set operation for an empty array" do
        expect(described_class.parse_operations([])).to eq([{set: []}])
      end

      it "parses a string array as a set operation with multiple values" do
        expect(described_class.parse_operations(["border-1", "border-bottom-0"])).to eq([{set: ["border-1", "border-bottom-0"]}])
      end

      it "correctly parses and array of operations" do
        parsed = described_class.parse_operations([{set: "9"}, {append: "10"}])
        expect(parsed).to eq([{set: ["9"]}, {append: ["10"]}])
      end

      it "handles arrays containing mixed types" do
        parsed = described_class.parse_operations(["border-1", 42, :symbol_value])
        expect(parsed).to eq([{set: ["border-1", "42", "symbol_value"]}])
      end

      it "handles arrays containing mixed types and operations" do
        parsed = described_class.parse_operations(["border-1", 42, :symbol_value, {append: "10"}])
        expect(parsed).to eq([{set: ["border-1"]}, {set: ["42"]}, {set: ["symbol_value"]}, {append: ["10"]}])
      end
    end

    context "when input contains a symbol" do
      it "parses a symbol as a set operation" do
        expect(described_class.parse_operations(:border)).to eq([{set: ["border"]}])
      end

      it "correctly parses a key-value pair where the value is a symbol" do
        expect(described_class.parse_operations({color: :primary})).to eq(color: [{set: ["primary"]}])
      end

      it "correctly parses an operation where the value is a symbol" do
        parsed = described_class.parse_operations(color: {append: :symbol_test})
        expect(parsed).to eq(color: [{append: ["symbol_test"]}])
      end
    end

    context "when input is a hash" do
      it "handles empty hash input" do
        expect(described_class.parse_operations({})).to eq({})
      end

      it "parses an append operation" do
        expect(described_class.parse_operations({append: "10"})).to eq([{append: ["10"]}])
      end

      it "parses a nested controller operation with non-string values" do
        expect(described_class.parse_operations({controller: ["border", 10]})).to eq({controller: [{set: ["border", "10"]}]})
      end

      it "parses a hash with a controller set as a string" do
        expect(described_class.parse_operations({controller: {set: "controller"}})).to eq({controller: [{set: ["controller"]}]})
      end

      it "parses a controller operation provided as a string" do
        expect(described_class.parse_operations({controller: "controller"})).to eq({controller: [{set: ["controller"]}]})
      end
    end

    context "when input contains unexpected types" do
      it "returns an empty set operation for nil input" do
        expect(described_class.parse_operations(nil)).to eq([{set: [""]}])
      end

      it "raises an error for types without a valid to_s" do
        no_to_s_object = Class.new do
          undef_method :to_s # Explicitly remove the to_s method
        end.new

        expect { described_class.parse_operations(no_to_s_object) }.to raise_error(NoMethodError)
      end
    end

    context "when input contains deep nesting and operations" do
      it "parses nested structures with string and array values" do
        parsed = described_class.parse_operations(
          {
            color: :primary,
            controller: "controller",
            deep: {
              nesting: ["foo", 10, :bar],
              controller: {append: "controller"}
            }
          }
        )
        expected = {
          color: [{set: ["primary"]}],
          controller: [{set: ["controller"]}],
          deep: {
            nesting: [{set: ["foo", "10", "bar"]}],
            controller: [{append: ["controller"]}]
          }
        }
        expect(parsed).to eq(expected)
      end
    end
  end
end
