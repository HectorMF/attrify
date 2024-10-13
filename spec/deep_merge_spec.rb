# frozen_string_literal: true

class TestHelpers
  include Attrify::Helpers
end

example_base = {
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

example_variant = {
  card: {
    # these are the attributes for the card slot
    attributes: {
      color: [{set: ["link"]}],
      style: [{append: ["background:blue;"]}]
    },
    # this is a single nested slot
    body: {
      attributes: {
        icon: [{set: ["x"]}]
      }
    },
    # this is a nested slot with sub-slots
    footer: {
      attributes: {
        color: [{set: ["outline"]}]
      },

      # Nested slots
      accept_button: {
        attributes: {
          class: [{append: ["disabled"]}]
        }
      },
      decline_button: {
        attributes: {
          color: [{set: ["warning"]}]
        }
      }
    },

    # this is a triple nested slot
    header: {
      close_button:
      {
        button_icon: {
          attributes: {
            icon: [{set: ["eye"]}],
            data: {
              controller: [{set: ["stimulus_controller"]}]
            },
            aria: {
              hidden: [{set: ["true"]}]
            }
          }
        }
      }
    }
  }
}

example_output = {
  card: {
    # these are the attributes for the card slot
    attributes: {
      color: [{set: ["primary"]}, {set: ["link"]}],
      class: [{append: ["card-test"]}],
      style: [{append: ["background:blue;"]}]
    },
    # this is a single nested slot
    body: {
      attributes: {
        color: [{set: ["secondary"]}],
        icon: [{set: ["x"]}]
      }
    },
    # this is a nested slot with sub-slots
    footer: {
      attributes: {
        color: [{set: ["outline"]}, {set: ["outline"]}],
        style: [{set: ["color: red;"]}]
      },

      # Nested slots
      accept_button: {
        attributes: {
          class: [{set: ["accept-button"]}, {append: ["disabled"]}]
        }
      },
      decline_button: {
        attributes: {
          color: [{set: ["danger"]}, {set: ["warning"]}]
        }
      }
    },

    # this is a triple nested slot
    header: {
      close_button:
      {
        button_icon: {
          attributes: {
            icon: [{set: ["cross"]}, {set: ["eye"]}],
            data: {
              controller: [{set: ["stimulus_controller"]}]
            },
            aria: {
              hidden: [{set: ["true"]}]
            }
          }
        }
      }
    }
  }
}

RSpec.describe Attrify::Helpers do
  context "when the helper is included" do
    it "adds the helper methods to the class" do
      expect(TestHelpers.new).to respond_to(:deep_merge_hashes)
    end
  end

  describe "#deep_merge_hashes" do
    context "when it is given simple inputs" do
      it "merges two hashes" do
        expect(TestHelpers.new.deep_merge_hashes({a: 1}, {b: 2})).to eq({a: 1, b: 2})
      end

      it "merges nested hashes" do
        expect(TestHelpers.new.deep_merge_hashes({a: {b: 1}}, {a: {c: 2}})).to eq({a: {b: 1, c: 2}})
      end

      it "merges arrays" do
        expect(TestHelpers.new.deep_merge_hashes({a: [1]}, {a: [2]})).to eq({a: [1, 2]})
      end

      it "merges nested arrays" do
        expect(TestHelpers.new.deep_merge_hashes({a: [1]}, {a: [2, 3]})).to eq({a: [1, 2, 3]})
      end
    end

    context "when it is given complex inputs" do
      it "merges" do
        expect(TestHelpers.new.deep_merge_hashes({"data-controller": ["test"], "data-id": [1]}, {"data-id": ["merge"]}))
          .to eq({"data-controller": ["test"], "data-id": [1, "merge"]})
      end

      it "merges deeply nested hashes" do
        expect(TestHelpers.new.deep_merge_hashes(example_base, example_variant)).to eq(example_output)
      end
    end
  end
end
