# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  it "correctly parses slots" do
    expect(Attrify::Parser.parse_slot(
      {
        class: %w[inline-flex items-center justify-center],
        data:
        {
          controller: "test"
        }
      }
    )).to eq(
      {
        adjust: {
          class: [{set: ["inline-flex", "items-center", "justify-center"]}],
          data: {
            controller: [{set: ["test"]}]
          }
        }
      }
    )
  end
end
