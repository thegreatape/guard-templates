# Guard::Templates

Guard::Templates is a Guard plugin that pre-compiles or translates your project's JS-language templates into include-ready Javascript files.

## Installation
If using Bundler, just add guard-templates to your Gemfile

```ruby
group :development do
  gem 'guard-templates'
end
```

Alternatively, install it system-wide with 
```bash
gem install guard-templates
```

Guard::Templates uses [ExecJS](https://github.com/sstephenson/execjs) for intermediary-stage compilation. You can install one of several JS engines and JSON libraries that it will use - see the ExecJS documentation for details. Presently, this is only necessary if you want to transform your Jade templates into precompiled functions.

## Usage
Once guard-templates is installed you can add a sample Guardfile with (ZOMG TODO):
```bash
guard init templates
```

## Options

## Dependencies
Guard::Templates uses ExecJS for intermediary-stage compilation. You can install one of several JS engines and JSON libraries that it will use - see the ExecJS documentation for details.
