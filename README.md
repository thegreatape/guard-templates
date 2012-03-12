# Guard::Templates

Guard::Templates is a Guard plugin that pre-compiles or translates your project's JS-language templates into include-ready Javascript files.

## Installation
If using Bundler, just add Guard::Templates to your Gemfile

```ruby
group :development do
  gem 'guard-templates'
end
```

## TODO
Add a sample Guardfile with:
```bash
guard init templates
```
## Usage

## Options

## Dependencies
Guard::Templates uses ExecJS for intermediary-stage compilation. You can install one of several JS engines and JSON libraries that it will use - see the ExecJS documentation for details.
