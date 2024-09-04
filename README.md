# Attrify

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/attrify`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attrify'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install attrify

## Usage

Configuring Component Attributes
This section details how to configure a component's attributes in your application. The configuration can be performed using two optional keys: variant for applying predefined attribute sets, and adjust for custom attribute adjustments.

Selecting Variants
Variants allow you to apply predefined attribute sets to components, which can modify their appearance or behavior based on a theme or specific configuration. You can specify variants to apply by using the variant key, which is optional.

Example Usage
ruby
Copy code
```ruby
Button.new(attributes: {
  variant: { color: :primary }
})

button.render
Description:

variant: (Optional) A dictionary that specifies the variants to apply to the component. For instance, { color: :link } might apply a specific style defined for link-themed buttons within your application.
Creating Adjustments
Adjustments provide a way to directly modify the component's attributes such as style, class, or other properties. You can make these adjustments using the adjust key, which allows for detailed control over the component's final presentation using operations like set, append, prepend, and remove.

Operations
set: Defines or redefines the value of the attribute, replacing any existing values.
append: Adds a value to the end of the attribute, useful for classes or styles where order matters.
prepend: Adds a value to the beginning of the attribute, which is particularly important for CSS precedence.
remove: Removes a specified value from the attribute, typically used with classes.
Example Usage
ruby
Copy code

```ruby
Button.new({
  adjust: {
    class: { append: "another-class" },
    style: { set: "color: red !important;" }
  }
})
```

button.render
Description:

adjust: (Optional) A dictionary where you can specify direct modifications or adjustments to the component’s attributes. The keys define what attribute you're adjusting, and the value is a dictionary specifying the operation and its target values.
Advantages
Using variant and adjust provides flexibility and precise control over component styling and behavior:

Flexibility: Combines the ease of using predefined configurations with the ability to apply custom modifications.
Clarity and Control: Clearly separates theme-based variations from direct style adjustments, allowing for granular and strategic styling modifications.
Powerful Customization: Supports detailed adjustments that cater to complex design requirements and dynamic UI behaviors.


TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HectorMF/attrify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/HectorMF/attrify/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Attrify project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/HectorMF/attrify/blob/master/CODE_OF_CONDUCT.md).

## Setting base attributes

```ruby
class Button < Component
 attributes(
    base: {
      class: %w[
        inline-flex items-center justify-center
        whitespace-nowrap rounded-md text-sm font-medium
        transition-colors focus-visible:outline-none focus-visible:ring-1 
        focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 
        h-9
      ],
      data:
      {
        controller: "button_controller"
      }
    }, 
    variants: {
      color: {
        primary: { class: %w[bg-primary text-primary-foreground shadow hover:bg-primary/90] },
        secondary: { class: %w[bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80] },
        destructive: { class: %w[bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90] },
        outline: { class: %w[border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground] },
        ghost: { class: %w[hover:bg-accent hover:text-accent-foreground] },
        link: { class: %w[text-primary underline-offset-4 hover:underline] }
      }, 
      type: {
        button: {
          type: "button"
        },
        submit: {
          type: "submit"
        },
        reset: {
          type: "reset"
        }
      },
      size: {
        sm: { class: %w[px-2.5 py-1] },
        md: { class: %w[px-3 py-1.5] },
        lg: { class: %w[px-3.5 py-2] },
        xl: { class: %w[px-4 py-2.5] }
      }
    },
    defaults: { variant: :color, type: :button, size: :sm })
end
```

