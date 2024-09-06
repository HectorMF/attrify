# frozen_string_literal: true

RSpec.describe Attrify::AttributeSet do
  it "handles remove operation" do
    set = Attrify::AttributeSet.new({
      main: {
        adjust: {
          class: [{set: %w[inline-flex items-center justify-center]}, {remove: %w[inline-flex]}]
        }
      }
    })

    expect(set.run).to eq({
      main: {
        adjust: {
          class: "items-center justify-center"
        }
      }
    })
  end

  it "handles procs" do
    set = Attrify::AttributeSet.new({
      main: {
        adjust: {
          class: [{set: ->{Time.now.to_s}}]
        }
      }
    })

    expect(set.evaluate_procs(self)).to eq({
      main: {
        adjust: {
          class: "items-center justify-center"
        }
      }
    })
  end

  # it "handles append operation" do
  #   engine = Attrify::VariantRegistry.new(
  #     base: {
  #       class: %w[inline-flex items-center justify-center]
  #     },
  #     variants: {
  #       color: {
  #         primary: {
  #           class: {
  #             append: "text-sm"
  #           }
  #         },
  #         secondary: {
  #           class: %w[bg-purple-500 text-white]
  #         }
  #       },
  #       size: {
  #         sm: {class: "text-sm"},
  #         md: {class: "text-base"},
  #         lg: {class: "px-4 py-3 text-lg"}
  #       }
  #     },
  #     defaults: {size: :md, color: :primary}
  #   )

  #   expect(engine.compile_and_run).to eq({
  #     class: %w[inline-flex items-center justify-center text-base text-sm]
  #   })
  # end

  # it "handles the set operation" do
  #   engine = Attrify::VariantRegistry.new(
  #     base: {
  #       class: %w[inline-flex items-center justify-center]
  #     },
  #     variants: {
  #       color: {
  #         primary: {
  #           class: {
  #             set: "text-sm"
  #           }
  #         },
  #         secondary: {
  #           class: %w[bg-purple-500 text-white]
  #         }
  #       },
  #       size: {
  #         sm: {class: "text-sm"},
  #         md: {class: "text-base"},
  #         lg: {class: "px-4 py-3 text-lg"}
  #       }
  #     },
  #     defaults: {size: :md, color: :primary}
  #   )

  #   expect(engine.compile_and_run).to eq({
  #     class: %w[text-sm]
  #   })
  # end

  # it "handles the prepend operation" do
  #   engine = Attrify::VariantRegistry.new(
  #     base: {
  #       class: %w[inline-flex items-center justify-center]
  #     },
  #     variants: {
  #       color: {
  #         primary: {
  #           class: {
  #             prepend: "text-sm"
  #           }
  #         },
  #         secondary: {
  #           class: %w[bg-purple-500 text-white]
  #         }
  #       },
  #       size: {
  #         sm: {class: "text-sm"},
  #         md: {class: "text-base"},
  #         lg: {class: "px-4 py-3 text-lg"}
  #       }
  #     },
  #     defaults: {size: :md, color: :primary}
  #   )

  #   expect(engine.compile_and_run).to eq({
  #     class: %w[text-sm inline-flex items-center justify-center text-base]
  #   })
  # end

  # it "handles multiple operations" do
  #   engine = Attrify::VariantRegistry.new(
  #     base: {
  #       class: %w[inline-flex items-center justify-center]
  #     },
  #     variants: {
  #       color: {
  #         primary: {
  #           class: [
  #             {prepend: "text-sm"},
  #             {append: %w[hello world]}
  #           ]
  #         },
  #         secondary: {
  #           class: %w[bg-purple-500 text-white]
  #         }
  #       },
  #       size: {
  #         sm: {class: "text-sm"},
  #         md: {class: "text-base"},
  #         lg: {class: "px-4 py-3 text-lg"}
  #       }
  #     },
  #     defaults: {size: :md, color: :primary}
  #   )

  #   expect(engine.compile_and_run).to eq({
  #     class: %w[text-sm inline-flex items-center justify-center text-base hello world]
  #   })
  # end

  # it "handles data attribute and operations" do
  #   engine = Attrify::VariantRegistry.new(
  #     base: {
  #       class: %w[inline-flex items-center justify-center],
  #       data:
  #       {
  #         controller: "test"
  #       }
  #     },
  #     variants: {
  #       color: {
  #         primary: {
  #           class: {
  #             prepend: "text-sm",
  #             append: %w[hello world]
  #           },
  #           data: {
  #             controller: {
  #               set: "test2"
  #             }
  #           }
  #         },
  #         secondary: {
  #           class: %w[bg-purple-500 text-white]
  #         }
  #       },
  #       size: {
  #         sm: {class: "text-sm"},
  #         md: {class: "text-base"},
  #         lg: {class: "px-4 py-3 text-lg"}
  #       }
  #     },
  #     defaults: {size: :md, color: :primary}
  #   )

  #   expect(engine.compile_and_run).to eq({
  #     class: %w[text-sm inline-flex items-center justify-center text-base hello world]
  #   })
  # end

end