# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_slots" do
    context "when the input is not a hash" do
      it "raises an ArgumentError" do
        expect { Attrify::Parser.parse_slots("not a hash") }.to raise_error(ArgumentError)
      end
    end

    context "when the input is an empty hash" do
      it "returns an empty hash" do
        expect(Attrify::Parser.parse_slots({})).to eq({})
      end
    end

    context "when there are circular references" do
      it "raises a SystemStackError or handles the circular reference" do
        input = {}
        input[:self] = input

        expect { Attrify::Parser.parse_slots(input) }.to raise_error(SystemStackError)
      end
    end

    context "when no slot name is given" do
      it "adds the 'main' slot" do
        # No Slot defined, so we wrap it in a main key
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
    end

    context "when a single slot is defined" do
      it "parses the slot correctly" do
        expect(Attrify::Parser.parse_slots({
          button: {
            class: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]],
            id: 10
          }
        })).to eq(
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
    end

    context "when multiple slots are defined" do
      it "parses the slots correctly" do
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

    context "when sub-slots are defined" do
      it "parses the slots correctly" do
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
  end
end
