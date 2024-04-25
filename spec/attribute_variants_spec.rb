# frozen_string_literal: true

RSpec.describe AttributeVariants do
  it "has a version number" do
    expect(AttributeVariants::VERSION).not_to be nil
  end

  it "handles empty state" do
    engine = AttributeVariants::Engine.new
    expect(engine.render).to eq({})
  end

  it "correctly outputs base attributes" do
    engine = AttributeVariants::Engine.new(
      base: {
        id: 10,
        class: %w[inline-flex items-center justify-center],
        style: "color: red;",
        data: {
          controller: "stimulus_controller"
        }
      }
    )
    expect(engine.render).to eq({
      id: 10,
      class: %w[inline-flex items-center justify-center],
      style: "color: red;",
      data: {
        controller: "stimulus_controller"
      }
    })
  end

  it "correctly outputs default attributes" do
    engine = AttributeVariants::Engine.new(base: {
                                             id: 10,
                                             class: %w[inline-flex items-center justify-center],
                                             style: "color: red;",
                                             data: {
                                               controller: "stimulus_controller"
                                             }
                                           },
      variants: {
        color: {
          primary: {
            class: %w[bg-blue-500 text-white]
          },
          secondary: {
            class: %w[bg-purple-500 text-white]
          }
        },
        size: {
          sm: {class: "text-sm"},
          md: {class: "text-base"},
          lg: {class: "px-4 py-3 text-lg"}
        }
      },
      defaults: {color: :primary, size: :sm})

    expect(engine.render).to eq({
      id: 10,
      class: "inline-flex items-center justify-center bg-blue-500 text-white text-sm",
      style: "color: red;",
      data: {
        controller: "stimulus_controller"
      }
    })
  end

  it "variant selection works, adds values" do
    engine = AttributeVariants::Engine.new(base: {
                                             id: 10,
                                             class: %w[inline-flex items-center justify-center],
                                             style: "color: red;",
                                             data: {
                                               controller: "stimulus_controller"
                                             }
                                           },
      variants: {
        color: {
          primary: {
            class: %w[bg-blue-500 text-white]
          },
          secondary: {
            class: %w[bg-purple-500 text-white]
          }
        },
        size: {
          sm: {style: "border-radius:40px;", class: "text-sm"},
          md: {class: "text-base"},
          lg: {class: "px-4 py-3 text-lg"}
        }
      },
      defaults: {color: :primary, size: :sm})

    expect(engine.render(variants: {color: :secondary})).to eq({
      id: 10,
      class: "inline-flex items-center justify-center bg-purple-500 text-white text-sm",
      style: "color: red; border-radius:40px;",
      data: {
        controller: "stimulus_controller"
      }
    })

    expect(engine.render(variants: {color: :secondary, size: :lg})).to eq({
      id: 10,
      class: "inline-flex items-center justify-center bg-purple-500 text-white px-4 py-3 text-lg",
      style: "color: red;",
      data: {
        controller: "stimulus_controller"
      }
    })
  end

  it "correctly computes compound variants" do
    engine = AttributeVariants::Engine.new(
      base: {
        class: %w[inline-flex items-center justify-center]
      },
      variants: {
        color: {
          primary: {
            class: %w[bg-blue-500 text-white]
          },
          secondary: {
            class: %w[bg-purple-500 text-white]
          }
        },
        size: {
          sm: {class: "text-sm"},
          md: {class: "text-base"},
          lg: {class: "px-4 py-3 text-lg"}
        }
      },
      compounds: [{
        variants: {
          color: :primary,
          size: :md
        },
        attributes: {
          class: "uppercase"
        }
      }],
      defaults: {color: :primary, size: :md}
    )

    expect(engine.render).to eq({
      class: "inline-flex items-center justify-center bg-blue-500 text-white text-base uppercase"
    })

    expect(engine.render(variants: {size: :sm})).to eq({
      class: "inline-flex items-center justify-center bg-blue-500 text-white text-sm"
    })
  end

  it "correctly overrides attributes" do
    engine = AttributeVariants::Engine.new(
      base: {
        class: %w[inline-flex items-center justify-center]
      },
      variants: {
        color: {
          primary: {
            class: %w[bg-blue-500 text-white]
          },
          secondary: {
            class: %w[bg-purple-500 text-white]
          }
        },
        size: {
          sm: {class: "text-sm"},
          md: {class: "text-base"},
          lg: {class: "px-4 py-3 text-lg"}
        }
      },
      compounds: [{
        variants: {
          color: :primary,
          size: :md
        },
        attributes: {
          class: "uppercase"
        }
      }],
      defaults: {color: :primary, size: :md}
    )

    expect(engine.render(attributes: {
      class: "color-red"
    })).to eq({
      class: "inline-flex items-center justify-center bg-blue-500 text-white text-base uppercase color-red"
    })
  end

  # it "correctly handles sub-components" do
  #   engine = AttributeVariants::Engine.new(
  #     base: [
  #       avatar: {
  #         class: %w[ inline-flex items-center justify-center ]
  #       },
  #       accept_button: {
  #         variants: {
  #           color: :primary,
  #           size: :sm
  #         }
  #       }
  #     ],
  #     variants: {
  #       type: {
  #         one: {
  #           avatar: { class: %w(bg-blue-500 text-white) },
  #           accept_button: {
  #             variants: {
  #               color: :primary,
  #               size: :sm
  #             }
  #           }
  #         },
  #         two: {
  #           avatar: { class: %w(bg-purple-500 text-white) },
  #           accept_button: {
  #             variants: {
  #               color: :secondary,
  #               size: :lg
  #             }
  #           }
  #         }
  #       }
  #     },
  #     defaults:{ type: :one })

  #     puts engine.render.inspect
  #  # expect(engine.render).to eq({
  #   #  class: "inline-flex items-center justify-center bg-blue-500 text-white text-base uppercase color-red"
  #   #})
  # end

  # it "accounts for replacing" do
  #   engine = AttributeVariants::Engine.new(base: {
  #     id:  10,
  #     class: %w[ inline-flex items-center justify-center ],
  #     style: "color: red;",
  #     data: {
  #       controller: "stimulus_controller"
  #     }
  #   },
  #   variants: {
  #     color: {
  #       primary: {
  #         class!: %w(bg-blue-500 text-white),
  #         style: "border-radius:40px"
  #       },
  #       secondary: {
  #         class: %w(bg-purple-500 text-white)
  #       }
  #     },
  #     size: {
  #       sm: { class!: "text-sm" },
  #       md: { class: "text-base" },
  #       lg: { class: "px-4 py-3 text-lg" }
  #     }
  #   },
  #   default:{ color: :primary, size: :sm })

  #   expect(engine.render).to eq(" id=\"10\" class=\"inline-flex items-center justify-center bg-purple-500 text-white text-sm\" style=\"color: red;\" data-controller=\"stimulus_controller\"")
  # end
end
