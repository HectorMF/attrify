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
                attributes: {
                  class: [{append: %w[bg-blue-500 text-white]}]
                }
              }
            },
            secondary: {
              main: {
                attributes: {
                  class: [{set: %w[bg-purple-500 text-white]}]
                }
              }
            }
          },
          size: {
            sm: {main: {attributes: {class: [{append: ["text-sm"]}]}}},
            md: {main: {attributes: {class: [{set: ["text-base"]}]}}},
            lg: {main: {attributes: {class: [{set: %w[px-4 py-3 text-lg]}]}}}
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
                attributes: {
                  class: [{append: %w[bg-blue-500 text-white]}]
                }
              },
              icon: {
                attributes: {
                  class: [{append: %w[text-black]}]
                }
              }
            },
            secondary: {
              main: {
                attributes: {
                  class: [{set: %w[bg-purple-500 text-white]}]
                }
              }
            }
          },
          size: {
            sm: {main: {attributes: {class: [{append: ["text-sm"]}]}}},
            md: {icon: {attributes: {class: [{set: ["text-base"]}]}}},
            lg: {main: {attributes: {class: [{set: %w[px-4 py-3 text-lg]}]}}}
          }
        }

        expect(Attrify::Parser.parse_variants(variants)).to eq(parsed_variants)
      end
    end
  end
end
