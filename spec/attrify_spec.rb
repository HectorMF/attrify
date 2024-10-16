class TestClass
  include Attrify

  def initialize(**args)
    with_attributes(**args)
  end
end

RSpec.describe Attrify do
  context "when no attributes are provided" do
    it "returns an empty hash" do
      expect(TestClass.new.attribs.to_hash).to eq({})
    end
  end
end
