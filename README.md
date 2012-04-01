# Guard::Templates

Guard::Templates is a [Guard](https://github.com/guard/guard) plugin that pre-compiles or translates your project's JS-language templates into include-ready Javascript files.

## Installation
If using Bundler, just add guard-templates to your Gemfile

```ruby
group :development do
  gem 'guard-templates'
end
```

Alternatively, install it system-wide with 

```
gem install guard-templates
```

Guard::Templates uses [ExecJS](https://github.com/sstephenson/execjs) for intermediary-stage compilation. You can install one of several JS engines and JSON libraries that it will use - see the ExecJS documentation for details. Presently, this is only necessary if you want to transform your Jade templates into precompiled functions.

## Usage
Once guard-templates is installed you can add a sample Guardfile with:

```
guard init templates
```

This will look something like:

```ruby
guard 'templates', :output => 'public/javascript/templates.js', :namespace => 'MyApp' do
  watch(/app\/javascripts\/templates\/(.*)\.jade$/)
end
```

Change the watch and output paths to match your application, and run 

```
guard&
```

## Options

```namespace``` Set to your application's namespace, defaults to 'this'. Use this to keep your templates out of the global scope like a good Javascript citizen. 
```output``` Path relative to Guard where the compiled Javascript files will be output. If this is a filename ending in .js, all of the templates will be attached to a single object, as above.

### Template Languages Without Precompiling Support
Presently, aside from Jade, this means all of them. :-) See adding new languages below if you'd like support precompilation for your favorite Javascript templating language.

With a templates directory that looks like:

```
templates/
├── foo
│   └── bar.handlebars
└── index.handlebars
```

Then ```:output => 'public/javascripts``` will produce a public/javascripts that looks like:

```
public/
└── javascripts
    ├── foo
    │   └── bar.js
    └── index.js
```

Each file contains the stringified template contents of the handlebars file:

```javascript
MyApp['index'] = "<div>{{index}}</div>\n"
```

If output is a path ending in .js, the templates will be compiled to an object in that file. Using the example above with ```:output => 'public/javascripts/templates.js'```, we get a single file result:

```
public/
└── javascripts
    └── templates.js
```

that looks like:

```javascript
MyApp.templates = {
  "index": "<div>{{index}}</div>\n",
  "foo/bar": "<p>{{example}}</p>\n"
}
```

### With Precompiling Jade
Templates with a .jade extension will be precompiled with Jade's compiler and turned into anonymous functions. The only difference between precompiled and unprecompiled templates is the precompiled ones get turned into functions rather than strings in the resulting Javascript.

With this filesystem structure, and a watch pattern like ```watch(/templates\/(.*)\.jade$/)```

```
templates/
├── foo
│   └── other.jade
└── index.jade
```

```:output => 'public/javascripts/templates.js'``` will produce a templates.js that looks like:

```javascript
MyApp.templates = {
  "foo/other": function anonymous(locals, attrs, escape, rethrow) {
    //function contents
  },
  "index": function anonymous(locals, attrs, escape, rethrow) {
    // function contents
  }
}
```

You can then include templates.js in your application and render the templates by calling the functions in question. I.e:

```javascript
MyApp.templates['foo/other']()
```

With ```:output => 'public/javascripts'```, each .jade file will be compiled to an individual .js file, like so:

```
├── public
│   └── javascripts
│       ├── foo
│       │   └── other.js
│       └── index.js
├── templates
│   ├── foo
│   │   └── other.jade
│   └── index.jade
```

With the contents of each compiled js file looking like:

```javascript
MyApp['index'] = function anonymous(locals, attrs, escape, rethrow) {
  //function contents
}
```

## Precompilation 
Currently, only [Jade](https://github.com/visionmedia/jade) is supported. All other template types fall back to being inlined as string literals.

### Adding Precompilation Support For Other Languages
Adding precompilation support for your favorite language is as simple as adding a single class method to Guard::Templates::Compilers. When checking for precompilation support for a particular file extension, guard-templates looks for a class method named ```compile_<extension>`` in that module. It should accept a string (representing the template source) and return a stringified Javascript function. See ```compile_jade``` in Guard::Templates::Compilers for an example.

