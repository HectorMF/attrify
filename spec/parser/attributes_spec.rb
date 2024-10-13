# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_attributes" do
    context "when attributes is an empty hash" do
      it "returns an empty hash" do
        expect(described_class.parse_attributes({})).to eq({})
      end
    end
    context "when attributes is not a hash" do
      it "raises an ArgumentError when an array" do
        expect { described_class.parse_attributes([:color, :primary]) }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError when a string" do
        expect { described_class.parse_attributes("color: primary") }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError when an integer" do
        expect { described_class.parse_attributes(123) }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError when a symbol" do
        expect { described_class.parse_attributes(:color) }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError when a boolean" do
        expect { described_class.parse_attributes(true) }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError when a float" do
        expect { described_class.parse_attributes(1.23) }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError when a nil" do
        expect { described_class.parse_attributes(nil) }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError when a proc" do
        expect { described_class.parse_attributes(proc {}) }.to raise_error(ArgumentError)
      end
    end
    context "when attributes has non-symbol keys" do
      it "raises an ArgumentError with a single key" do
        expect { described_class.parse_attributes({"color" => :primary}) }.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError with mixed keys" do
        expect { described_class.parse_attributes({:class => "red", "color" => :primary}) }.to raise_error(ArgumentError)
      end
    end
    context "when attribute's value is a string" do
      it "parses the string as a set operation" do
        expect(described_class.parse_attributes({class: "red"})).to eq({class: [{set: ["red"]}]})
      end
    end
    context "when attribute's value is a integer" do
      it "parses the integer as a set operation" do
        expect(described_class.parse_attributes({id: 10})).to eq({id: [{set: ["10"]}]})
      end
    end
    context "when attribute's value is a hash" do
      it "parses the hash correctly" do
        expect(described_class.parse_attributes({data: {controller: "stimulus_controller"}})).to eq({data: {controller: [{set: ["stimulus_controller"]}]}})
      end
    end
  end
end
