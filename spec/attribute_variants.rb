# # frozen_string_literal: true

# RSpec.describe Attrify do
#   # id: { append: "10" },
#   # name: "name",
#   # name2: [{set: 'hello'}, {append: "world"}],
#   # data: {
#   #   controller: ["asdfsa", "asdfsaf"],
#   #   context: { set: "10" },
#   #   test:{
#   #     multiple:
#   #     {
#   #       test2: "123"
#   #       levels:
#   #       {
#   #         set: "100"
#   #       }
#   #     }
#   #   }
#   # }

#   # id: { append: "10" },
#   # name: { set: "name" },
#   # name2: [{ set: 'hello' }, { append: "world" }],
#   # data: {
#   #   controller: {set: ["asdfsa", "asdfsaf"]},
#   #   context: { set: "10" },
#   #   test: {
#   #     multiple:
#   #     {
#   #       test2: {set: "123"}
#   #       levels:
#   #       {
#   #         set: {set: "100"}
#   #       }
#   #     }
#   #   }
#   # }

#   it "has a version number" do
#     expect(Attrify::VERSION).not_to be nil
#   end

#   it "correctly handles s" do
#     engine = Attrify::AttributeSet.new(base: {
#                                                    accept_button:
#                                                    {
#                                                      variant: {color: :destructive}
#                                                    },
#                                                    card:
#       {
#         class: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]
#       }
#                                                  },
#       variants: {
#         style: {
#           one: {
#             accept_button:
#             {
#               variant: {color: :primary}
#             },
#             card:
#             {
#               class: {append: "bg-purple-400"}
#             }
#           },
#           two: {
#             accept_button:
#             {
#               variant: {color: :secondary}
#             },
#             card: {class: {append: "bg-purple-400"}}
#           }
#         }
#       },
#       defaults: {style: :one})

#     expect(engine.render).to eq({
#       adjust: {
#         class: [{set: ["bg-blue-500", "text-white"]}]
#       }
#     })
#   end

#   it "correctly resolves" do
#     engine = Attrify::AttributeSet.new
#     expect(engine.execute_and_merge_operations(
#       {accept_button: {variant: {color: :primary}, adjust: {}}, card: {adjust: {class: [{set: ["rounded-xl", "border", "bg-card", "text-card-foreground", "shadow", "w-[350px]"]}], append: ["bg-purple-400"]}}}
#     )).to eq({
#       test: "!"
#     })
#   end

#   it "testsss" do
#     engine = Attrify::AttributeSet.new(base: {
#                                                    accept_button:
#                                                    {
#                                                      variant: {color: :destructive}
#                                                    },
#                                                    card:
#       {
#         class: %w[rounded-xl border bg-card text-card-foreground shadow w-[350px]]
#       }
#                                                  },
#       variants: {
#         style: {
#           one: {
#             accept_button:
#             {
#               variant: {color: :primary}
#             },
#             card: {
#               class: {append: "bg-purple-400"}
#             }
#           },
#           two: {
#             accept_button:
#             {
#               variant: {color: :secondary}
#             },
#             card: {
#               class: {append: "bg-blue-400"}
#             }
#           }
#         }
#       },
#       defaults: {style: :one})
#   end

#   it "works?" do
#     engine = Attrify::AttributeSet.new(
#       base: {
#         class: %w[
#           inline-flex items-center justify-center
#           whitespace-nowrap rounded-md text-sm font-medium
#           transition-colors focus-visible:outline-none focus-visible:ring-1
#           focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50
#           h-9 px-4 py-2
#         ]
#       },
#       variants: {
#         color: {
#           primary: {class: {append: [10, 11, "23"]}},
#           secondary: {class: {append: %w[bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80]}},
#           destructive: {class: {append: %w[bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90]}},
#           outline: {class: {append: %w[border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground]}},
#           ghost: {class: {append: %w[hover:bg-accent hover:text-accent-foreground]}},
#           link: {class: {append: %w[text-primary underline-offset-4 hover:underline]}}
#         },
#         type: {
#           button: {
#             type: "button"
#           },
#           submit: {
#             type: "submit"
#           },
#           reset: {
#             type: "reset"
#           }
#         }
#       },
#       defaults: {color: :primary, type: :button}
#     )

#     expect(engine.render).to eq({
#       adjust: {
#         class: [{set: ["bg-blue-500", "text-white"]}]
#       }
#     })
#   end

#   it "new define" do
#     resolver = Attrify::Resolver.new
#     resolver.define("component") do
#       {
#         base: {
#           class: %w[
#             inline-flex items-center justify-center
#             whitespace-nowrap rounded-md text-sm font-medium
#             transition-colors focus-visible:outline-none focus-visible:ring-1
#             focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50
#             h-9 px-4 py-2
#           ]
#         }
#       }
#     end
#   end

#   it "correctly works with registry" do
#     registry = Attrify::Registry.new
#     registry.register(base: {})
#     expect(registry.register).to eq(true)
#   end

#   # expect(engine.render).to eq({
#   #  class: "inline-flex items-center justify-center bg-blue-500 text-white text-base uppercase color-red"
#   # })
#   # it "accounts for replacing" do
#   #   engine = Attrify::AttributeSet.new(base: {
#   #     id:  10,
#   #     class: %w[ inline-flex items-center justify-center ],
#   #     style: "color: red;",
#   #     data: {
#   #       controller: "stimulus_controller"
#   #     }
#   #   },
#   #   variants: {
#   #     color: {
#   #       primary: {
#   #         class!: %w(bg-blue-500 text-white),
#   #         style: "border-radius:40px"
#   #       },
#   #       secondary: {
#   #         class: %w(bg-purple-500 text-white)
#   #       }
#   #     },
#   #     size: {
#   #       sm: { class!: "text-sm" },
#   #       md: { class: "text-base" },
#   #       lg: { class: "px-4 py-3 text-lg" }
#   #     }
#   #   },
#   #   default:{ color: :primary, size: :sm })

#   #   expect(engine.render).to eq(" id=\"10\" class=\"inline-flex items-center justify-center bg-purple-500 text-white text-sm\" style=\"color: red;\" data-controller=\"stimulus_controller\"")
#   # end
# end
