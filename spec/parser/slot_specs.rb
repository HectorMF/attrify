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

  describe ".parse_slots" do
    context "when operation hashes have invalid keys" do
      it "ignores or raises errors for unknown operations" do
        input = {
          class: [{unknown_op: "value"}]
        }

        expect { Attrify::Parser.parse_slots(input) }.to raise_error(ArgumentError)
      end
    end

    context "when keys contain special characters" do
      it "handles keys with special characters appropriately" do
        input = {
          "data-controller": "my_controller",
          "data-action": "click->doSomething"
        }

        expected_output = {
          main: {
            attributes: {
              "data-controller": [{set: ["my_controller"]}],
              "data-action": [{set: ["click->doSomething"]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when values contain special characters" do
      it "handles special characters in values appropriately" do
        input = {
          class: ["<script>alert('xss')</script>", "&", "%"]
        }

        expected_output = {
          main: {
            attributes: {
              class: [{set: ["<script>alert('xss')</script>", "&", "%"]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when attributes include unexpected nested arrays" do
      it "raises an error or handles nested arrays" do
        input = {
          class: [["nested_array"]]
        }

        expected_output = {
          main: {
            attributes: {
              class: [{set: ["nested_array"]}]
            }
          }
        }

        # Depending on implementation, parser might flatten nested arrays or raise an error
        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when attributes include numbers as keys" do
      it "raises an error or converts number keys to strings" do
        input = {
          123 => "value"
        }

        expected_output = {
          main: {
            attributes: {
              "123": [{set: ["value"]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when operation hashes have invalid values" do
      it "raises an error for invalid operation values" do
        input = {
          class: [{set: Object.new}]
        }

        expect { Attrify::Parser.parse_slots(input) }.to raise_error(TypeError)
      end
    end

    context "when operation hashes are missing values" do
      it "raises an error or handles missing operation values" do
        input = {
          class: [{set: nil}]
        }

        expected_output = {
          main: {
            attributes: {
              class: [{set: [nil]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when operation hashes contain multiple operations" do
      it "handles operation hashes with multiple operations" do
        input = {
          class: [{append: "btn", prepend: "icon"}]
        }

        expect { Attrify::Parser.parse_slots(input) }.to raise_error(ArgumentError)
      end
    end

    context "when input includes invalid slot names" do
      it "raises an error for invalid slot names" do
        input = {
          nil => {
            class: "some_class"
          }
        }

        expect { Attrify::Parser.parse_slots(input) }.to raise_error(ArgumentError)
      end
    end

    context "when attributes include duplicate keys" do
      it "uses the last value for duplicate keys" do
        input = {
          class: "first_class",
          class: "second_class"
        }

        expected_output = {
          main: {
            attributes: {
              class: [{set: ["second_class"]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when attributes include special values like NaN or Infinity" do
      it "handles special numeric values appropriately" do
        input = {
          value: Float::NAN,
          max: Float::INFINITY
        }

        expected_output = {
          main: {
            attributes: {
              value: [{set: ["NaN"]}],
              max: [{set: ["Infinity"]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when attributes include boolean values" do
      it "converts boolean values to strings" do
        input = {
          disabled: true,
          hidden: false
        }

        expected_output = {
          main: {
            attributes: {
              disabled: [{set: ["true"]}],
              hidden: [{set: ["false"]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when attributes include Date and Time objects" do
      it "converts Date and Time objects to ISO 8601 strings" do
        date = Date.new(2021, 12, 25)
        time = Time.new(2021, 12, 25, 12, 0, 0)
        input = {
          start_date: date,
          start_time: time
        }

        expected_output = {
          main: {
            attributes: {
              start_date: [{set: [date.iso8601]}],
              start_time: [{set: [time.iso8601]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end

    context "when attributes include BigDecimal values" do
      it "converts BigDecimal values to strings" do
        big_decimal = BigDecimal("123.456")
        input = {
          price: big_decimal
        }

        expected_output = {
          main: {
            attributes: {
              price: [{set: [big_decimal.to_s]}]
            }
          }
        }

        expect(Attrify::Parser.parse_slots(input)).to eq(expected_output)
      end
    end
  end
end
