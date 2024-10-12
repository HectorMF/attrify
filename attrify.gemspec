# frozen_string_literal: true

require_relative "lib/attrify/version"

Gem::Specification.new do |spec|
  spec.name = "attrify"
  spec.version = Attrify::VERSION
  spec.authors = ["Hector Medina Fetterman"]
  spec.email = ["javi@digitalhospital.com"]

  spec.summary = "A powerful and flexible variant API to manage HTML attributes inside your components."
  spec.description = "Whether you're using ViewComponent, Tailwind CSS, or any other framework, Attrify allows you to seamlessly Handle complex UI components with ease."
  spec.homepage = "https://www.github.com/hectormf/attrify"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "> 7.0"
  spec.add_dependency "actionview", "> 7.0"
end
