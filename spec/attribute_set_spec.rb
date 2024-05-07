RSpec.describe AttributeVariants::AttributeSet do
  it "handles empty state" do
    expect(AttributeVariants::AttributeSet.new.compile).to eq({})
  end

  it "correctly outputs base attributes" do
    set = AttributeVariants::AttributeSet.new(
      base: {
        id: 10,
        class: %w[inline-flex items-center justify-center],
        style: "color: red;",
        data: {
          controller: "stimulus_controller"
        }
      }
    )

    expect(set.compile).to eq(
      {
        component:
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
      }
    )
  end

  it "correctly outputs default attributes" do
    set = AttributeVariants::AttributeSet.new(
      base: {
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
            class: {append: %w[bg-blue-500 text-white]}
          },
          secondary: {
            class: %w[bg-purple-500 text-white]
          }
        },
        size: {
          sm: {class: {append: "text-sm"}},
          md: {class: "text-base"},
          lg: {class: %w[px-4 py-3 text-lg]}
        }
      },
      defaults: {color: :primary, size: :sm}
    )

    expect(set.compile).to eq({
      component:
      {
        adjust: {
          id: [{set: ["10"]}],
          class: [{set: %w[inline-flex items-center justify-center]}, {append: %w[bg-blue-500 text-white]}, {append: %w[text-sm]}],
          style: [{set: ["color: red;"]}],
          data: {
            controller: [{set: ["stimulus_controller"]}]
          }
        }
      }
    })
  end

  it "variant selection works, adds values" do
    set = AttributeVariants::AttributeSet.new(
      base: {
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
            class: {append: %w[bg-blue-500 text-white]}
          },
          secondary: {
            class: {append: %w[bg-purple-500 text-white]}
          }
        },
        size: {
          sm: {style: {append: "border-radius:40px;"}, class: {prepend: "text-sm"}},
          md: {class: "text-base"},
          lg: {class: %w[px-4 py-3 text-lg]}
        }
      },
      defaults: {color: :primary, size: :sm}
    )

    expect(set.compile_and_run({variant: {color: :secondary}})[:component][:adjust]).to eq({
      id: "10",
      class: "text-sm inline-flex items-center justify-center bg-purple-500 text-white",
      style: "color: red; border-radius:40px;",
      data: {
        controller: "stimulus_controller"
      }
    })

    expect(set.compile_and_run({variant: {color: :secondary, size: :lg}})[:component][:adjust]).to eq({
      id: "10",
      class: "px-4 py-3 text-lg",
      style: "color: red;",
      data: {
        controller: "stimulus_controller"
      }
    })
  end

  it "correctly computes compound variants" do
    engine = AttributeVariants::AttributeSet.new(
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
          lg: {class: %w[px-4 py-3 text-lg]}
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
      class: %w[inline-flex items-center justify-center bg-blue-500 text-white text-base uppercase]
    })

    expect(engine.render(attributes: {variant: {size: :sm}})).to eq({
      class: %w[inline-flex items-center justify-center bg-blue-500 text-white text-sm]
    })
  end

  it "correctly overrides attributes" do
    engine = AttributeVariants::AttributeSet.new(
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
      adjust: {class: "color-red"}
    })).to eq({
      class: %w[inline-flex items-center justify-center bg-blue-500 text-white text-base uppercase color-red]
    })
  end

  it "handles remove operation" do
    engine = AttributeVariants::AttributeSet.new(
      base: {
        class: %w[inline-flex items-center justify-center]
      },
      variants: {
        color: {
          primary: {
            class: {
              remove: "inline-flex"
            }
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
      defaults: {color: :primary, size: :md}
    )

    expect(engine.render).to eq({
      class: %w[items-center justify-center text-base]
    })
  end

  it "handles append operation" do
    engine = AttributeVariants::AttributeSet.new(
      base: {
        class: %w[inline-flex items-center justify-center]
      },
      variants: {
        color: {
          primary: {
            class: {
              append: "text-sm"
            }
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
      defaults: {size: :md, color: :primary}
    )

    expect(engine.render).to eq({
      class: %w[inline-flex items-center justify-center text-base text-sm]
    })
  end

  it "handles the set operation" do
    engine = AttributeVariants::AttributeSet.new(
      base: {
        class: %w[inline-flex items-center justify-center]
      },
      variants: {
        color: {
          primary: {
            class: {
              set: "text-sm"
            }
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
      defaults: {size: :md, color: :primary}
    )

    expect(engine.render).to eq({
      class: %w[text-sm]
    })
  end

  it "handles the prepend operation" do
    engine = AttributeVariants::AttributeSet.new(
      base: {
        class: %w[inline-flex items-center justify-center]
      },
      variants: {
        color: {
          primary: {
            class: {
              prepend: "text-sm"
            }
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
      defaults: {size: :md, color: :primary}
    )

    expect(engine.render).to eq({
      class: %w[text-sm inline-flex items-center justify-center text-base]
    })
  end

  it "handles multiple operations" do
    engine = AttributeVariants::AttributeSet.new(
      base: {
        class: %w[inline-flex items-center justify-center]
      },
      variants: {
        color: {
          primary: {
            class: [
              {prepend: "text-sm"},
              {append: %w[hello world]}
            ]
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
      defaults: {size: :md, color: :primary}
    )

    expect(engine.render).to eq({
      class: %w[text-sm inline-flex items-center justify-center text-base hello world]
    })
  end

  it "handles data attribute and operations" do
    engine = AttributeVariants::AttributeSet.new(
      base: {
        class: %w[inline-flex items-center justify-center],
        data:
        {
          controller: "test"
        }
      },
      variants: {
        color: {
          primary: {
            class: {
              prepend: "text-sm",
              append: %w[hello world]
            },
            data: {
              controller: {
                set: "test2"
              }
            }
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
      defaults: {size: :md, color: :primary}
    )

    expect(engine.render).to eq({
      class: %w[text-sm inline-flex items-center justify-center text-base hello world]
    })
  end

  it "correctly handles sub-components" do
    engine = AttributeVariants::AttributeSet.new(
      base: {
        avatar: {
          class: %w[inline-flex items-center justify-center]
        },
        accept_button: {
          variants: {
            color: "primary",
            size: "sm"
          }
        }
      },
      variants: {
        type: {
          one: {
            avatar: {class: %w[bg-blue-500 text-white]},
            accept_button: {
              variants: {
                color: {set: "primary"},
                size: {set: "sm"}
              }
            }
          },
          two: {
            avatar: {class: %w[bg-purple-500 text-white]},
            accept_button: {
              variants: {
                color: {set: "secondary"},
                size: {set: "lg"}
              }
            }
          }
        }
      },
      defaults: {type: :one}
    )

    expect(engine.render[:avatar]).to eq({
      adjust: {
        class: [{set: ["bg-blue-500", "text-white"]}]
      }
    })

    puts engine.render.inspect
  end
end
