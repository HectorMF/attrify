# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_defaults" do
    context "when defaults is a valid flat hash of symbols" do
      it "returns the same hash" do
        defaults = {color: :primary, type: :button, disabled: :yes}
        expect(Attrify::Parser.parse_defaults(defaults)).to eq(defaults)
      end
    end

    context "when defaults is not a hash" do
      it "raises an ArgumentError if defaults is not a hash" do
        expect { Attrify::Parser.parse_defaults([:color, :primary]) }.to raise_error(ArgumentError, "Defaults must be a hash, got Array")
        expect { Attrify::Parser.parse_defaults("color: primary") }.to raise_error(ArgumentError, "Defaults must be a hash, got String")
        expect { Attrify::Parser.parse_defaults(123) }.to raise_error(ArgumentError, "Defaults must be a hash, got Integer")
      end
    end

    context "when defaults has non-symbol keys or values" do
      it "raises an ArgumentError if any key is not a symbol" do
        defaults = {"color" => :primary, :type => :button}
        expect { Attrify::Parser.parse_defaults(defaults) }.to raise_error(ArgumentError, 'Defaults must be a flat hash of symbols. Got: {"color"=>:primary, :type=>:button}')
      end

      it "raises an ArgumentError if any value is not a symbol" do
        defaults = {color: "primary", type: :button}
        expect { Attrify::Parser.parse_defaults(defaults) }.to raise_error(ArgumentError, 'Defaults must be a flat hash of symbols. Got: {:color=>"primary", :type=>:button}')
      end

      it "raises an ArgumentError if both keys and values are not symbols" do
        defaults = {"color" => "primary", "type" => :button}
        expect { Attrify::Parser.parse_defaults(defaults) }.to raise_error(ArgumentError, 'Defaults must be a flat hash of symbols. Got: {"color"=>"primary", "type"=>:button}')
      end
    end

    context "when defaults is an empty hash" do
      it "returns an empty hash without errors" do
        defaults = {}
        expect(Attrify::Parser.parse_defaults(defaults)).to eq({})
      end
    end

    context "when defaults is an empty hash" do
      it "returns an empty hash without errors" do
        defaults = {}
        expect(Attrify::Parser.parse_slots(defaults)).to eq({})
      end
    end
  end
end
