# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_slot" do
    context "when the input is not a hash" do
      it "raises an ArgumentError" do
        expect { Attrify::Parser.parse_slot("not a hash") }.to raise_error(ArgumentError)
      end
    end

    context "when the input is an empty hash" do
      it "returns an empty hash" do
        expect(Attrify::Parser.parse_slot({})).to eq({})
      end
    end

    context "when attributes include unexpected data types" do
      it "handles nil values appropriately" do
        input = {
          id: nil,
          class: nil
        }

        expected_output = {
          attributes: {
            id: [{set: [""]}],
            class: [{set: [""]}]
          }
        }

        expect(Attrify::Parser.parse_slot(input)).to eq(expected_output)
      end
    end

    context "when keys are not symbols" do
      it "converts string keys to symbols" do
        input = {
          "class" => "my_class",
          "data-id" => 123
        }

        expected_output = {
          attributes: {
            class: [{set: ["my_class"]}],
            "data-id": [{set: ["123"]}]
          }
        }

        expect(Attrify::Parser.parse_slot(input)).to eq(expected_output)
      end
    end

    context "when values are symbols" do
      it "converts symbols to strings" do
        input = {
          class: [:class1, :class2]
        }

        expected_output = {
          attributes: {
            class: [{set: ["class1", "class2"]}]
          }

        }

        expect(Attrify::Parser.parse_slot(input)).to eq(expected_output)
      end
    end

    context "when values are arrays with mixed content" do
      it "handles arrays containing both strings and hashes" do
        input = {
          class: ["button", {append: "large"}, :primary, {prepend: "icon"}]
        }

        expected_output = {
          attributes: {
            class: [
              {set: "button"},
              {append: "large"},
              {set: "primary"},
              {prepend: "icon"}
            ]
          }
        }

        expect(Attrify::Parser.parse_slot(input)).to eq(expected_output)
      end
    end

    context "when operation hashes have multiple keys" do
      it "raises an error for invalid operation hashes" do
        input = {
          class: [{set: "btn", append: "btn-primary"}]
        }

        expect { Attrify::Parser.parse_slot(input) }.to raise_error(ArgumentError)
      end
    end

    context "when there are circular references" do
      it "raises a SystemStackError or handles the circular reference" do
        input = {}
        input[:self] = input

        expect { Attrify::Parser.parse_slots(input) }.to raise_error(SystemStackError)
      end
    end

    context "when the input is extremely large" do
      it "handles large inputs without performance issues" do
        large_input = {}
        1000.times do |i|
          large_input[:"key#{i}"] = "value#{i}"
        end

        expected_output = {
          attributes: large_input.transform_values { |v| [{set: [v]}] }
        }

        expect(Attrify::Parser.parse_slot(large_input)).to eq(expected_output)
      end
    end

    context "when values are empty arrays" do
      it "handles empty arrays appropriately" do
        input = {
          class: []
        }

        expected_output = {
          attributes: {
            class: [{set: []}]
          }
        }

        expect(Attrify::Parser.parse_slot(input)).to eq(expected_output)
      end
    end

    context "when attributes are deeply nested" do
      it "correctly parses deeply nested structures" do
        input = {
          data: {
            nested1: {
              nested2: {
                nested3: "deep_value"
              }
            }
          }
        }

        expected_output = {
          attributes: {
            data: {
              nested1: {
                nested2: {
                  nested3: [{set: ["deep_value"]}]
                }
              }
            }
          }
        }

        expect(Attrify::Parser.parse_slot(input)).to eq(expected_output)
      end
    end

    context "when values are procs" do
      it "includes proc values without execution" do
        my_proc = proc { "computed_value" }
        input = {
          class: [my_proc]
        }

        expected_output = {
          attributes: {
            class: [{set: [my_proc]}]
          }
        }

        expect(Attrify::Parser.parse_slot(input)).to eq(expected_output)
      end
    end

    describe ".parse_slotsss" do
      it "correctly parses slots 1" do
        # No Slot defined, so we wrap it in a default key
        expect(Attrify::Parser.parse_slots({
          class: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]],
          id: 10
        })).to eq(
          {
            main: {
              attributes: {
                class: [{set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}],
                id: [{set: ["10"]}]
              }
            }
          }
        )
      end

      it "correctly parses slots 2" do
        # Slot defined, so we keep it
        expect(Attrify::Parser.parse_slots({
          button: {
            class: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]],
            id: 10
          }
        })).to eq(

          # parses to
          {
            button: {
              attributes: {
                class: [{set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}],
                id: [{set: ["10"]}]
              }
            }
          }
        )
      end

      it "correctly parses slots 3" do
        expect(Attrify::Parser.parse_slots(
          {
            card: {
              # these are the attributes for the card slot
              color: :primary,
              class: [{append: ["card-test"]}],
              # this is a single nested slot
              body: {
                color: :secondary
              },
              # this is a nested slot with sub-slots
              footer: {
                color: :outline,
                style: "color: red;",
                # Nested slots
                accept_button: {
                  class: "accept-button"
                },
                decline_button: {
                  color: :danger
                }
              },

              # this is a triple nested slot
              header: {
                close_button:
                {
                  button_icon: {
                    icon: :cross
                  }
                }
              }
            }
          }
        )).to eq(
          {
            card: {
              # these are the attributes for the card slot
              attributes: {
                color: [{set: ["primary"]}],
                class: [{append: ["card-test"]}]
              },
              # this is a single nested slot
              body: {
                attributes: {
                  color: [{set: ["secondary"]}]
                }
              },
              # this is a nested slot with sub-slots
              footer: {
                attributes: {
                  color: [{set: ["outline"]}],
                  style: [{set: ["color: red;"]}]
                },

                # Nested slots
                accept_button: {
                  attributes: {
                    class: [{set: ["accept-button"]}]
                  }
                },
                decline_button: {
                  attributes: {
                    color: [{set: ["danger"]}]
                  }
                }
              },

              # this is a triple nested slot
              header: {
                close_button:
                {
                  button_icon: {
                    attributes: {
                      icon: [{set: ["cross"]}]
                    }
                  }
                }
              }
            }
          }
        )
      end
    end

    describe ".parse_slots" do
      context "when input is a single slot" do
        it "parses a single slot as the main slot" do
          slot = {class: "test"}
          parsed = described_class.parse_slots(slot)

          expect(parsed).to eq({
            main: {attributes: {class: [{set: ["test"]}]}}
          })
        end
      end

      context "when input contains multiple slots" do
        it "parses multiple slots with variants and adjust operations" do
          slots = {
            button: {color: :primary, class: "test"},
            card: {attributes: {class: {append: "card-test"}}}
          }

          parsed = described_class.parse_slots(slots)

          expect(parsed).to eq({
            button: {
              attributes: {
                color: [{set: ["primary"]}],
                class: [{set: ["test"]}]
              }
            },
            card: {
              attributes: {class: [{append: ["card-test"]}]}
            }
          })
        end
      end
    end
  end
end
