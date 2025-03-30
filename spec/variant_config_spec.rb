# frozen_string_literal: true

RSpec.describe Attrify::VariantConfig do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "creates an empty hash-like object" do
      expect(config).to be_empty
    end

    it "auto-initializes missing keys as new VariantConfig instances" do
      expect(config[:missing]).to be_an_instance_of(described_class)
    end
  end

  describe "#[]=" do
    it "stores simple values directly" do
      config[:key] = "value"
      expect(config[:key]).to eq("value")
    end

    it "converts plain hashes to VariantConfig instances" do
      config[:nested] = { key: "value" }
      expect(config[:nested]).to be_an_instance_of(described_class)
      expect(config[:nested][:key]).to eq("value")
    end

    it "preserves existing VariantConfig instances" do
      nested = described_class.new
      config[:nested] = nested
      expect(config[:nested]).to be(nested)
    end
  end

  describe "#<< (deep merge)" do
    context "when merging simple keys" do
      it "merges two hashes with non-conflicting keys" do
        config[:data] = {disabled: true}
        config[:data] << {tags: "foo,bar"}
        expect(config[:data][:disabled]).to be true
        expect(config[:data][:tags]).to eq("foo,bar")
      end

      it "overwrites a non-hash value with the new one" do
        config[:data] = {disabled: true}
        config[:data] << {disabled: false}
        expect(config[:data][:disabled]).to eq(false)
      end
    end

    context "when merging nested hashes" do
      it "performs deep merges with nested hashes" do
        config[:nested] = {a: 1, b: {c: 2}}
        config << {nested: {b: {c: 5, d: 3}, e: 4}}

        expect(config[:nested][:a]).to eq(1)
        expect(config[:nested][:b][:c]).to eq(5)
        expect(config[:nested][:b][:d]).to eq(3)
        expect(config[:nested][:e]).to eq(4)
      end

      it "preserves non-hash values in nested structures" do
        config[:nested] = {array: [1, 2, 3]}
        config << {nested: {other: "value"}}
        expect(config[:nested][:array]).to eq([1, 2, 3])
      end
    end
  end

  describe "nested assignment" do
    it "allows nested assignment without error" do
      # Even if :data is not set yet, accessing it auto-initializes an VariantConfig
      config[:data][:tags] = "label"
      expect(config[:data]).to be_an_instance_of(Attrify::VariantConfig)
      expect(config[:data][:tags]).to eq("label")
    end
  end
end
