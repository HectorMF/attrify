# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_slot" do
    context "when input is valid" do
      it "parses a valid slot with a variant" do
        slot = {variant: {color: :primary}, operations: {append: "test"}}
        parsed = described_class.parse_slot(slot)

        expect(parsed).to eq({
          variant: {color: :primary},
          operations: {append: ["test"]}
        })
      end

      it "parses a valid slot without a variant" do
        slot = {append: "test"}
        parsed = described_class.parse_slot(slot)

        expect(parsed).to eq({
          attributes: {append: ["test"]}
        })
      end
    end

    context "when input is invalid" do
      it "raises an error for non-hash input" do
        expect { described_class.parse_slot(["invalid", "data"]) }.to raise_error(ArgumentError)
      end

      it "raises an error for invalid variant structure" do
        invalid_slot = {variant: "invalid_variant_structure"}
        expect { described_class.parse_slot(invalid_slot) }
          .to raise_error(ArgumentError)
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
