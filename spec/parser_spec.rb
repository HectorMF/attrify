RSpec.describe Attrify::Parser do
  it "correctly parses operations" do
    expect(Attrify::Parser.parse_operations("border-1")).to eq({set: ["border-1"]})
    expect(Attrify::Parser.parse_operations(["border-1", "border-bottom-0"])).to eq({set: ["border-1", "border-bottom-0"]})
    expect(Attrify::Parser.parse_operations(["border-1", "border-bottom-0"])).to eq({set: ["border-1", "border-bottom-0"]})
    expect(Attrify::Parser.parse_operations({append: "10"})).to eq({append: ["10"]})
    expect(Attrify::Parser.parse_operations({controller: ["border", 10]})).to eq({controller: [{set: ["border", "10"]}]})
    expect(Attrify::Parser.parse_operations({controller: {set: "controller"}})).to eq({controller: [{set: ["controller"]}]})
    expect(Attrify::Parser.parse_operations({controller: "controller"})).to eq({controller: [{set: ["controller"]}]})
    expect(Attrify::Parser.parse_operations(
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

    expect(Attrify::Parser.parse_operations(
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
    expect(Attrify::Parser.parse_operations(
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

  it "correctly parses base attributes" do
    # if the base has no slot, we wrap it in a default key
    expect(Attrify::Parser.parse_base(
      {
        id: 10,
        class: %w[inline-flex items-center justify-center],
        style: "color: red;",
        data: {
          controller: "stimulus_controller"
        }
      }
    )).to eq(
      default:
      {
        adjust: {
          id: [{set: ["10"]}],
          class: [{set: %w[inline-flex items-center justify-center]}],
          style: [{set: ["color: red;"]}],
          data: {
            controller: [{set: ["stimulus_controller"]}]
          }
        }
      }
    )

    # if the base has a defined slot, we keep it
    expect(Attrify::Parser.parse_base(
      {
        default: {
          id: 10,
          class: %w[inline-flex items-center justify-center],
          style: "color: red;",
          data: {
            controller: "stimulus_controller"
          }
        }
      }
    )).to eq(
      default:
      {
        adjust: {
          id: [{set: ["10"]}],
          class: [{set: %w[inline-flex items-center justify-center]}],
          style: [{set: ["color: red;"]}],
          data: {
            controller: [{set: ["stimulus_controller"]}]
          }
        }
      }
    )

    expect(Attrify::Parser.parse_base(
      {
        button: {
          id: 10,
          class: %w[inline-flex items-center justify-center],
          style: "color: red;",
          data: {
            controller: "stimulus_controller"
          }
        }
      }
    )).to eq(
      button:
      {
        adjust: {
          id: [{set: ["10"]}],
          class: [{set: %w[inline-flex items-center justify-center]}],
          style: [{set: ["color: red;"]}],
          data: {
            controller: [{set: ["stimulus_controller"]}]
          }
        }
      }
    )

    # if the base has multiple slots, we adjust accordingly
    expect(Attrify::Parser.parse_base(
      {
        avatar: {
          class: %w[inline-flex items-center justify-center]
        },
        accept_button: {
          variants: {
            color: "primary",
            size: "sm"
          }
        }
      })).to eq({
        avatar:{
          adjust: {
            class: [{set: %w[inline-flex items-center justify-center]}]
          }
        },
        accept_button: {
          adjust: {
            variants: {color: [{set: ["primary"]}], size: [{set: ["sm"]}]}
          }
        }
      })
  end

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
