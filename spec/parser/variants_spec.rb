# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_variants" do
    context "two variants with no slot are defined" do
      it "returns the correctly parsed variants" do
        variants = {
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
        }

        parsed_variants = {
          color: {
            primary: {
              main: {
                operations: {
                  class: [{append: %w[bg-blue-500 text-white]}]
                }
              }
            },
            secondary: {
              main: {
                operations: {
                  class: [{set: %w[bg-purple-500 text-white]}]
                }
              }
            }
          },
          size: {
            sm: {main: {operations: {class: [{append: ["text-sm"]}]}}},
            md: {main: {operations: {class: [{set: ["text-base"]}]}}},
            lg: {main: {operations: {class: [{set: %w[px-4 py-3 text-lg]}]}}}
          }
        }

        expect(Attrify::Parser.parse_variants(variants)).to eq(parsed_variants)
      end
    end

    context "multiple variants with complex slot structure are given" do
      it "returns the correctly parsed variants" do
        variants = {
          color: {
            primary: {
              main: {
                class: {append: %w[bg-blue-500 text-white]}
              },
              icon: {
                class: {append: %w[text-black]}
              }
            },
            secondary: {
              class: %w[bg-purple-500 text-white]
            }
          },
          size: {
            sm: {class: {append: "text-sm"}},
            md: {icon: {class: "text-base"}},
            lg: {class: %w[px-4 py-3 text-lg]}
          }
        }

        parsed_variants = {
          color: {
            primary: {
              main: {
                operations: {
                  class: [{append: %w[bg-blue-500 text-white]}]
                }
              },
              icon: {
                operations: {
                  class: [{append: %w[text-black]}]
                }
              }
            },
            secondary: {
              main: {
                operations: {
                  class: [{set: %w[bg-purple-500 text-white]}]
                }
              }
            }
          },
          size: {
            sm: {main: {operations: {class: [{append: ["text-sm"]}]}}},
            md: {icon: {operations: {class: [{set: ["text-base"]}]}}},
            lg: {main: {operations: {class: [{set: %w[px-4 py-3 text-lg]}]}}}
          }
        }

        expect(Attrify::Parser.parse_variants(variants)).to eq(parsed_variants)
      end
    end
  end
end
