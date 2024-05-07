RSpec.describe AttributeVariants::Parser do
  it "correctly parses operations" do
    expect(AttributeVariants::Parser.parse_operations("border-1")).to eq({set: ["border-1"]})
    expect(AttributeVariants::Parser.parse_operations(["border-1", "border-bottom-0"])).to eq({set: ["border-1", "border-bottom-0"]})
    expect(AttributeVariants::Parser.parse_operations(["border-1", "border-bottom-0"])).to eq({set: ["border-1", "border-bottom-0"]})
    expect(AttributeVariants::Parser.parse_operations({append: "10"})).to eq({append: ["10"]})
    expect(AttributeVariants::Parser.parse_operations({controller: ["border", 10]})).to eq({controller: [{set: ["border", "10"]}]})
    expect(AttributeVariants::Parser.parse_operations({controller: {set: "controller"}})).to eq({controller: [{set: ["controller"]}]})
    expect(AttributeVariants::Parser.parse_operations({controller: "controller"})).to eq({controller: [{set: ["controller"]}]})
    expect(AttributeVariants::Parser.parse_operations(
      {
        controller: "controller",
        deep: {
          nesting: ["foo", "bar"],
          controller: {set: "controller"}
        }
      }
    )).to eq(
      {
        controller: [{set: ["controller"]}],
        deep: {
          nesting: [{set: ["foo", "bar"]}],
          controller: [{set: ["controller"]}]
        }
      }
    )

    expect(AttributeVariants::Parser.parse_operations(
      {
        class: {append: "test"},
        data: {
          controller: [{prepend: 10}, {set: 10}]
        }
      }
    )).to eq(
      {
        class: [{append: ["test"]}],
        data: {
          controller: [{prepend: ["10"]}, {set: ["10"]}]
        }
      }
    )
    expect(AttributeVariants::Parser.parse_operations(
      {
        class: [{append: "10"}, {set: "11"}],
        data:
        {
          controller: {set: 10}
        }
      }
    )).to eq(
      {
        class: [{append: ["10"]}, {set: ["11"]}],
        data: {
          controller: [{set: ["10"]}]
        }
      }
    )
  end

  it "correctly parses components" do
    expect(AttributeVariants::Parser.parse_component(
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
