RSpec.describe Attrify::VariantRegistry do
  describe "handles empty and base attributes" do
    it "returns an empty attribute set when no attributes are defined" do
      expect(Attrify::VariantRegistry.new.fetch.operations).to eq({})
    end

    it "returns base attributes when no variants are specified" do
      variant = Attrify::VariantRegistry.new(
        base: {
          color: :primary,
          id: 10,
          class: %w[inline-flex items-center justify-center],
          style: "color: red;",
          data: {controller: "stimulus_controller"}
        }
      ).fetch

      expect(variant.operations).to eq(
        {
          main: {
            attributes: {
              color: [{set: ["primary"]}],
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
  end

  describe "handles variants" do
    it "correctly returns default variants" do
      variant = Attrify::VariantRegistry.new(
        base: {
          id: 10,
          class: %w[inline-flex items-center justify-center],
          style: "color: red;",
          data: {controller: "stimulus_controller"}
        },
        variants: {
          color: {
            primary: {class: {append: %w[bg-blue-500 text-white]}},
            secondary: {class: %w[bg-purple-500 text-white]}
          },
          size: {
            sm: {class: {append: "text-sm"}},
            md: {class: "text-base"},
            lg: {class: %w[px-4 py-3 text-lg]}
          }
        },
        defaults: {color: :primary, size: :sm}
      ).fetch

      expect(variant.operations).to eq({
        main: {
          attributes: {
            id: [{set: ["10"]}],
            class: [{set: %w[inline-flex items-center justify-center]}, {append: %w[bg-blue-500 text-white]}, {append: %w[text-sm]}],
            style: [{set: ["color: red;"]}],
            data: {controller: [{set: ["stimulus_controller"]}]}
          }
        }
      })
    end

    context "returns the correct set when a variant is selected" do
      let(:registry) {
        Attrify::VariantRegistry.new(
          base: {
            id: 10,
            class: %w[inline-flex items-center justify-center],
            style: "color: red;",
            data: {controller: "stimulus_controller"}
          },
          variants: {
            color: {
              primary: {class: {append: %w[bg-blue-500 text-white]}},
              secondary: {class: {append: %w[bg-purple-500 text-white]}}
            },
            size: {
              sm: {style: {append: "border-radius:40px;"}, class: {prepend: "text-sm"}},
              md: {class: "text-base"},
              lg: {class: %w[px-4 py-3 text-lg]}
            }
          },
          defaults: {color: :primary, size: :sm}
        )
      }

      it "applies secondary color variant with default size" do
        expect(registry.fetch(color: :secondary).operations).to eq({
          main: {
            attributes: {
              id: [{set: ["10"]}],
              class: [{set: %w[inline-flex items-center justify-center]}, {append: %w[bg-purple-500 text-white]}, {prepend: %w[text-sm]}],
              style: [{set: ["color: red;"]}, {append: ["border-radius:40px;"]}],
              data: {controller: [{set: ["stimulus_controller"]}]}
            }
          }
        })
      end

      it "applies primary color and large size variants" do
        expect(registry.fetch(color: :primary, size: :lg).operations).to eq({
          main: {
            attributes: {
              id: [{set: ["10"]}],
              class: [{set: %w[inline-flex items-center justify-center]}, {append: %w[bg-blue-500 text-white]}, {set: %w[px-4 py-3 text-lg]}],
              style: [{set: ["color: red;"]}],
              data: {controller: [{set: ["stimulus_controller"]}]}
            }
          }
        })
      end
    end
  end

  describe "handling compound variants" do
    let(:registry) {
      Attrify::VariantRegistry.new(
        base: {class: %w[inline-flex items-center justify-center]},
        variants: {
          color: {
            primary: {class: %w[bg-blue-500 text-white]},
            secondary: {class: %w[bg-purple-500 text-white]}
          },
          size: {
            sm: {class: "text-sm"},
            md: {class: "text-base"},
            lg: {class: %w[px-4 py-3 text-lg]}
          }
        },
        compounds: [{
          variants: {color: :primary, size: :md},
          attributes: {
            class: {append: "uppercase"}
          }
        }],
        defaults: {color: :primary, size: :md}
      )
    }

    it "returns expected set when non-compound is asked for" do
      expect(registry.fetch(size: :sm).operations).to eq({
        main: {
          attributes: {
            class: [{set: %w[inline-flex items-center justify-center]}, {set: %w[bg-blue-500 text-white]}, {set: %w[text-sm]}]
          }
        }
      })
    end

    it "returns the correct compound variant" do
      expect(registry.fetch.operations).to eq({
        main: {
          attributes: {
            class: [{set: %w[inline-flex items-center justify-center]}, {set: %w[bg-blue-500 text-white]}, {set: %w[text-base]}, {append: %w[uppercase]}]
          }
        }
      })
    end
  end

  describe "handling attribute overrides" do
    let(:registry) {
      Attrify::VariantRegistry.new(
        base: {class: %w[inline-flex items-center justify-center]},
        variants: {
          color: {
            primary: {class: %w[bg-blue-500 text-white]},
            secondary: {class: %w[bg-purple-500 text-white]}
          },
          size: {
            sm: {class: "text-sm"},
            md: {class: {append: "text-base"}},
            lg: {class: "px-4 py-3 text-lg"}
          }
        },
        compounds: [{
          variants: {color: :primary, size: :md},
          attributes: {class: {append: "uppercase"}}
        }],
        defaults: {color: :primary, size: :md}
      )
    }

    it "correctly overrides attributes with adjustments" do
      expect(registry.fetch(class: {append: "color-red"}).operations).to eq({
        main: {
          attributes: {
            class: [
              {set: %w[inline-flex items-center justify-center]},
              {set: %w[bg-blue-500 text-white]},
              {append: %w[text-base]},
              {append: %w[uppercase]},
              {append: %w[color-red]}
            ]
          }
        }
      })
    end
  end

  context "when mulitple slots are defined" do
    let(:registry) {
      Attrify::VariantRegistry.new(
        base: {
          button: {color: :link},
          card: {class: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}
        },
        variants: {
          style: {
            one: {
              button: {color: :primary},
              card: {class: {append: "bg-purple-400"}}
            },
            two: {
              button: {color: :secondary},
              card: {class: {append: "bg-primary"}}
            }
          },
          color: {
            primary: {
              button: {class: {append: "w-100"}},
              card: {class: {append: "bg-primary"}}
            },
            secondary: {
              button: {class: {append: "w-200"}},
              card: {class: {append: "bg-secondary"}}
            }
          }
        },
        compounds: [
          {
            variants: {style: :one, color: :primary},
            attributes: {
              button: {
                color: :destructive,
                class: {append: "w-300"}
              }
            }
          }
        ],
        defaults: {style: :one}
      )
    }

    it "returns default slot variants and adjustments" do
      expect(registry.fetch.operations).to eq({
        button: {
          attributes: {
            color: [{set: ["link"]}, {set: ["primary"]}]
          }
        },
        card: {
          attributes: {
            class: [{set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}, {append: ["bg-purple-400"]}]
          }
        }
      })
    end

    it "applies compound variants for button and card slots" do
      expect(registry.fetch(color: :primary).operations).to eq({
        button: {
          attributes: {
            color: [{set: ["link"]}, {set: ["primary"]}, {set: ["destructive"]}],
            class: [{append: ["w-100"]}, {append: ["w-300"]}]
          }
        },
        card: {
          attributes: {
            class: [
              {set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]},
              {append: ["bg-purple-400"]},
              {append: ["bg-primary"]}
            ]
          }
        }
      })
    end
  end

  describe "when compound variants and slots are defined" do
    let(:registry) {
      Attrify::VariantRegistry.new(
        base: {
          button: {color: :link},
          card: {class: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}
        },
        variants: {
          style: {
            one: {
              button: {color: :primary},
              card: {class: {append: "bg-purple-400"}}
            },
            two: {
              button: {color: :secondary},
              card: {class: {append: "bg-primary"}}
            }
          },
          color: {
            primary: {
              button: {class: {append: "w-100"}},
              card: {class: {append: "bg-primary"}}
            },
            secondary: {
              button: {class: {append: "w-200"}},
              card: {class: {append: "bg-secondary"}}
            }
          }
        },
        compounds: [
          {
            variants: {style: :one, color: :primary},
            attributes: {
              button: {
                color: :destructive,
                class: {append: "w-300"}
              }
            }
          }
        ],
        defaults: {style: :one}
      )
    }

    it "returns default slot variants and adjustments" do
      expect(registry.fetch.operations).to eq({
        button: {
          attributes: {
            color: [{set: ["link"]}, {set: ["primary"]}]
          }
        },
        card: {
          attributes: {
            class: [{set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}, {append: ["bg-purple-400"]}]
          }
        }
      })
    end

    it "applies compound variants for button and card slots" do
      expect(registry.fetch(color: :primary).operations).to eq({
        button: {
          attributes: {
            color: [{set: ["link"]}, {set: ["primary"]}, {set: ["destructive"]}],
            class: [{append: ["w-100"]}, {append: ["w-300"]}]
          }
        },
        card: {
          attributes: {
            class: [
              {set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]},
              {append: ["bg-purple-400"]},
              {append: ["bg-primary"]}
            ]
          }
        }
      })
    end
  end
end
