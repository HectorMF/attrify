# Attrify
> [!WARNING]  
> This a pre-release version of the gem. The API may change


:muscle: A powerful variant API for ruby components

- Define component variants directly in your ruby 
- Framework agnostic
- Seamlessly handle complex UI components

[![Build Status](https://github.com/hectormf/attrify/actions/workflows/main.yml/badge.svg)](https://github.com/hectormf/attrify/actions)
[![License: MIT](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1c34_License-MIT-blue.svg)](/LICENSE.txt)

## Installation

Add this line to your application's gemfile

```ruby
gem "attrify"
```

## Getting Started

Add it to your model
```ruby
class BaseComponent
  include Attrify

  # Optional: pass keyword arguments from the initializer directly to the attributes API
  def initialize(**args)
    variant.set(**args)
  end
end
```

Define variants for your class:
```ruby
class Button < BaseComponent
  variants do
    base id: ->{ "button_#{SecureRandom.uuid}}"},
         class: %w[inline-flex items-center rounded], 
         data: { controller: "button_controller" }
    
    variant(:color) do
      primary   class: { append: %w[bg-blue-500 text-white] }
      secondary class: { append: %w[bg-gray-500 text-white shadow-sm] }
      danger    class: { append: %w[bg-red-500 text-white] }
    end

    variant(:size) do
      xs class: { append: %w[text-xs h-7 px-3 py-1] }
      sm class: { append: %w[text-sm h-8 px-3.5 py-1.5] }
      md class: { append: %w[text-sm h-9 px-4 py-2] }
      lg class: { append: %w[text-base h-10 px-5 py-2.5] }
      xl class: { append: %w[text-lg h-11 px-6 py-3] }
    end

    default color: :primary, size: :md
  end
end
```

Add the attributes to your component's html
```erb
  <button <%= attributes %>> <%= content %> </button> 
```

Try it out!
```ruby
  # Use the default variant
  Button.new() { "Click Me" }

  # Use a predefined color and size 
  Button.new(color: :primary, size: :sm) { "Click Me" }

  # Override the attributes as needed
  Button.new(color: :primary, 
             id: "special_button",
             class: { remove: "border" }, 
             style: "width: 300px;", 
             href: "https://www.google.com") { "Click Me" }
```

## Operations

To best leverage the variants API it is important to understand it's workings. 
Under the hood, attributes are parsed into operations. 

List of operations:

```ruby
{ set: value }
{ remove: value }
{ append: value }
{ prepend: value }
```

Let's take a look at some examples
```ruby 
# The default operation is SET so the following buttons are equivelant
Button.new(color: :primary, class: "bg-purple-500")
Button.new(color: :primary, class: { set: "bg-purple-500" })

# We can define multiple operations like this:
Button.new(color: :primary, class: [{ remove: "bg-blue-500" }, 
                                    { prepend: "text-black" }])
```

## Slots
Slots allow you to define different attributes for different parts of a component. 

```ruby
class Card < BaseComponent
  variants do
    base do
      slot :card, id: ->{"card_#{id}"}, class: %w[rounded-md border]
      slot :header, class: %w[bg-gray-100 border-b]
      slot :body, class: %w[]
      slot :footer, class: %w[border-t]
    end

    variant(:color) do
      primary do
        slot :header, class: { append: %w[bg-blue-500] }
        slot :footer, class: { append: %w[bg-blue-500] }
      end
      danger do
        slot :header, class: { append: %w[bg-red-500] }
        slot :footer, class: { append: %w[bg-red-500] }
      end
    end

    default color: :primary
  end
end
```

Use it in your html
```erb
<div <%= attributes(slot: :card) %>>
  <div <%= attributes(slot: :header) %>> Header </div>
  <div <%= attributes(slot: :body) %>> Body </div>
  <div <%= attributes(slot: :footer) %>> Footer </div>
</div>
```

Override attributes like this:
```ruby
Card.new(color: :primary, footer: { id: "footer_id" },
                          card: { class: { append: "border-3" }})
```

## Child components
We can define variants of a child component inside a parent

```ruby
class Alert < BaseComponent
  variants do
    base do
      slot :main, class: %w[rounded-md border]
      slot :button, size: :md 
    end
    variant(:color) do
      primary do
        slot :main, class: { append: %w[bg-blue-100] }
        slot :button, color: :primary
      end
      danger do
        slot :main, class: { append: %w[bg-red-100] }
        slot :button, color: :danger, size: :lg, id: "alert_button_1"
      end
    end
  end
```

```erb
<div <%= attributes(slot: :main) %>>
  Hello World
  <%= render Button.new(**attributes(slot: :button)) %>
</div>
```
**Note:** You can override like this as well
```erb
<div <%= attributes(slot: :main, class: { append: "h-10" }) %>>
  Hello World
  <%= render Button.new(**attributes(slot: :button, size: :xl)) %>
</div>
```


## Acknowledgements
Greatly inspired by Tailwind Variants, ViewComponentContrib::StyleVariants, and what GitHub is doing with Primer::Classify.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

