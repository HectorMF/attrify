class TestClass
  include Attrify

  def initialize(**args)
    variant.replace(args)
  end
end

RSpec.describe Attrify do
  context "when no attributes are provided" do
    it "returns an empty hash" do
      expect(TestClass.new.attributes.to_hash).to eq({})
    end
  end
end
