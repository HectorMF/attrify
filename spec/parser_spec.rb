# frozen_string_literal: true

RSpec.describe Attrify::Parser do
    describe '.parse_operations' do
      context 'when input is a string' do
        it 'returns an empty set operation for an empty string' do
          expect(described_class.parse_operations("")).to eq({set: [""]})
        end

        it 'parses the string as a set operation' do
          expect(described_class.parse_operations("border-1")).to eq({set: ["border-1"]})
        end
      end
  
      context 'when input is an array' do
        it 'returns an empty set operation for an empty array' do
          expect(described_class.parse_operations([])).to eq({set: []})
        end
  
        it 'parses the array as a set operation with multiple values' do
          expect(described_class.parse_operations(["border-1", "border-bottom-0"])).to eq({set: ["border-1", "border-bottom-0"]})
        end
      end
  
      context 'when input is a hash' do
        it 'handles empty hash input' do
          expect(described_class.parse_operations({})).to eq({})
        end

        it 'parses an append operation' do
          expect(described_class.parse_operations({append: "10"})).to eq({append: ["10"]})
        end
  
        it 'parses a nested controller operation with non-string values' do
          expect(described_class.parse_operations({controller: ["border", 10]})).to eq({controller: [{set: ["border", "10"]}]})
        end
  
        it 'parses a hash with a controller set as a string' do
          expect(described_class.parse_operations({controller: {set: "controller"}})).to eq({controller: [{set: ["controller"]}]})
        end
  
        it 'parses a controller operation provided as a string' do
          expect(described_class.parse_operations({controller: "controller"})).to eq({controller: [{set: ["controller"]}]})
        end
      end
  
      context 'when input contains non-primitive types' do
        it 'returns an empty set operation for nil input' do
          expect(described_class.parse_operations(nil)).to eq({set: [""]})
        end

        it 'parses operations with symbols by converting them to strings' do
          parsed = described_class.parse_operations({append: :symbol_test})
          expect(parsed).to eq({append: ["symbol_test"]})
        end
  
        it 'handles arrays containing mixed types' do
          parsed = described_class.parse_operations(["border-1", 42, :symbol_value])
          expect(parsed).to eq({set: ["border-1", "42", "symbol_value"]})
        end

        it 'raises an error for types without a valid to_s' do
          no_to_s_object = Class.new do
            undef_method :to_s # Explicitly remove the to_s method
          end.new
  
          expect { described_class.parse_operations(no_to_s_object) }.to raise_error(NoMethodError)
        end
      end

      context 'when input contains deep nesting and operations' do
        it 'parses nested structures with string and array values' do
          parsed = described_class.parse_operations(
            {
              controller: "controller",
              deep: {
                nesting: ["foo", 10, :bar],
                controller: {set: "controller"}
              }
            }
          )
          expected = {
            controller: [{set: ["controller"]}],
            deep: {
              nesting: [{set: ["foo", "10", "bar"]}],
              controller: [{set: ["controller"]}]
            }
          }
          expect(parsed).to eq(expected)
        end
      end
    end
    
    describe '.parse_slot' do
      context 'when input is valid' do
        it 'parses a valid slot with a variant' do
          slot = { variant: { color: :primary }, adjust: { append: "test" } }
          parsed = described_class.parse_slot(slot)
  
          expect(parsed).to eq({
            variant: { color: :primary },
            adjust: { append: ["test"] }
          })
        end
  
        it 'parses a valid slot without a variant' do
          slot = { append: "test" }
          parsed = described_class.parse_slot(slot)
  
          expect(parsed).to eq({
            adjust: { append: ["test"] }
          })
        end
      end
  
      context 'when input is invalid' do
        it 'raises an error for non-hash input' do
          expect { described_class.parse_slot(["invalid", "data"]) }.to raise_error(ArgumentError)
        end
  
        it 'raises an error for invalid variant structure' do
          invalid_slot = { variant: "invalid_variant_structure" }
          expect { described_class.parse_slot(invalid_slot) }
            .to raise_error(ArgumentError)
        end
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
          adjust: {
            class: [{set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}],
            id: [{set: ["10"]}]
          }
        } 
      })
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
          adjust: {
            class: [{set: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]}],
            id: [{set: ["10"]}]
          }
        }
      })
    end

    it "correctly parses slots 3" do
      expect(Attrify::Parser.parse_slots(
      {
        card: {
          # these are the attributes for the card slot
          variant: { color: :primary },
          adjust: { class: [{ append: ["card-test"] }]},

          # this is a single nested slot
          body: { variant: { color: :primary } },
          
          # this is a nested slot with multiple slots
          footer: {
            variant: { color: :primary },

            # Nested slots
            accept_button: { variant: { color: :primary } },
            decline_button: { variant: { color: :danger } }
          },

          # this is a double nested slot
          header: {
            close_button:
            {
              button_icon: { variant: { icon: :cross } }
            }
          }
        }
      }
      )).to eq(
      # parses to
      {
        card: {
          variant: { color: :primary },
          adjust: { class: [{ append: ["card-test"] }] },

          body: { variant: {color: :primary} },

          footer: {
            variant: { color: :primary },

            # Nested slots
            accept_button: { variant: { color: :primary } },
            decline_button: { variant: { color: :danger } }
          },
          header: {
            close_button: {
              button_icon: { variant: { icon: :cross } }
            }
          }
        }
      })
    end
    end

    describe '.parse_slots' do
      context 'when input is a single slot' do
        it 'parses a single slot as the main slot' do
          slot = { append: "test" }
          parsed = described_class.parse_slots(slot)
  
          expect(parsed).to eq({
            main: { adjust: { append: ["test"] } }
          })
        end
      end
  
      context 'when input contains multiple slots' do
        it 'parses multiple slots with variants and adjust operations' do
          slots = {
            button: { variant: { color: :primary }, adjust: { class: "test" } },
            card: { adjust: {class: {append: "card-test"}} }
          }
          

          
  
          parsed = described_class.parse_slots(slots)
  
          expect(parsed).to eq({
            button: {
              variant: { color: :primary },
              adjust: { class: [{set: ["test"]}]}
            },
            card: {
              adjust: { class: [{ append: ["card-test"] }]}
            }
          })
        end
      end
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
      main:
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
          variant: {
            color: :primary,
            size: :sm
          }
        }
      })).to eq({
        avatar:{
          adjust: {
            class: [{set: %w[inline-flex items-center justify-center]}]
          }
        },
        accept_button: {
          variant: { color: :primary, size: :sm }
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
  describe '.parse_variants' do
    context 'as' do
      it 'returns the defaults' do
        variants = {
          color: {
            primary: {
              class: { append: %w[bg-blue-500 text-white]}
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
        } 

        parsed_variants = {
          color: {
            primary: {
              main: {
                adjust: {
                  class: [{ append: %w[bg-blue-500 text-white]}]
                }
              }
            },
            secondary: {
              main: {
                adjust: {
                  class: [{ set: %w[bg-purple-500 text-white] }]
                }
              }
            }
          },
          size: {
            sm: { main: { adjust: { class: [{append: ["text-sm"]}]}}},
            md: { main: { adjust: { class: [{set: ["text-base"]}]}}},
            lg: { main: { adjust: { class: [{set: %w[px-4 py-3 text-lg]}]}}
          }
        }}


        expect(Attrify::Parser.parse_variants(variants)).to eq(parsed_variants)
      end
    end
  end

  describe '.parse_defaults' do
    context 'when defaults is a valid flat hash of symbols' do
      it 'returns the defaults' do
        defaults = { color: :primary, type: :button, disabled: :yes }
        expect(Attrify::Parser.parse_defaults(defaults)).to eq(defaults)
      end
    end
  
    context 'when defaults is not a hash' do
      it 'raises an ArgumentError if defaults is not a hash' do
        expect { Attrify::Parser.parse_defaults([:color, :primary]) }.to raise_error(ArgumentError, "Defaults must be a hash, got Array")
        expect { Attrify::Parser.parse_defaults("color: primary") }.to raise_error(ArgumentError, "Defaults must be a hash, got String")
        expect { Attrify::Parser.parse_defaults(123) }.to raise_error(ArgumentError, "Defaults must be a hash, got Integer")
      end
    end
  
    context 'when defaults has non-symbol keys or values' do
      it 'raises an ArgumentError if any key is not a symbol' do
        defaults = { "color" => :primary, type: :button }
        expect { Attrify::Parser.parse_defaults(defaults) }.to raise_error(ArgumentError, 'Defaults must be a flat hash of symbols. Got: {"color"=>:primary, :type=>:button}')
      end
  
      it 'raises an ArgumentError if any value is not a symbol' do
        defaults = { color: 'primary', type: :button }
        expect { Attrify::Parser.parse_defaults(defaults) }.to raise_error(ArgumentError, 'Defaults must be a flat hash of symbols. Got: {:color=>"primary", :type=>:button}')
      end
  
      it 'raises an ArgumentError if both keys and values are not symbols' do
        defaults = { "color" => "primary", "type" => :button }
        expect { Attrify::Parser.parse_defaults(defaults) }.to raise_error(ArgumentError, 'Defaults must be a flat hash of symbols. Got: {"color"=>"primary", "type"=>:button}')
      end
    end
  
    context 'when defaults is an empty hash' do
      it 'returns an empty hash without errors' do
        defaults = {}
        expect(Attrify::Parser.parse_defaults(defaults)).to eq({})
      end
    end


      
    context 'when defaults is an empty hash' do
      it 'returns an empty hash without errors' do
        defaults = {
          data:
          {
            controller: "click->alert#close"
          }
        }
        expect(Attrify::Parser.parse_slots(defaults)).to eq({})
      end
    end
  end
end
