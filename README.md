# Attrify

![Gem Version](https://img.shields.io/gem/v/attrify)
![License](https://img.shields.io/github/license/hectormf/attrify)

A powerful and flexible variant API to manage HTML attributes inside your components. 
Whether you're using ViewComponent, Tailwind CSS, or any other framework, **Attrify** allows you to seamlessly Handle complex UI components with ease. 

# Installation

Add this line to your application's gemfile

```ruby
gem "attrify"
```

# Getting Started

Add it to your model
```ruby
class BaseComponent
  include Attrify

  # Optional: pass the args from the initializer directly to the attributes API
  def initialize(**args)
    with_attributes(**args)
  end
end
```

Define attributes for your class:
```ruby
class Button < BaseComponent
  attributes {
    base id: ->{ "button_#{SecureRandom.uuid}}"} 
         class: %w[inline-flex items-center rounded], 
         data: { controller: "button_controller" }
    
    variant(:color) {
      primary   class: { append: %w[bg-blue-500 text-white] }
      secondary class: { append: %w[bg-gray-500 text-white shadow-sm] }
      danger    class: { append: %w[bg-red-500 text-white] }
    }

    variant(:size) {
      xs class: { append: %w[text-xs h-7 px-3 py-1] }
      sm class: { append: %w[text-sm h-8 px-3.5 py-1.5] }
      md class: { append: %w[text-sm h-9 px-4 py-2] }
      lg class: { append: %w[text-base h-10 px-5 py-2.5] }
      xl class: { append: %w[text-lg h-11 px-6 py-3] }
    }

    default color: :primary, size: :md
  }
end
```

Add the attributes to your component's html
```html
  <button <%= attribs() %>> <%= content %> </button> 
```

Try it out!
```ruby
  # Use default attributes
  Button.new() { "Click Me" }

  # Use a predefined color and size 
  Button.new(color: :primary, size: :sm) { "Click Me" }

  # Override the attributes as you like
  Button.new(color: :primary, 
             class: { remove: "border" }, 
             style: "width: 300px;", 
             href: "https://www.google.com") { "Click Me" }
```

## Acknowledgements
Greatly inspired by Tailwind Variants, ViewComponentContrib::StyleVariants, and what GitHub is doing with Primer::Classify.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

